// lib/auth_gate.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'screens/login_screen.dart'; // Halaman login kita

// Halaman utama (akan kita buat nanti)
import 'screens/main_screen.dart'; 

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // StreamBuilder ini akan "mendengarkan" perubahan status login
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Jika snapshot tidak punya data, artinya pengguna belum login
        if (!snapshot.hasData) {
          return LoginScreen(); // Tampilkan halaman login
        }

        // Jika ada data, artinya pengguna sudah login
        // Nanti kita akan arahkan ke MainScreen(), untuk sekarang Scaffold saja
        return MainScreen();
      },
    );
  }
}