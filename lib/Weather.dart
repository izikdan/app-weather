 ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';
import 'package:local_notification_app_demo/Services/notifi_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'תחזית מזג האוויר',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          titleTextStyle:
              TextStyle(color: Color.fromARGB(255, 31, 15, 34), fontSize: 24),
          backgroundColor: Color.fromARGB(255, 223, 125, 199),
        ),
      ),
      home: const FirstPage(title: 'תחזית מזג האוויר', city: 'city'),
    );
  }
}

class FirstPage extends StatefulWidget {
  const FirstPage({super.key, required this.title, required this.city});
  final String title;
  final String city;

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  var cityController2 = TextEditingController();

  var localStorage = LocalStorage('saved_city');
  var cityController = TextEditingController();

  @override
  void initState() {
    futureWeather = fetchWeather(widget.city);
    futureWeather.then((data) =>
        setState(() => weatherData = data)); // Update weatherData after fetch
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _loadCityFromLocalStorage();
      _scheduleDailyCityLoad();
      _getClothingAdvice();
      didChangeDependencies();
    });
  }

  Future<String> fetchExample() async {
    final url = Uri.parse('http://10.0.2.2:3000'); //בשביל כרום צריך לרשום localhost:3000
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = response.body;
      return data;
    } else {
      print('שגיאה: ${response.statusCode}');
      throw Exception('נכשל באחזור נתונים');
    }
  }

  String _getClothingAdvice() {
    if (weatherData != null) {
      final temperature = weatherData!['main']['temp'];
      if (temperature < 20) {
        return "מזג האוויר קריר - כדאי להתלבש חם";
      } else if (temperature > 25) {
        return "מזג האוויר חם - כדאי להתלבש קיצי";
      } else {
        return "מזג האוויר נעים - התלבש כרצונך";
      }
    } else {
      return "טוען נתוני מזג אוויר...";
    }
  }

  void _updateLocalStorageWithCityData(String city) async {
    if (city.isNotEmpty) {
      await localStorage.setItem('city', city);
    }
  }

  Future<dynamic> _loadCityFromLocalStorage() async {
    final savedCity = await localStorage.getItem('city');
    if (savedCity != null) {
      setState(() {
        cityController.text = savedCity;
        if (weatherData != null) {
          // Access weather data here
          double temperature =
              weatherData!['main']['temp']; // Extract temperature
          NotificationService().showNotification(
            title: ' תחזית מזג אוויר : \n ${_getClothingAdvice()}',
            body:
                '   טמפרטורה ל : $savedCity \n ${temperature.toStringAsFixed(1)} מעלות ',
          );
        }
        futureWeather = fetchWeather(savedCity); // עדכון futureWeather
      });
    }
    final fetchedCity = await fetchExample();
    if (fetchedCity.isNotEmpty) {
      _updateLocalStorageWithCityData(fetchedCity);
      fetchWeather(fetchedCity); // עדכן אחסון מקומי
    }
  }

  late Future<Map<String, dynamic>> futureWeather;
  Map<String, dynamic>? weatherData;
  Future<Map<String, dynamic>> fetchWeather(String city) async {
    final getCity = await fetchExample();
    if (city == "") {
      city = getCity;
    }
    final response = await http.get(Uri.parse(
      //add private permission
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=9448ab20206f11d8e5b397cd1ab0b599&units=metric'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load weather data2');
    }
  }

  void _scheduleDailyCityLoad() async {
    // קבל את השעה הנוכחית
    var now = DateTime.now();

    // חשב את הזמן עבור הופעת 8 בבוקר הבאה
    var targetTime = DateTime(now.year, now.month, now.day, 01, 26, 0);

    // בדוק אם זמן היעד כבר חלף עבור היום הנוכחי
    if (targetTime.isBefore(now)) {
      // אם חלף, חשב את הזמן עבור היום הבא
      targetTime = targetTime.add(const Duration(days: 1));
    }

    // צור טיימר להפעלת משימת טעינת העיר בזמן היעד
    Timer(targetTime.difference(now), () async {
      _loadCityFromLocalStorage();
      // תזמן מחדש את המשימה עבור היום הבא בתוך קוד ההחזרה של הטיימר
      _scheduleDailyCityLoad();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('תחזית מזג האוויר'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.symmetric(),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 223, 125, 199),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: cityController,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  labelText: 'הקלד את שם העיר',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyHomePage(
                      city: cityController.text,
                    ),
                  ),
                );
              },
              child: const Text('קבל תחזית'),
            ),
            Container(
              margin: const EdgeInsets.symmetric(),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 223, 125, 199),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: cityController2,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  labelText: 'הגדר עיר',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                String enteredCity = cityController2.text;
                _loadCityFromLocalStorage();
                if (enteredCity.isNotEmpty) {
                  await localStorage.setItem('city', enteredCity);
                } else {
                  print('Please enter a city name.');
                }
              },
              child: const Text('שמור עיר'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ListOfCities()),
                );
              },
              child: const Text('רשימת ערים'),
            ),
          ],
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String city;

  const MyHomePage({
    super.key,
    required this.city,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<Map<String, dynamic>> futureWeather;
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

  Future<Map<String, dynamic>> getWeather(String city) {
    return fetchWeather(city);
  }

  @override
  void initState() {
    super.initState();
    futureWeather = fetchWeather(widget.city);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FutureBuilder<Map<String, dynamic>>(
              future: futureWeather,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  var iconCode = snapshot.data!['weather'][0]['icon'];
                  var iconUrl = 'http://openweathermap.org/img/w/$iconCode.png';

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        '${snapshot.data!['name']} :עיר ',
                        style: const TextStyle(fontSize: 30),
                      ),
                      Image.network(
                        iconUrl,
                        width: 200,
                        height: 200,
                      ),
                      Text(
                        ' °C ${snapshot.data!['main']['temp']} :טמפרטורה',
                        style: const TextStyle(fontSize: 20),
                      ),
                      Text(
                        ' ${snapshot.data!['weather'][0]['description']} :תחזית',
                        style: const TextStyle(fontSize: 20),
                      ),
                      Text(
                        'מהירות הרוח: ${snapshot.data!['wind']['speed']} מטר לשניה',
                        style: const TextStyle(fontSize: 16),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ListOfCities()),
                          );
                        },
                        child: const Text('רשימת ערים'),
                      ),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ListOfCities extends StatefulWidget {
  const ListOfCities({super.key});

  @override
  State<ListOfCities> createState() => _ListOfCitiesState();
}

