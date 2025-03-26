import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Transparent background for the screen
      appBar: AppBar(
        title: Text(
          "Community Page",
          style: GoogleFonts.nunito( // Use Nunito font for consistency
            fontSize: 28,
            fontWeight: FontWeight.w600, // Medium-bold for a professional look
            color: Colors.white, // White color for contrast
          ),
        ),
        centerTitle: true, // Centers the title for better alignment
        backgroundColor: Colors.black.withOpacity(0.2), // Subtle transparency in the background
        elevation: 2, // Adds a slight shadow for depth
        automaticallyImplyLeading: false, // Removes the default back button
      ),
      body: Center(
        child: Text(
          'Coming Soon!', 
          style: TextStyle(fontSize: 36, color: Colors.white),
        ),
      ),
    );
  }
}