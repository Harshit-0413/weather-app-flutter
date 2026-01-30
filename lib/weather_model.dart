class Weather {
  final double temperature;
  final double humidity;
  final double windSpeed;
  final int pressure;
  final String condition;
  final String cityName;
  final String description;

  Weather({
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.pressure,
    required this.condition,
    required this.cityName,
    required this.description,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    final current = json['list'][0];

    return Weather(
      temperature: (current["main"]["temp"] as num).toDouble(),
      humidity: (current["main"]["humidity"] as num).toDouble(),
      pressure: current["main"]["pressure"],
      windSpeed: (current["wind"]["speed"] as num).toDouble(),
      condition: current['weather'][0]['main'],
      cityName: json['city']['name'],
      description: current['weather'][0]['description'],
    );
  }
}
