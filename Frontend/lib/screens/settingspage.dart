import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = false;
  bool staySignedIn = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      staySignedIn = prefs.getBool('staySignedIn') ?? true;
    });
  }

  Future<void> _saveBoolSetting(String settingName, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(settingName, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: const Text("Enable Notifications"),
              subtitle: const Text("Receive motivational reminders"),
              value: notificationsEnabled,
              onChanged: (bool value) {
                setState(() {
                  notificationsEnabled = value;
                });
                _saveBoolSetting('notificationsEnabled', value);
              },
            ),

            SwitchListTile(
              title: const Text("Stay Signed In"),
              subtitle: const Text("Remain logged in after closing the app"),
              value: staySignedIn,
              onChanged: (bool value) {
                setState(() {
                  staySignedIn = value;
                });
                _saveBoolSetting('staySignedIn', value);
              },
            ),
          ],
        ),
      ),
    );
  }
}

