import 'package:alquran_app/utils/colors.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class WelcomeScreen extends StatelessWidget {
  final VoidCallback
      onWelcomeComplete; // Callback untuk menyimpan status sudah dilihat

  // Tambahkan parameter onWelcomeComplete pada constructor
  WelcomeScreen({required this.onWelcomeComplete});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppColors.cardBackground, // Warna latar belakang hijau muda
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            // 0xFF162644
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Teks utama dengan tema warna hijau tua
              const Text(
                "Hello,\nEveryone!",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF162644), // Warna hijau gelap
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),

              // Teks deskripsi singkat
              const Text(
                "Selamat datang di aplikasi ini!",
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF537A5A),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // Gambar di bawah teks
              Image.asset(
                '/Users/rizkicahya/alquran_app/assets/logo/kereem-1.png', // Pastikan path ini sesuai di pubspec.yaml
                height: 200,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 40),

              // Tombol Sign In dengan warna hijau tua
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF537A5A), // Warna tombol hijau tua
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  onWelcomeComplete(); // Set isFirstLaunch menjadi false
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
                child: const Text(
                  'Sign In',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Teks navigasi ke halaman Register
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterScreen()),
                  );
                },
                child: const Text(
                  'Create New Account',
                  style: TextStyle(
                    color: Color(0xFF537A5A), // Warna teks sesuai tema hijau
                    fontSize: 16,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
