Directory Structure:

└── ./
    ├── crates
    │   ├── client
    │   │   └── src
    │   │       ├── client.rs
    │   │       ├── consts.rs
    │   │       ├── consumers.rs
    │   │       ├── manager.rs
    │   │       └── message.rs
    │   ├── data
    │   │   └── src
    │   │       ├── compression.rs
    │   │       ├── data.rs
    │   │       ├── merge.rs
    │   │       └── transformer.rs
    │   ├── saver
    │   │   └── src
    │   │       └── main.rs
    │   ├── simulator
    │   │   └── src
    │   │       ├── main.rs
    │   │       └── server.rs
    │   └── timescale
    │       └── src
    │           ├── app_timing.rs
    │           ├── lib.rs
    │           └── timing.rs
    └── services
        ├── analytics
        │   └── src
        │       ├── server
        │       │   ├── gap.rs
        │       │   ├── health.rs
        │       │   └── laptime.rs
        │       └── main.rs
        ├── api
        │   └── src
        │       ├── endpoints
        │       │   ├── health.rs
        │       │   └── schedule.rs
        │       └── main.rs
        ├── importer
        │   └── src
        │       ├── main.rs
        │       ├── models.rs
        │       └── parsers.rs
        └── live
            └── src
                ├── server
                │   ├── drivers.rs
                │   ├── health.rs
                │   └── live.rs
                ├── compression.rs
                └── main.rs



---
File: /crates/client/src/client.rs
---

use std::time::Duration;
use std::{env, error::Error};

use axum::http::HeaderValue;

use futures::SinkExt;
use reqwest::{header, Url};
use serde_json::Value;

use tokio::time::timeout;
use tokio_stream::{Stream, StreamExt};
use tokio_tungstenite::tungstenite::client::IntoClientRequest;
use tokio_tungstenite::{tungstenite::http::Request, MaybeTlsStream, WebSocketStream};
use tracing::{debug, info, trace};

pub use tokio_tungstenite::tungstenite;

mod consts;
pub mod consumers;
pub mod manager;
pub mod message;

pub use consumers::broadcast;
pub use consumers::keep_state;
pub use manager::manage;

type WsStream = WebSocketStream<MaybeTlsStream<tokio::net::TcpStream>>;

pub async fn parse_stream(stream: WsStream) -> impl Stream<Item = message::Message> {
    stream.filter_map(|msg| msg.ok()).filter_map(|msg| {
        match msg {
            tungstenite::Message::Text(txt) => message::parse(txt),
            tungstenite::Message::Close(_) => None, // how do i break out of the while let loop?
            _ => None,
        }
    })
}

pub async fn init() -> Result<WsStream, Box<dyn Error>> {
    let req = create_request().await?;

    debug!(?req, "created request");

    let connect_result = timeout(
        Duration::from_secs(10),
        tokio_tungstenite::connect_async(req),
    )
    .await;

    let (mut socket, _) = match connect_result {
        Ok(Ok(res)) => res,
        Ok(Err(e)) => return Err(Box::new(e)),
        Err(_) => return Err("ws connect timed out".into()),
    };

    info!("connected");

    socket
        .send(tungstenite::Message::text(consts::SIGNALR_SUBSCRIBE))
        .await?;

    info!("subscribed");

    Ok(socket)
}

async fn create_request() -> Result<Request<()>, Box<dyn Error>> {
    trace!("creating request");

    match env_url() {
        Some(url) => Ok(url.into_client_request()?),
        None => {
            trace!("no url detected");

            let negotiation = negotiate().await?;

            trace!(negotiation.token, negotiation.cookie);

            let url = Url::parse_with_params(
                &format!("wss://{}/connect", consts::F1_BASE_URL),
                &[
                    ("clientProtocol", "1.5"),
                    ("transport", "webSockets"),
                    ("connectionToken", &negotiation.token),
                    ("connectionData", consts::SIGNALR_HUB),
                ],
            )?;

            trace!(?url);

            let mut req: Request<()> = url.into_client_request()?;

            let headers = req.headers_mut();
            headers.insert(
                header::USER_AGENT, // asd
                HeaderValue::from_static("BestHTTP"),
            );
            headers.insert(
                header::ACCEPT_ENCODING,
                HeaderValue::from_static("gzip,identity"),
            );
            headers.insert(
                header::COOKIE, // asd
                negotiation.cookie.parse().unwrap(),
            );

            Ok(req)
        }
    }
}

struct Negotiaion {
    token: String,
    cookie: String,
}

async fn negotiate() -> Result<Negotiaion, Box<dyn Error>> {
    trace!("negotiating");

    let url = Url::parse_with_params(
        &format!("https://{}/negotiate", consts::F1_BASE_URL),
        &[
            ("clientProtocol", "1.5"),
            ("connectionData", consts::SIGNALR_HUB),
        ],
    )?;

    let res = match timeout(Duration::from_secs(5), reqwest::get(url)).await {
        Ok(Ok(r)) => r,
        Ok(Err(e)) => return Err(Box::new(e)),
        Err(_) => return Err("negotiation HTTP request timed out".into()),
    };

    // TODO refactor this
    let headers = res.headers().clone();
    let body = res.text().await?;
    let json = serde_json::from_str::<Value>(&body)?;

    trace!(?json, "negotiation response");

    Ok(Negotiaion {
        token: json["ConnectionToken"]
            .as_str()
            .unwrap_or_default()
            .to_string(),
        cookie: headers[header::SET_COOKIE]
            .to_str()
            .unwrap_or_default()
            .to_string(),
    })
}

fn env_url() -> Option<Url> {
    let env_url = env::var_os("WS_URL")?.into_string().ok()?;
    Some(Url::parse(&env_url).ok()?)
}



---
File: /crates/client/src/consts.rs
---

pub const F1_BASE_URL: &str = "livetiming.formula1.com/signalr";

pub const SIGNALR_HUB: &str = r#"[{ "name": "Streaming" }]"#;

pub const SIGNALR_SUBSCRIBE: &str = r#"{
    "H": "Streaming",
    "M": "Subscribe",
    "A": [[
        "Heartbeat",
        "CarData.z",
        "Position.z",
        "ExtrapolatedClock",
        "TopThree",
        "RcmSeries",
        "TimingStats",
        "TimingAppData",
        "WeatherData",
        "TrackStatus",
        "SessionStatus",
        "DriverList",
        "RaceControlMessages",
        "SessionInfo",
        "SessionData",
        "LapCount",
        "TimingData",
        "TeamRadio",
        "PitLaneTimeCollection",
        "ChampionshipPrediction"
    ]],
    "I": 1,
}"#;



---
File: /crates/client/src/consumers.rs
---

use std::sync::{Arc, Mutex};

use data::merge::merge;
use serde_json::{json, Map, Value};
use tokio::sync::broadcast::{self, Receiver, Sender};
use tokio_stream::{wrappers::ReceiverStream, StreamExt};
use tracing::error;

use crate::message::Message;

pub fn broadcast(mut stream: ReceiverStream<Message>) -> (Sender<Message>, Receiver<Message>) {
    let (tx, rx) = broadcast::channel::<Message>(32);

    let manage_tx = tx.clone();

    tokio::spawn(async move {
        while let Some(message) = stream.next().await {
            let _ = manage_tx.send(message);
        }
    });

    (tx, rx)
}

