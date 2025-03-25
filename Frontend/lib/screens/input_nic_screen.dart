import 'package:flutter/material.dart';
import 'nicotine_types/vapes_screen.dart';      // Import from subfolder
import 'nicotine_types/cigarettes_screen.dart';
import 'nicotine_types/snus_screen.dart';
import 'nicotine_types/custom_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class InputNicScreen extends StatelessWidget {
  const InputNicScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //extendBodyBehindAppBar: true,  // 🔹 Makes the body extend behind the AppBar
      backgroundColor: Colors.transparent, // Transparent background for the screen
      appBar: AppBar(
        title: Text("INPUT NIC",
        style: GoogleFonts.nunito( // Change to Montserrat, Roboto, or any other
      fontSize: 28,
      fontWeight: FontWeight.w600, // Medium-bold for professionalism
      color: Colors.white,
        ),
        ),
        centerTitle: true, // Centers the title for better alignment
        backgroundColor: Colors.black.withOpacity(0.2), // Subtle transparency in the background
        elevation: 2, // Adds a slight shadow for depth
        automaticallyImplyLeading: false, // Removes the default back button
      ),
      body: Stack(
        children: [
          // 🔹 Background Image
          Positioned.fill(
            child: Image.asset(
              'images/Tree.jpg', // Make sure the path is correct
              fit: BoxFit.cover,
            ),
          ),

          // 🔹 Foreground Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => VapesScreen()),
                    );
                  },
                  child: Text('Vapes'),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CigarettesScreen()),
                    );
                  },
                  child: Text('Cigarettes'),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SnusScreen()),
                    );
                  },
                  child: Text('Snus'),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CustomScreen()),
                    );
                  },
                  child: Text('Custom'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}