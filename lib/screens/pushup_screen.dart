// lib/screens/pushup_screen.dart
import 'package:flutter/material.dart';

class PushupScreen extends StatelessWidget {
  const PushupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Push Up Screen\n(Camera Feature Here)', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 24)),
      ),
    );
  }
}