import 'package:flutter/material.dart';

class CustomScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Custom')),
      body: Center(
        child: Text('Custom Page', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}