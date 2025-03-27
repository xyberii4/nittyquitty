import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nittyquitty/services/noti_service.dart';
import 'package:nittyquitty/services/db_requests.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/goal_generator.dart';
import 'savings_screen.dart';
import 'input_nic_screen.dart';
import 'analytics_screen.dart';
import 'community_screen.dart';
import 'settingspage.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 2; // Default to 'Home'
  final NotiService notiService = NotiService(); // Notification service instance

  DateTime startDate = DateTime.now(), endDate = DateTime.now();
  int initialIntake = 0;
  double targetIntake = 0;

  @override
  void initState() {
    super.initState();
    _initializeApp();
    fetchData();
  }

  void fetchData() async {
    startDate = DateTime.now();
    endDate = await getGoalDeadline();
    initialIntake = await getWeeklyUsage("snus") + await getWeeklyUsage("vape") + await getWeeklyUsage("cig");
    targetIntake = await getGoal();
  }

  Future<void> _initializeApp() async {
    WidgetsFlutterBinding.ensureInitialized();
    await notiService.initNotification();
  }

  // List of pages corresponding to each tab
  final List<Widget> _pages = [
    SavingsScreen(),
    InputNicScreen(),
    MainHomeScreen(),
    AnalyticsScreen(),
    CommunityScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.green,
        title: Image.asset('images/Logo.png',
          height: 60,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'images/Tree.jpg',
              fit: BoxFit.cover,
            ),
          ),
          generateGoalChart(context),
          Center(child: _pages[_selectedIndex]),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.account_balance), label: 'Savings'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Input Nic'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.assessment), label: 'Analytics'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Community'),
        ],
      ),
    );
  }
  Widget generateGoalChart(BuildContext context) {
    List<FlSpot> goalData = generateNicotineGoals(
      startDate,
      endDate,
      initialIntake,
      targetIntake,
    );
    return SizedBox(
      height: 300,
      child: LineChart(
        LineChartData(
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 40),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  int index = value.toInt();
                  if (index % 5 == 0) {
                    return Text('${index}d');
                  }
                  return const SizedBox.shrink();
                },
                reservedSize: 30,
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: goalData,
              isCurved: true,
              color: Colors.green,
              barWidth: 4,
              isStrokeCapRound: true,
              belowBarData: BarAreaData(show: false),
              dotData: FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  _MainHomeScreenState createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int? userId;
  String recentData = "";
  String oldData = "";

  @override
  void initState() {
    super.initState();
    _displayRecentUsage();
  }

  Future<void> _displayRecentUsage() async {
    final now = DateTime.now();
    const duration = 7;

    final recentList = await fetchConsumptionData(
      userID: await getUserId(),
      startDate: now.subtract(const Duration(days: duration)),
      endDate: now,
    );

    double sum = 0.0;
    for (var data in recentList) {
      sum += data.calcNicotineUsage();
    }

    if (!mounted) return;
    setState(() {
      recentData = "$sum mg"; // Display only the sum
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Transparent background
      appBar: AppBar(
        title: Text(
          "HOME PAGE", // Title for the app bar
          style: GoogleFonts.nunito( // Professional font
            fontSize: 28, // Font size
            fontWeight: FontWeight.w600, // Medium-bold weight for a professional look
            color: Colors.white, // White text color
          ),
        ),
        centerTitle: true, // Centers the title
        backgroundColor: Colors.black.withOpacity(0.2), // Semi-transparent background
        elevation: 2, // Adds slight shadow for depth
        automaticallyImplyLeading: false, // No back button by default
      ),
      body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Text(
            'Recent Nicotine Intake: $recentData',
            style: const TextStyle(fontSize: 18, color: Colors.white),
          ),
        ],
      ),
    ),

    );
  }
}
