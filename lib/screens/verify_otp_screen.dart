import 'package:alquran_app/utils/colors.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:another_flushbar/flushbar.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String phoneNumber;
  final String email;

  VerifyOtpScreen({required this.phoneNumber, required this.email});

  @override
  _VerifyOtpScreenState createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _isResendButtonDisabled = true;
  int _resendCountdown = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startResendCountdown();
  }

  // Fungsi untuk memulai countdown tombol kirim ulang OTP
  void _startResendCountdown() {
    setState(() {
      _isResendButtonDisabled = true;
      _resendCountdown = 60;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendCountdown > 0) {
          _resendCountdown--;
        } else {
          _isResendButtonDisabled = false;
          _timer?.cancel();
        }
      });
    });
  }

  // Fungsi untuk memverifikasi OTP
  Future<void> _verifyOtp() async {
    if (_otpController.text.isEmpty) {
      _showNotification(
        "Kode OTP tidak boleh kosong",
        Colors.redAccent,
      );
      return;
    }

    final url =
        Uri.parse('https://zaky.yappsdev.com/api/quran/auth/verify-otp');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "phone_number": widget.phoneNumber,
        "email": widget.email,
        "otp": _otpController.text,
      }),
    );

    if (response.statusCode == 200) {
      _showSuccessNotification();
    } else {
      _showNotification(
        "Kode OTP salah atau tidak valid, coba lagi",
        Colors.redAccent,
      );
    }
  }

  // Fungsi untuk menampilkan notifikasi sukses verifikasi OTP
  void _showSuccessNotification() {
    Flushbar(
      messageText: const Text(
        "Verifikasi Berhasil! Anda akan diarahkan ke halaman login.",
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          // fontWeight: FontWeight.bold,
        ),
      ),
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(8),
      flushbarPosition: FlushbarPosition.TOP,
      backgroundGradient: const LinearGradient(
        colors: [
          AppColors.textPrimary, // Warna awal gradient hijau muda
          AppColors.cardBackground, // Warna akhir gradient hijau tua
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      icon: const Icon(
        Icons.check_circle,
        color: Colors.white,
        size: 28,
      ),
    ).show(context);

    // Tunggu beberapa saat, lalu navigasi ke halaman login
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  // Fungsi untuk menampilkan notifikasi (gagal atau berhasil) umum
  void _showNotification(String message, Color gradientEndColor) {
    Flushbar(
      messageText: Text(
        message,
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
      backgroundGradient: LinearGradient(
        colors: [
          const Color(0xFFE57373), // Warna awal gradient merah muda
          gradientEndColor, // Warna akhir gradient dinamis berdasarkan status
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ).show(context);
  }

  // Fungsi untuk mengirim ulang OTP
  Future<void> _resendOtp() async {
    final url =
        Uri.parse('https://zaky.yappsdev.com/api/quran/auth/resend-otp');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({"phone_number": widget.phoneNumber}),
    );

    if (response.statusCode == 200) {
      _showNotification(
        "OTP telah dikirim ulang ke WhatsApp Anda",
        Colors.green,
      );
      _startResendCountdown(); // Mulai ulang countdown kirim ulang
    } else {
      _showNotification(
        "Gagal mengirim ulang OTP",
        Colors.redAccent,
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Masukkan kode OTP yang dikirim ke WhatsApp Anda',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 6,
              decoration: InputDecoration(
                counterText: "",
                hintText: 'Masukkan OTP',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _verifyOtp,
              child: const Text('Verifikasi'),
            ),
            const SizedBox(height: 20),
            Text(
              _isResendButtonDisabled
                  ? 'Kirim ulang OTP dalam $_resendCountdown detik'
                  : 'Belum menerima kode OTP?',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isResendButtonDisabled ? null : _resendOtp,
              child: const Text('Kirim Ulang OTP'),
            ),
          ],
        ),
      ),
    );
  }
}