pub fn keep_state(mut reciver: Receiver<Message>) -> Arc<Mutex<Value>> {
    let state = Arc::new(Mutex::new(json!({})));

    let manage_state = state.clone();

    tokio::spawn(async move {
        while let Ok(message) = reciver.recv().await {
            match message {
                Message::Updates(updates) => {
                    let Ok(mut state) = manage_state.lock() else {
                        error!("failed to lock state");
                        continue;
                    };

                    for (topic, update) in updates {
                        let mut map = Map::new();
                        map.insert(topic, update);
                        merge(&mut state, Value::Object(map));
                    }
                }
                Message::Initial(initial) => {
                    let Ok(mut state) = manage_state.lock() else {
                        error!("failed to lock state");
                        continue;
                    };

                    *state = initial;
                }
            }
        }
    });

    state
}



---
File: /crates/client/src/manager.rs
---

use std::time::Duration;

use tokio::{
    sync::mpsc,
    time::{sleep, timeout},
};
use tokio_stream::{wrappers::ReceiverStream, StreamExt};
use tracing::error;

use crate::{init, message::Message, parse_stream};

pub fn manage() -> ReceiverStream<Message> {
    let (tx, rx) = mpsc::channel::<Message>(32);

    tokio::spawn(async move {
        'manage: loop {
            sleep(Duration::from_secs(3)).await;

            let stream = match init().await {
                Ok(stream) => stream,
                Err(err) => {
                    error!(?err, "error occored starting the client, restarting");
                    continue 'manage;
                }
            };

            let mut parsed_stream = parse_stream(stream).await;

            loop {
                let res = timeout(Duration::from_secs(30), parsed_stream.next()).await;

                match res {
                    Ok(Some(message)) => {
                        if check_restart(&message) {
                            continue 'manage;
                        }
                        let _ = tx.send(message).await;
                    }
                    Ok(None) => {
                        error!("stream ended unexpectedly, restarting client");
                        continue 'manage;
                    }
                    Err(err) => {
                        error!(
                            ?err,
                            "timeout while waiting for next message, restarting client"
                        );
                        continue 'manage;
                    }
                }
            }
        }
    });

    ReceiverStream::new(rx)
}

fn check_restart(message: &Message) -> bool {
    match message {
        Message::Updates(updates) => {
            for (cat, update) in updates {
                if cat == "sessionInfo" && update.pointer("/name").is_some() {
                    return true;
                }
            }

            false
        }
        Message::Initial(_) => false,
    }
}



---
File: /crates/client/src/message.rs
---

use data::transformer::{to_camel_case, transform};
use serde_json::Value;
use tokio_tungstenite::tungstenite::Utf8Bytes;
use tracing::trace;

#[derive(Clone)]
pub enum Message {
    Updates(Vec<(String, Value)>),
    Initial(Value),
}

pub fn parse(data: Utf8Bytes) -> Option<Message> {
    trace!(?data, "parsing message");

    let msg = serde_json::from_str::<Value>(&data).ok()?;

    if let Some(initial) = msg.pointer("/R") {
        let mut data = initial.clone();
        transform(&mut data);
        return Some(Message::Initial(data));
    };

    if let Some(Value::Array(updates)) = msg.pointer("/M") {
        if updates.len() < 1 {
            return None;
        }

        let mut ups = Vec::new();

        for update in updates {
            let Some(cat) = update.pointer("/A/0").and_then(|v| v.as_str()) else {
                continue;
            };

            let Some(data) = update.pointer("/A/1") else {
                continue;
            };

            let mut update_value = data.clone();

            transform(&mut update_value);

            ups.push((to_camel_case(cat), update_value));
        }

        return Some(Message::Updates(ups));
    }

    None
}



---
File: /crates/data/src/compression.rs
---

use base64::Engine;
use flate2::write::DeflateEncoder;
use flate2::Compression;
use std::io::prelude::*;

pub fn deflate(data: String) -> Option<String> {
    // Create a ZlibEncoder
    let mut encoder = DeflateEncoder::new(Vec::new(), Compression::default());

    // Write the JSON string into the encoder
    match encoder.write_all(data.as_bytes()) {
        Ok(_) => (),
        Err(_) => return None,
    }

    // Finish the encoding process
    let encoded_bytes = match encoder.finish() {
        Ok(bytes) => bytes,
        Err(_) => return None,
    };

    // Convert the byte array to base64
    Some(base64::engine::general_purpose::STANDARD.encode(encoded_bytes))
}



---
File: /crates/data/src/data.rs
---

pub mod compression;
pub mod merge;
pub mod transformer;



---
File: /crates/data/src/merge.rs
---

use serde_json::Value;

pub fn merge(base: &mut Value, update: Value) {
    match (base, update) {
        (Value::Object(ref mut prev), Value::Object(update)) => {
            for (k, v) in update {
                merge(prev.entry(k).or_insert(Value::Null), v);
            }
        }
        (Value::Array(ref mut a), Value::Array(b)) => {
            a.extend(b);
        }
        (Value::Array(ref mut prev), Value::Object(update)) => {
            for (k, v) in update {
                if let Some(index) = k.parse::<usize>().ok() {
                    if let Some(item) = prev.get_mut(index) {
                        merge(item, v);
                    } else {
                        prev.push(v);
                    }
                }
            }
        }
        (a, b) => *a = b,
    }
}



---
File: /crates/data/src/transformer.rs
---

use std::mem;

use serde_json::{Map, Value};

pub fn to_camel_case(string: &str) -> String {
    heck::AsLowerCamelCase(string).to_string()
}

pub fn transform(value: &mut Value) {
    match value {
        Value::Object(object) => {
            let mut camel_case_map = Map::new();

            for (key, value) in object.iter_mut() {
                if key == "_kf" {
                    continue;
                }

                transform(value);
                camel_case_map.insert(to_camel_case(&key), mem::take(value));
            }

            *value = Value::Object(camel_case_map);
        }
        Value::Array(array) => {
            for value in array.iter_mut() {
                transform(value);
            }
        }
        _ => {}
    }
}

pub fn transform_map(map: &mut Map<String, Value>) -> Value {
    let mut camel_case_map = Map::new();

    for (key, value) in map.iter_mut() {
        transform(value);
        let new_key = to_camel_case(&key);
        camel_case_map.insert(new_key, mem::take(value));
    }

    Value::Object(camel_case_map)
}



---
File: /crates/saver/src/main.rs
---

use std::{
    env,
    fs::File,
    io::{LineWriter, Write},
};

use tokio_stream::StreamExt;
use tracing::{debug, error, info, level_filters::LevelFilter, warn};

use client;

