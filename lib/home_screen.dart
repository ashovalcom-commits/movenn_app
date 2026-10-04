import 'package:flutter/material.dart';
import 'main.dart';
import 'instructions_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo placeholder
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade100,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Center(
                  child: Text(
                    'MOVENN',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 60),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const GameScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    textStyle: const TextStyle(fontSize: 20),
                  ),
                  child: const Text('התחל משחק'),
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const InstructionsScreen()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    textStyle: const TextStyle(fontSize: 20),
                  ),
                  child: const Text('איך משחקים?'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
