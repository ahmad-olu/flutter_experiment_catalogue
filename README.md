# Experiment Catalogue

```sh
# Development
$ flutter run --flavor development --target lib/main_development.dart
$ flutter run --flavor development --target lib/main_development.dart -d chrome
```

## 01. Todos Page

- install pocket base then `pocketbase serve`
- then run `flutter run`
- to run on the web `/#/todo01-route`

## 02. Weather app

- get open weather api key from [open weather](https://openweathermap.org/)
- add it to `lib/applications/02_weather/cubit/weather_cubit.dart`
- then run `flutter run`
- enter a city name then press submit.
- to run on the web `/#/weather02-route`

## 03. bmi calculator

- run `flutter run`
- enter `height in meters e.g 1.75` and `weight in kg e.g 70`
- to run on the web `/#/bmi-calc03-route`

## 04. quiz

- run `flutter run`
- data coming from [quizapi](https://quizapi.io/) also added hydrated bloc so you can continue from were you last stopped.
- to run on the web `/#/quiz04-route`

## 05. Chat App (Socket Io)

- make sure you have rust installed then go to `,.backend/ax` then run `cargo run`
- run `flutter run` in the root of your program
- to run on the web `/#/socket-test05-route`

## 06. Chat App (Web Socket)

- make sure you have rust installed then go to `./backend/ax` then run `cargo run`
- run `flutter run` in the root of your program
- to run on the web `/#/chat06-route`

## 07. Music Player

- run `flutter run`
- to run on the web `/#/music07-route`

## 16. video streaming
- make sure you have rust installed then go to `./backend/ax`, create a `video` folder then run `cargo run`
- run `flutter run` in the root of your program
- to run on the web `/#/upload-vid16-route`

## 20. web RTC
