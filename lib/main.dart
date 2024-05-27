import 'package:flutter/material.dart';
import 'Services/notifi_service.dart';
// import 'Weather.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'test.dart';
import 'login.dart';
// import 'home_page.dart';

void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
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
      home:  const LoginPage(),
    );
  }
}
