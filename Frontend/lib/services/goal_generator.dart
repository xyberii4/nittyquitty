import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';

import 'db_requests.dart';

/*
import 'db_requests.dart';
void main() async {
  await fetchTestData();
}
Future<void> fetchTestData() async {
  final userId = await getUserId();
  
  final startDate = DateTime.now().subtract(Duration(days: 30));
  final endDate = DateTime.now().subtract(Duration(days: 2));

  if (userId == -1) {
    return;
  }

  final entries = await fetchConsumptionData(
    userID: userId,
    startDate: startDate,
    endDate: endDate,
  );

  final filteredEntries = entries.where((entry) => entry.mg != 0).toList();

  if (filteredEntries.isEmpty) {
    print("No data returned or an error occurred (or mg=0).");
    return;
  }

  final dailyTotals = <DateTime, double>{};

  for (var entry in filteredEntries) {
    final day = DateTime(
      entry.timestamp.year,
      entry.timestamp.month,
      entry.timestamp.day,
      
    );
    print(entry.mg);
    final quantity = entry.quantity == 0 ? 1 : entry.quantity; // currently quantity is listed as 0, so this is to pretend qty=0 is actually 1
    final usage = entry.mg * quantity;

    dailyTotals[day] = (dailyTotals[day] ?? 0) + usage;
  }

  dailyTotals.forEach((day, usage) {
    print("Day: $day => total usage: $usage");
  });

  final nextDayTarget = computeNextDayTarget(dailyTotals, daysLookback: 7);
  print("Next day target usage: $nextDayTarget");
}


// 1 cig is 10mg

// currently just takes an average of the past week, and does 0.8 * avg


double computeNextDayTarget(Map<DateTime, double> dailyTotals, {int daysLookback = 7}) {
  if (dailyTotals.isEmpty) return 0.0;

  // Sort days in ascending order
  final sortedDays = dailyTotals.keys.toList()..sort();
  final lastDay = sortedDays.last;

  // when to look back from
  final cutoffDate = DateTime(
    lastDay.year,
    lastDay.month,
    lastDay.day,
  ).subtract(Duration(days: daysLookback - 1));

  // Filter to only the relevant days
  final relevantDays = sortedDays.where((day) =>
  day.isAfter(cutoffDate) || day.isAtSameMomentAs(cutoffDate)
  ).toList();

  if (relevantDays.isEmpty) {
    return 0.0;
  }

  double sumUsage = 0.0;
  for (var day in relevantDays) {
    sumUsage += dailyTotals[day]!;
  }

  final avgUsage = sumUsage / relevantDays.length;
  final target = avgUsage * 0.8;
  return target;
}
*/


// Exponential decay model:

List<FlSpot> generateNicotineGoals(
    DateTime startDate,
    DateTime endDate,
    int initialIntake,
    double targetIntake,
    ) {

  int totalDays = endDate.difference(startDate).inDays;
  List<FlSpot> goals = [];

  if (totalDays <= 0 || initialIntake <= targetIntake) {
    return [FlSpot.zero];
  }
  double k = -math.log(initialIntake - targetIntake) / totalDays;
  for (int day = 0; day <= totalDays; day++) {
    double intake = targetIntake + (initialIntake - targetIntake) * math.exp(-k * day);
    goals.add(FlSpot(day.toDouble(), intake));
  }
  return goals;
}