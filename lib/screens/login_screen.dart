import 'package:alquran_app/screens/main_screen.dart/MainHome/jadwalSholat.dart';
import 'package:alquran_app/utils/colors.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'register_screen.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _passwordVisible = false;

  // Fungsi untuk proses login
  void _login() async {
    // Validasi input
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      Flushbar(
        messageText: const Text(
          "Email dan Password wajib diisi!",
          style: TextStyle(
            color: Colors.white, // Warna teks agar kontras dengan background
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(8),
        flushbarPosition: FlushbarPosition.TOP, // Muncul di atas layar
        backgroundGradient: const LinearGradient(
          colors: [
            Color(0xFFE57373), // Warna awal gradient untuk error (merah muda)
            Color(0xFFEF5350), // Warna akhir gradient
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ).show(context);
      return;
    }

    // Panggil fungsi login dari AuthProvider dan terima respons
    final response =
        await Provider.of<AuthProvider>(context, listen: false).login(
      _emailController.text,
      _passwordController.text,
    );

    // Periksa hasil respons login
    if (response["success"] == true) {
      await Flushbar(
        messageText: const Text(
          "Anda Berhasil Login!",
          style: TextStyle(
            color: Colors.white, // Warna teks agar kontras dengan background
            fontSize: 16,
          ),
        ),
        duration: const Duration(seconds: 1),
        margin: const EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(8),
        flushbarPosition: FlushbarPosition.TOP, // Muncul di atas layar
        backgroundGradient: const LinearGradient(
          colors: [
            AppColors.cardBackground, // Warna awal gradient
            AppColors.textPrimary, // Warna akhir gradient
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ).show(context);

      // Navigasi ke halaman berikutnya setelah Flushbar selesai
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Flushbar(
        messageText: Text(
          response["message"] ?? "Login gagal!",
          style: const TextStyle(
            color: Colors.white, // Warna teks agar kontras dengan background
            fontSize: 16,
          ),
        ),
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(8),
        flushbarPosition: FlushbarPosition.TOP, // Muncul di atas layar
        backgroundGradient: const LinearGradient(
          colors: [
            Color(0xFFE57373), // Warna awal gradient untuk error (merah muda)
            Color(0xFFEF5350), // Warna akhir gradient untuk error (merah)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ).show(context);
    }
  }

  void _onLoginSuccess(BuildContext context, String userName, int userId,
      String email, String phoneNumber, String profilePictureUrl) {
    // Update status login di AuthProvider dengan informasi pengguna
    Provider.of<AuthProvider>(context, listen: false).login(
      userName,
      phoneNumber,
    );

    // Arahkan ke MainScreen setelah login berhasil
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MainScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: AppColors.cardBackground,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DefaultTextStyle(
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                  color: Colors.black,
                ),
                child: AnimatedTextKit(
                  animatedTexts: [
                    TypewriterAnimatedText(
                      'Selamat datang di halaman Login',
                      speed: const Duration(milliseconds: 100),
                    ),
                  ],
                  totalRepeatCount: 1,
                  pause: const Duration(milliseconds: 500),
                  displayFullTextOnTap: true,
                  stopPauseOnTap: true,
                ),
              ),
              const SizedBox(height: 50),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Masukkan email Anda',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  suffixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                keyboardType: TextInputType.visiblePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Masukkan password Anda',
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passwordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                  ),
                ),
                obscureText: !_passwordVisible,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                child: const Text('Login'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const RegisterScreen(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        const begin = Offset(1.0, 0.0); // Mulai dari kanan
                        const end = Offset.zero; // Berakhir di posisi normal
                        const curve = Curves.easeInOutCubicEmphasized;

                        var tween = Tween(begin: begin, end: end)
                            .chain(CurveTween(curve: curve));
                        var slideAnimation = animation.drive(tween);

                        return SlideTransition(
                          position: slideAnimation,
                          child: child,
                        );
                      },
                    ),
                  );
                },
                child: RichText(
                  text: const TextSpan(
                    text: 'Belum punya akun? ',
                    style: TextStyle(
                      color: Color.fromARGB(255, 33, 37, 40),
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Register',
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
}
