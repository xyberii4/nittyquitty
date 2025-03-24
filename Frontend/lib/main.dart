import 'package:flutter/material.dart';
import 'screens/landing_screen.dart'; // Import the HomeScreen
import 'noti_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final notiService = NotiService();
  await notiService.initNotification(); // Initialize and start all notifications

  runApp( MyApp());
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