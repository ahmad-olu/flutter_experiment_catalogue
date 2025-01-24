import 'package:auto_route/auto_route.dart';
import 'package:experiment_catalogue/applications/02_weather/cubit/weather_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class Weather02Page extends StatelessWidget {
  const Weather02Page({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WeatherCubit()..getWeather('Lagos'),
      child: const WeatherView(),
    );
  }
}

class WeatherView extends StatelessWidget {
  const WeatherView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<WeatherCubit, WeatherState>(
              builder: (context, state) {
                return switch (state) {
                  WeatherInitial() || WeatherLoading() => const Center(
                      child: Text('No Data to show... Or Loading'),
                    ),
                  WeatherLoaded(
                    temperature: final temp,
                    logLat: final logLat,
                    weather: final weather,
                    country: final country,
                    date: final date,
                  ) =>
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${temp.celsius?.toStringAsFixed(1)}°C',
                          style: const TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          getWeatherEmoji(weather.icon ?? ''),
                          style: const TextStyle(
                            fontSize: 70,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          weather.main ?? '',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          date?.toIso8601String() ?? 'Unknown Date',
                          style: const TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          country ?? 'Unknown Country',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${logLat.lat}°N, ${logLat.log}°E',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  WeatherError(errorMessage: final message) => Center(
                      child: Text('Error Occurred: $message'),
                    ),
                };
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: WeatherTextInput(),
          ),
        ],
      ),
    );
  }
}

class WeatherTextInput extends StatefulWidget {
  const WeatherTextInput({super.key});

  @override
  _WeatherTextInputState createState() => _WeatherTextInputState();
}

class _WeatherTextInputState extends State<WeatherTextInput> {
  final textController = TextEditingController(text: '');

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: textController,
              decoration: InputDecoration(
                labelText: 'Enter city name',
                hintText: 'e.g., London',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                prefixIcon: const Icon(Icons.search),
              ),
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () =>
                context.read<WeatherCubit>().getWeather(textController.text),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: const Text('Submit'),
          )
        ],
      ),
    );
  }
}

String getWeatherEmoji(String iconCode) {
  switch (iconCode) {
    case '01d':
      return '☀️';
    case '01n':
      return '🌙';
    case '02d':
      return '🌤️';
    case '02n':
      return '🌙☁️';
    case '03d':
    case '03n':
      return '☁️';
    case '04d':
    case '04n':
      return '☁️';
    case '09d':
    case '09n':
      return '🌧️';
    case '10d':
    case '10n':
      return '🌦️';
    case '11d':
    case '11n':
      return '⛈️';
    case '13d':
    case '13n':
      return '❄️';
    case '50d':
    case '50n':
      return '🌫️';
    default:
      return '❓'; // Unknown code
  }
}
