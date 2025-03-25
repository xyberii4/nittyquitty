import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'services/db_requests.dart';

class NotiService {
  final FlutterLocalNotificationsPlugin notificationPlugin =
  FlutterLocalNotificationsPlugin();
  Timer? _morningTimer;
  Timer? _eveningTimer;
  Timer? _smartTimer;
  int _lastMorningNotificationDay = -1;
  int _lastEveningNotificationDay = -1;
  Set<int> _sentSmartHours = {};
  int _lastSmartNotificationDay = -1;

  final List<String> motivationalMessages = [
    'Cravings are temporary. Freedom is forever. Ride it out—you’re stronger than the urge.',
    'You don’t need a cigarette, you need a deep breath. Inhale strength, exhale cravings.',
    'Every cigarette you don’t smoke is a win. Keep stacking those victories.',
    'You are not giving up smoking. You are taking back your health and freedom.',
    'Slipped up? Reset, refocus, and keep moving forward. One mistake doesn’t erase your progress.',
    'Think about the money saved. The extra years gained. The fresh air. This is worth it.',
    'Cravings feel powerful, but they pass. Distract yourself, take a walk, sip water—you’ve got this.',
    'You quit for a reason. Keep that reason front and center. Your future self will thank you.',
    'You didn’t come this far just to come this far. Keep pushing—you’re winning.',
  ];

  final String apiBaseUrl = "http://34.105.133.181:8080";
  int? userId;

  Future<void> initNotification() async {
    try {
      userId = await getUserId();

      const AndroidInitializationSettings androidInitSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings initSettings =
      InitializationSettings(android: androidInitSettings);

      await notificationPlugin.initialize(initSettings);

      scheduleMorningNotification();
      scheduleEveningNotification();
      await analyzeUsageAndScheduleSmartNotifications();
    } catch (e) {
      print('[NotiService] Error during initialization: $e');
    }
  }

  Future<void> showNotification(String title, String body) async {
    try {
      await notificationPlugin.show(
        Random().nextInt(1000000),
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'channel_id',
            'channel_name',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
      );
    } catch (e) {
    }
  }

  void scheduleMorningNotification() {
    _morningTimer?.cancel();
    _morningTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      final now = DateTime.now();
      if (now.hour == 8 && now.minute == 0 && now.day != _lastMorningNotificationDay) {
        _lastMorningNotificationDay = now.day;
        showNotification("Morning Motivation",
            motivationalMessages[Random().nextInt(motivationalMessages.length)]);
      }
    });
  }

  void scheduleEveningNotification() {
    _eveningTimer?.cancel();
    _eveningTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      final now = DateTime.now();
      if (now.hour == 21 && now.minute == 0 && now.day != _lastEveningNotificationDay) {
        _lastEveningNotificationDay = now.day;
        showNotification("Evening Check-in", "Review your smoke-free day in the app!");
      }
    });
  }

  Future<List<DateTime>> getUsageTimes() async {
    final now = DateTime.now().toUtc();
    final String startDate = now.subtract(const Duration(days: 7000)).toIso8601String();
    final String endDate = now.toIso8601String();

    try {
      print('[NotiService] Making API request to: $apiBaseUrl/api/getConsumption');
      print('[NotiService] Request payload: ' + jsonEncode({
        "user_id": userId,
        "start_date": startDate,
        "end_date": endDate,
      }));

      final request = http.Request('GET', Uri.parse("$apiBaseUrl/api/getConsumption"))
        ..headers['Content-Type'] = 'application/json'
        ..headers['Accept'] = 'application/json'
        ..body = jsonEncode({
          "user_id": userId,
          "start_date": startDate,
          "end_date": endDate,
        });

      final response = await http.Client().send(request);
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode != 200) {

        return [];
      }

      final List<dynamic> data = jsonDecode(responseBody);
      return data.map((entry) => DateTime.parse(entry['timestamp'])).toList();
    } catch (e) {
      print('[NotiService] Error fetching usage times: $e');
      return [];
    }
  }

  Future<Map<int, List<int>>> analyzeUsagePatterns() async {
    print('[NotiService] Analyzing usage patterns...');
    List<DateTime> usageData = await getUsageTimes();
    print('[NotiService] Found ${usageData.length} usage records');

    Map<int, List<int>> frequentHours = {};

    for (var entry in usageData) {
      int day = entry.weekday;
      int hour = entry.hour;
      frequentHours.putIfAbsent(day, () => []);
      frequentHours[day]!.add(hour);
    }

    Map<int, List<int>> topHours = {};
    frequentHours.forEach((day, hours) {
      print('[NotiService] Day $day has ${hours.length} usage entries');
      Map<int, int> hourCounts = {};
      for (var h in hours) {
        hourCounts[h] = (hourCounts[h] ?? 0) + 1;
      }
      var sortedHours = hourCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      topHours[day] = sortedHours.take(2).map((e) => e.key).toList();
    });

    print('[NotiService] Top usage hours: $topHours');
    return topHours;
  }

  Future<void> analyzeUsageAndScheduleSmartNotifications() async {
    print('[NotiService] Starting smart notification analysis');
    Map<int, List<int>> topUsageHours = await analyzeUsagePatterns();

    final Map<int, List<int>> peakSchedule = {};
    const defaultHours = [12, 17];

    for (int day = 1; day <= 7; day++) {
      final dataHours = topUsageHours[day] ?? [];
      peakSchedule[day] = _mergeHours(dataHours, defaultHours);
    }

    print('[NotiService] Final notification schedule:');
    peakSchedule.forEach((day, hours) {
      print("   ${_getWeekdayName(day).padRight(9)}: ${hours.map((h) => '${h.toString().padLeft(2, '0')}:00').join(', ')}");
    });

    _smartTimer?.cancel();
    _smartTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      final now = DateTime.now();
      final today = now.weekday;

      if (now.day != _lastSmartNotificationDay) {
        _sentSmartHours.clear();
        _lastSmartNotificationDay = now.day;
      }

      for (final targetHour in peakSchedule[today]!) {
        if (now.hour == targetHour &&
            now.minute == 0 &&
            !_sentSmartHours.contains(targetHour)) {
          _sentSmartHours.add(targetHour);
          final timeStr = DateFormat('HH:mm').format(now);
          print('[NotiService] Triggering smart notification at $timeStr');
          showNotification("Craving Alert!",
              "This is your scheduled alert to stay smoke-free!");
        }
      }
    });
  }

  List<int> _mergeHours(List<int> dataHours, List<int> defaultHours) {
    final merged = <int>[];
    final uniqueHours = {...dataHours, ...defaultHours};

    for (final hour in dataHours) {
      if (merged.length < 2 && !merged.contains(hour)) {
        merged.add(hour);
      }
    }

    for (final hour in defaultHours) {
      if (merged.length < 2 && !merged.contains(hour)) {
        merged.add(hour);
      }
    }

    print('[NotiService] Merged hours: $merged (from data: $dataHours, defaults: $defaultHours)');
    return merged;
  }

  String _getWeekdayName(int weekday) {
    return const [
      'Monday', 'Tuesday', 'Wednesday',
      'Thursday', 'Friday', 'Saturday', 'Sunday'
    ][weekday - 1];
  }
}


