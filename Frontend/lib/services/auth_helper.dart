import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:nittyquitty/screens/home_screen.dart';

// If successful, store user_id in SharedPreferences and navigate to HomeScreen
// If fail, show a SnackBar error

Future<void> attemptLogin(BuildContext context, String username, String password) async {
  final loginUrl = Uri.parse('http://34.105.133.181:8080/user/login');
  try {
    final response = await http.post(
      loginUrl,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"username": username, "password": password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data.containsKey("user_id")) {
        int userId = data["user_id"];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt("user_id", userId);
        await prefs.setBool("notificationsEnabled", true);
        await prefs.setBool("staySignedIn", true);

        if (!Navigator.canPop(context)) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
        return;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login failed: user_id not found.")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login failed. Error: ${response.body}")),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error connecting to server: $e")),
    );
  }
}
