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
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool("notificationsEnabled", true);
      await prefs.setBool("staySignedIn", true);

      final data = jsonDecode(response.body);
      print(data);
      

      try {
        await prefs.setInt("user_id", data["user_id"]);
        print("[PREFERENCES] user_id data was set to ${data["user_id"]}");
        await prefs.setString("username", data["username"]);
        print("[PREFERENCES] username data was set to ${data["username"]}");
        await prefs.setBool("snus", data["snus"]);
        print("[PREFERENCES] snus data was set to ${data["snus"]}");
        await prefs.setInt("snus_weekly_usage", data["snus_weekly_usage"]);
        print("[PREFERENCES] snus_weekly_usage data was set to ${data["snus_weekly_usage"]}");
        await prefs.setInt("snus_strength", data["snus_strength"]);
        print("[PREFERENCES] snus_strength data was set to ${data["snus_strength"]}");
        await prefs.setBool("vape", data["vape"]);
        print("[PREFERENCES] vape data was set to ${data["vape"]}");
        await prefs.setInt("vape_weekly_usage", data["vape_weekly_usage"]);
        print("[PREFERENCES] vape_weekly_usage data was set to ${data["vape_weekly_usage"]}");
        await prefs.setInt("vape_strength", data["vape_strength"]);
        print("[PREFERENCES] vape_strength data was set to ${data["vape_strength"]}");
        await prefs.setBool("cigarette", data["cigarette"]);
        print("[PREFERENCES] cigarette data was set to ${data["cigarette"]}");
        await prefs.setInt("cig_weekly_usage", data["cig_weekly_usage"]);
        print("[PREFERENCES] cig_weekly_usage data was set to ${data["cig_weekly_usage"]}");
        await prefs.setDouble("goal", (data["goal"] as num).toDouble());
        if (data["goal_deadline"] != null) {
          await prefs.setString("goal_deadline", data["goal_deadline"].toString());
          print("[PREFERENCES] goal_deadline data was set to ${data["goal_deadline"]}");
        } else {
          print("[PREFERENCES] goal_deadline data was null in the first place");
        }
        await prefs.setDouble("weekly_spending", (data["weekly_spending"] as num).toDouble());
        print("[PREFERENCES] weekly_spending data was set to ${data["weekly_spending"]}");

        // print out all preferences for debugging
        final allKeys = prefs.getKeys();
        for (String key in allKeys) {
          final value = prefs.get(key);
          print("[PREFERENCES] $key: $value");
        }
        print("[PREFERENCES] goal_deadline's type:${prefs.get("goal_deadline").runtimeType}");

        if (!Navigator.canPop(context)) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
        return;
      } catch (e) {
        print("Error saving preferences: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login failed: login data not found")),
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
