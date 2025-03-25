import 'package:domasna/screens/home_screen.dart';
import 'package:domasna/screens/map_screen.dart';
import 'package:domasna/screens/profile_screen.dart';
import 'package:domasna/screens/sign_in_screen.dart';
import 'package:domasna/screens/sign_up_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const ChillSpotApp());
}

class ChillSpotApp extends StatelessWidget {
  const ChillSpotApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        fontFamily: 'Montserrat',
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
          bodyMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
          bodySmall: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
          headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => ChillSpotHome(),
        '/sign_in': (context) => SignInScreen(),
        '/sign_up': (context) => SignUpScreen(),
        '/profile': (context) => ProfileScreen(),
        '/map': (context) => MapScreen(),
      },
    );
  }
}
