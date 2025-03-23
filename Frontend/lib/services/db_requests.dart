import 'dart:convert';
import 'package:http/http.dart' as http;


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
