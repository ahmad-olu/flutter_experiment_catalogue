use serde_json::Value;
use socketioxide::{
    extract::{Data, SocketRef},
    ParserConfig, SocketIo,
};

use tracing::info;
use tracing_subscriber::FmtSubscriber;

//https://github.com/Totodore/socketioxide/blob/main/examples/webrtc-node-app/public/client.js

#[derive(serde::Deserialize, serde::Serialize)]
#[serde(rename_all = "camelCase")]
struct Event {
    room_id: String,
    sdp: Value,
}

#[derive(serde::Deserialize, serde::Serialize)]
#[serde(rename_all = "camelCase")]
struct IceCandidate {
    room_id: String,
    #[serde(flatten)]
    data: Value,
}

pub fn on_rtc_socket_connect(socket: SocketRef, Data(data): Data<Value>) {
    info!("Socket.IO connected: {:?} {:?}", socket.ns(), socket.id);
    socket.emit("msg", &data).ok();

    // Join a room
    socket.on(
        "join",
        |socket: SocketRef, Data::<String>(room_id)| async move {
            println!("User joined room: {}", room_id);
            socket.join(room_id.clone());
        },
    );

    // Handle SDP exchange
    socket.on(
        "offer",
        |socket: SocketRef, Data::<Event>(event)| async move {
            println!("Received offer for room: {}", event.room_id);
            socket
                .to(event.room_id.clone())
                .emit("offer", &event)
                .await
                .ok();
        },
    );

    socket.on(
        "answer",
        |socket: SocketRef, Data::<Event>(event)| async move {
            println!("Received answer for room: {}", event.room_id);
            socket
                .to(event.room_id.clone())
                .emit("answer", &event)
                .await
                .ok();
        },
    );
    // Handle ICE Candidates
    socket.on(
        "ice-candidate",
        |socket: SocketRef, Data::<IceCandidate>(event)| async move {
            println!("Received ICE Candidate for room: {}", event.room_id);
            socket
                .to(event.room_id.clone())
                .emit("ice-candidate", &event)
                .await
                .ok();
        },
    );
}
