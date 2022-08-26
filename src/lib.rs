use actix_web::dev::Server;
use actix_web::{web, App, HttpRequest, HttpResponse, HttpServer, Responder};
use serde;
use std::net::TcpListener;

#[derive(serde::Deserialize)]
struct FormData {
    email: String,
    name: String,
}

async fn health_check() -> HttpResponse {
    HttpResponse::Ok().finish()
}

async fn greet(req: HttpRequest) -> impl Responder {
    let name: &str = req.match_info().get("name").unwrap_or("World");
    format!("Hello {}!", &name)
}

async fn subscribe(_form: web::Form<FormData>) -> HttpResponse {
    HttpResponse::Ok().finish()
}

// We need to mark `run` as public.
// It is no longer a binary entrypoint, therefore we can mark it as async
// without having to use any proc-macro incantation.
// #[tokio::main]
pub fn run(listener: TcpListener) -> Result<Server, std::io::Error> {
    let server = HttpServer::new(|| {
        App::new()
            .route("/health_check", web::get().to(health_check))
            .route("/", web::get().to(greet))
            .route("/subscriptions", web::post().to(subscribe))
            .route("/{name}", web::get().to(greet))
    })
    .listen(listener)?
    .run();

    Ok(server)
}
