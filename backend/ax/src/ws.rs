use axum::{
    extract::{
        ws::{Message, WebSocket, WebSocketUpgrade},
        State,
    },
    response::IntoResponse,
};
use futures::{sink::SinkExt, stream::StreamExt};
use std::sync::Arc;

use crate::AppState;

#[derive(Debug, serde::Deserialize, serde::Serialize, PartialEq)]
enum MessageType {
    Init,
    Message,
}

#[derive(Debug, serde::Deserialize, serde::Serialize)]
struct ChatResponse {
    typed: MessageType,
    username: Option<String>,
    thread: Option<String>,
    message: Option<String>,
}

pub async fn ws_handler(
    ws: WebSocketUpgrade,
    State(state): State<Arc<AppState>>,
) -> impl IntoResponse {
    ws.on_upgrade(|socket| handle_socket(socket, state))
}

pub async fn handle_socket(ws: WebSocket, state: Arc<AppState>) {
    // Create the user
    //let uid = uuid::Uuid::new_v4().to_string();
    let (mut sender, mut receiver) = ws.split();

    let mut username = String::new();
    while let Some(Ok(message)) = receiver.next().await {
        if let Message::Text(msg) = message {
            let chat = serde_json::from_str::<ChatResponse>(&msg);
            tracing::info!("{:?}", chat);
            if let Ok(m) = chat {
                if m.typed == MessageType::Init && m.username.is_some() {
                    let username_str = m.username.as_deref().unwrap_or("No username");
                    tracing::info!("{} :: joined", username_str);
                    let req = format!("Welcome 🟫 {}", username_str);
                    if let Some(username_val) = &m.username {
                        let mut user_set = state.user_set.lock().unwrap();
                        user_set.insert(username_val.to_owned());
                        username.push_str(username_val);
                    }

                    let _ = sender.send(Message::Text(req.into())).await;

                    break;
                }
            }
        }
    }

    let mut rx = state.tx.subscribe();

    let msg = format!("{} joined.", username);
    tracing::debug!("{msg}");
    let _ = state.tx.send(msg);

    let mut send_task = tokio::spawn(async move {
        while let Ok(msg) = rx.recv().await {
            // In any websocket error, break loop.
            if sender.send(Message::text(msg)).await.is_err() {
                break;
            }
        }
    });

    let tx = state.tx.clone();
    let name = username.clone();

    let mut recv_task = tokio::spawn(async move {
        while let Some(Ok(text)) = receiver.next().await {
            if let Message::Text(msg) = text {
                let chat = serde_json::from_str::<ChatResponse>(&msg);
                if let Ok(m) = chat {
                    if m.typed == MessageType::Message && m.message.is_some() {
                        let message_str = m.message.as_deref().unwrap_or("No message");
                        let _ = tx.send(format!("{name}: {message_str}"));
                    }
                }
            }
        }
    });

    tokio::select! {
        _ = &mut send_task => recv_task.abort(),
        _ = &mut recv_task => send_task.abort(),
    };

    let msg = format!("{} left.", username.clone());
    tracing::debug!("{msg}");
    let _ = state.tx.send(msg);

    state.user_set.lock().unwrap().remove(&username);
}

// let mut username = String::new();
// while let Some(Ok(message)) = receiver.next().await {
//     if let Message::Text(name) = message {
//         // If username that is sent by client is not taken, fill username string.
//         check_username(&state, &mut username, name.as_str());
//         if !username.is_empty() {
//             break;
//         } else {
//             // Only send our client that username is taken.
//             let _ = sender
//                 .send(Message::Text(Utf8Bytes::from_static(
//                     "Username already taken.",
//                 )))
//                 .await;

//             return;
//         }
//     }
// }

// fn check_username(state: &AppState, string: &mut String, name: &str) {
//     let mut user_set = state.user_set.lock().unwrap();

//     if !user_set.contains(name) {
//         user_set.insert(name.to_owned());
//         string.push_str(name);
//     }
// }
