use mpl_token_metadata::{instructions::CreateMetadataAccountV3, types::DataV2};
use rustler::Error;
use solana_client::rpc_client::RpcClient;
use solana_sdk::{
    message::Message, program_pack::Pack, pubkey::Pubkey, signature::Keypair, signer::Signer,
    system_instruction, system_program, sysvar, transaction::Transaction,
};
use spl_token::{instruction as token_instruction, state::Mint};
use tracing::{debug, error, info};

pub struct Core {
    pub rpc_client_url: String,
}

impl Core {
    pub fn new(rpc_client_url: String) -> Self {
        info!("Initializing Core with RPC URL: {}", rpc_client_url);
        Core { rpc_client_url }
    }

    pub fn create_transaction(
        &self,
        sender: String,
        recipient: String,
        amount: u64,
    ) -> Result<String, Error> {
        debug!("Creating new transaction");

        let rpc_client = RpcClient::new(self.rpc_client_url.clone());

        let recent_blockhash = match rpc_client.get_latest_blockhash() {
            Ok(blockhash) => {
                debug!("Got recent blockhash");
                blockhash
            }
            Err(e) => {
                error!("Failed to get recent blockhash: {}", e);
                return Err(Error::Term(Box::new("Failed to get recent blockhash")));
            }
        };

        let sender_pubkey = match Pubkey::try_from(sender.as_str()) {
            Ok(pubkey) => {
                debug!("Sender public key parsed successfully");
                pubkey
            }
            Err(e) => {
                error!("Failed to parse sender address: {}", e);
                return Err(Error::Term(Box::new("Invalid sender address")));
            }
        };

        let recipient_pubkey = match Pubkey::try_from(recipient.as_str()) {
            Ok(pubkey) => {
                debug!("Recipient public key parsed successfully");
                pubkey
            }
            Err(e) => {
                error!("Failed to parse recipient address: {}", e);
                return Err(Error::Term(Box::new("Invalid recipient address")));
            }
        };

        let instruction = system_instruction::transfer(&sender_pubkey, &recipient_pubkey, amount);
        debug!("Transfer instruction created");

        let message =
            Message::new_with_blockhash(&[instruction], Some(&sender_pubkey), &recent_blockhash);
        let transaction = Transaction::new_unsigned(message);

        match bincode::serialize(&transaction) {
            Ok(bytes) => {
                let hex = bytes.iter().map(|b| format!("{:02x}", b)).collect();
                info!("Transaction created successfully");
                Ok(hex)
            }
            Err(e) => {
                error!("Failed to serialize transaction: {}", e);
                Err(Error::Term(Box::new("Failed to serialize transaction")))
            }
        }
    }

    pub fn sign_transaction(
        &self,
        transaction_hex: String,
        private_key: String,
    ) -> Result<String, Error> {
        debug!("Starting transaction signing process");

        let transaction_bytes = self.hex_to_bytes(&transaction_hex, "transaction")?;
        debug!("Transaction hex decoded successfully");

        let mut transaction: Transaction = match bincode::deserialize(&transaction_bytes) {
            Ok(tx) => {
                debug!("Transaction deserialized successfully");
                tx
            }
            Err(e) => {
                error!("Failed to deserialize transaction: {}", e);
                return Err(Error::Term(Box::new("Failed to deserialize transaction")));
            }
        };

        let keypair = Keypair::from_base58_string(&private_key);

        transaction.sign(&[&keypair], transaction.message.recent_blockhash);
        debug!("Transaction signed successfully");

        match bincode::serialize(&transaction) {
            Ok(bytes) => {
                let hex = bytes.iter().map(|b| format!("{:02x}", b)).collect();
                info!("Transaction signed and serialized successfully");
                Ok(hex)
            }
            Err(e) => {
                error!("Failed to serialize signed transaction: {}", e);
                Err(Error::Term(Box::new(
                    "Failed to serialize signed transaction",
                )))
            }
        }
    }

    pub fn send_transaction(&self, signed_transaction_hex: String) -> Result<String, Error> {
        debug!("Initializing RPC client with URL: {}", self.rpc_client_url);
        let rpc_client = RpcClient::new(self.rpc_client_url.clone());

        let transaction_bytes = self.hex_to_bytes(&signed_transaction_hex, "signed transaction")?;

        let transaction: Transaction = match bincode::deserialize(&transaction_bytes) {
            Ok(tx) => {
                debug!("Signed transaction deserialized successfully");
                tx
            }
            Err(e) => {
                error!("Failed to deserialize signed transaction: {}", e);
                return Err(Error::Term(Box::new("Failed to deserialize transaction")));
            }
        };

        match rpc_client.send_transaction(&transaction) {
            Ok(signature) => {
                info!(
                    "Transaction sent successfully with signature: {}",
                    signature
                );
                Ok(signature.to_string())
            }
            Err(e) => {
                error!("Failed to send transaction: {}", e);
                Err(Error::Term(Box::new("Failed to send transaction")))
            }
        }
    }

