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

    socket.on(
        "join",
        |socket: SocketRef, Data::<String>(room_id)| async move {
            let socket_cnt = socket.within(room_id.clone()).sockets().len();
            if socket_cnt == 0 {
                tracing::info!("creating room {room_id} and emitting room_created socket event");
                socket.join(room_id.clone());
                socket.emit("room_created", &room_id).unwrap();
            } else if socket_cnt == 1 {
                tracing::info!("joining room {room_id} and emitting room_joined socket event");
                socket.join(room_id.clone());
                socket.emit("room_joined", &room_id).unwrap();
            } else {
                tracing::info!("Can't join room {room_id}, emitting full_room socket event");
                socket.emit("full_room", &room_id).ok();
            }
        },
    );

    socket.on(
        "start_call",
        |socket: SocketRef, Data::<String>(room_id)| async move {
            tracing::info!("broadcasting start_call event to peers in room {room_id}");
            socket.to(room_id.clone())
                .emit("start_call", &room_id)
                .await
                .ok();
        },
    );
    socket.on(
        "webrtc_offer",
        |socket: SocketRef, Data(event): Data<Event>| async move {
            tracing::info!(
                "broadcasting webrtc_offer event to peers in room {}",
                event.room_id
            );
            socket.to(event.room_id)
                .emit("webrtc_offer", &event.sdp)
                .await
                .ok();
        },
    );
    socket.on(
        "webrtc_answer",
        |socket: SocketRef, Data(event): Data<Event>| async move {
            tracing::info!(
                "broadcasting webrtc_answer event to peers in room {}",
                event.room_id
            );
            socket.to(event.room_id)
                .emit("webrtc_answer", &event.sdp)
                .await
                .ok();
        },
    );
    socket.on(
        "webrtc_ice_candidate",
        |socket: SocketRef,Data(event): Data<IceCandidate>| async move {
            tracing::info!(
                "broadcasting ice_candidate event to peers in room {}",
                event.room_id
            );
            socket.to(event.room_id.clone())
                .emit("webrtc_ice_candidate", &event)
                .await
                .ok();
        },
    );
}
