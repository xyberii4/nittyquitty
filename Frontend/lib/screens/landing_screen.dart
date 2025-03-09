import 'package:flutter/material.dart';
import 'login_screen.dart'; // Import the login page

class LandingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'images/Tree.jpg', // Make sure to add this image to assets
              fit: BoxFit.cover,
            ),
          ),

          // Overlay for readability
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5), // Dark overlay for contrast
            ),
          ),

          // Content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // App Name
                Text(
                  "Welcome to NicQuit",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),

                // Subtitle
                Text(
                  "Track your nicotine intake & save money",
                  style: TextStyle(fontSize: 18, color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40),

                // Get Started Button
                ElevatedButton(
                  onPressed: () {
                    // Navigate to Login Page
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "Get Started",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}