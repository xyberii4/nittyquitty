import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _snusWeeklyUsageController = TextEditingController();
  final TextEditingController _snusStrengthController = TextEditingController();
  final TextEditingController _vapeWeeklyUsageController = TextEditingController();
  final TextEditingController _vapeStrengthController = TextEditingController();
  final TextEditingController _cigaretteWeeklyUsageController = TextEditingController();
  final TextEditingController _goalController = TextEditingController();
  final TextEditingController _goalDeadlineController = TextEditingController();

  bool _snusSelected = false;
  bool _vapeSelected = false;
  bool _cigaretteSelected = false;

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      final Map<String, dynamic> requestBody = {
        "username": _usernameController.text,
        "password": _passwordController.text,
        "snus": _snusSelected,
        "snus_weekly_usage": int.tryParse(_snusWeeklyUsageController.text) ?? 0,
        "snus_strength": int.tryParse(_snusStrengthController.text) ?? 0,
        "vape": _vapeSelected,
        "vape_weekly_usage": int.tryParse(_vapeWeeklyUsageController.text) ?? 0,
        "vape_strength": int.tryParse(_vapeStrengthController.text) ?? 0,
        "cigarette": _cigaretteSelected,
        "cigarette_weekly_usage": int.tryParse(_cigaretteWeeklyUsageController.text) ?? 0,
        "goal": double.tryParse(_goalController.text) ?? 0.0,
        "goal_deadline": _goalDeadlineController.text,
      };

      // Debug: Print the request body
      print("Request Body: $requestBody");

      final String jsonBody = json.encode(requestBody);
      final Uri url = Uri.parse('http://34.105.133.181:8080/user/signup');

      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonBody,
        );

        // Debug: Print the response
        print("Response Status Code: ${response.statusCode}");
        print("Response Body: ${response.body}");

        if (!mounted) return; // Check if widget is still mounted

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sign up successful!')),
          );
          Navigator.pop(context); // Go back to the previous screen
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to sign up. Error: ${response.body}')),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade100,
      appBar: AppBar(
        title: const Text('Sign Up'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Username Input Field
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: "Username",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter a username";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password Input Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter a password";
                    } else if (value.length < 6) {
                      return "Password must be at least 6 characters";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Snus Usage Toggle
                SwitchListTile(
                  title: const Text("Do you use Snus?"),
                  value: _snusSelected,
                  onChanged: (value) {
                    setState(() {
                      _snusSelected = value;
                    });
                  },
                ),
                const SizedBox(height: 8),

                // Snus Weekly Usage Input (if Snus is selected)
                if (_snusSelected)
                  TextFormField(
                    controller: _snusWeeklyUsageController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Snus Weekly Usage",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (_snusSelected && (value == null || value.isEmpty)) {
                        return "Please enter your Snus weekly usage";
                      }
                      return null;
                    },
                  ),
                const SizedBox(height: 8),

                // Snus Strength Input (if Snus is selected)
                if (_snusSelected)
                  TextFormField(
                    controller: _snusStrengthController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Snus Strength",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (_snusSelected && (value == null || value.isEmpty)) {
                        return "Please enter your Snus strength";
                      }
                      return null;
                    },
                  ),
                const SizedBox(height: 16),

                // Vape Usage Toggle
                SwitchListTile(
                  title: const Text("Do you use Vape?"),
                  value: _vapeSelected,
                  onChanged: (value) {
                    setState(() {
                      _vapeSelected = value;
                    });
                  },
                ),
                const SizedBox(height: 8),

                // Vape Weekly Usage Input (if Vape is selected)
                if (_vapeSelected)
                  TextFormField(
                    controller: _vapeWeeklyUsageController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Vape Weekly Usage",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (_vapeSelected && (value == null || value.isEmpty)) {
                        return "Please enter your Vape weekly usage";
                      }
                      return null;
                    },
                  ),
                const SizedBox(height: 8),

                // Vape Strength Input (if Vape is selected)
                if (_vapeSelected)
                  TextFormField(
                    controller: _vapeStrengthController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Vape Strength",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (_vapeSelected && (value == null || value.isEmpty)) {
                        return "Please enter your Vape strength";
                      }
                      return null;
                    },
                  ),
                const SizedBox(height: 16),

                // Cigarette Usage Toggle
                SwitchListTile(
                  title: const Text("Do you use Cigarettes?"),
                  value: _cigaretteSelected,
                  onChanged: (value) {
                    setState(() {
                      _cigaretteSelected = value;
                    });
                  },
                ),
                const SizedBox(height: 8),

                // Cigarette Weekly Usage Input (if Cigarette is selected)
                if (_cigaretteSelected)
                  TextFormField(
                    controller: _cigaretteWeeklyUsageController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Cigarette Weekly Usage",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (_cigaretteSelected && (value == null || value.isEmpty)) {
                        return "Please enter your Cigarette weekly usage";
                      }
                      return null;
                    },
                  ),
                const SizedBox(height: 24),

                // Goal Input Field
                TextFormField(
                  controller: _goalController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Goal",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter a goal";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),

                // Goal Deadline Input Field
                TextFormField(
                  controller: _goalDeadlineController,
                  keyboardType: TextInputType.datetime,
                  decoration: const InputDecoration(
                    labelText: "Goal Deadline (YYYY-MM-DD)",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter a goal deadline";
                    }
                    return null;
                  },
                ),

                // Sign Up Button
                ElevatedButton(
                  onPressed: _signUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Sign Up",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
