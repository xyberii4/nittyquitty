import 'package:flutter/material.dart';

class CigarettesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cigarettes')),
      body: Center(
        child: Text('Cigarettes Page', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}


