import 'package:bloc/bloc.dart';
import 'package:experiment_catalogue/app/env.dart';
import 'package:meta/meta.dart';
import 'package:weather/weather.dart';

part 'weather_state.dart';

class WeatherCubit extends Cubit<WeatherState> {
  WeatherCubit() : super(WeatherInitial());

  Future<void> getWeather(String cityName) async {
    emit(WeatherLoading());
    try {
      final wf = WeatherFactory(openWeatherApi);
      final w = await wf.currentWeatherByCityName(cityName);
      // final forcast = await wf.fiveDayForecastByCityName(cityName);
      final temperature = w.temperature;
      final logLat = (log: w.longitude, lat: w.latitude);
      final weather = (icon: w.weatherIcon, main: w.weatherMain);

//forcast.map((e)=>e.).toList()

      emit(
        WeatherLoaded(
          temperature: (
            celsius: temperature?.celsius,
            fahrenheit: temperature?.fahrenheit,
            kelvin: temperature?.kelvin
          ),
          logLat: logLat,
          weather: weather,
          country: w.country,
          date: w.date,
        ),
      );
    } catch (e) {
      emit(WeatherError(errorMessage: e.toString()));
    }
  }
}
