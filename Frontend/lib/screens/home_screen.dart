import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nittyquitty/noti_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
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

  @override
  void initState() {
    super.initState();
    _initializeApp();
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
    _fetchNicotineConsumptionData();
  }

  Future<int> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt("user_id");
    if (userId == null) {
      debugPrint("Error loading user ID");
      return -1;
    }
    debugPrint("User ID: $userId");
    return userId;
  }

  Future<List<dynamic>> fetchConsumptionData({
  required int userID,
  required DateTime startDate,
  required DateTime endDate,
}) async {
  const String apiBaseUrl = "http://34.105.133.181:8080";

  try {
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

    final response = await http.Client().send(request);

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      return jsonDecode(responseBody) ?? []; // Ensure it always returns a list
    } else {
      debugPrint("Error fetching data: ${response.statusCode}");
      return [];
    }
  } catch (e) {
    debugPrint("Exception in fetchConsumptionData: $e");
    return [];
  }
}


  Future<void> _fetchNicotineConsumptionData() async {
    userId = await getUserId();
    if (userId == -1) return;

    final now = DateTime.now();
    const duration = 7;

    // Fetch recent data and sum mg intake
    final recentList = await fetchConsumptionData(
      userID: userId!,
      startDate: now.subtract(const Duration(days: duration)),
      endDate: now,
    );

    double totalRecentMg = recentList
        .map((item) => (item['mg'] ?? 0.0)) // Extract mg values
        .fold(0.0, (sum, mg) => sum + mg);  // Sum up mg values

    setState(() {
      recentData = "${totalRecentMg.toStringAsFixed(2)} mg"; // Display only the sum
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
