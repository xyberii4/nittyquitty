import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:nittyquitty/services/db_requests.dart';

class VapesScreen extends StatefulWidget {
  @override
  _VapesScreenState createState() => _VapesScreenState();
}

class _VapesScreenState extends State<VapesScreen> {
  final _formKey = GlobalKey<FormState>(); // Key for the form
  final TextEditingController _timeController = TextEditingController();

  int _puffs = 0; // Number of puffs
  double _mg = 0.0; // Mg of nicotine
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
      "product": "vape",
      "user_id": await getUserId(), // Replace with the actual user ID
      "mg": _mg,
      "quantity": _puffs,
      "cost": _cost,
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
            content: Text('Vape data has been saved.'),
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
            content: Text('Failed to save vape data. Please try again.'),
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
        title: Text('Vape Input'),
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
                // Input for the number of puffs
                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Number of Puffs',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _puffs = int.tryParse(value) ?? 0;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the number of puffs';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Time input
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

                // Input for the nicotine strength in mg
                TextFormField(
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Nicotine Strength (mg)',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _mg = double.tryParse(value) ?? 0.0;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the nicotine strength';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Input for the cost of the vape
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