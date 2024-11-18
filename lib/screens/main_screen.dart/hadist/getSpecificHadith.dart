import 'dart:convert';
import 'package:http/http.dart' as http;

class GetSpecificHadith {
  static const String baseUrl = "https://api.hadith.gading.dev/books";

  /// Mengambil hadith spesifik berdasarkan nomor tertentu
  Future<Map<String, dynamic>> getSpecificHadith(
      String bookName, int hadithNumber) async {
    final url = Uri.parse("$baseUrl/$bookName/$hadithNumber");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'] ?? {};
    } else {
      throw Exception('Failed to load specific hadith');
    }
  }
}