#[tokio::main]
async fn main() {
    init_logs();

    let path = match env::args().nth(1) {
        Some(path) => path,
        None => {
            error!(r#"no path provided, usage "saver <path>""#);
            return;
        }
    };

    let path = std::path::Path::new(&path);

    if path.exists() {
        error!("file already exists at path {}", path.display());
        return;
    }

    let mut file = match File::create(path) {
        Ok(file) => LineWriter::new(file),
        Err(e) => {
            error!("failed to create file at path {}", e);
            return;
        }
    };

    info!("saving socket data to path {}", path.display());

    let stream = client::init().await;

    let mut stream = match stream {
        Ok(stream) => stream,
        Err(e) => {
            error!("failed to init client {}", e);
            return;
        }
    };

    while let Some(Ok(msg)) = stream.next().await {
        match msg {
            client::tungstenite::Message::Text(txt) => {
                debug!("received message: {}", txt);

                match writeln!(file, "{}", txt) {
                    Ok(_) => {}
                    Err(e) => error!("failed to write message to file {}", e),
                }
            }
            client::tungstenite::Message::Close(_) => {
                error!("connection got closed by server");
                break;
            }
            _ => warn!("unhandled message, probably binary, ping or pong"),
        }
    }

    match file.flush() {
        Ok(_) => {}
        Err(e) => error!("failed to flush file {}", e),
    }

    info!("done");
}

fn init_logs() {
    let env_filter = tracing_subscriber::EnvFilter::builder()
        .with_default_directive(LevelFilter::INFO.into())
        .with_env_var("RUST_LOG")
        .from_env_lossy();

    tracing_subscriber::fmt().with_env_filter(env_filter).init();
}



---
File: /crates/simulator/src/main.rs
---

use std::{
    env,
    fs::File,
    io::{self, BufRead},
    path::Path,
    time::Duration,
};

use tokio::{
    sync::{broadcast, mpsc},
    time::sleep,
};
use tracing::{error, info, level_filters::LevelFilter};

mod server;

#[tokio::main]
async fn main() {
    init_logs();

    let interval_ms: u64 = match env::args().nth(2) {
        Some(interval_str) => match interval_str.parse() {
            Ok(interval) => interval,
            Err(_) => {
                error!("failed to parse interval, using default of 100ms");
                100
            }
        },
        None => 100,
    };

    let path = match env::args().nth(1) {
        Some(path) => path,
        None => {
            error!(r#"no path provided, usage "simulator <path>""#);
            return;
        }
    };

    let path = std::path::Path::new(&path);

    if !path.exists() {
        error!("file does not exist at path {}", path.display());
        return;
    }

    info!("serving file at path {}", path.display());

    let lines = match read_lines(path) {
        Ok(lines) => lines,
        Err(_) => {
            error!("failed to read file at path {}", path.display());
            return;
        }
    };

    let (tx, _rx) = broadcast::channel::<String>(10);
    let (mpsc_tx, mut mpsc_rx) = mpsc::channel::<()>(10);

    let reader_tx = tx.clone();

    info!("starting reader thread");

    tokio::task::spawn(async move {
        mpsc_rx.recv().await;

        info!("reader has started broadcasting lines");

        for line in lines {
            sleep(Duration::from_millis(interval_ms)).await;

            match line {
                Ok(txt) => {
                    reader_tx.send(txt).unwrap();
                }
                Err(_) => {
                    error!("failed to read line");
                }
            };
        }

        info!("reader has finished broadcasting lines")
    });

    server::init(tx, mpsc_tx).await;
}

fn init_logs() {
    let env_filter = tracing_subscriber::EnvFilter::builder()
        .with_default_directive(LevelFilter::INFO.into())
        .with_env_var("RUST_LOG")
        .from_env_lossy();

    tracing_subscriber::fmt().with_env_filter(env_filter).init();
}

fn read_lines<P>(filename: P) -> io::Result<io::Lines<io::BufReader<File>>>
where
    P: AsRef<Path>,
{
    let file = File::open(filename)?;
    Ok(io::BufReader::new(file).lines())
}



---
File: /crates/simulator/src/server.rs
---

use std::sync::Arc;

use axum::{
    extract::{
        ws::{Message, WebSocket},
        State, WebSocketUpgrade,
    },
    response::Response,
    routing::get,
    Router,
};

use futures::{SinkExt, StreamExt};
use tokio::sync::{broadcast, mpsc};
use tracing::{error, info};

pub struct AppState {
    tx: broadcast::Sender<String>,
    mpsc_tx: mpsc::Sender<()>,
}

fn addr() -> String {
    std::env::var("SIMULATOR_ADDRESS").unwrap_or("0.0.0.0:8000".to_string())
}

pub async fn init(tx: broadcast::Sender<String>, mpsc_tx: mpsc::Sender<()>) {
    let app_state = Arc::new(AppState { tx, mpsc_tx });

    let app = Router::new()
        .route("/ws", get(handle_http))
        .with_state(app_state);

    let listener = tokio::net::TcpListener::bind(addr())
        .await
        .expect("failed to bind to port");

    info!("serving ws simulator on {}", addr());

    axum::serve(listener, app)
        .await
        .expect("failed to server http server");
}

async fn handle_http(ws: WebSocketUpgrade, State(state): State<Arc<AppState>>) -> Response {
    ws.on_upgrade(|socket| handle_ws(socket, state))
}

async fn handle_ws(socket: WebSocket, state: Arc<AppState>) {
    let mut reader_rx = state.tx.subscribe();

    state.mpsc_tx.clone().send(()).await.unwrap();

    info!("client connected to ws simulator");

    let (mut tx, mut rx) = socket.split();

    tokio::select! {
        _ = async {
            while let Ok(msg) = reader_rx.recv().await {
                match tx.send(Message::text(msg)).await {
                    Ok(_) => {}
                    Err(_) => error!("failed to send message"),
                }
            }
        } => {}
        _ = async {
            while let Some(Ok(msg)) = rx.next().await {
                match msg {
                    Message::Close(_) => {
                        info!("received close");
                        break;
                    }
                    _ => {}
                }
            }
        } => {}
    }

    info!("client disconnected from ws simulator");
}



---
File: /crates/timescale/src/app_timing.rs
---

use sqlx::PgPool;

pub struct TireDriver {
    pub nr: String,
    pub lap: Option<i32>,
    pub compound: String,
    pub laps: i32,
}

pub async fn insert_tire_driver(pool: &PgPool, driver: TireDriver) -> Result<(), anyhow::Error> {
    sqlx::query(
        r#"
        insert into tire_driver (nr, lap, compound, laps)
        values ($1, $2, $3, $4)
        "#,
    )
    .bind(driver.nr)
    .bind(driver.lap)
    .bind(driver.compound)
    .bind(driver.laps)
    .execute(pool)
    .await?;

    Ok(())
}



---
File: /crates/timescale/src/lib.rs
---

use sqlx::{postgres::PgPoolOptions, PgPool};
use std::env;

pub mod app_timing;
pub mod timing;

// pub use app_timing::insert_tire_driver;
// pub use timing::{get_laptimes, insert_timing_driver};

pub async fn init_timescaledb(migrate: bool) -> Result<PgPool, anyhow::Error> {
    let database_url = env::var("DATABASE_URL")?;

    let pool = PgPoolOptions::new()
        .max_connections(10)
        .connect(&database_url)
        .await?;

    if migrate {
        sqlx::migrate!().run(&pool).await?;
    }

    Ok(pool)
}



---
File: /crates/timescale/src/timing.rs
---

use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use sqlx::PgPool;

pub struct TimingDriver {
    pub nr: String,
    pub lap: Option<i32>,
    pub gap: i64,
    pub leader_gap: i64,
    pub laptime: i64,
    pub sector_1: i64,
    pub sector_2: i64,
    pub sector_3: i64,
}

pub async fn insert_timing_driver(
    pool: &PgPool,
    driver: TimingDriver,
) -> Result<(), anyhow::Error> {
    sqlx::query!(
        r#"
        insert into timing_driver (nr, lap, gap, leader_gap, laptime, sector_1, sector_2, sector_3)
        values ($1, $2, $3, $4, $5, $6, $7, $8)
        "#,
        driver.nr,
        driver.lap,
        driver.gap,
        driver.leader_gap,
        driver.laptime,
        driver.sector_1,
        driver.sector_2,
        driver.sector_3
    )
    .execute(pool)
    .await?;

    Ok(())
}

#[derive(Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Laptime {
    pub time: DateTime<Utc>,
    pub lap: Option<i32>,
    pub laptime: i64,
}

pub async fn get_laptimes(pool: &PgPool, nr: &str) -> Result<Vec<Laptime>, anyhow::Error> {
    let laptimes = sqlx::query!(
        r#"
        select
            lap,
            min(laptime) AS "laptime!",
            min(time) AS "time!"
        from
            timing_driver
        where
            nr = $1
            and laptime != 0
        group by
            lap
        order by
            lap;
        "#,
        nr
    )
    .map(|row| Laptime {
        time: row.time,
        lap: row.lap,
        laptime: row.laptime,
    })
    .fetch_all(pool)
    .await?;

    Ok(laptimes)
}

#[derive(Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Gap {
    pub time: DateTime<Utc>,
    pub gap: i64,
}

