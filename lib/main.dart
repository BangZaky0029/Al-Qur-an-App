import 'package:alquran_app/screens/main_screen.dart/MainHome/jadwalSholat.dart';
import 'package:alquran_app/screens/verify_otp_screen.dart';
import 'package:alquran_app/screens/login_screen.dart';
import 'package:alquran_app/screens/register_screen.dart';
import 'package:alquran_app/screens/main_screen.dart/HOME/home_screen.dart';
import 'package:alquran_app/screens/welcome_screen.dart';
import 'package:alquran_app/utils/themes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import dotenv
import 'providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Muat variabel lingkungan dari file .env
    await dotenv.load(fileName: ".env");
    print("File .env berhasil dimuat");
  } catch (e) {
    // Menangani error jika file .env tidak ditemukan atau gagal dimuat
    print("Gagal memuat file .env: $e");
  }

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState(); // Pastikan tipe returnnya sesuai
}

class _MyAppState extends State<MyApp> {
  bool isFirstLaunch = true;
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _loadInitialState();
  }

  Future<void> _loadInitialState() async {
    // Mendapatkan nilai awal dari SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
      isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    });
  }

  Future<void> _setFirstLaunchCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstLaunch', false);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Al-Quran App',
        theme: appTheme,
        initialRoute:
            isFirstLaunch ? '/welcome' : (isLoggedIn ? '/home' : '/login'),
        routes: {
          '/welcome': (context) => WelcomeScreen(
                onWelcomeComplete: _setFirstLaunchCompleted,
              ),
          '/login': (context) => LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => MainScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/verify-otp') {
            final args = settings.arguments as Map<String, String>?;

            if (args != null &&
                args.containsKey('phoneNumber') &&
                args.containsKey('email')) {
              final phoneNumber = args['phoneNumber']!;
              final email = args['email']!;

              return MaterialPageRoute(
                builder: (context) => VerifyOtpScreen(
                  phoneNumber: phoneNumber,
                  email: email,
                ),
              );
            } else {
              return MaterialPageRoute(
                builder: (context) => LoginScreen(),
                fullscreenDialog: true,
                settings: const RouteSettings(
                  arguments: 'Nomor telepon atau email tidak tersedia',
                ),
              );
            }
          }
          return MaterialPageRoute(builder: (context) => LoginScreen());
        },
      ),
    );
  }
}
