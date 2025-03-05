import 'package:flutter/material.dart';

class VapesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Vapes')),
      body: Center(
        child: Text('Vapes Page', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}