pub async fn get_gaps(pool: &PgPool, nr: &str) -> Result<Vec<Gap>, anyhow::Error> {
    let gaps = sqlx::query!(
        r#"
        select
            gap as "gap!",
            time as "time!"
        from
            timing_driver
        where
            nr = $1
            and gap != 0
        "#,
        nr
    )
    .map(|row| Gap {
        time: row.time,
        gap: row.gap,
    })
    .fetch_all(pool)
    .await?;

    Ok(gaps)
}



---
File: /services/analytics/src/server/gap.rs
---

use std::sync::Arc;

use timescale::timing::{get_gaps, Gap};

use axum::{
    extract::{Path, State},
    http::StatusCode,
    Json,
};

use tracing::error;

use crate::AppState;

#[derive(serde::Deserialize)]
pub struct Params {
    driver_nr: String,
}

pub async fn get_driver_gap(
    State(app_state): State<Arc<AppState>>,
    Path(Params { driver_nr }): Path<Params>,
) -> Result<Json<Vec<Gap>>, StatusCode> {
    let gaps = get_gaps(&app_state.pool, &driver_nr).await;

    match gaps {
        Ok(gaps) => Ok(Json(gaps)),
        Err(error) => {
            error!(?error, driver_nr, "failed to get gaps");
            Err(StatusCode::INTERNAL_SERVER_ERROR)
        }
    }
}



---
File: /services/analytics/src/server/health.rs
---

use axum::{http::StatusCode, response::IntoResponse, Json};
use serde_json::json;

pub async fn healt_check() -> impl IntoResponse {
    (StatusCode::OK, Json(json!({ "success": true })))
}



---
File: /services/analytics/src/server/laptime.rs
---

use std::sync::Arc;

use timescale::timing::{get_laptimes, Laptime};

use axum::{
    extract::{Path, State},
    http::StatusCode,
    Json,
};

use tracing::error;

use crate::AppState;

#[derive(serde::Deserialize)]
pub struct Params {
    driver_nr: String,
}

pub async fn get_driver_laptimes(
    State(app_state): State<Arc<AppState>>,
    Path(Params { driver_nr }): Path<Params>,
) -> Result<Json<Vec<Laptime>>, StatusCode> {
    let laptimes = get_laptimes(&app_state.pool, &driver_nr).await;

    match laptimes {
        Ok(laptimes) => Ok(Json(laptimes)),
        Err(error) => {
            error!(?error, driver_nr, "failed to get laptimes");
            Err(StatusCode::INTERNAL_SERVER_ERROR)
        }
    }
}



---
File: /services/analytics/src/main.rs
---

use std::{env, sync::Arc};

use axum::{
    http::{HeaderValue, Method},
    routing::get,
    Router,
};
use dotenvy::dotenv;
use sqlx::PgPool;
use tokio::net::TcpListener;
use tower_http::cors::CorsLayer;
use tracing::info;
use tracing_subscriber::{fmt, layer::SubscriberExt, util::SubscriberInitExt, EnvFilter};

use timescale::init_timescaledb;

use server::{gap::get_driver_gap, health::healt_check, laptime::get_driver_laptimes};

mod server {
    pub mod gap;
    pub mod health;
    pub mod laptime;
}

pub struct AppState {
    pool: PgPool,
}

#[tokio::main]
async fn main() -> Result<(), anyhow::Error> {
    let _ = dotenv();

    tracing_subscriber::registry()
        .with(fmt::layer())
        .with(EnvFilter::from_default_env())
        .init();

    let default_addr = "0.0.0.0:4002".to_string();
    let addr = env::var("ANALYTICS_ADDRESS").unwrap_or(default_addr);

    info!(addr, "starting analytics service");

    let pool = init_timescaledb(false).await?;

    let cors = cors_layer()?;

    let app_state = Arc::new(AppState { pool });

    let app = Router::new()
        .route("/api/health", get(healt_check))
        .route("/api/laptime/{driver_nr}", get(get_driver_laptimes))
        .route("/api/gap/{driver_nr}", get(get_driver_gap))
        .layer(cors)
        .with_state(app_state);

    let listener = TcpListener::bind(addr).await?;

    axum::serve(listener, app).await?;

    Ok(())
}

pub fn cors_layer() -> Result<CorsLayer, anyhow::Error> {
    let origin = env::var("ORIGIN")?; // origins string split by semicolumn

    let origins = origin
        .split(';')
        .filter_map(|o| HeaderValue::from_str(o).ok())
        .collect::<Vec<HeaderValue>>();

    Ok(CorsLayer::new()
        .allow_origin(origins)
        .allow_methods([Method::GET, Method::CONNECT]))
}



---
File: /services/api/src/endpoints/health.rs
---

use axum::{http::StatusCode, response::IntoResponse, Json};
use serde_json::json;

pub async fn check() -> impl IntoResponse {
    (StatusCode::OK, Json(json!({ "success": true })))
}



---
File: /services/api/src/endpoints/schedule.rs
---

use chrono::{DateTime, Datelike, NaiveDateTime, TimeZone, Utc};
use ical::parser::ical::component::IcalEvent;
use regex::Regex;
use serde::{Deserialize, Serialize};
use std::io::BufReader;
use tracing::{debug, error, warn};

use cached::proc_macro::io_cached;

#[derive(Serialize, Deserialize, Debug, Clone)]
#[serde(rename_all = "camelCase")]
pub struct Session {
    kind: String,
    start: DateTime<Utc>,
    end: DateTime<Utc>,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
#[serde(rename_all = "camelCase")]
pub struct Round {
    name: String,
    country_name: String,
    country_key: Option<String>,
    start: DateTime<Utc>,
    end: DateTime<Utc>,
    sessions: Vec<Session>,
    over: bool,
}

fn parse_ical_utc(date_string: &str) -> Option<DateTime<Utc>> {
    // Attempt to parse the date string
    match NaiveDateTime::parse_from_str(date_string, "%Y%m%dT%H%M%SZ") {
        Ok(naive_datetime) => Some(Utc.from_utc_datetime(&naive_datetime)),
        Err(_) => None,
    }
}

fn get_property(event: &IcalEvent, name: &str) -> Option<String> {
    for property in &event.properties {
        if property.name == name {
            return property.value.clone();
        }
    }

    None
}

fn find_round_mut<'a>(rounds: &'a mut Vec<Round>, name: &str) -> Option<&'a mut Round> {
    rounds.iter_mut().find(|r| r.name == name)
}

fn parse_name(full_name: &str) -> Option<(String, String)> {
    let regex = Regex::new(r"FORMULA 1 (?P<name>.+) - (?P<kind>.+)").ok()?;
    let captures = regex.captures(full_name)?;
    Some((captures["name"].to_owned(), captures["kind"].to_owned()))
}

