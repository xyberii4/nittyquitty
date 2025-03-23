import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'home_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  Future<void> _login() async {
  if (!_formKey.currentState!.validate()) return;

  // Simulating a delay to mimic a real API call (optional)
  await Future.delayed(Duration(seconds: 1));

  // Navigate to HomeScreen regardless of login status
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => HomeScreen()),
  );
  //Database call waiting on API to be implemented 
  // final url = Uri.parse("http://34.105.133.181:8080/user/login"); 

  // try {
  //   final response = await http.post(
  //     url,
  //     headers: {"Content-Type": "application/json"},
  //     body: jsonEncode({
  //       "username": _usernameController.text, 
  //       "password": _passwordController.text,
  //     }),
  //   );

  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   await prefs.setInt("user_id", userId);

  //   if (response.statusCode == 200) {

  //     final responseData = jsonDecode(response.body);
  //     int userId = responseData["user_id"]; // Extract user_id

  //     //Pass userId to HomeScreen      
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(builder: (context) => HomeScreen()),
  //     );
  //   } else {
  //     final responseData = jsonDecode(response.body);
  //     String errorMessage = responseData["error"] ?? "Login failed. Check credentials.";
      
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text(errorMessage)),
  //     );
  //   }
  // } catch (e) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(content: Text("Error connecting to server.")),
  //   );
  // }
}


  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade100,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "NicQuit Login",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 24),

                // Username Input Field 
                TextFormField(
                  controller: _usernameController, 
                  decoration: InputDecoration(
                    labelText: "Username",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your username";
                    } else if (value.length < 3) {
                      return "Username must be at least 3 characters";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Password Input Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your password";
                    } else if (value.length < 6) {
                      return "Password must be at least 6 characters";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Login Button
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text("Login", style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
                SizedBox(height: 12),

                // Sign Up and Forgot Password Links
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignUpScreen()),
                        );
                      },
                      child: Text("Sign Up"),
                    ),
                    Text(" | "),
                    TextButton(
                      onPressed: () {
                        // Navigate to Forgot Password Page
                      },
                      child: Text("Forgot Password?"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}