List<City> cities = [
  City(name: 'ירושלים'),
  City(name: "תל אביב"),
  City(name: "חיפה"),
  City(name: "באר שבע"),
  City(name: "חולון"),
  City(name: "נתניה"),
  City(name: "קרית גת"),
  City(name: "אשדוד"),
  City(name: "מודיעין"),
  City(name: "בני ברק"),
  City(name: "בת ים"),
  City(name: "צפת"),
  City(name: "חדרה"),
  City(name: "רעננה"),
  City(name: "ניו יורק"),
  City(name: "לונדון"),
  City(name: "פריז"),
  City(name: "רומא"),
  City(name: "ונציה"),
  City(name: "עזה"),
];

class City {
  final String name;
  City({required this.name});
}

int determineCrossAxisCount(BuildContext context) {
  final double screenWidth = MediaQuery.of(context).size.width;
  if (screenWidth >= 600) {
    return 2; // Two columns for larger screens
  } else {
    return 1; // One column for smaller screens
  }
}

class _ListOfCitiesState extends State<ListOfCities> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('רשימת ערים'),
      ),
      body: Center(
        child: GridView.count(
          crossAxisCount: determineCrossAxisCount(context),
          childAspectRatio: 6,
          children: cities.map((city) {
            return Card(
              child: ListTile(
                title: Text(city.name),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyHomePage(
                        city: city.name,
                      ),
                    ),
                  );
                },
              ),
            );
          }).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(
              context,
              MaterialPageRoute(
                  builder: (context) => const FirstPage(
                        title: '',
                        city: '',
                      )));
        },
        tooltip: ('!חזור'),
        child: const Icon(Icons.backup_table),
      ),
    );
  }
}