fn new_round(event: IcalEvent, name: &str, kind: &str) -> Option<Round> {
    let country = get_property(&event, "LOCATION")?;
    let start_str = get_property(&event, "DTSTART")?;
    let end_str = get_property(&event, "DTEND")?;

    let start: DateTime<Utc> = parse_ical_utc(&start_str)?;
    let end: DateTime<Utc> = parse_ical_utc(&end_str)?;

    let sessions = vec![Session {
        kind: kind.to_owned(),
        start,
        end,
    }];

    let round = Round {
        name: name.to_owned(),
        country_name: country,
        country_key: None,
        start,
        end,
        sessions,
        over: false,
    };

    Some(round)
}

fn update_round(event: IcalEvent, round: &mut Round, kind: &str) -> Option<()> {
    let start_str = get_property(&event, "DTSTART")?;
    let end_str = get_property(&event, "DTEND")?;

    let start: DateTime<Utc> = parse_ical_utc(&start_str)?;
    let end: DateTime<Utc> = parse_ical_utc(&end_str)?;

    let new_session = Session {
        kind: kind.to_owned(),
        start,
        end,
    };

    round.sessions.push(new_session);

    if start < round.start {
        round.start = start;
    }

    if end > round.end {
        round.end = end;
    }

    Some(())
}

#[io_cached(
    map_error = r##"|e| anyhow::anyhow!(format!("disk cache error {:?}", e))"##,
    disk = true,
    time = 1800
)]
async fn get_schedule(year: i32) -> Result<Vec<Round>, anyhow::Error> {
    // webcal://ics.ecal.com/ecal-sub/660897ca63f9ca0008bcbea6/Formula%201.ics
    // *note this is a link created by entering a email and other info on the f1 website
    // i hope this does not expire...
    let cal_url = "https://ics.ecal.com/ecal-sub/660897ca63f9ca0008bcbea6/Formula%201.ics";
    let cal_bytes = reqwest::get(cal_url).await?.bytes().await?;
    let cal_buf = BufReader::new(cal_bytes.as_ref());
    let cal_reader = ical::IcalParser::new(cal_buf);

    let mut rounds: Vec<Round> = vec![];

    for line in cal_reader {
        let calendar = line?;

        for event in calendar.events {
            let full_name = get_property(&event, "SUMMARY");

            let Some(full_name) = full_name else {
                continue;
            };

            let Some((name, kind)) = parse_name(&full_name) else {
                continue;
            };

            match find_round_mut(&mut rounds, &name) {
                Some(round) => {
                    let _ = update_round(event, round, &kind);
                }
                None => {
                    let Some(new_round) = new_round(event, &name, &kind) else {
                        warn!("failed to create round with name: {}", name);
                        continue;
                    };

                    if new_round.start.year() != year {
                        debug!("filtering round for year: {}", name);
                        continue;
                    }

                    rounds.push(new_round);
                }
            }
        }
    }

    rounds.sort_unstable_by(|a, b| a.start.cmp(&b.start));

    let utc_now = Utc::now();

    for round in &mut rounds {
        round.over = round.end < utc_now;

        round
            .sessions
            .sort_unstable_by(|a, b| a.start.cmp(&b.start));
    }

    Ok(rounds)
}

pub async fn get() -> Result<axum::Json<Vec<Round>>, axum::http::StatusCode> {
    let year = chrono::Utc::now().year();
    let schedule = get_schedule(year).await;

    match schedule {
        Ok(schedule) => Ok(axum::Json(schedule)),
        Err(_) => {
            error!("failed to create schedule for year {}", year);
            Err(axum::http::StatusCode::INTERNAL_SERVER_ERROR)
        }
    }
}

pub async fn get_next() -> Result<axum::Json<Round>, axum::http::StatusCode> {
    let year = chrono::Utc::now().year();
    let schedule = get_schedule(year).await;

    match schedule {
        Ok(schedule) => {
            let not_over: Vec<Round> = schedule.into_iter().filter(|r| !r.over).collect();
            let next_round = not_over.first().cloned();

            match next_round {
                Some(next_round) => Ok(axum::Json(next_round)),
                None => Err(axum::http::StatusCode::NO_CONTENT),
            }
        }
        Err(_) => {
            error!("failed to create schedule for year {}", year);
            Err(axum::http::StatusCode::INTERNAL_SERVER_ERROR)
        }
    }
}



---
File: /services/api/src/main.rs
---

use std::env;

use axum::{
    http::{HeaderValue, Method},
    routing::get,
    Router,
};
use dotenvy::dotenv;
use tokio::net::TcpListener;
use tower_http::cors::CorsLayer;
use tracing::info;
use tracing_subscriber::{fmt, layer::SubscriberExt, util::SubscriberInitExt, EnvFilter};

mod endpoints {
    pub(crate) mod health;
    pub(crate) mod schedule;
}

#[tokio::main]
async fn main() -> Result<(), anyhow::Error> {
    let _ = dotenv();

    tracing_subscriber::registry()
        .with(fmt::layer())
        .with(EnvFilter::from_default_env())
        .init();

    let default_addr = "0.0.0.0:4001".to_string();
    let addr = env::var("API_ADDRESS").unwrap_or(default_addr);

    info!(addr, "starting api service");

    let app = Router::new()
        .route("/api/schedule", get(endpoints::schedule::get))
        .route("/api/schedule/next", get(endpoints::schedule::get_next))
        .route("/api/health", get(endpoints::health::check));

    let listener = TcpListener::bind(addr).await?;

    axum::serve(listener, app).await?;

    Ok(())
}

pub fn cors_layer() -> Result<CorsLayer, anyhow::Error> {
    let origin = env::var("ORIGIN")?; // origins string split by semicolumn

    let origins = origin
        .split(';')
        .filter_map(|o| HeaderValue::from_str(o).ok())
        .collect::<Vec<HeaderValue>>();

    Ok(CorsLayer::new()
        .allow_origin(origins)
        .allow_methods([Method::GET, Method::CONNECT]))
}



---
File: /services/importer/src/main.rs
---

use anyhow::Error;
use dotenvy::dotenv;
use serde_json::Value;
use sqlx::PgPool;
use tracing::{info, trace};
use tracing_subscriber::{fmt, layer::SubscriberExt, util::SubscriberInitExt, EnvFilter};

use client::message::Message;

use timescale::{
    app_timing::{insert_tire_driver, TireDriver},
    init_timescaledb,
    timing::{insert_timing_driver, TimingDriver},
};

use models::State;
use parsers::{parse_timing_driver, parse_tire_driver};

mod models;
mod parsers;

#[tokio::main]
async fn main() -> Result<(), anyhow::Error> {
    let _ = dotenv();

    tracing_subscriber::registry()
        .with(fmt::layer())
        .with(EnvFilter::from_default_env())
        .init();

    info!("starting importer service");

    let pool = init_timescaledb(true).await?;

    let stream = client::manage();
    let (tx, rx) = client::broadcast(stream);
    let state = client::keep_state(rx);

    let mut message_rx = tx.subscribe();

    while let Ok(message) = message_rx.recv().await {
        match message {
            Message::Updates(updates) => {
                trace!(?updates, "recived updates, saving");

                let currnet_state = state.lock().unwrap().clone();

                let _ = parse_update(&pool, currnet_state, updates).await;
            }
            Message::Initial(initial) => {
                trace!(?initial, "recived initial, saving");

                let _ = save_initial_state(&pool, initial).await;
            }
        }
    }

    Ok(())
}

