import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'package:nittyquitty/services/db_requests.dart';

enum Period {
  day,
  week,
  month,
  year,
}

final now = DateTime.now();

final Map<Period, List<String>> xLabels = {
  Period.day: List.generate(24, (i) {
    final hour = i % 12 == 0 ? 12 : i % 12;
    final period = i < 12 ? "am" : "pm";
    return "$hour:00$period";
  }),

  Period.week: () {
    final weekdayToday = now.weekday;
    final List<String> allDays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    return List.generate(7, (i) => allDays[(weekdayToday + i) % 7]);
  }(),

  Period.month: () {
    final dateFormat = DateFormat('d MMM');
    return List.generate(30, (i) {
      final date = now.subtract(Duration(days: 29 - i));
      return dateFormat.format(date);
    });
  }(),

  Period.year: () {
    final months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    final currentMonth = now.month; // 1–12
    return List.generate(12, (i) => months[(currentMonth + i) % 12]);
  }(),
};
List<String> getFilteredXLabels(Period period, int step) {
  final List<String> list = xLabels[period] ?? [];
  return List.generate(list.length, (i) {
    return i % step == 0 ? list[i] : '';
  });
}

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  Period _selectedPeriod = Period.day;
  DataType _selectedDataType = DataType.nicotine;

  List<double> _barData = [];
  List<String> _xLabels = [];

  Future<void> _fetchChartData() async {
    _barData = [];
    _xLabels = [];

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (_selectedPeriod) {
      case Period.day: {
        final entries = await fetchConsumptionData(
          startDate: today,
          endDate: today.add(const Duration(days: 1)),
        );
        _barData = List.filled(24, 0.0);
        _xLabels = getFilteredXLabels(Period.day, 4);

        for (var entry in entries) {
          _barData[entry.timestamp.hour] += entry.getNicotineOrSpending(_selectedDataType);
        }
        break;
      }

      case Period.week: {
        final startDate = today.subtract(const Duration(days: 6));
        final entries = await fetchConsumptionData(
          startDate: startDate,
          endDate: today.add(const Duration(days: 1)),
        );
        _barData = List.filled(7, 0.0);
        _xLabels = getFilteredXLabels(Period.week, 2);

        for (var entry in entries) {
          final diff = entry.timestamp.difference(startDate).inDays;
          if (diff >= 0 && diff < 7) {
            _barData[diff] += entry.getNicotineOrSpending(_selectedDataType);
          }
        }
        break;
      }

      case Period.month: {
        final startDate = today.subtract(const Duration(days: 29));
        final entries = await fetchConsumptionData(
          startDate: startDate,
          endDate: today.add(const Duration(days: 1)),
        );
        _barData = List.filled(30, 0.0);
        _xLabels = getFilteredXLabels(Period.month, 6);

        for (var entry in entries) {
          final diff = entry.timestamp.difference(startDate).inDays;
          if (diff >= 0 && diff < 30) {
            _barData[diff] += entry.getNicotineOrSpending(_selectedDataType);
          }
        }
        break;
      }

      case Period.year: {
        final startDate = DateTime(today.year - 1, today.month, today.day);
        final entries = await fetchConsumptionData(
          startDate: startDate,
          endDate: today.add(const Duration(days: 1)),
        );
        _barData = List.filled(12, 0.0);
        _xLabels = getFilteredXLabels(Period.year, 1);

        for (var entry in entries) {
          final monthIndex = (entry.timestamp.month - startDate.month + 12) % 12;
          _barData[monthIndex] += entry.getNicotineOrSpending(_selectedDataType);
        }
        break;
      }
    }

    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Compute max for bar
    final barMax = _barData.isNotEmpty ? _barData.reduce(math.max) : 0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          "ANALYTICS PAGE",
        style: GoogleFonts.nunito( // Change to Montserrat, Roboto, or any other
            fontSize: 28,
            fontWeight: FontWeight.w600, // Medium-bold for professionalism
            color: Colors.white,
        ),
        ),
        centerTitle: true, // Centers the title for better alignment
        backgroundColor: Colors.black.withOpacity(0.2), // Subtle transparency
        elevation: 2, // Adds a small shadow for depth
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildPeriodToggle(),
              _buildDataTypeToggle(),

              const SizedBox(height: 16),

              // --- BAR CHART ---
              Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    height: 300,
                    child: BarChart(
                      BarChartData(
                        minY: 0,
                        maxY: barMax + 5,
                        
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index < 0 || index >= _xLabels.length) {
                                  return const SizedBox.shrink();
                                }
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),  // Add horizontal padding
                                  child: Text(
                                    _xLabels[index],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(
                                    value.toStringAsFixed(0),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: _buildBarGroups(_barData),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  /// Builds the ToggleButtons for Day/Week/Month/Year
  Widget _buildPeriodToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
      Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child:
        ToggleButtons(
          isSelected: [
            _selectedPeriod == Period.day,
            _selectedPeriod == Period.week,
            _selectedPeriod == Period.month,
            _selectedPeriod == Period.year,
          ],
          onPressed: (index) {
            setState(() {
              _selectedPeriod = Period.values[index];
            });
            _fetchChartData();
          },
          renderBorder: false,
          fillColor: Colors.green,
          children: const [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text('Day'),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text('Week'),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Month'),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Year'),
            ),
          ],
        ),
      )],
    );
  }

  /// Builds the ToggleButtons for Nicotine/Spending
  Widget _buildDataTypeToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
      Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child:
        ToggleButtons(
          isSelected: [
            _selectedDataType == DataType.nicotine,
            _selectedDataType == DataType.spending,
          ],
          onPressed: (index) {
            setState(() {
              _selectedDataType = DataType.values[index];
            });
            _fetchChartData();
          },
          fillColor: Colors.green,
          children: const [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text('Nicotine'),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text('Spending'),
            ),
          ],
        ),
      )],
    );
  }

  /// Convert barData into BarChartGroups
  List<BarChartGroupData> _buildBarGroups(List<double> data) {
    return List.generate(data.length, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: data[index],
            color: Colors.green,
            width: 12,
          ),
        ],
      );
    });
  }
}