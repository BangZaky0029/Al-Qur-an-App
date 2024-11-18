import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;

class ApiService {
  final int method =
      5; // Metode perhitungan sesuai dengan Kementerian Agama Indonesia
  final String apiUrl = "https://api.aladhan.com/v1/calendarByCity";

  // Fungsi untuk membaca daftar kota dari file JSON lokal
  Future<List<Map<String, String>>> loadCities() async {
    try {
      final String response =
          await rootBundle.loadString('assets/cityOfIndonesia.json');
      final List<dynamic> data = json.decode(response);
      return data
          .map<Map<String, String>>((city) => {
                "city": city["city"],
                "country": city["country"],
              })
          .toList();
    } catch (e) {
      print("Error saat membaca file JSON: $e");
      return [];
    }
  }

  // Fungsi utama untuk mengambil jadwal sholat
  Future<List<dynamic>> fetchPrayerTimes({
    required String city,
    required String country,
    required int month,
    required int year,
  }) async {
    final String requestUrl =
        "$apiUrl?city=$city&country=$country&month=$month&year=$year&method=$method";

    try {
      // Mengirim request ke API dengan timeout 10 detik
      final response = await http
          .get(Uri.parse(requestUrl))
          .timeout(const Duration(seconds: 10), onTimeout: () {
        throw Exception('Request to API timed out. Please try again.');
      });

      // Memeriksa status response
      if (response.statusCode == 200) {
        // Parsing response JSON
        final data = json.decode(response.body);
        return data["data"];
      } else if (response.statusCode == 404) {
        throw Exception('City or country not found. Please check your input.');
      } else {
        throw Exception(
            'Failed to load prayer times. Status Code: ${response.statusCode}');
      }
    } on http.ClientException {
      throw Exception('Network error. Please check your internet connection.');
    } catch (e) {
      print("Error: $e");
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // Fungsi untuk mendapatkan jadwal sholat berdasarkan kota dari JSON
  Future<List<dynamic>> fetchPrayerTimesFromJson({
    required String selectedCity,
    required int month,
    required int year,
  }) async {
    try {
      // Load daftar kota dari file JSON
      final List<Map<String, String>> cities = await loadCities();

      // Cari kota yang sesuai
      final city = cities.firstWhere(
        (c) => c["city"]!.toLowerCase() == selectedCity.toLowerCase(),
        orElse: () => throw Exception('City not found in JSON'),
      );

      // Lanjutkan mengambil data dari API dengan kota yang ditemukan
      return await fetchPrayerTimes(
        city: city["city"]!,
        country: city["country"]!,
        month: month,
        year: year,
      );
    } catch (e) {
      print("Error: $e");
      throw Exception('Failed to fetch prayer times from JSON: $e');
    }
  }
}
