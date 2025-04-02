import 'package:flutter/material.dart';
import 'package:nittyquitty/screens/nicotine_types/input_nic_functions.dart';
import 'package:nittyquitty/services/db_requests.dart';

class CigarettesScreen extends StatefulWidget {
  const CigarettesScreen({super.key});

  @override
  _CigarettesScreenState createState() => _CigarettesScreenState();
}

class _CigarettesScreenState extends State<CigarettesScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _timeController = TextEditingController();

  int _cigarettes = 0;
  double _cost = 0.0;
  DateTime? _selectedTime;

  Future<void> _logConsumption() async {
    if (_selectedTime == null) return;
    bool successful = await logConsumption(product: "cigarette", mg: 10, quantity: _cigarettes, cost: _cost, timestamp: _selectedTime);

    if (successful) {
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
                     int? intValue = int.tryParse(value);
                    if (intValue == null) {
                      return 'Please enter a valid number';
                    } else if (intValue < 0 || intValue > 10) {
                      return 'The number must be between 1-10';
                    }
                    return null;
                  },
                ), 
                SizedBox(height: 16),

                TextFormField(
                  controller: _timeController,
                  keyboardType: TextInputType.datetime,
                  decoration: InputDecoration(
                    labelText: 'Time (HH:MM)',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    if (isValidTime(value)) {
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
                    if (!isValidTime(value)) {
                      return 'Invalid time format. Use HH:MM (24-hour format)';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

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
                    } int? intValue = int.tryParse(value);
                    if (intValue == null) {
                      return 'Please enter a valid number';
                    } else if (intValue < 0 || intValue > 50 ) {
                      return 'The number must be between 1-50';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),

                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
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