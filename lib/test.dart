import 'dart:async';
// import 'dart:convert';
import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:localstorage/localstorage.dart';
import 'package:local_notification_app_demo/Services/notifi_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_database/firebase_database.dart';
import 'weather_api.dart';
import 'login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
          backgroundColor: Color.fromARGB(255, 179, 238, 244),
        ),
      ),
      home: const PermenentPage(title: 'תחזית מזג האוויר', city: 'city'),
    );
  }
}

class PermenentPage extends StatefulWidget {
  const PermenentPage({super.key, required this.title, required this.city});
  final String title;
  final String city;

  @override
  State<PermenentPage> createState() => _PermenentPageState();
}

class _PermenentPageState extends State<PermenentPage> {
  late Future<Map<String, dynamic>> futureWeather;
  @override
  void initState() {
    super.initState();
    _scheduleDailyCityLoad();
  }

  void _scheduleDailyCityLoad() async {
    // קבל את השעה הנוכחית
    var now = DateTime.now();

    // חשב את הזמן עבור הופעת 8 בבוקר הבאה
    var targetTime = DateTime(now.year, now.month, now.day, 17, 53, 0);

    // בדוק אם זמן היעד כבר חלף עבור היום הנוכחי
    if (targetTime.isBefore(now)) {
      // אם חלף, חשב את הזמן עבור היום הבא
      targetTime = targetTime.add(const Duration(days: 1));
    }

    // צור טיימר להפעלת משימת טעינת העיר בזמן היעד
    Timer(targetTime.difference(now), () async {
      final db = FirebaseDatabase.instance.ref();
      final snapshot = await db.child('city_name').get(); 
      if (snapshot.exists) {
        final cityName = snapshot.value.toString(); 
        final weatherData = await fetchWeather(cityName); 
        final temperature = weatherData['main']['temp']; 

        NotificationService().showNotification(
          title: ' תחזית מזג אוויר : \n ${_getClothingAdvice(temperature)}',
          body:
              ' $cityName: טמפרטורה ל \n ${temperature.toStringAsFixed(1)} מעלות ',
        );
        // תזמן מחדש את המשימה עבור היום הבא בתוך קוד ההחזרה של הטיימר
        _scheduleDailyCityLoad();
      }
    });
  }

  String _getClothingAdvice(double temperature) {
    if (temperature < 20) {
      return "מזג האוויר קריר - כדאי להתלבש חם";
    } else if (temperature > 25) {
      return "מזג האוויר חם - כדאי להתלבש קיצי";
    } else {
      return "מזג האוויר נעים - התלבש כרצונך";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.purple, width: 10),
          color: const Color.fromARGB(255, 210, 231, 162),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          StreamBuilder(
            stream: FirebaseDatabase.instance.ref().child('city_name').onValue,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
                String cityName = snapshot.data!.snapshot.value.toString();
                return FutureBuilder<Map<String, dynamic>>(
                  future: fetchWeather(cityName),
                  builder: (context, weatherSnapshot) {
                    if (weatherSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (weatherSnapshot.hasData) {
                      return Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 178, 243, 247),
                            border: Border.all(
                                color: Colors.purple,
                                width: 5,
                                style: BorderStyle.solid),
                            borderRadius: BorderRadius.circular(30)),
                        child: Column(
                          children: [
                            Text(
                              cityName,
                              style: const TextStyle(
                                  fontSize: 34, color: Colors.purple),
                            ),
                            Text(
                              '${weatherSnapshot.data!['main']['temp']}°C :טמפרטורה   ',
                              style: const TextStyle(
                                  fontSize: 20, color: Colors.blue),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return const Text("Error getting weather information");
                    }
                  },
                );
              } else {
                return const Text('טרם הוגדרה עיר');
              }
            },
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const FirstPage(
                            title: '',
                            city: '',
                          )));
            },
            child: const Text('חפש עיר'),
          ),
        ]));
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
  var cityController = TextEditingController();
  var cityController2 = TextEditingController();

  @override
  void dispose() {
    cityController.dispose();
    cityController2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('תחזית מזג האוויר'),
        ),
        body: Container(
          decoration: BoxDecoration(
              border: Border.all(color: Colors.purple, width: 10),
              color: const Color.fromARGB(255, 210, 231, 162),
              borderRadius: BorderRadius.circular(30)),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.symmetric(),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 181, 255, 254),
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
                    color: const Color.fromARGB(255, 181, 255, 254),
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
                  onPressed: () {
                    final db = FirebaseDatabase.instance.ref();
                    db.child('city_name').set(cityController2.text);
                  },
                  child: const Text('הגדר עיר'),
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
            ),
          ),
        ));
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
  @override
  void initState() {
    super.initState();
    futureWeather = fetchWeather(widget.city);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Container(
          decoration: BoxDecoration(
              border: Border.all(color: Colors.purple, width: 5),
              color: const Color.fromARGB(255, 210, 231, 162),
              borderRadius: BorderRadius.circular(30)),
          child: Center(
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
                      var iconUrl =
                          'http://openweathermap.org/img/w/$iconCode.png';

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
        ));
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
      body: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.purple, width: 10),
          color: const Color.fromARGB(255, 210, 231, 162),
        ),
        child: Center(
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context);
        },
        tooltip: ('!חזור'),
        child: const Icon(Icons.backup_table),
      ),
    );
  }
}
