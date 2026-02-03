import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'weather_model.dart';

class WeatherService {
  String city = 'Mumbai';

  void updateCity(String newCity) {
    city = newCity;
  }

  String get apiKey {
    final key = dotenv.env['WEATHER_API'];
    if (key == null) {
      throw Exception('WEATHER_API key not found in .env file');
    }
    return key;
  }

  Future<Weather> fetchWeather() async {
    final url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=$apiKey&units=metric',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Weather.fromJson(data);
    } else {
      throw Exception('Failed to load weather data.');
    }
  }

  //Hourly Forecast
  Future<List<Map<String, dynamic>>> fetchHourlyForecast() async {
    final url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=$apiKey&units=metric',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      List list = data['list'];
      int timeZoneOffSet = data['city']['timezone'];

      List<Map<String, dynamic>> filtered = [];

      List<Map<String, dynamic>> converted = list.map<Map<String, dynamic>>((
        item,
      ) {
        int dt = item['dt'];

        DateTime utcTime = DateTime.fromMillisecondsSinceEpoch(
          dt * 1000,
          isUtc: true,
        );

        DateTime localTime = utcTime.add(Duration(seconds: timeZoneOffSet));

        return {
          'hour': localTime.hour,
          'temperature': (item['main']['temp'] as num).toDouble(),
          'condition': item['weather'][0]['main'],
        };
      }).toList();

      int startIndex = converted.indexWhere((e) => e['hour'] == 8);

      if (startIndex == -1) startIndex = 0;

      for (
        int i = startIndex;
        i < startIndex + 9 && i < converted.length;
        i++
      ) {
        filtered.add({
          'time': converted[i]['hour'].toString(),
          'temperature': converted[i]['temperature'],
          'condition': converted[i]['condition'],
        });
      }

      return filtered;
    } else {
      throw Exception("Failed to load hourly forecast");
    }
  }

  Future<Weather> fetchWeatherByLocation(double lat, double lon) async {
    final url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Weather.fromJson(data);
    } else {
      throw Exception("Failed to load weather by location.");
    }
  }

  Future<List<Map<String, dynamic>>> fetchHourlyForecastByLocation(
    double lat,
    double lon,
  ) async {
    final url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      List list = data['list'];
      int timeZoneOffSet = data['city']['timezone'];

      List<Map<String, dynamic>> filtered = [];

      for (int i = 0; i < list.length && i < 8; i++) {
        final item = list[i];

        int dt = item['dt'];
        DateTime utcTime = DateTime.fromMillisecondsSinceEpoch(
          dt * 1000,
          isUtc: true,
        );
        DateTime localTime = utcTime.add(Duration(seconds: timeZoneOffSet));

        filtered.add({
          'time': localTime.hour.toString(),
          'temperature': (item['main']['temp'] as num).toDouble(),
          'condition': item['weather'][0]['main'],
        });
      }

      return filtered;
    } else {
      throw Exception("Failed to load hourly forecast by location");
    }
  }
}
