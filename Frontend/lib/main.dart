import 'package:flutter/material.dart';
import 'package:nittyquitty/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/landing_screen.dart';
import 'noti_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final prefs = await SharedPreferences.getInstance();
  bool staySignedIn = prefs.getBool('staySignedIn') ?? true;
  bool isLoggedIn = prefs.containsKey('user_id');

  Widget startScreen;

  if (staySignedIn && isLoggedIn) {
    startScreen = HomeScreen();
  } else {
    startScreen = LandingScreen();
  }

  final notiService = NotiService();
  await notiService.initNotification(); // Initialize and start all notifications

  runApp(MyApp(startScreen: startScreen));
}

class MyApp extends StatelessWidget {
  final Widget startScreen;

  MyApp({super.key, Widget? startScreen})
      : startScreen = startScreen ?? LandingScreen();
      // default to LandingScreen() if no value is provided

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: startScreen,
    );
  }
}
