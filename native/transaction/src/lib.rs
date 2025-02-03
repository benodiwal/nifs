use rustler::NifResult;
use tracing::{debug, error, info, instrument};
mod config;
mod core;

use core::Core;

#[rustler::nif]
#[instrument]
fn read_rpc_client() -> NifResult<String> {
    debug!("Reading RPC client configuration");
    let settings = match config::get_configurations() {
        Ok(s) => {
            debug!("Configuration loaded successfully");
            s
        }
        Err(e) => {
            error!("Failed to load configuration: {}", e);
            return Err(rustler::Error::Term(Box::new(e.to_string())));
        }
    };

    let rpc_client = settings.get_rpc_client();
    info!("RPC client URL retrieved: {}", rpc_client);
    Ok(rpc_client)
}

#[rustler::nif]
#[instrument(skip(private_key_hex))]
fn make_transaction(
    sender: String,
    recipient: String,
    amount: u64,
    private_key_hex: String,
) -> NifResult<String> {
    info!("Starting transaction process");
    debug!(
        "Transaction parameters: sender={}, recipient={}, amount={}",
        sender, recipient, amount
    );

    let settings = match config::get_configurations() {
        Ok(s) => {
            debug!("Configuration loaded successfully");
            s
        }
        Err(e) => {
            error!("Failed to load configuration: {}", e);
            return Err(rustler::Error::Term(Box::new(e.to_string())));
        }
    };

    let core = Core::new(settings.get_rpc_client());

    // Create transaction
    let transaction_hex = match core.create_transaction(sender, recipient, amount) {
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
    match core.send_transaction(signed_transaction_hex) {
        Ok(signature) => {
            info!(
                "Transaction completed successfully with signature: {}",
                signature
            );
            Ok(signature)
        }
        Err(e) => {
            error!("Failed to send transaction: {:?}", e);
            Err(e)
        }
    }
}

rustler::init!("Elixir.Transaction");
