import 'package:flutter/material.dart';
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

  // List of pages corresponding to each tab
  final List<Widget> _pages = [
    SavingsScreen(),
    InputNicScreen(),
    MainHomeScreen(),
    AnalyticsScreen(),
    PeopleScreen(),
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
        title: const Text("NicQuit"),
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
          // 🔹 Background Image
          Positioned.fill(
            child: Image.asset(
              'images/Tree.jpg', // Local asset
              fit: BoxFit.cover,
            ),
          ),
          // 🔹 Foreground Content (Display selected page)
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
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'People'),
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
