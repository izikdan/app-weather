import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'test.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

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
      home: CityDefinition(),
    );
  }
}

class CityDefinition extends StatefulWidget {
  const CityDefinition({super.key});

  @override
  State<CityDefinition> createState() => _CityDefinitionState();
}

class _CityDefinitionState extends State<CityDefinition> {
  final _db = FirebaseDatabase.instance.ref('users').child('user');
  final _searchController = TextEditingController();
  String? _selectedCity;

  void _searchUser(String searchTerm) async {
  final snapshot = await _db.orderByChild('email').equalTo(searchTerm).get();
  if (snapshot.exists && snapshot.value != null) {
final userData = Map<dynamic, dynamic>.from(snapshot.value as Map);
    // מניחים שנמצא משתמש יחיד
    if (userData.isNotEmpty) {
      final dynamic firstKey = userData.keys.first;
      final dynamic user = userData[firstKey];
      final String cityName = user['city_name'];
      setState(() {
        _selectedCity = cityName;
      });
    }
  } else {
    print('משתמש לא נמצא');
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('משתמשים'),
      ),
      body: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration:
                const InputDecoration(labelText: 'חיפוש שם משתמש או אימייל'),
            onSubmitted: _searchUser,
          ),
          const SizedBox(height: 16.0),
          if (_selectedCity != null) Text('העיר שבחר המשתמש: $_selectedCity'),
          if (_selectedCity == null) const Text('לא נמצאה עיר'),
          ElevatedButton(
            onPressed: () {
              _searchUser(_searchController.text);
            },
            child: const Text('חיפוש'),
          ),
        ],
      ),
    );
  }
}
