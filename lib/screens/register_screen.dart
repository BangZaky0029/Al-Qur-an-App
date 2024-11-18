import 'dart:math';
import 'package:alquran_app/screens/login_screen.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'verify_otp_screen.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:alquran_app/utils/colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _waController = TextEditingController();
  final _userNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  // Fungsi untuk memformat nomor telepon menjadi format internasional
  String formatPhoneNumber(String phoneNumber) {
    phoneNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');
    if (phoneNumber.startsWith('0')) {
      phoneNumber = '62' + phoneNumber.substring(1);
    } else if (!phoneNumber.startsWith('62')) {
      phoneNumber = '62' + phoneNumber;
    }
    return phoneNumber;
  }

  // Fungsi untuk mengecek kekuatan password
  bool _isPasswordStrong(String password) {
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasDigits = password.contains(RegExp(r'[0-9]'));
    final hasSpecialCharacters =
        password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    final isAtLeast6Chars = password.length >= 6;

    return hasUppercase &&
        hasLowercase &&
        hasDigits &&
        hasSpecialCharacters &&
        isAtLeast6Chars;
  }

  // Fungsi untuk membuat saran password acak yang kuat
  String _generateStrongPassword() {
    const length = 12;
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*(),.?":{}|<>';
    Random random = Random();

    return List.generate(length, (index) => chars[random.nextInt(chars.length)])
        .join();
  }

  void _register() async {
    final formattedPhoneNumber = formatPhoneNumber(_waController.text);

    // Validasi input: Pastikan semua kolom diisi
    if (_userNameController.text.isEmpty ||
        formattedPhoneNumber.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      Flushbar(
        messageText: const Text(
          "Semua kolom wajib diisi!",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(8),
        flushbarPosition: FlushbarPosition.TOP,
        backgroundGradient: const LinearGradient(
          colors: [
            Color(0xFFE57373),
            Color(0xFFEF5350),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ).show(context);
      return;
    }

    // Validasi: Pastikan password kuat
    if (!_isPasswordStrong(_passwordController.text)) {
      String suggestedPassword = _generateStrongPassword();
      Flushbar(
        messageText: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Password kurang kuat!",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Saran password kuat:",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: suggestedPassword));
                    Flushbar(
                      messageText: const Text(
                        "Password disalin ke clipboard!",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      duration: const Duration(seconds: 2),
                      margin: const EdgeInsets.all(8),
                      borderRadius: BorderRadius.circular(8),
                      flushbarPosition: FlushbarPosition.TOP,
                      backgroundGradient: const LinearGradient(
                        colors: [
                          AppColors.textPrimary,
                          AppColors.cardBackground,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ).show(context);
                  },
                  child: Text(
                    suggestedPassword,
                    style: const TextStyle(
                      color: Colors.yellow,
                      fontSize: 14,
                      // decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.copy, color: Colors.white),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: suggestedPassword));
                    Flushbar(
                      messageText: const Text(
                        "Password disalin ke clipboard!",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      duration: const Duration(seconds: 2),
                      margin: const EdgeInsets.all(8),
                      borderRadius: BorderRadius.circular(8),
                      flushbarPosition: FlushbarPosition.TOP,
                      backgroundGradient: const LinearGradient(
                        colors: [
                          AppColors.textPrimary,
                          AppColors.cardBackground,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ).show(context);
                  },
                ),
              ],
            ),
          ],
        ),
        duration: const Duration(seconds: 5),
        margin: const EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(8),
        flushbarPosition: FlushbarPosition.TOP,
        backgroundGradient: const LinearGradient(
          colors: [
            Color(0xFFE57373),
            Color(0xFFEF5350),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ).show(context);
      return;
    }

    // Validasi: Pastikan password cocok
    if (_passwordController.text != _confirmPasswordController.text) {
      Flushbar(
        messageText: const Text(
          "Password tidak cocok!",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(8),
        flushbarPosition: FlushbarPosition.TOP,
        backgroundGradient: const LinearGradient(
          colors: [
            Color(0xFFE57373),
            Color(0xFFEF5350),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ).show(context);
      return;
    }

    // Panggil fungsi register dari AuthProvider
    final response =
        await Provider.of<AuthProvider>(context, listen: false).register(
      _emailController.text,
      formattedPhoneNumber,
      _passwordController.text,
      _userNameController.text,
    );

    // Periksa hasil respons registrasi
    if (response["success"] == true) {
      Flushbar(
        messageText: Text(
          "Kode OTP telah dikirim ke WhatsApp $formattedPhoneNumber",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(8),
        flushbarPosition: FlushbarPosition.TOP,
        backgroundGradient: const LinearGradient(
          colors: [
            AppColors.textPrimary,
            AppColors.cardBackground,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ).show(context);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => VerifyOtpScreen(
            phoneNumber: formattedPhoneNumber,
            email: _emailController.text,
          ),
        ),
      );
    } else {
      Flushbar(
        messageText: Text(
          response["message"] ?? "Registrasi gagal!",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(8),
        flushbarPosition: FlushbarPosition.TOP,
        backgroundGradient: const LinearGradient(
          colors: [
            Color(0xFFE57373),
            Color(0xFFEF5350),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ).show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        automaticallyImplyLeading:
            false, // Supaya bisa kembali ke halaman sebelumnya
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              DefaultTextStyle(
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: 'Poppins',
                ),
                child: AnimatedTextKit(
                  animatedTexts: [
                    TypewriterAnimatedText(
                      'Selamat datang di halaman Register',
                      speed: const Duration(milliseconds: 100),
                    ),
                  ],
                  totalRepeatCount: 1,
                  pause: const Duration(milliseconds: 500),
                  displayFullTextOnTap: true,
                  stopPauseOnTap: true,
                ),
              ),
              const SizedBox(height: 30),
              _buildTextField(
                controller: _userNameController,
                label: "User Name",
                hint: "Masukkan User Name",
                icon: Icons.person,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _waController,
                label: "Nomor WhatsApp",
                hint: "Masukkan nomor WhatsApp Anda",
                icon: Icons.phone,
                inputType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _emailController,
                label: "Email",
                hint: "Masukkan email Anda",
                icon: Icons.email,
                inputType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              _buildPasswordField(
                controller: _passwordController,
                label: "Password",
                hint: "Masukkan password Anda",
                isVisible: _passwordVisible,
                onTapVisibility: () {
                  setState(() {
                    _passwordVisible = !_passwordVisible;
                  });
                },
              ),
              const SizedBox(height: 20),
              _buildPasswordField(
                controller: _confirmPasswordController,
                label: "Confirm Password",
                hint: "Masukkan password Anda",
                isVisible: _confirmPasswordVisible,
                onTapVisibility: () {
                  setState(() {
                    _confirmPasswordVisible = !_confirmPasswordVisible;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _register,
                child: const Text('Register'),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginScreen(),
                    ),
                  );
                },
                child: RichText(
                  text: const TextSpan(
                    text: 'Sudah punya akun? ',
                    style: TextStyle(
                      color: Color.fromARGB(255, 33, 37, 40),
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Login',
                        style: TextStyle(
                          color: Color.fromARGB(255, 34, 38, 41),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

// Fungsi untuk membangun TextField biasa
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType inputType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        suffixIcon: Icon(icon, color: Colors.black),
      ),
    );
  }

// Fungsi untuk membangun PasswordField dengan Visibility Toggle
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isVisible,
    required VoidCallback onTapVisibility,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.visiblePassword,
      obscureText: !isVisible,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        suffixIcon: IconButton(
          icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off),
          onPressed: onTapVisibility,
        ),
      ),
    );
  }
}
