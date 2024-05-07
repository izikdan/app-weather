import 'package:flutter/material.dart';
import 'Services/notifi_service.dart';
import 'Weather.dart';
// import 'home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationService().initNotification();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Notifications',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // home: const MyHomePage(title: 'Flutter Local notification2'),
      home:  const FirstPage(title: 'תחזית מזג באוויר',city: '',),
    );
  }
}