async fn parse_update(
    pool: &PgPool,
    state: Value,
    updates: Vec<(String, Value)>,
) -> Result<(), Error> {
    // check for TIMING_TOPICS
    // check for every driver that has a update and fill the rest

    let state = serde_json::from_value::<State>(state)?;

    for (topic, update) in updates {
        match &topic[..] {
            "timingData" => {
                let Some(drivers) = parse_timing_update(&state, update).await else {
                    continue;
                };

                for driver in drivers {
                    let _ = insert_timing_driver(pool, driver).await;
                }
            }
            "timingAppData" => {
                let Some(drivers) = parse_tire_update(&state, update).await else {
                    continue;
                };

                for driver in drivers {
                    let _ = insert_tire_driver(pool, driver).await;
                }
            }
            _ => {}
        }
    }

    Ok(())
}

async fn parse_timing_update(state: &State, update: Value) -> Option<Vec<TimingDriver>> {
    // for every driver in the update parse driver and use state for None values
    let timing_data = state.timing_data.as_ref()?;
    let lap = state.lap_count.as_ref()?.current_lap;

    let mut drivers = vec![];

    for (nr, update_driver) in update["lines"].as_object()?.into_iter() {
        let Some(driver) = timing_data.lines.get(nr) else {
            continue;
        };

        let Some(driver) = parse_timing_driver(nr, Some(lap), driver, Some(update_driver)) else {
            continue;
        };

        drivers.push(driver);
    }

    Some(drivers)
}

async fn parse_tire_update(state: &State, update: Value) -> Option<Vec<TireDriver>> {
    let timing_app_data = state.timing_app_data.as_ref()?;
    let lap = state.lap_count.as_ref()?.current_lap;

    let mut drivers = vec![];

    for (nr, update_driver) in update["lines"].as_object()?.into_iter() {
        let Some(driver) = timing_app_data.lines.get(nr) else {
            continue;
        };

        let Some(driver) = parse_tire_driver(nr, Some(lap), driver, Some(update_driver)) else {
            continue;
        };

        drivers.push(driver);
    }

    Some(drivers)
}

async fn save_initial_state(pool: &PgPool, state: Value) -> Result<(), Error> {
    let state = serde_json::from_value::<State>(state)?;

    let lap = state.lap_count.and_then(|v| Some(v.current_lap));

    if let Some(timing_data) = state.timing_data {
        for (nr, driver) in timing_data.lines.iter() {
            let Some(timing_driver) = parse_timing_driver(&nr, lap, &driver, None) else {
                continue;
            };

            let _ = insert_timing_driver(pool, timing_driver).await;
        }
    }

    if let Some(app_timing_data) = state.timing_app_data {
        for (nr, driver) in app_timing_data.lines.iter() {
            let Some(tire_driver) = parse_tire_driver(&nr, lap, &driver, None) else {
                continue;
            };

            let _ = insert_tire_driver(pool, tire_driver).await;
        }
    }

    Ok(())
}



---
File: /services/importer/src/models.rs
---

use serde::{Deserialize, Serialize};
use std::collections::HashMap;

#[derive(Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct State {
    // pub heartbeat: Option<Heartbeat>,
    // pub extrapolated_clock: Option<ExtrapolatedClock>,
    // pub top_three: Option<TopThree>,
    // pub timing_stats: Option<TimingStats>,
    pub timing_app_data: Option<TimingAppData>,
    // pub weather_data: Option<WeatherData>,
    // pub track_status: Option<TrackStatus>,
    // pub session_status: Option<SessionStatus>,
    // pub driver_list: Option<HashMap<String, Driver>>,
    // pub race_control_messages: Option<RaceControlMessages>,
    // pub session_info: Option<SessionInfo>,
    // pub session_data: Option<SessionData>,
    pub lap_count: Option<LapCount>,
    pub timing_data: Option<TimingData>,
    // pub team_radio: Option<TeamRadio>,
    // pub championship_prediction: Option<ChampionshipPrediction>,
}

#[derive(Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct TimingStats {
    pub withheld: bool,
    pub lines: HashMap<String, TimingStatsDriver>,
    pub session_type: String,
    #[serde(rename = "_kf")]
    pub kf: bool,
}

#[derive(Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct TimingAppData {
    pub lines: HashMap<String, TimingAppDataDriver>,
}

#[derive(Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct TimingAppDataDriver {
    pub racing_number: String,
    pub stints: Vec<Stint>,
    pub line: i32,
    pub grid_pos: String,
}

#[derive(Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Stint {
    pub total_laps: Option<i32>,
    pub compound: Option<String>, // "SOFT" | "MEDIUM" | "HARD" | "INTERMEDIATE" | "WET"
    #[serde(rename = "new")]
    pub is_new: Option<String>, // "TRUE" | "FALSE"
}

#[derive(Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct WeatherData {
    pub air_temp: String,
    pub humidity: String,
    pub pressure: String,
    pub rainfall: String,
    pub track_temp: String,
    pub wind_direction: String,
    pub wind_speed: String,
}

#[derive(Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct TrackStatus {
    pub status: String,
    pub message: String,
}

#[derive(Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct SessionStatus {
    pub status: String, // "Started" | "Finished" | "Finalised" | "Ends"
}

#[derive(Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Driver {
    pub racing_number: String,
    pub broadcast_name: String,
    pub full_name: String,
    pub tla: String,
    pub line: i32,
    pub team_name: String,
    pub team_colour: String,
    pub first_name: String,
    pub last_name: String,
    pub reference: String,
    pub headshot_url: String,
    pub country_code: String,
}

#[derive(Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct LapCount {
    pub current_lap: i32,
    pub total_laps: i32,
}

#[derive(Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct TimingData {
    pub no_entries: Option<Vec<i32>>,
    pub session_part: Option<i32>,
    pub cut_off_time: Option<String>,
    pub cut_off_percentage: Option<String>,
    pub lines: HashMap<String, TimingDataDriver>,
    pub withheld: bool,
}

#[derive(Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct TimingDataDriver {
    pub stats: Option<Vec<Stats>>,
    pub time_diff_to_fastest: Option<String>,
    pub time_diff_to_position_ahead: Option<String>,
    pub gap_to_leader: String,
    pub interval_to_position_ahead: Option<IntervalToPositionAhead>,
    pub line: i32,
    // pub position: String,
    // pub show_position: bool,
    pub racing_number: String,
    // pub retired: bool,
    // pub in_pit: bool,
    // pub pit_out: bool,
    // pub stopped: bool,
    // pub status: i32,
    pub sectors: Vec<Sector>,
    // pub speeds: Speeds,
    pub best_lap_time: PersonalBestLapTime,
    pub last_lap_time: I1,
    // pub number_of_laps: i32,
    // pub knocked_out: Option<bool>,
    // pub cutoff: Option<bool>,
}

#[derive(Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Stats {
    pub time_diff_to_fastest: String,
    pub time_diff_to_position_ahead: String,
}

#[derive(Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct IntervalToPositionAhead {
    pub value: String,
    pub catching: bool,
}

#[derive(Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Sector {
    pub stopped: bool,
    pub value: String,
    pub previous_value: Option<String>,
    pub status: i32,
    pub overall_fastest: bool,
    pub personal_fastest: bool,
    pub segments: Vec<Segment>,
}

#[derive(Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Segment {
    pub status: i32,
}

#[derive(Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Speeds {
    pub i1: I1,
    pub i2: I1,
    pub fl: I1,
    pub st: I1,
}

#[derive(Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct I1 {
    pub value: String,
    pub status: i32,
    pub overall_fastest: bool,
    pub personal_fastest: bool,
}

#[derive(Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct TimingStatsDriver {
    pub line: i32,
    pub racing_number: String,
    pub personal_best_lap_time: PersonalBestLapTime,
    pub best_sectors: Vec<PersonalBestLapTime>,
    pub best_speeds: BestSpeeds,
}

