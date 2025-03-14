import 'package:flutter/material.dart';

class VapesScreen extends StatefulWidget {
  @override
  _VapesScreenState createState() => _VapesScreenState();
}

class _VapesScreenState extends State<VapesScreen> {
  final _formKey = GlobalKey<FormState>();  // Key for the form

  int _puffs = 0; // Number of puffs
  String _strength = "Low"; // Strength (Dropdown)
  DateTime _selectedTime = DateTime.now(); // Time
  double _cost = 0.0; // Cost

  // Function to pick time using DateTime Picker
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _selectedTime.hour, minute: _selectedTime.minute),
    );
    if (picked != null && picked != TimeOfDay(hour: _selectedTime.hour, minute: _selectedTime.minute)) {
      setState(() {
        _selectedTime = DateTime(_selectedTime.year, _selectedTime.month, _selectedTime.day, picked.hour, picked.minute);
      });
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
                        if (value == null || value.isEmpty) {
                          return 'Please select the time';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Input for the number of Mg
                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Number of Mg',
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
                      // Process data if form is valid
                      // You can add logic to save this data
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
