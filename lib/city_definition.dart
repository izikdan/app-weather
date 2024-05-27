import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'test.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'login.dart'

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const CityDefinition());
}

class CityDefinition extends StatefulWidget {
  const CityDefinition({super.key});

  @override
  State<CityDefinition> createState() => _CityDefinitionState();
}

class _CityDefinitionState extends State<CityDefinition> {
  var cityController = TextEditingController();
  @override
  void dispose() {
    cityController.dispose();
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
                        labelText: ' הגדר עיר קבועה',
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (cityController.text.isNotEmpty) {
                        // FirebaseAuth.instance
                        //     .createUserWithEmailAndPassword(
                        //         email: "email", password: "password")
                        //     .then((userCredential) {
                        // UID זמין עכשיו ב- userCredential.user.uid
                        // שמירת שם העיר ב-Realtime Database
                        //   var uid = userCredential.user?.uid;
                        //   var userCity = "העיר שהמשתמש בחר";
                        //   FirebaseDatabase.instance.ref("users/$uid").set({
                        //     'city_name': userCity,
                        //   });
                        // }).catchError((error) {
                        //   // טיפול בשגיאה
                        // });
                        final db = FirebaseDatabase.instance.ref('users/user/');
                        // .child('user/$uid');

                        // final foundUsersQuerySnapshot = await FirebaseDatabase
                        //     .instance
                        //     .ref("Users")
                        //     .orderByChild("uid")
                        //     .equalTo(924027678)
                        //     .limitToFirst(1)
                        //     .once();
                        // foundUsersQuerySnapshot.update({"city_name":"jerusalem"});
                        db.child('city_name').set(cityController.text);
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PermenentPage(
                            title: 'תחזית מזג אוויר',
                            city: 'city',
                          ),
                        ),
                      );
                    },
                    child: const Text('התחבר'),
                  ),
                ]))));
  }
}
