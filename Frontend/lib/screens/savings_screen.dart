import 'package:flutter/material.dart';
import 'package:nittyquitty/services/db_requests.dart';

enum Period {
  week,
  month,
  year,
}

class SavingsScreen extends StatefulWidget {
  const SavingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
        'Savings Page', style: TextStyle(fontSize: 24, color: Colors.white),
    );
  }

  @override
  State<StatefulWidget> createState() => _SavingsScreenState();

}

class _SavingsScreenState extends State<SavingsScreen> {

  Period _selectedPeriod = Period.week;
  List<bool> _isSelected = [true, false, false];
  double _savingsAmount = 0;

  Future<double> averageSavings(int userID, int duration) async {

    final now = DateTime.now();
    List<ConsumptionEntry> recentData, oldData;

    recentData = await fetchConsumptionData(userID: userID, startDate: now.subtract(Duration(days: duration)), endDate: now);
    oldData = await fetchConsumptionData(userID: userID, startDate: now.subtract(Duration(days: 3*duration)), endDate: now);

    double recentSpent = 0, oldSpent = 0;
    for (ConsumptionEntry entry in recentData) {
      recentSpent += entry.cost;
    }
    for (ConsumptionEntry entry in oldData) {
      oldSpent += entry.cost;
    }
    recentSpent /= recentData.length;
    oldSpent /= oldData.length;

    return (oldSpent - recentSpent) * duration;
  }

  Future<void> _updateSavings() async {

    final now = DateTime.now();
    final nowUTC = now.toUtc();

    List<ConsumptionEntry> recentData, oldData;
    int expenditure;
    switch (_selectedPeriod) {
      case Period.week:
        _savingsAmount = await averageSavings(123, 7);
      case Period.month:
        _savingsAmount = await averageSavings(123, 31);
      case Period.year:
        _savingsAmount = await averageSavings(123, 365);
    }
  }

  Widget build(BuildContext context) {
    _updateSavings();
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'images/Tree.jpg',
              fit: BoxFit.cover,
            ),
          ),
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
