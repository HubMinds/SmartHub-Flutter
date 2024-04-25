import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

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

  final Location location = Location();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _checkLocationService();
    _fetchCurrentLocationAndWeather(); // Fetch immediately on app start.
    _startPeriodicWeatherUpdates(); // Then start the periodic updates.
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _checkLocationService() async {
    bool _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        setState(() => _location = 'Location services are disabled.');
        return;
      }
    }
    _checkPermission();
  }

  void _checkPermission() async {
    PermissionStatus _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        setState(() => _location = 'Location permission denied.');
        return;
      }
    }
    _fetchCurrentLocationAndWeather(); // Also fetch weather after permission is granted.
  }

  void _startPeriodicWeatherUpdates() {
    _timer = Timer.periodic(
        Duration(minutes: 30), (Timer t) => _fetchCurrentLocationAndWeather());
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
          _temperature = '${weatherData['main']['temp']}°C';
          _weatherDescription = weatherData['weather'][0]['description'];
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather in Your Location'),
        backgroundColor: Colors.blueGrey[900],
        elevation: 0,
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
                style: TextStyle(
                    fontSize: 28.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            SizedBox(height: 10),
            Text(_temperature,
                style: TextStyle(
                    fontSize: 60.0,
                    fontWeight: FontWeight.w300,
                    color: Colors.white)),
            Text(_weatherDescription,
                style: TextStyle(fontSize: 24.0, color: Colors.white)),
            SizedBox(height: 20),
            Text(_wind,
                style: TextStyle(fontSize: 16.0, color: Colors.white70)),
            Text(_humidity,
                style: TextStyle(fontSize: 16.0, color: Colors.white70)),
            Text(_precipitation,
                style: TextStyle(fontSize: 16.0, color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}
