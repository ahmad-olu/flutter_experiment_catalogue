use axum::{routing::get, Router};
use socket::on_socket_connect;
use socketioxide::SocketIo;
use std::{
    collections::HashSet,
    sync::{Arc, Mutex},
};
use tokio::sync::broadcast;
use tracing_subscriber::{layer::SubscriberExt, util::SubscriberInitExt};
use ws::ws_handler as ws;

pub struct AppState {
    user_set: Mutex<HashSet<String>>,
    tx: broadcast::Sender<String>,
}

pub mod socket;
pub mod ws;

//bacon run -- -q
//https://www.shuttle.dev/launchpad/issues/2023-12-09-issue-08-websockets-chat
// ws://0.0.0.0:3000/ws
#[tokio::main]
async fn main() {
    tracing_subscriber::registry()
        .with(
            tracing_subscriber::EnvFilter::try_from_default_env()
                .unwrap_or_else(|_| format!("{}=trace", env!("CARGO_CRATE_NAME")).into()),
        )
        .with(tracing_subscriber::fmt::layer())
        .init();

    let (layer, io) = SocketIo::new_layer();
    io.ns("/", on_socket_connect);
    io.ns("/custom", on_socket_connect);

    let user_set = Mutex::new(HashSet::new());
    let (tx, _rx) = broadcast::channel(100);
    let app_state = Arc::new(AppState { user_set, tx });

    let app = Router::new()
        .route("/ws", get(ws))
        .with_state(app_state)
        .layer(layer);

    let listener = tokio::net::TcpListener::bind("0.0.0.0:3000").await.unwrap();
    tracing::debug!("listening on {}", listener.local_addr().unwrap());
    axum::serve(listener, app).await.unwrap();
}
