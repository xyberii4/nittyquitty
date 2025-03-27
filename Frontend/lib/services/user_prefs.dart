import 'package:shared_preferences/shared_preferences.dart';

// returns userId, or -1 if an error has occured
Future<int> getUserId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int? userId = prefs.getInt("user_id");
  if (userId == null) {
    print("Error loading user ID");
    return -1;
  }
  print("User ID: $userId");
  return userId;
}

Future<double> getWeeklySpending() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  double? spending = prefs.getDouble("weekly_spending");
  if (spending == null) {
    print("Error loading weekly spending");
    return -1;
  }
  print("Usage: $spending");
  return spending;
}

Future<int> getWeeklyUsage(String nicType) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int? usage = prefs.getInt("${nicType}_weekly_usage");
  if (usage == null) {
    print("Error loading weekly $nicType usage");
    return -1;
  }
  print("Usage: $usage");
  return usage;
}

Future<double> getGoal() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  double? goal = prefs.getDouble("goal");
  if (goal == null) {
    print("Error loading goal");
    return -1;
  }
  print("Usage: $goal");
  return goal;
}

Future<DateTime> getGoalDeadline() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? goalDeadline = prefs.getString("goalDeadline");
  if (goalDeadline == null) {
    print("Error loading goalDeadline");
    return DateTime.now();
  }
  print("Usage: $goalDeadline");
  return DateTime.parse(goalDeadline);
}
