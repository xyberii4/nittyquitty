import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nittyquitty/services/db_requests.dart';

enum Period {
  week,
  month,
  year,
}

class SavingsScreen extends StatefulWidget {
  const SavingsScreen({super.key});

  @override
  State<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen> {
  Period _selectedPeriod = Period.week; // default Period when loading the page
  final List<bool> _isSelected = [true, false, false];
  double _savingsAmount = 0;

  @override
  void initState() {
    super.initState();
    _updateSavings();
  }

  Future<double> averageSavings(int userID, int duration) async {
    final now = DateTime.now();
    List<ConsumptionEntry> recentData = await fetchConsumptionData(userID: userID, startDate: now.subtract(Duration(days: duration)), endDate: now);
    double avgSpent = await getWeeklySpending() / 7;

    if (recentData.isNotEmpty) {

      double recentSpent = 0;
      for (ConsumptionEntry entry in recentData) {
        recentSpent += entry.cost;
      }
      return avgSpent * duration - recentSpent;
    }
    else {
      return avgSpent * duration;
    }
  }

  Future<void> _updateSavings() async {

    int userId = await getUserId();
    double tmpSavings;
    switch (_selectedPeriod) {
      case Period.week:
        tmpSavings = await averageSavings(userId, 7);
      case Period.month:
        tmpSavings = await averageSavings(userId, 31);
      case Period.year:
        tmpSavings = await averageSavings(userId, 365);
    }

    setState(() {
      _savingsAmount = tmpSavings;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text("SAVINGS SCREEN",
          style: GoogleFonts.nunito(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.black.withOpacity(0.2),
        elevation: 2, // Adds a slight shadow for depth
        automaticallyImplyLeading: false, // Removes the default back button
      ),
      body: Stack(
        children: [
          _buildPeriodToggle(),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Card(
                    color: Colors.transparent,
                    child: Center(
                      child: TweenAnimationBuilder(
                        duration: Duration(seconds: 1),
                        tween: Tween<double>(begin: 0, end: _savingsAmount),
                        builder: (context, double value, child) {
                          return RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 60,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    blurRadius: 10.0,
                                    color: Colors.black54,
                                    offset: Offset(3, 3),
                                  ),
                                ],
                              ),
                              children: [
                                const TextSpan(text: "You've saved £ "),
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: ShaderMask(
                                    shaderCallback: (bounds) => LinearGradient(
                                      colors: [Colors.amber, Colors.orangeAccent],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ).createShader(bounds),
                                    child: Text(
                                      value.toStringAsFixed(2),
                                      style: const TextStyle(
                                        fontSize: 60,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        shadows: [
                                          Shadow(
                                            blurRadius: 20.0,
                                            color: Colors.orangeAccent,
                                            offset: Offset(-3, -3),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const TextSpan(text: " !"),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ToggleButtons(
            isSelected: _isSelected,
            onPressed: (index) async {
              _selectedPeriod = Period.values[index];

              // Update selection state immediately
              setState(() {
                for (int i = 0; i < _isSelected.length; i++) {
                  _isSelected[i] = (i == index);
                }
              });

              // Await the database update before doing anything else
              await _updateSavings();

              // Ensure state is fully updated after the async call
              if (mounted) {
                setState(() {});
              }
            },
            renderBorder: false,
            fillColor: Colors.green,
            children: const [
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
        ),
      ],
    );
  }
}