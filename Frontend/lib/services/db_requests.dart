import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


class ConsumptionEntry {
  final String product;
  final int userId;
  final double mg;
  final int quantity;
  final double cost;
  final DateTime timestamp;

  ConsumptionEntry({
    required this.product,
    required this.userId,
    required this.mg,
    required this.quantity,
    required this.cost,
    required this.timestamp,
  });

  factory ConsumptionEntry.fromJson(Map<String, dynamic> json) {
    return ConsumptionEntry(
      product: json['product'],
      userId: json['user_id'],
      mg: (json['mg'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 0,
      cost: (json['cost'] ?? 0).toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class UserDataEntry {
  final String username, password;
  final String goal_deadline; // "YYYY-MM-DD"
  final bool snus, vape, cigarette;
  final int snus_weekly_usage, vape_weekly_usage, cig_weekly_usage, snus_strength, vape_strength;
  final double goal;

  UserDataEntry({
    required this.username,
    required this.password,
    required this.goal,
    required this.goal_deadline,
    required this.snus,
    required this.vape,
    required this.cigarette,
    required this.snus_weekly_usage,
    required this.vape_weekly_usage,
    required this.cig_weekly_usage,
    required this.snus_strength,
    required this.vape_strength,
  });

  factory UserDataEntry.fromJson(Map<String, dynamic> json) {
    return UserDataEntry(
      username: json['username'],
      password: json['password'],
      goal: (json['goal'] ?? 0).toDouble(),
      goal_deadline: json['goal_deadline'],
      snus: json['snus'],
      vape: json['vape'],
      cigarette: json['cigarette'],
      snus_weekly_usage: json['snus_weekly_usage'],
      vape_weekly_usage: json['vape_weekly_usage'],
      cig_weekly_usage: json['cig_weekly_usage'],
      snus_strength: json['snus_strength'],
      vape_strength: json['vape_strength'],
    );
  }
}

Future<List<ConsumptionEntry>> fetchConsumptionData({
  required int userID,
  required DateTime startDate,
  required DateTime endDate,
}) async {
  const String apiBaseUrl = "http://34.105.133.181:8080";

  final request = http.Request(
    'GET',
    Uri.parse("$apiBaseUrl/api/getConsumption"),
  )
    ..headers['Content-Type'] = 'application/json'
    ..headers['Accept'] = 'application/json'
    ..body = jsonEncode({
      "user_id": userID,
      "start_date": startDate.toUtc().toIso8601String(),
      "end_date": endDate.toUtc().toIso8601String(),
    });

  try {
    final response = await http.Client().send(request);
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode != 200) {
      throw Exception("Failed to load data: ${response.statusCode}");
    }

    final List<dynamic> rawData = jsonDecode(responseBody);
    return rawData.map((entry) => ConsumptionEntry.fromJson(entry)).toList();
  } catch (e) {
    // error, log maybe?
    return [];
  }
}

// returns userId, or -1 if an error has occured
Future<int> getUserId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int? userId = prefs.getInt("user_id");
  if (userId == null) {
    print("Error loading user ID");
    return userId = -1;
  }
  print("User ID: $userId.toString()");
  return userId;
}
