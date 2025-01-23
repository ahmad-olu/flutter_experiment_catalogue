part of 'weather_cubit.dart';

typedef TemperatureM = ({double? celsius, double? fahrenheit, double? kelvin});
typedef LogLatM = ({double? log, double? lat});
typedef WeatherM = ({String? icon, String? main});

@immutable
sealed class WeatherState {}

final class WeatherInitial extends WeatherState {}

final class WeatherLoading extends WeatherState {}

final class WeatherLoaded extends WeatherState {
  WeatherLoaded({
    required this.temperature,
    required this.logLat,
    required this.weather,
    required this.country,
    required this.date,
  });

  final TemperatureM temperature;
  final LogLatM logLat;
  final WeatherM weather;
  final String? country;
  final DateTime? date;
}

final class WeatherError extends WeatherState {
  WeatherError({this.errorMessage});

  final String? errorMessage;
}
