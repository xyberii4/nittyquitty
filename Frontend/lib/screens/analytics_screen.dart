import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

enum Period {
  day,
  week,
  month,
  year,
}
enum DataType {
  nicotine,
  spending,
}

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  Period _selectedPeriod = Period.day;
  DataType _selectedDataType = DataType.nicotine;

  List<double> _barData = [];
  List<String> _xLabels = [];

  @override
  void initState() {
    super.initState();
    _fetchChartData();
  }

  Future<void> _fetchChartData() async {
    _barData = [];
    _xLabels = [];

    // currently just random data, but need to connect to database
    switch (_selectedPeriod) {
      case Period.day:
      // For "day" -> 24 hours
        _barData = List.generate(24, (i) => (math.Random().nextDouble() * 10).roundToDouble());
        //_xLabels = List.generate(24, (i) => i.toString()); // "0", "1", ..., "23"
        _xLabels = [];
        break;

      case Period.week:
      // For "week" -> 7 days
        _barData = List.generate(7, (i) => (math.Random().nextDouble() * 20).roundToDouble());
        _xLabels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
        break;

      case Period.month:
      // For "month" -> ~30 days
        _barData = List.generate(30, (i) => (math.Random().nextDouble() * 25).roundToDouble());
        //_xLabels = List.generate(30, (i) => (i + 1).toString());
        _xLabels = [];
        break;

      case Period.year:
      // For "year" -> 12 months
        _barData = List.generate(12, (i) => (math.Random().nextDouble() * 40).roundToDouble());
        _xLabels = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
          "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
        break;
    }

    // If you want to differentiate Nicotine vs. Spending, add logic here.
    // For now, the data is just random.

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
          "Analytics Page",
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
                                final label = (value * (meta.max - meta.min) / 5).toStringAsFixed(0);

                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(
                                    label,
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
