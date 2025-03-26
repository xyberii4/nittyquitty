import 'package:flutter/material.dart';
import 'savings_screen.dart';
import 'input_nic_screen.dart';
import 'analytics_screen.dart';
import 'community_screen.dart';
import 'settingspage.dart';
import '../noti_service.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedIndex = 2; // Default to 'Home'
  int? userId; // Variable to store user ID
  final NotiService notiService =
      NotiService(); // Notification service instance

  late final AnimationController _controller;
  late final Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _initializeApp();

    _controller = AnimationController(
      duration: const Duration(seconds: 16),
      vsync: this,
    )..repeat();

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(1.4, 0),
      end: const Offset(-1.4, 0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _launchNHSUrl() async {
    final Uri url = Uri.parse('https://www.nhs.uk/better-health/quit-smoking/');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  Future<void> _initializeApp() async {
    WidgetsFlutterBinding.ensureInitialized();
    await notiService.initNotification();
    // You can add other initialization code here if needed
  }

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
        title: Image.asset('images/Logo.png', height: 60),
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
            child: Image.asset('images/Tree.jpg', fit: BoxFit.cover),
          ),
          Center(child: _pages[_selectedIndex]),
          Positioned(
            left: 0,
            right: 0,
            bottom:
                20, // positioned just above navigation bar, adjust slightly if needed
            child: GestureDetector(
              onTap: _launchNHSUrl,
              child: Container(
                color: Colors.green[800], // dark green color
                padding: const EdgeInsets.symmetric(vertical: 4),
                height: 35, // reduced height clearly matching text
                alignment: Alignment.center, // vertically centered text
                child: ClipRect(
                  child: SlideTransition(
                    position: _offsetAnimation,
                    child: const Text(
                      '   For professional health resources to quit nicotine, please press here to visit the NHS website   ',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.visible,
                      softWrap: false,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance),
            label: 'Savings',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Input Nic'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.assessment),
            label: 'Analytics',
          ),
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
    return const Text(
      'Home Page',
      style: TextStyle(fontSize: 24, color: Colors.white),
    );
  }
}
