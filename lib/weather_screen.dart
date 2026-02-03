import 'dart:ui';
import 'package:geolocator/geolocator.dart';

import 'package:flutter/material.dart';
import 'package:weather_app/weather_model.dart';
import 'package:weather_app/weather_service.dart';
import 'package:weather_app/hourly_forecast_item.dart' show HourlyForecastItem;
import 'package:weather_app/additional_info_item.dart' show AdditionalInfoItem;

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _cityController = TextEditingController();

  final WeatherService _service = WeatherService();
  late Future<Weather> weatherFuture;
  late Future<List<Map<String, dynamic>>> hourlyFuture;

  Future<void> _getCurrentLocationWeather() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location services are disabled!")),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permission permanently denied')),
      );
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );

    if (!mounted) return;
    setState(() {
      weatherFuture = _service.fetchWeatherByLocation(
        position.latitude,
        position.longitude,
      );
      hourlyFuture = _service.fetchHourlyForecastByLocation(
        position.latitude,
        position.longitude,
      );
    });
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  IconData getWeatherIcon(String condition) {
    switch (condition) {
      case 'Clear':
        return Icons.wb_sunny;
      case 'Clouds':
        return Icons.cloud;
      case 'Rain':
        return Icons.umbrella;
      case 'Drizzle':
        return Icons.grain;
      case 'Thunderstorm':
        return Icons.flash_on;
      case 'Snow':
        return Icons.ac_unit;
      case 'Mist':
      case 'Haze':
      case 'Fog':
        return Icons.blur_on;
      default:
        return Icons.cloud;
    }
  }

  @override
  void initState() {
    super.initState();
    weatherFuture = _service.fetchWeather();
    hourlyFuture = _service.fetchHourlyForecast();
  }

  String formatTime(int hour) {
    if (hour == 0) return "12 AM";
    if (hour < 12) return "$hour AM";
    if (hour == 12) return "12 PM";
    return "${hour - 12} PM";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Weather',
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontStyle: FontStyle.normal,
            fontWeight: FontWeight.w400,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _getCurrentLocationWeather,
            icon: const Icon(Icons.my_location),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                weatherFuture = _service.fetchWeather();
                hourlyFuture = _service.fetchHourlyForecast();
              });
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
        centerTitle: true,
      ),

      body: FutureBuilder<Weather>(
        future: weatherFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error : ${snapshot.error}"));
          } else if (!snapshot.hasData) {
            return const Text("No weather data");
          }

          final weather = snapshot.data!;

          return SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      elevation: 30,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            child: TextField(
                              controller: _cityController,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                              ),
                              textAlignVertical: TextAlignVertical.center,

                              decoration: const InputDecoration(
                                hintText: "Search city...",
                                prefixIcon: Icon(Icons.search),
                                border: InputBorder.none, // important
                              ),
                              onSubmitted: (value) {
                                if (value.isNotEmpty) {
                                  setState(() {
                                    _service.updateCity(value);
                                    weatherFuture = _service.fetchWeather();
                                    hourlyFuture = _service
                                        .fetchHourlyForecast();
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,

                      child: Card(
                        elevation: 30,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.location_on, size: 18),
                                      const SizedBox(width: 4),
                                      Text(
                                        weather.cityName,
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 8),

                                  Text(
                                    '${weather.temperature} °C',
                                    style: const TextStyle(
                                      fontSize: 35,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Icon(
                                    getWeatherIcon(weather.condition),
                                    size: 50,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    weather.description,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),

                                  const SizedBox(height: 10),
                                  const Text(
                                    'Current Weather',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Weather Forecast',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 2),
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: hourlyFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text("Hourly error: ${snapshot.error}");
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Text("No hourly forecast available");
                        }

                        final filtered = snapshot.data!;

                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: filtered.map((hourData) {
                              int hour = int.parse(hourData["time"]);
                              String displayTime = formatTime(hour);

                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: HourlyForecastItem(
                                  time: displayTime,
                                  icon: getWeatherIcon(hourData['condition']),
                                  temperature: "${hourData["temperature"]} °C",
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    Text(
                      'Additional Information',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          AdditionalInfoItem(
                            icon: Icons.water_drop,
                            label: 'Humidity',
                            value: '${weather.humidity} %',
                          ),

                          SizedBox(width: 8),

                          AdditionalInfoItem(
                            icon: Icons.air,
                            label: 'Wind Speed',
                            value: '${weather.windSpeed} m/s',
                          ),

                          SizedBox(width: 8),
                          AdditionalInfoItem(
                            icon: Icons.compress,
                            label: 'Pressure',
                            value: '${weather.pressure} hPa',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
