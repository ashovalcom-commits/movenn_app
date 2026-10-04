import 'package:flutter/material.dart';

class InstructionsScreen extends StatelessWidget {
  const InstructionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('איך משחקים?'),
        centerTitle: true,
      ),
      body: const Padding(
        padding: EdgeInsets.all(24.0),
        child: Center(
          child: Text(
            'הוראות המשחק יופיעו כאן',
            style: TextStyle(fontSize: 20),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
