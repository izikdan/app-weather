import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'test.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'cityDefiniyion.dart';

import 'city_definition.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const LoginPage());
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  final _emailController = TextEditingController();
  final _cityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('התחברות'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'שם'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return ' נא למלא שם';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _numberController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'טלפון'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return ' נא למלא מספר טלפון';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'אימייל '),
                validator: (value) {
                  if (value!.isEmpty) {
                    return ' נא לרשום אימייל';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _cityController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'סיסמה '),
                validator: (value) {
                  if (value!.isEmpty) {
                    return ' נא לרשום סיסמה';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32.0),
              ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final db =
                          FirebaseDatabase.instance.ref('users').child('user');
                      final uid = UniqueKey().hashCode;
                      final updates = {
                        'uid': uid,
                        'first_name': _nameController.text,
                        'last_name': _numberController.text,
                        'email': _emailController.text,
                        'city_name': _cityController.text
                      };
                      db.push().set(updates);
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CityDefinition()),
                    );
                  },
                  child: const Text('התחבר')),
            ],
          ),
        ),
      ),
    );
  }
}
