import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/home-dino.dart';
import 'auth/login-dino.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp_dino());
}

class MyApp_dino extends StatelessWidget {
  const MyApp_dino({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CinemaPro',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins',
        textTheme: Theme.of(context).textTheme,
      ),
      debugShowCheckedModeBanner: false,
      home: const initialScreen_dino(),
    );
  }
}

class initialScreen_dino extends StatelessWidget {
  const initialScreen_dino({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: SharedPreferences.getInstance().then(
        (prefs) => prefs.getString('user_uid'),
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData &&
            snapshot.data != null &&
            snapshot.data!.isNotEmpty) {
          return const HomePage_dino();
        }
        return const LoginPage_dino();
      },
    );
  }
}