#[derive(Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct BestSpeeds {
    pub i1: PersonalBestLapTime,
    pub i2: PersonalBestLapTime,
    pub fl: PersonalBestLapTime,
    pub st: PersonalBestLapTime,
}

#[derive(Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct PersonalBestLapTime {
    pub value: String,
    // pub position: i32,
}

#[derive(Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct TopThreeDriver {
    pub position: String,
    pub show_position: bool,
    pub racing_number: String,
    pub tla: String,
    pub broadcast_name: String,
    pub full_name: String,
    pub team: String,
    pub team_colour: String,
    pub lap_time: String,
    pub lap_state: i32,
    pub diff_to_ahead: String,
    pub diff_to_leader: String,
    pub overall_fastest: bool,
    pub personal_fastest: bool,
}

#[derive(Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct TeamRadio {
    pub captures: Vec<RadioCapture>,
}

#[derive(Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct RadioCapture {
    pub utc: String,
    pub racing_number: String,
    pub path: String,
}

#[derive(Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct ChampionshipPrediction {
    pub drivers: HashMap<String, ChampionshipDriver>,
    pub teams: HashMap<String, ChampionshipTeam>,
}

#[derive(Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct ChampionshipDriver {
    pub racing_number: String,
    pub current_position: i32,
    pub predicted_position: i32,
    pub current_points: i32,
    pub predicted_points: i32,
}

#[derive(Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct ChampionshipTeam {
    pub team_name: String,
    pub current_position: i32,
    pub predicted_position: i32,
    pub current_points: i32,
    pub predicted_points: i32,
}

#[derive(Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Position {
    pub position: Vec<PositionItem>,
}

#[derive(Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct PositionItem {
    pub timestamp: String,
    pub entries: HashMap<String, PositionCar>,
}

#[derive(Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct PositionCar {
    pub status: String,
    pub x: f64,
    pub y: f64,
    pub z: f64,
}

#[derive(Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct CarData {
    pub entries: Vec<Entry>,
}

#[derive(Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Entry {
    pub utc: String,
    pub cars: HashMap<String, CarDataChannels>,
}

#[derive(Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct CarDataChannels {
    #[serde(rename = "0")]
    pub rpm: i32,
    #[serde(rename = "2")]
    pub speed: i32,
    #[serde(rename = "3")]
    pub gear: i32,
    #[serde(rename = "4")]
    pub throttle: i32,
    #[serde(rename = "5")]
    pub brake: i32,
    #[serde(rename = "45")]
    pub drs: i32,
}



---
File: /services/importer/src/parsers.rs
---

use serde_json::Value;
use timescale::{app_timing::TireDriver, timing::TimingDriver};
use tracing::trace;

use crate::models::{TimingAppDataDriver, TimingDataDriver};

// "LAP1" / "" / "+0.273" / "1L" / "20L"
pub fn parse_gap(gap: String) -> i64 {
    if gap.is_empty() {
        trace!(gap, "gap empty");
        return 0;
    }
    if gap.contains("L") {
        trace!(gap, "gap contains L");
        return 0;
    }
    if let Ok(ms) = gap.replace("+", "").parse::<f64>() {
        trace!(gap, ms, "gap parsed");
        return (ms * 1000.0) as i64;
    }

    trace!(gap, "gap failed to parse");

    return 0;
}

// "1:21.306" / ""
pub fn parse_laptime(lap: String) -> i64 {
    if lap.is_empty() {
        trace!(lap, "laptime empty");
        return 0;
    }
    let parts: Vec<&str> = lap.split(':').collect();
    if parts.len() == 2 {
        if let (Ok(minutes), Ok(seconds)) = (parts[0].parse::<i64>(), parts[1].parse::<f64>()) {
            trace!(lap, "laptime parsed");
            return minutes * 60_000 + (seconds * 1000.0) as i64;
        }
    }
    trace!(lap, "laptime failed to parse");
    return 0;
}

// "26.259" / ""
pub fn parse_sector(sector: String) -> i64 {
    if sector.is_empty() {
        trace!(sector, "sector empty");
        return 0;
    }
    if let Ok(seconds) = sector.parse::<f64>() {
        trace!(sector, "sector parsed");
        return (seconds * 1000.0) as i64;
    }
    trace!(sector, "sector failed to parse");
    return 0;
}

fn str_pointer<'a>(update: Option<&'a Value>, pointer: &str) -> Option<&'a str> {
    update
        .and_then(|v| v.pointer(pointer))
        .and_then(|v| v.as_str())
}

pub fn parse_timing_driver(
    nr: &String,
    lap: Option<i32>,
    driver: &TimingDataDriver,
    update: Option<&Value>,
) -> Option<TimingDriver> {
    let gap = str_pointer(update, "/intervalToPositionAhead/value");
    let leader_gap = str_pointer(update, "/gapToLeader");

    let laptime = str_pointer(update, "/lastLaptime/value");

    let sector_1 = str_pointer(update, "/sectors/0/value");
    let sector_2 = str_pointer(update, "/sectors/1/value");
    let sector_3 = str_pointer(update, "/sectors/2/value");

    if gap.is_some()
        || leader_gap.is_some()
        || laptime.is_some()
        || sector_1.is_some()
        || sector_2.is_some()
        || sector_3.is_some()
    {
        return None;
    }

    Some(TimingDriver {
        nr: nr.clone(),
        lap,
        gap: parse_gap(
            gap.unwrap_or(&driver.interval_to_position_ahead.as_ref().unwrap().value)
                .to_string(),
        ),
        leader_gap: parse_gap(leader_gap.unwrap_or(&driver.gap_to_leader).to_string()),
        laptime: parse_laptime(laptime.unwrap_or(&driver.last_lap_time.value).to_string()),
        sector_1: parse_sector(sector_1.unwrap_or(&driver.sectors[0].value).to_string()),
        sector_2: parse_sector(sector_2.unwrap_or(&driver.sectors[1].value).to_string()),
        sector_3: parse_sector(sector_3.unwrap_or(&driver.sectors[2].value).to_string()),
    })
}

pub fn parse_tire_driver(
    nr: &String,
    lap: Option<i32>,
    driver: &TimingAppDataDriver,
    update: Option<&Value>,
) -> Option<TireDriver> {
    let update_stint = update
        .and_then(|v| v.pointer("/stints"))
        .and_then(|v| v.as_array())
        .and_then(|v| v.last());

    let last_stint = driver.stints.last();

    let compound = update_stint
        .and_then(|v| v.get("compound"))
        .and_then(|v| v.as_str());

    let laps = update_stint
        .and_then(|v| v.get("totalLaps"))
        .and_then(|v| v.as_i64());

    if compound.is_some() || laps.is_some() {
        return None;
    }

    Some(TireDriver {
        nr: nr.clone(),
        lap,
        compound: compound
            .unwrap_or(last_stint.unwrap().compound.as_ref().unwrap())
            .to_string(),
        laps: laps.unwrap_or(last_stint.unwrap().total_laps.unwrap().clone() as i64) as i32,
    })
}



---
File: /services/live/src/server/drivers.rs
---

use std::{mem, sync::Arc};

use axum::extract::State;
use serde_json::Value;
use tracing::error;

use crate::AppState;

fn map_to_vec(value: Value) -> Vec<Value> {
    match value {
        Value::Object(map) => map.into_iter().map(|(_, v)| v).collect(),
        _ => vec![],
    }
}