    fn hex_to_bytes(&self, hex_str: &str, context: &str) -> Result<Vec<u8>, Error> {
        let bytes = hex_str
            .as_bytes()
            .chunks(2)
            .map(|chunk| {
                u8::from_str_radix(std::str::from_utf8(chunk).unwrap(), 16).map_err(|e| {
                    error!("Invalid hex string for {}: {}", context, e);
                    Error::Term(Box::new(format!("Invalid {} hex", context)))
                })
            })
            .collect::<Result<Vec<u8>, Error>>()?;

        debug!("Hex string converted to bytes successfully");
        Ok(bytes)
    }

    pub fn mint_nft(
        &self,
        creator_key: String,
        name: String,
        symbol: String,
        uri: String,
    ) -> Result<String, Error> {
        debug!("Starting NFT minting process");

        let rpc_client = RpcClient::new(self.rpc_client_url.clone());
        let creator = Keypair::from_base58_string(&creator_key);
        let mint = Keypair::new();
        let mint_pubkey = mint.pubkey();

        let seeds = &[
            b"metadata",
            mpl_token_metadata::ID.as_ref(),
            mint_pubkey.as_ref(),
        ];
        let (metadata_account, _) = Pubkey::find_program_address(seeds, &mpl_token_metadata::ID);

        let recent_blockhash = match rpc_client.get_latest_blockhash() {
            Ok(blockhash) => {
                debug!("Got recent blockhash");
                blockhash
            }
            Err(e) => {
                error!("Failed to get recent blockhash: {}", e);
                return Err(Error::Term(Box::new("Failed to get recent blockhash")));
            }
        };

        let mint_rent =
            match rpc_client.get_minimum_balance_for_rent_exemption(spl_token::state::Mint::LEN) {
                Ok(rent) => {
                    debug!("Got mint rent");
                    rent
                }
                Err(e) => {
                    error!("Failed to get mint rent: {}", e);
                    return Err(Error::Term(Box::new("Failed to get mint rent")));
                }
            };

        let create_mint_ix = system_instruction::create_account(
            &creator.pubkey(),
            &mint.pubkey(),
            mint_rent,
            Mint::LEN as u64,
            &spl_token::id(),
        );

        let init_mint_ix = match token_instruction::initialize_mint(
            &spl_token::id(),
            &mint.pubkey(),
            &creator.pubkey(),
            None,
            0,
        ) {
            Ok(ix) => {
                debug!("Initialized mint");
                ix
            }
            Err(e) => {
                error!("Failed to initialize mint: {}", e);
                return Err(Error::Term(Box::new("Failed to initialize mint")));
            }
        };

        let metadata_ix = CreateMetadataAccountV3 {
            metadata: metadata_account,
            mint: mint.pubkey(),
            mint_authority: creator.pubkey(),
            payer: creator.pubkey(),
            update_authority: (creator.pubkey(), true),
            system_program: system_program::id(),
            rent: Some(sysvar::rent::id()),
        };
        let metadata_ix_instruction = metadata_ix.instruction(
            mpl_token_metadata::instructions::CreateMetadataAccountV3InstructionArgs {
                data: DataV2 {
                    name,
                    symbol,
                    uri,
                    seller_fee_basis_points: 0,
                    creators: None,
                    collection: None,
                    uses: None,
                },
                is_mutable: true,
                collection_details: None,
            },
        );

        let transaction = Transaction::new_signed_with_payer(
            &[create_mint_ix, init_mint_ix, metadata_ix_instruction],
            Some(&creator.pubkey()),
            &[&creator, &mint],
            recent_blockhash,
        );

        let signature = match rpc_client.send_and_confirm_transaction(&transaction) {
            Ok(signature) => {
                info!("NFT minted successfully with signature: {}", signature);
                signature
            }
            Err(e) => {
                error!("Failed to mint NFT: {}", e);
                return Err(Error::Term(Box::new("Failed to mint NFT")));
            }
        };

        Ok(signature.to_string())
    }
}
