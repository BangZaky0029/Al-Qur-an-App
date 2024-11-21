import 'package:alquran_app/screens/main_screen.dart/MainHome/jadwalSholat.dart';
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
                "Assalamu'alamualaikum,\nEveryone!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF162644), // Warna hijau gelap
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),

              // Teks deskripsi singkat
              const Text(
                "Sudahkah membaca Al Qur'an hari ini?",
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF537A5A),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // Gambar di bawah teks
              Image.asset(
                '/Users/rizkicahya/alquran_app/assets-1/logo/kereem-1.png', // Pastikan path ini sesuai di pubspec.yaml
                height: 200,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 40),

              // Tombol Sign In dengan warna hijau tua
              Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF537A5A), // Warna dasar tombol
                      borderRadius:
                          BorderRadius.circular(30), // Bentuk sudut tombol
                      boxShadow: [
                        // Inner shadow
                        BoxShadow(
                          color: Colors.black
                              .withOpacity(0.5), // Warna inner shadow
                          offset: const Offset(3, 3), // Posisi bayangan
                          blurRadius: 6, // Blur radius
                          spreadRadius: -4, // Spread negatif untuk inner shadow
                        ),
                        BoxShadow(
                          color:
                              Colors.white.withOpacity(0.2), // Warna highlight
                          offset:
                              const Offset(2, 2), // Posisi bayangan highlight
                          blurRadius: 6, // Blur radius
                          spreadRadius: -4, // Spread negatif untuk inner shadow
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.transparent, // Background transparan
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: const BorderSide(
                              color: AppColors.background, width: 3), // Outline
                        ),
                        elevation:
                            0, // Hilangkan efek shadow default ElevatedButton
                      ),
                      onPressed: () {
                        onWelcomeComplete(); // Set isFirstLaunch menjadi false
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MainScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Get Start',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 100),

                  // Teks navigasi ke halaman Register
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors
                              .cardBackground, // Warna tombol hijau tua
                          padding: const EdgeInsets.symmetric(
                              horizontal: 130, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                            side: const BorderSide(
                              color:
                                  AppColors.background, // Warna outline border
                              width: 3, // Ketebalan outline border
                            ),
                          ),
                          shadowColor: AppColors.textPrimary,
                          elevation: 3,
                        ),
                        onPressed: () {
                          onWelcomeComplete(); // Set isFirstLaunch menjadi false
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginScreen()),
                          );
                        },
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors
                              .cardBackground, // Warna tombol hijau tua
                          padding: const EdgeInsets.symmetric(
                              horizontal: 120, vertical: 15),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                              side: const BorderSide(
                                  color: AppColors.background, width: 3)),
                          shadowColor: AppColors.textPrimary,
                          elevation: 3,
                        ),
                        onPressed: () {
                          onWelcomeComplete(); // Set isFirstLaunch menjadi false
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const RegisterScreen()),
                          );
                        },
                        child: const Text(
                          'Register',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
