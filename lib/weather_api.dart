import 'dart:convert';
   import 'package:http/http.dart' as http;
import 'dart:async';

Future<Map<String, dynamic>> fetchWeather(String city) async {
    final response = await http.get(Uri.parse(
        // add private permission
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=9448ab20206f11d8e5b397cd1ab0b599&units=metric'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load weather data');
    }
  }
