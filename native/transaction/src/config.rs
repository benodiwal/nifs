use config::{File, FileFormat};
use serde::Deserialize;

#[derive(Deserialize, Debug)]
pub struct Settings {
    rpc_client_url: String,
}

pub fn get_configurations() -> Result<Settings, config::ConfigError> {
    let builder = config::Config::builder().add_source(File::new("configs", FileFormat::Yaml));

    let config = builder.build()?;
    config.try_deserialize::<Settings>()
}

impl Settings {
    pub fn get_rpc_client(&self) -> String {
        self.rpc_client_url.clone()
    }
}
