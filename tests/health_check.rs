use email_newsletter;
use reqwest::{Client, Response};
use std::net::TcpListener;

// You can inspect what code gets generated using
// `cargo expand --test health_check` (<- name of the test file)
fn spawn_app() -> String {
    let listener: TcpListener =
        TcpListener::bind("127.0.0.1:0").expect("Failed to bind random port");
    //  trying to bind port 0 will trigger an OS scan for an available port which will then be bound to the application.
    let port: u16 = listener.local_addr().unwrap().port();
    let server = email_newsletter::run(listener).expect("Failed to bind address");
    let _ = tokio::spawn(server);
    // We return the application address to the caller!
    format!("http://127.0.0.1:{}", port)
}

// `tokio::test` is the testing equivalent of `tokio::main`.
// It also spares you from having to specify the `#[test]` attribute.
#[tokio::test]
async fn health_check_works() {
    let address: String = spawn_app();
    let client: Client = Client::new();

    let response: Response = client
        .get(&format!("{}/health_check", &address))
        .send()
        .await
        .expect("Failed to execute request.");

    assert!(response.status().is_success());
    assert_eq!(Some(0), response.content_length());
}
