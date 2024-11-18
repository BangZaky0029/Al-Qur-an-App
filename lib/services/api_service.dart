import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class ApiService {
  // URL untuk API
  final String baseUrl = 'https://zaky.yappsdev.com/api/quran/auth';
  // Url untuk testing
  // final String baseUrl = 'http://127.0.0.1:8000/auth';

  Timer? _resendOtpTimer;
  int _resendOtpCountdown = 0;

  int get resendOtpCountdown => _resendOtpCountdown;

  void startResendOtpCountdown() {
    _resendOtpCountdown = 60;
    _resendOtpTimer?.cancel();

    _resendOtpTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_resendOtpCountdown > 0) {
        _resendOtpCountdown--;
      } else {
        timer.cancel();
      }
    });
  }

  // Fungsi untuk Register
  Future<Map<String, dynamic>> register(String email, String phoneNumber,
      String password, String userName) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'phone_number': phoneNumber,
          'password': password,
          'user_name': userName, // Menambahkan user_name dalam registrasi
        }),
      );

      if (response.statusCode == 201) {
        startResendOtpCountdown();
        return {
          "success": true,
          "message": "OTP has been sent to your WhatsApp",
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          "success": false,
          "message": errorData['detail'] ?? "Registration failed",
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "An error occurred: $e",
      };
    }
  }

  // Fungsi untuk Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return {
          "success": true,
          "message": "Login successful",
          "data": responseData,
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          "success": false,
          "message": errorData['detail'] ?? "Login failed",
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "An error occurred: $e",
      };
    }
  }

  // Fungsi untuk Verifikasi OTP
  Future<Map<String, dynamic>> verifyOtp(
      String email, String phoneNumber, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verify-otp'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'phone_number': phoneNumber,
          'otp': otp,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return {
          "success": true,
          "message": "OTP verification successful",
          "data": responseData,
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          "success": false,
          "message": errorData['detail'] ?? "OTP verification failed",
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "An error occurred: $e",
      };
    }
  }

  // Fungsi untuk Resend OTP
  Future<Map<String, dynamic>> resendOtp(String phoneNumber) async {
    if (_resendOtpCountdown > 0) {
      return {
        "success": false,
        "message": "Please wait $_resendOtpCountdown seconds to resend OTP",
      };
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/resend-otp'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'phone_number': phoneNumber,
        }),
      );

      if (response.statusCode == 200) {
        startResendOtpCountdown();
        return {
          "success": true,
          "message": "OTP has been resent to your WhatsApp",
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          "success": false,
          "message": errorData['detail'] ?? "Resend OTP failed",
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "An error occurred: $e",
      };
    }
  }

  // Fungsi untuk membersihkan timer saat aplikasi ditutup atau tidak diperlukan lagi
  void dispose() {
    _resendOtpTimer?.cancel();
  }
}
