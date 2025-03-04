use std::{fs, process::Command, sync::Arc};

use axum::{
    extract::{Multipart, Path, State},
    http::StatusCode,
    response::{IntoResponse, Redirect, Response},
    routing::{get, post},
    Json, Router,
};
use serde::{Deserialize, Serialize};
use tower_http::services::ServeDir;
use uuid::Uuid;

#[derive(Debug, Clone)]
struct AppState {
    video_dir: String,
}

pub fn video_stream_router() -> Router {
    let state = Arc::new(AppState {
        video_dir: "videos".to_string(),
    });
    Router::new()
        .route("/upload", post(upload_video))
        .route("/convert/{video_id}", post(convert_video))
        .route("/stream/{video_id}", get(stream_video))
        .nest_service("/videos", ServeDir::new("./videos"))
        .with_state(state)
}

#[derive(Serialize, Deserialize)]
struct UploadResponse {
    video_id: String,
    message: String,
}

async fn upload_video(
    State(state): State<Arc<AppState>>,
    mut multipart: Multipart,
) -> impl IntoResponse {
    if let Some(field) = multipart.next_field().await.unwrap() {
        let file_name = field.file_name().unwrap_or("video.mp4").to_string();
        let video_id = Uuid::new_v4().to_string();
        let save_path = format!("{}/{}.mp4", state.video_dir, video_id);

        let data = field.bytes().await.unwrap();
        fs::write(&save_path, data).unwrap();

        Json(UploadResponse {
            video_id,
            message: format!("Uploaded as {}", file_name),
        })
        .into_response()
    } else {
        (StatusCode::BAD_REQUEST, "No file uploaded").into_response()
    }
}

async fn convert_video(
    State(state): State<Arc<AppState>>,
    Path(video_id): Path<String>,
) -> Response {
    let input_path = format!("{}/{}.mp4", state.video_dir, video_id);
    let output_dir = format!("{}/{}", state.video_dir, video_id);
    fs::create_dir_all(&output_dir).unwrap();

    let output_path = format!("{}/index.m3u8", output_dir);

    let ffmpeg_cmd = format!(
        "ffmpeg -i {} -preset veryfast -g 48 -sc_threshold 0 \
        -map 0:v:0 -b:v:0 800k -c:v:0 libx264 -filter:v:0 scale=-2:360 \
        -map 0:v:0 -b:v:1 1200k -c:v:1 libx264 -filter:v:1 scale=-2:720 \
        -map 0:v:0 -b:v:2 2500k -c:v:2 libx264 -filter:v:2 scale=-2:1080 \
        -map 0:a:0 -b:a:0 128k -c:a:0 aac \
        -f hls -hls_time 10 -hls_playlist_type vod \
        -hls_segment_filename {}/segment_%03d.ts {}",
        input_path, output_dir, output_path
    );

    let status = Command::new("sh")
        .arg("-c")
        .arg(&ffmpeg_cmd)
        .status()
        .expect("Failed to execute FFmpeg");

    if status.success() {
        Json(format!("Video converted: {}/index.m3u8", video_id)).into_response()
    } else {
        (
            StatusCode::INTERNAL_SERVER_ERROR,
            "FFmpeg conversion failed",
        )
            .into_response()
    }
}

async fn stream_video(
    State(state): State<Arc<AppState>>,
    Path(video_id): Path<String>,
) -> impl IntoResponse {
    let hls_path = format!("{}/{}/index.m3u8", state.video_dir, video_id);
    if fs::metadata(&hls_path).is_ok() {
        Redirect::temporary(&format!("/video/videos/{}/index.m3u8", video_id)).into_response()
    } else {
        (StatusCode::NOT_FOUND, "Video not found").into_response()
    }
}
