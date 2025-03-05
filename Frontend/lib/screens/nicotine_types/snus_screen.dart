import 'package:flutter/material.dart';

class SnusScreen extends StatefulWidget {
  @override
  _SnusScreenState createState() => _SnusScreenState();
}

class _SnusScreenState extends State<SnusScreen> {
  final _formKey = GlobalKey<FormState>();  // Key for the form

  int _portions = 0; // Number of snus portions
  String _strength = "1 dot"; // Strength (Dropdown)
  DateTime _selectedTime = DateTime.now(); // Time
  double _cost = 0.0; // Cost

  // Function to pick time using DateTime Picker
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _selectedTime.hour, minute: _selectedTime.minute),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = DateTime(
          _selectedTime.year,
          _selectedTime.month,
          _selectedTime.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Snus Input'),
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
                // Input for the number of snus portions
                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Number of Snus Portions',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _portions = int.tryParse(value) ?? 0;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the number of snus portions';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Time input button
                GestureDetector(
                  onTap: () => _selectTime(context),
                  child: AbsorbPointer(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Time',
                        hintText: '${_selectedTime.hour}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        // Time field should be selected before submitting
                        if (_selectedTime == DateTime.now()) {
                          return 'Please select a time';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Dropdown for strength selection
                DropdownButtonFormField<String>(
                  value: _strength,
                  decoration: InputDecoration(
                    labelText: 'Strength',
                    border: OutlineInputBorder(),
                  ),
                  items: ['1 dot', '2 dot', '3 dot', '4 dot', '5 dot', '6 dot']
                      .map((strength) => DropdownMenuItem<String>(
                            value: strength,
                            child: Text(strength),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _strength = value ?? '1 dot';
                    });
                  },
                  validator: (value) {
                    if (value == null || value == '1 dot') {
                      return 'Please select a valid strength';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Input for the cost of the snus
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
                      // Process data if form is valid
                      // You can add logic to save this data
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Submission Successful'),
                            content: Text('Snus data has been saved.'),
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