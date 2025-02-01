use rustler::NifResult;

mod config;

#[rustler::nif]
fn read_rpc_client() -> NifResult<String> {
    let settings =
        config::get_configurations().map_err(|e| rustler::Error::Term(Box::new(e.to_string())))?;

    Ok(settings.get_rpc_client())
}

rustler::init!("Elixir.Transaction");
