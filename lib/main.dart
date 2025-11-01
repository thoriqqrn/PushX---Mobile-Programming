// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // File yang digenerate oleh flutterfire
// import 'package:pushup/auth_gate.dart'; // Tambahkan import ini
import 'package:pushup/screens/splash_screen.dart'; // Tambahkan import ini

// Fungsi utama yang akan dijalankan pertama kali
void main() async {
  // Pastikan semua komponen Flutter siap sebelum menjalankan kode lain
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inisialisasi Firebase menggunakan opsi dari file firebase_options.dart
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Menjalankan aplikasi kita
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Menghilangkan banner debug
      title: 'pushX',
      theme: ThemeData(
        // Kita atur tema dasar di sini
        brightness: Brightness.light,
        scaffoldBackgroundColor: Color(0xFFF3F4F6), // Warna latar belakang abu-abu muda
        primaryColor: Color(0xFF1F2937), // Warna hitam/biru tua
      ),
      // Untuk sementara, kita tampilkan teks saja untuk memastikan setup berhasil
      home: const SplashScreen(),
    );
  }
}