use serde_json::Value;
use socketioxide::extract::{AckSender, Data, SocketRef};
use tracing::{error, info};

pub fn on_socket_connect(socket: SocketRef, Data(data): Data<Value>) {
    info!("Socket.IO connected: {:?} {:?}", socket.ns(), socket.id);
    // socket.emit("auth", &data).ok();
    socket.emit("msg", &data).ok();

    socket.on("message", |socket: SocketRef, Data::<Value>(data)| {
        info!("Received event: {:?} ", data);
        socket.emit("message-back", &data).ok();
    });

    socket.on("msg", |socket: SocketRef, Data::<Value>(data)| {
        info!("Received event: {:?} ", data);
        socket.emit("message-back", &data).ok();
    });

    //--chat start

    socket.on("join-room", |socket: SocketRef, Data::<Value>(room_name)|{
        info!("socket {:?} joining room {:?}", socket.id, room_name);
        socket.join(room_name.as_str().map(|e|e.to_owned()).unwrap());
    });

    socket.on("chat", |socket: SocketRef, Data::<Value>(data)| async move{
        info!("Received event: {:?} ", data);
        //socket.emit("message-back", &data).ok();
        socket.broadcast().emit("message-back", &data).await.ok();
        if let Err(e) = socket.to(["Room1"]).emit("message-back", &data).await{
            error!("Failed to send to {:?}",e);
        };
        info!("${:?}", socket.rooms())
    });

    //--chat-end

    socket.on("message-with-ack", |Data::<Value>(data), ack: AckSender| {
        info!("Received event: {:?}", data);
        ack.send(&data).ok();
    });
}
