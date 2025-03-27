import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:nittyquitty/services/noti_service.dart';
import 'package:nittyquitty/services/db_requests.dart';
import 'package:nittyquitty/services/user_prefs.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/goal_generator.dart';
import 'savings_screen.dart';
import 'input_nic_screen.dart';
import 'analytics_screen.dart';
import 'community_screen.dart';
import 'settingspage.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin  {
  int _selectedIndex = 2; // Default to 'Home'
  final NotiService notiService = NotiService(); // Notification service instance

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
              icon: Icon(Icons.account_balance), label: 'Savings'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Input Nic'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.assessment), label: 'Analytics'),
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

  bool _dataFetched = false;
  bool _usageDisplayed = false;
  DateTime startDate = DateTime.now();
  late DateTime endDate;
  late double initialIntake;
  late double targetIntake;

  @override
  void initState() {
    super.initState();
    _displayRecentUsage().then((_) {
      setState(() {
        _usageDisplayed = true;
      });
    });
    fetchData().then((_) {
      setState(() {
        _dataFetched = true;
      });
    });
  }

  Future<void> fetchData() async {
    startDate = DateTime.now();
    endDate = await getGoalDeadline();
    initialIntake = (
            await getWeeklyUsage("snus") +
            await getWeeklyUsage("vape") +
            await getWeeklyUsage("cig")) / 7;
    targetIntake = await getGoal();
    print("[FETCHDATA] startDate: $startDate");
    print("[FETCHDATA] endDate: $endDate");
    print("[FETCHDATA] initialIntake: $initialIntake");
    print("[FETCHDATA] targetIntake: $targetIntake");
  }

  Future<void> _displayRecentUsage() async {
    final now = DateTime.now();
    const duration = 7;

    final recentList = await fetchConsumptionData(
      user_id: await getUserId(),
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
          generateGoalChart(context),
        ],
      ),
    ),

    );
  }
  Widget generateGoalChart(BuildContext context) {
    if (!_dataFetched || !_usageDisplayed) {
      return Center(child: CircularProgressIndicator());
    }

    List<FlSpot> goalData = generateNicotineGoals(
      startDate,
      endDate,
      initialIntake,
      targetIntake,
    );

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, // White background
          borderRadius: BorderRadius.circular(12), // Rounded corners
          boxShadow: [
            BoxShadow(
              color: Colors.black26, // Subtle shadow for depth
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Center(child: Text(
              "Nicotine Reduction Goal",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            )),
            const SizedBox(height: 8),

            // Graph
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: initialIntake-(initialIntake%10)+20,
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                      ),
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
                    rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
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
                  extraLinesData: ExtraLinesData(
                    horizontalLines: [
                      HorizontalLine(
                        y: double.parse(recentData.replaceAll(" mg", "")),
                        color: Colors.red,
                        dashArray: [5, 5],
                        label: HorizontalLineLabel(
                          labelResolver: (line) => "Recent Intake",
                          show: true,
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(child: Text(
              'Recent Nicotine Intake: $recentData',
              style: const TextStyle(fontSize: 18, color: Colors.green),
            )),
          ],
        ),
      ),
    );
  }
}
