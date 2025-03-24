import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'savings_screen.dart';
import 'input_nic_screen.dart';
import 'analytics_screen.dart';
import 'community_screen.dart';
import 'settingspage.dart'; // Import the new Settings screen

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
 
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 2; // Default to 'Home'
  int? userId; // Variable to store user ID


  // commented out userId related functions, moved this to lib/services/db_requests.dart as getUserId()
  // commented out code can be removed safely

  /*
  late List<Widget> _pages;
  @override
  void initState() {
    super.initState();
    _loadUserId(); // Fetch user ID when screen loads
  }
  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt("user_id"); // Retrieve stored user ID
      _pages = [
        SavingsScreen(),
        InputNicScreen(),
        MainHomeScreen(),
        AnalyticsScreen(),
        CommunityScreen(),
      ];
  });
  */

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
        backgroundColor: Colors.green,
        title: Image.asset('images/Logo.png',
        height: 60, // Adjust height as needed
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings), // 🔹 Settings Icon
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

class MainHomeScreen extends StatelessWidget {
  const MainHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text('Home Page', style: TextStyle(fontSize: 24, color: Colors.white));
  }
}
