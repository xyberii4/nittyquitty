import 'package:flutter/material.dart';
import 'noti_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final notiService = NotiService();
  await notiService.initNotification(); // Initialize and start all notifications

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notifications Demo")),
      body: const Center(
        child: Text(
          "🧠 Notifications running in background.\n\n8AM Motivation\n9PM Reminder\n+ Smart Alerts",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
