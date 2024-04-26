import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:logger/logger.dart';

var logger = Logger();

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({Key? key}) : super(key: key);

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  String _location = 'Loading location...';
  String _temperature = '';
  String _weatherDescription = '';
  String _wind = '';
  String _humidity = '';
  String _precipitation = '';
  String _weatherIcon = '';
  List<dynamic> _forecastData = [];

  final Location location = Location();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _checkLocationService();
    _fetchCurrentLocationAndWeather();
    _fetchForecastData();
    _startPeriodicWeatherUpdates();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _checkLocationService() async {
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        setState(() => _location = 'Location services are disabled.');
        return;
      }
    }
    _checkPermission();
  }

  void _checkPermission() async {
    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        setState(() => _location = 'Location permission denied.');
        return;
      }
    }
    _fetchCurrentLocationAndWeather();
  }

  void _startPeriodicWeatherUpdates() {
    _timer = Timer.periodic(const Duration(minutes: 30),
        (Timer t) => _fetchCurrentLocationAndWeather());
  }

  void _fetchCurrentLocationAndWeather() async {
    var currentLocation = await location.getLocation();
    _fetchWeather(currentLocation.latitude!, currentLocation.longitude!);
  }

  Future<void> _fetchWeather(double latitude, double longitude) async {
    try {
      var url = Uri.parse(
          'https://c8c4-178-62-65-5.ngrok-free.app/weather?action=1&lat=$latitude&lon=$longitude');
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var weatherData = jsonDecode(response.body);
        if (!mounted) return;
        setState(() {
          _location =
              '${weatherData['name']}, ${weatherData['sys']['country']}';
          _temperature =
              '${double.parse(weatherData['main']['temp'].toString()).toStringAsFixed(1)}°C';
          _weatherDescription =
              _capitalizeWords(weatherData['weather'][0]['description']);
          _weatherIcon = _getWeatherIcon(weatherData['weather'][0]['main']);
          _wind = 'Wind: ${weatherData['wind']['speed']} m/s';
          _humidity = 'Humidity: ${weatherData['main']['humidity']}%';
          _precipitation = weatherData.containsKey('rain')
              ? 'Precip: ${weatherData['rain']['1h']} mm'
              : 'Precip: None';
        });
      } else {
        throw Exception(
            'Failed to load weather data with status code: ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _location = 'Failed to load weather data. Error: $e';
      });
    }
  }

  Future<void> _fetchForecastData() async {
    var currentLocation = await location.getLocation();
    var url = Uri.parse(
        'https://c8c4-178-62-65-5.ngrok-free.app/weather?action=2&lat=${currentLocation.latitude}&lon=${currentLocation.longitude}');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var forecastData = jsonDecode(response.body);
      if (!mounted) return;
      setState(() {
        _forecastData = forecastData['list'];
      });
    } else {
      logger.i('Failed to load forecast data');
    }
  }

  String _capitalizeWords(String input) {
    return input
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  String _getWeatherIcon(String main) {
    switch (main.toLowerCase()) {
      case 'clear':
        return '☀️';
      case 'clouds':
        return '☁️';
      case 'rain':
        return '🌧️';
      case 'snow':
        return '❄️';
      case 'drizzle':
        return '🌦️';
      case 'thunderstorm':
        return '⛈️';
      default:
        return '🌫️'; // Default to fog for other cases
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather'),
        backgroundColor: Colors.blueGrey[900],
      ),
      body: buildBody(),
    );
  }

  Widget buildBody() {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blueGrey[800]!, Colors.blueGrey[900]!],
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(_location,
                style: const TextStyle(
                    fontSize: 28.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_temperature,
                    style: const TextStyle(
                        fontSize: 60.0,
                        fontWeight: FontWeight.w300,
                        color: Colors.white)),
              ],
            ),
            Text(_weatherIcon, style: const TextStyle(fontSize: 48)),
            Text(_weatherDescription,
                style: const TextStyle(fontSize: 24.0, color: Colors.white)),
            const SizedBox(height: 20),
            Text(_wind,
                style: const TextStyle(fontSize: 16.0, color: Colors.white70)),
            Text(_humidity,
                style: const TextStyle(fontSize: 16.0, color: Colors.white70)),
            Text(_precipitation,
                style: const TextStyle(fontSize: 16.0, color: Colors.white70)),
            const SizedBox(height: 20),
            const Text("Every 3-hours Forecast",
                style: TextStyle(
                    fontSize: 22.0,
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
            _buildForecastList(),
          ],
        ),
      ),
    );
  }

  Widget _buildForecastList() {
    return Column(
      children: _forecastData.map((entry) {
        return ListTile(
          title: Text(_capitalizeWords(entry['weather'][0]['description']),
              style: const TextStyle(color: Colors.white)),
          subtitle: Text(
              'Temp: ${entry['main']['temp'].toString()}°C at ${entry['dt_txt']}',
              style: const TextStyle(color: Colors.white70)),
          leading: Text(_getWeatherIcon(entry['weather'][0]['main']),
              style: const TextStyle(fontSize: 24)),
          trailing: Text('Wind: ${entry['wind']['speed'].toString()} m/s',
              style: const TextStyle(color: Colors.white70)),
        );
      }).toList(),
    );
  }
}
