import 'package:flutter/material.dart';

class SnusScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Snus')),
      body: Center(
        child: Text('Snus Page', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}