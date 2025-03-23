import 'package:flutter/material.dart';
import 'nicotine_types/vapes_screen.dart';      // Import from subfolder
import 'nicotine_types/cigarettes_screen.dart';
import 'nicotine_types/snus_screen.dart';
import 'nicotine_types/custom_screen.dart';

class InputNicScreen extends StatelessWidget {
  const InputNicScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,  // 🔹 Makes the body extend behind the AppBar
      appBar: AppBar(
        title: Text("Input Nic"),
        backgroundColor: Colors.transparent, // 🔹 Makes AppBar transparent
        elevation: 0, // 🔹 Removes shadow
        automaticallyImplyLeading: false,
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