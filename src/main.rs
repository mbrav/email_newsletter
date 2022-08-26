use email_newsletter::conf::get_configuration;
use email_newsletter::run;
use std::net::TcpListener;

#[tokio::main]
async fn main() -> std::io::Result<()> {
    let configuration = get_configuration().expect("Failed to read configuration.");
    println!("Conf {:?}", configuration);
    let address: String = format!("127.0.0.1:{}", configuration.application_port);
    let listener: TcpListener = TcpListener::bind(address)?;
    run(listener)?.await
}
