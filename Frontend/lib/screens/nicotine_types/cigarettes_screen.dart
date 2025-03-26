import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:nittyquitty/services/db_requests.dart';

class CigarettesScreen extends StatefulWidget {
  @override
  _CigarettesScreenState createState() => _CigarettesScreenState();
}

class _CigarettesScreenState extends State<CigarettesScreen> {
  final _formKey = GlobalKey<FormState>(); // Key for the form
  final TextEditingController _timeController = TextEditingController();

  int _cigarettes = 0; // Number of cigarettes smoked
  double _cost = 0.0; // Cost
  DateTime? _selectedTime; // User-entered time

  // Function to validate time input
  bool _isValidTime(String input) {
    final RegExp timeRegex = RegExp(r'^(?:[01]?\d|2[0-3]):[0-5]\d$'); // Matches 00:00 - 23:59
    return timeRegex.hasMatch(input);
  }

  // Function to log consumption data to the backend
  Future<void> _logConsumption() async {
    if (_selectedTime == null) {
      // Ensure time is selected
      return;
    }

    // Prepare the request body
    final Map<String, dynamic> requestBody = {
      "product": "cigarette",
      "user_id": await getUserId(), // Replace with the actual user ID
      "mg": 0, // Cigarettes don't have mg, so set to 0
      "quantity": _cigarettes,
      "cost": _cost,
      //"ts": //hh:mm
    };

    // Convert the request body to JSON
    final String jsonBody = json.encode(requestBody);

    // Make the POST request
    final Uri url = Uri.parse('http://34.105.133.181:8080/api/logConsumption');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonBody,
    );

    // Check if the request was successful
    if (response.statusCode == 200) {
      // Show success message
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Submission Successful'),
            content: Text('Cigarette data has been saved.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      // Show error message
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Submission Failed'),
            content: Text('Failed to save cigarette data. Please try again.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cigarette Input'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Input for the number of cigarettes smoked
                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Number of Cigarettes',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _cigarettes = int.tryParse(value) ?? 0;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the number of cigarettes';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // User enters time manually
                TextFormField(
                  controller: _timeController,
                  keyboardType: TextInputType.datetime,
                  decoration: InputDecoration(
                    labelText: 'Time (HH:MM)',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    if (_isValidTime(value)) {
                      List<String> parts = value.split(":");
                      int hour = int.parse(parts[0]);
                      int minute = int.parse(parts[1]);
                      setState(() {
                        _selectedTime = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, hour, minute);
                      });
                    } else {
                      setState(() {
                        _selectedTime = null;
                      });
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a valid time';
                    }
                    if (!_isValidTime(value)) {
                      return 'Invalid time format. Use HH:MM (24-hour format)';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Input for the cost of the cigarettes
                TextFormField(
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Cost',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _cost = double.tryParse(value) ?? 0.0;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the cost';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),

                // Submit button
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      // Log consumption data to the backend
                      _logConsumption();
                    }
                  },
                  child: Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}