use axum::{
    extract::Json,
    response::{Html, IntoResponse},
    routing::{get, post},
    Router,
};
use serde::{Deserialize, Serialize};
use std::net::SocketAddr;

#[derive(Serialize)]
struct StatusResponse {
    status: &'static str,
    message: &'static str,
}

#[derive(Deserialize, Serialize)]
struct EchoRequest {
    content: String,
}

#[derive(Serialize)]
struct EchoResponse {
    echo: String,
    length: usize,
}

async fn root() -> Html<&'static str> {
    Html("<h1>Size-Optimized Axum Server</h1><p>Routes: GET /, GET /status, POST /echo</p>")
}

async fn status() -> impl IntoResponse {
    Json(StatusResponse {
        status: "ok",
        message: "Server is running",
    })
}

async fn echo(Json(payload): Json<EchoRequest>) -> impl IntoResponse {
    let length = payload.content.len();
    Json(EchoResponse {
        echo: payload.content,
        length,
    })
}

fn build_router() -> Router {
    Router::new()
        .route("/", get(root))
        .route("/status", get(status))
        .route("/echo", post(echo))
}

#[tokio::main]
async fn main() {
    let app = build_router();
    let addr = SocketAddr::from(([127, 0, 0, 1], 3000));
    let listener = tokio::net::TcpListener::bind(addr).await.unwrap();
    axum::serve(listener, app).await.unwrap();
}
