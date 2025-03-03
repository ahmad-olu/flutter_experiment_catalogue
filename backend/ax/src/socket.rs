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

    socket.on(
        "join-room",
        |socket: SocketRef, Data::<String>(room_name)| {
            info!("socket {:?} joining room {:?}", socket.id, room_name);
            socket.leave_all();
            socket.join(room_name.clone());
        },
    );

    socket.on(
        "chat",
        |socket: SocketRef, Data::<String>(data)| async move {
            info!("Received Message: {:?} ", data);
            // Debug: Log rooms
            let rooms = socket.rooms();
            info!("Socket is in rooms: {:?}", rooms);
            //socket.emit("message-back", &data).ok();


            // ! to broadcast everyone (except user who sent) not withstanding the group
            socket.broadcast().emit("return-message", &format!("{}:{}", "Broad:2",&data)).await.ok();
            // ! to send to only user who sent the message
            socket.emit("message-back", &data).ok();
            

            // ! to method (everyone except the user who sent the message)
            // ! note: room can be "Room1" or ["Room1",...]
            // if let Err(e) = socket.to("Room1").emit("return-message", &data).await {
            //     error!("Failed to emit message: {:?}", e);
            // }

            // ! within method (everyone including the user who sent the message)
            //if let Err(e) = socket.within("Room1").emit("return-message", &format!("{}:{}", socket.id,&data)).await {
            //    error!("Failed to emit message: {:?}", e);
            //} 
            //  info!("${:?}", socket.rooms())
        },
    );

    //--chat-end

    socket.on("message-with-ack", |Data::<Value>(data), ack: AckSender| {
        info!("Received event: {:?}", data);
        ack.send(&data).ok();
    });
}
