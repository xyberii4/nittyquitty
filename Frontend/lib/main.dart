import 'package:flutter/material.dart';
import 'screens/landing_screen.dart'; // Import the HomeScreen

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LandingScreen(), // Set the LandingPage as the starting page
    );
  }
}