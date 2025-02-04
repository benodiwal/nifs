pub fn init() {
    tracing_subscriber::fmt()
        .with_env_filter(tracing_subscriber::EnvFilter::from_default_env())
        .with_timer(tracing_subscriber::fmt::time::ChronoLocal::rfc_3339())
        .with_line_number(true)
        .json()
        .with_current_span(false)
        .flatten_event(true)
        .init();
}
