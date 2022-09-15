use email_newsletter::conf::get_configuration;
use email_newsletter::startup::run;
use env_logger::Env;
use sqlx::PgPool;
use std::net::TcpListener;

#[tokio::main]
async fn main() -> std::io::Result<()> {
    env_logger::Builder::from_env(Env::default().default_filter_or("info")).init();
    let configuration = get_configuration().expect("Failed to read configuration.");
    println!("Conf {:?}", configuration);
    let connection_pool = PgPool::connect(&configuration.database.connection_string())
        .await
        .expect("Failed to connect to Postgres.");
    let address: String = format!("0.0.0.0:{}", configuration.application_port);
    let listener: TcpListener = TcpListener::bind(address)?;
    run(listener, connection_pool)?.await
}
