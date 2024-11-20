import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthProvider with ChangeNotifier {
  String? _userPhoneNumber;
  String? _userEmail;
  String? _userName;
  String? _profilePictureUrl;
  int? _userId;
  final String _baseUrl = 'https://zaky.yappsdev.com/api/quran/auth';

  String? get userPhoneNumber => _userPhoneNumber;
  String? get userEmail => _userEmail;
  String? get userName => _userName;
  String? get profilePictureUrl => _profilePictureUrl;
  int? get userId => _userId;

  void setUserPhoneNumber(String phoneNumber) {
    _userPhoneNumber = phoneNumber;
    notifyListeners();
  }

  void setUserEmail(String email) {
    _userEmail = email;
    notifyListeners();
  }

  void setUserName(String name) {
    _userName = name;
    notifyListeners();
  }

  void setUserId(int id) {
    _userId = id;
    notifyListeners();
  }

  void setProfilePictureUrl(String? url) {
    _profilePictureUrl = url;
    notifyListeners();
  }

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  void setLoginStatus(bool status) {
    _isLoggedIn = status;
    notifyListeners();
  }

  String formatPhoneNumber(String phoneNumber) {
    phoneNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');
    if (phoneNumber.startsWith('0')) {
      return '62' + phoneNumber.substring(1);
    } else if (!phoneNumber.startsWith('62')) {
      return '62' + phoneNumber;
    }
    return phoneNumber;
  }

  Future<Map<String, dynamic>> register(String email, String phoneNumber,
      String password, String userName) async {
    final url = Uri.parse('$_baseUrl/register');
    final formattedPhoneNumber = formatPhoneNumber(phoneNumber);

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "email": email,
          "phone_number": formattedPhoneNumber,
          "password": password,
          "user_name": userName,
        }),
      );

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        return {"success": true, "message": responseData['message']};
      } else {
        final errorData = json.decode(response.body);
        return {
          "success": false,
          "message": errorData['detail'] ?? "Registration failed"
        };
      }
    } catch (e) {
      return {"success": false, "message": "Error occurred: $e"};
    }
  }

  Future<Map<String, dynamic>> verifyOtp(
      String email, String phoneNumber, String otp) async {
    final url = Uri.parse('$_baseUrl/verify-otp');
    final formattedPhoneNumber = formatPhoneNumber(phoneNumber);

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "email": email,
          "phone_number": formattedPhoneNumber,
          "otp": otp,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return {"success": true, "message": responseData['message']};
      } else {
        final errorData = json.decode(response.body);
        return {
          "success": false,
          "message": errorData['detail'] ?? "OTP verification failed"
        };
      }
    } catch (e) {
      return {"success": false, "message": "Error occurred: $e"};
    }
  }

  Future<Map<String, dynamic>> resendOtp(String phoneNumber) async {
    final url = Uri.parse('$_baseUrl/resend-otp');
    final formattedPhoneNumber = formatPhoneNumber(phoneNumber);

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "phone_number": formattedPhoneNumber,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return {"success": true, "message": responseData['message']};
      } else {
        final errorData = json.decode(response.body);
        return {
          "success": false,
          "message": errorData['detail'] ?? "Failed to resend OTP"
        };
      }
    } catch (e) {
      return {"success": false, "message": "Error occurred: $e"};
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$_baseUrl/login');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "email": email,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData.containsKey("user_id") &&
            responseData["user_id"] != null) {
          int? userId = int.tryParse(responseData["user_id"].toString());
          if (userId == null) {
            return {
              "success": false,
              "message": "Invalid response: user_id is not a valid integer"
            };
          }

          setUserId(userId);
          setUserEmail(responseData["email"] ?? "");
          setUserPhoneNumber(responseData["phone_number"] ?? "");
          setUserName(responseData["user_name"] ?? "");
          setProfilePictureUrl(responseData["picture"] ?? "");

          setLoginStatus(true);

          return {"success": true};
        } else {
          return {
            "success": false,
            "message": "Invalid response: Missing user_id"
          };
        }
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        return {
          "success": false,
          "message": errorData['detail'] ??
              "Login failed with status: ${response.statusCode}"
        };
      }
    } catch (e) {
      return {"success": false, "message": "An error occurred: $e"};
    }
  }

  Future<bool> updateProfilePicture(
      File imageFile, BuildContext context) async {
    if (_userId == null) {
      print("User ID is null. Please login first.");
      return false;
    }

    final url = Uri.parse('$_baseUrl/upload-profile-picture');
    var request = http.MultipartRequest('POST', url);

    request.fields['user_id'] = _userId!.toString();
    request.files
        .add(await http.MultipartFile.fromPath('file', imageFile.path));

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final decodedData = json.decode(responseData);

        setProfilePictureUrl(decodedData['picture_url']);
        return true;
      } else {
        print(
            "Failed to update profile picture with status: ${response.statusCode}");
        return false;
      }
    } catch (error) {
      print("Error updating profile picture: $error");
      return false;
    }
  }

  Future<void> fetchProfilePicture(String userId) async {
    final url = Uri.parse('$_baseUrl/get-profile-picture/$userId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        setProfilePictureUrl(decodedData['picture_url']);
      } else {
        print(
            "Failed to fetch profile picture with status: ${response.statusCode}");
      }
    } catch (error) {
      print("Error fetching profile picture: $error");
    }
  }

  void logout() {
    _userPhoneNumber = null;
    _userEmail = null;
    _userName = null;
    _profilePictureUrl = null;
    _userId = null;
    _isLoggedIn = false;
    notifyListeners();
  }
}