pub async fn get_drivers(
    State(state): State<Arc<AppState>>,
) -> Result<axum::Json<Vec<Value>>, axum::http::StatusCode> {
    let state_lock = state.state.lock().unwrap();
    let live_state = state_lock.clone();
    mem::drop(state_lock);

    match live_state.pointer("/driverList") {
        Some(drivers) => Ok(axum::Json(map_to_vec(drivers.clone()))),
        None => {
            error!("failed to get drivers from live state");
            Err(axum::http::StatusCode::INTERNAL_SERVER_ERROR)
        }
    }
}



---
File: /services/live/src/server/health.rs
---

use axum::{http::StatusCode, response::IntoResponse, Json};
use serde_json::json;

pub async fn check() -> impl IntoResponse {
    (StatusCode::OK, Json(json!({ "success": true })))
}



---
File: /services/live/src/server/live.rs
---

use std::{convert::Infallible, mem, sync::Arc, time::Duration};

use axum::{
    extract::State,
    response::{sse, Sse},
};
use client::message::Message;
use futures::Stream;
use serde_json::{json, Map, Value};
use tokio_stream::{wrappers::BroadcastStream, StreamExt};
use tracing::{debug, info};

use data::merge::merge;

use crate::AppState;

// TODO clean this up a bit maybe
fn sse_event(message: Message) -> sse::Event {
    let (event, data): (&str, Value) = match message {
        Message::Updates(updates) => {
            let mut batched_update = json!({});

            for (topic, update) in updates {
                let mut map = Map::new();
                map.insert(topic, update);
                merge(&mut batched_update, Value::Object(map));
            }

            // TODO maybe send the updates in array instead of object

            ("update", batched_update)
        }
        Message::Initial(value) => ("initial", value),
    };

    sse::Event::default().event(event).json_data(data).unwrap()
}

pub async fn sse_handler(
    State(state): State<Arc<AppState>>,
) -> Sse<impl Stream<Item = Result<sse::Event, Infallible>>> {
    let rx = state.tx.subscribe();
    let connections = state.tx.receiver_count();

    info!(connections, "new sse connection");

    let initial_state_lock = state.state.lock().unwrap();
    let initial_state = initial_state_lock.clone();
    mem::drop(initial_state_lock);

    let initial_stream = futures::stream::once(async {
        debug!("streaming current initial");

        Ok(sse::Event::default()
            .event("initial")
            .json_data(initial_state)
            .unwrap())
    });

    let updates_stream = BroadcastStream::new(rx)
        .filter_map(|msg| msg.ok())
        .map(|message| sse_event(message))
        .map(Ok);

    let stream = initial_stream.chain(updates_stream);

    let keep_alive = sse::KeepAlive::new()
        .interval(Duration::from_secs(10))
        .text("keep-alive-text");

    Sse::new(stream).keep_alive(keep_alive)
}



---
File: /services/live/src/compression.rs
---

use axum::body::{Body, BodyDataStream, Bytes};
use axum::extract::Request;
use axum::http::header;
use axum::middleware::Next;
use axum::response::Response;
use flate2::write::GzEncoder;
use flate2::Compression;
use futures_util::stream::Stream;

use std::io::Write;
use std::pin::{pin, Pin};
use std::task::Context;
use std::task::Poll;

pub async fn compress_sse(request: Request, next: Next) -> Response {
	let accept_encoding = request.headers().get(header::ACCEPT_ENCODING).cloned();

	let response = next.run(request).await;

	let content_encoding = response.headers().get(header::CONTENT_ENCODING);
	let content_type = response.headers().get(header::CONTENT_TYPE);

	// No accept-encoding from client or content-type from server.
	let (Some(ct), Some(ae)) = (content_type, accept_encoding) else {
		return response;
	};
	// Already compressed.
	if content_encoding.is_some() {
		return response;
	}
	// Not text/event-stream.
	if ct.as_bytes() != b"text/event-stream" {
		return response;
	}
	// Client doesn't accept gzip compression.
	if !ae.to_str().map(|v| v.contains("gzip")).unwrap_or(false) {
		return response;
	}

	let (mut parts, body) = response.into_parts();

	let body = body.into_data_stream();
	let body = Body::from_stream(CompressedStream::new(body));

	parts.headers.insert(
		header::CONTENT_ENCODING,
		header::HeaderValue::from_static("gzip"),
	);
	parts.headers.insert(
		header::VARY,
		header::HeaderValue::from_static("accept-encoding"),
	);

	Response::from_parts(parts, body)
}

struct CompressedStream {
	inner: BodyDataStream,
	compression: GzEncoder<Vec<u8>>,
}

impl CompressedStream {
	pub fn new(body: BodyDataStream) -> Self {
		Self {
			inner: body,
			compression: GzEncoder::new(Vec::new(), Compression::default()),
		}
	}
}

impl Stream for CompressedStream {
	type Item = Result<Bytes, axum::Error>;

	#[inline]
	fn poll_next(mut self: Pin<&mut Self>, cx: &mut Context<'_>) -> Poll<Option<Self::Item>> {
		match pin!(&mut self.inner).as_mut().poll_next(cx) {
			Poll::Ready(Some(Ok(x))) => {
				self.compression.write_all(&x).unwrap();
				self.compression.flush().unwrap();

				let mut buf = Vec::new();
				std::mem::swap(&mut buf, self.compression.get_mut());

				Poll::Ready(Some(Ok(buf.into())))
			}
			x => x,
		}
	}
}



---
File: /services/live/src/main.rs
---

use std::{
    env,
    net::SocketAddr,
    sync::{Arc, Mutex},
};

use axum::{
    http::{HeaderValue, Method},
    routing::get,
    Router,
};
use compression::compress_sse;
use dotenvy::dotenv;
use serde_json::Value;
use tokio::{net::TcpListener, sync::broadcast};
use tower_http::cors::CorsLayer;
use tracing::info;
use tracing_subscriber::{fmt, layer::SubscriberExt, util::SubscriberInitExt, EnvFilter};

use client::message::Message;

mod compression;
mod server {
    pub mod drivers;
    pub mod health;
    pub mod live;
}

pub struct AppState {
    tx: broadcast::Sender<Message>,
    state: Arc<Mutex<Value>>,
}

#[tokio::main]
async fn main() -> Result<(), anyhow::Error> {
    let _ = dotenv();

    tracing_subscriber::registry()
        .with(fmt::layer())
        .with(EnvFilter::from_default_env())
        .init();

    let default_addr = "0.0.0.0:4000".to_string();
    let addr = env::var("LIVE_ADDRESS").unwrap_or(default_addr);

    info!(?addr, "starting live service");

    let stream = client::manage();
    let (tx, rx) = client::broadcast(stream);
    let state = client::keep_state(rx);

    let cors = cors_layer()?;

    let app_state = Arc::new(AppState { tx, state });

    let app = Router::new()
        .route("/api/health", get(server::health::check))
        .route("/api/sse", get(server::live::sse_handler))
        .route("/api/drivers", get(server::drivers::get_drivers))
        .layer(cors)
        .layer(axum::middleware::from_fn(compress_sse))
        .with_state(app_state)
        .into_make_service_with_connect_info::<SocketAddr>();

    let listener = TcpListener::bind(addr).await?;

    axum::serve(listener, app).await?;

    Ok(())
}

pub fn cors_layer() -> Result<CorsLayer, anyhow::Error> {
    let origin = env::var("ORIGIN")?; // origins string split by semicolumn

    let origins = origin
        .split(';')
        .filter_map(|o| HeaderValue::from_str(o).ok())
        .collect::<Vec<HeaderValue>>();

    Ok(CorsLayer::new()
        .allow_origin(origins)
        .allow_methods([Method::GET, Method::CONNECT]))
}

