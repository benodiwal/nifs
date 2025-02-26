use rustler::{Env, NifResult, Term};
use tracing::{debug, error, info, instrument};
mod core;
mod subscriber;

use core::Core;

fn load(_env: Env, _term: Term) -> bool {
    subscriber::init();
    true
}

#[rustler::nif]
#[instrument(skip(private_key_hex))]
fn make_transaction(
    sender: String,
    recipient: String,
    amount: u64,
    private_key_hex: String,
    recent_blockhash: String,
) -> NifResult<String> {
    info!("Starting transaction process");
    debug!(
        "Transaction parameters: sender={}, recipient={}, amount={}",
        sender, recipient, amount
    );

    let core = Core::new();

    // Create transaction
    let transaction_hex = match core.create_transaction(sender, recipient, amount, recent_blockhash)
    {
        Ok(tx) => {
            debug!("Transaction created successfully");
            tx
        }
        Err(e) => {
            error!("Failed to create transaction: {:?}", e);
            return Err(e);
        }
    };

    // Sign transaction
    let signed_transaction_hex = match core.sign_transaction(transaction_hex, private_key_hex) {
        Ok(tx) => {
            debug!("Transaction signed successfully");
            tx
        }
        Err(e) => {
            error!("Failed to sign transaction: {:?}", e);
            return Err(e);
        }
    };

    // Send transaction
    // match core.send_transaction(signed_transaction_hex) {
    //     Ok(signature) => {
    //         info!(
    //             "Transaction completed successfully with signature: {}",
    //             signature
    //         );
    //         Ok(signature)
    //     }
    //     Err(e) => {
    //         error!("Failed to send transaction: {:?}", e);
    //         Err(e)
    //     }
    // }

    Ok(signed_transaction_hex)
}

#[rustler::nif]
#[instrument(skip(creator_key))]
fn create_mint_nft_transaction(
    creator_key: String,
    name: String,
    symbol: String,
    uri: String,
    recent_blockhash: String,
    mint_rent: u64,
) -> NifResult<String> {
    info!("Starting NFT minting process");
    debug!(
        "NFT parameters: name={}, symbol={}, uri={}",
        name, symbol, uri
    );

    let core = Core::new();

    match core.create_mint_nft_transaction(
        creator_key,
        name,
        symbol,
        uri,
        recent_blockhash,
        mint_rent,
    ) {
        Ok(signature) => {
            info!("NFT minted successfully with signature: {}", signature);
            Ok(signature)
        }
        Err(e) => {
            error!("Failed to mint NFT: {:?}", e);
            Err(e)
        }
    }
}

rustler::init!("Elixir.Transaction", load = load);
