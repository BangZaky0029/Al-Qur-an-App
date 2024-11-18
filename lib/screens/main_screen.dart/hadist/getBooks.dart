import 'dart:convert';
import 'package:http/http.dart' as http;

class GetBooks {
  static const String baseUrl = "https://api.hadith.gading.dev/books";

  /// Mengambil daftar buku hadith
  Future<List<Map<String, dynamic>>> getBooks() async {
    final url = Uri.parse(baseUrl);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['data']);
    } else {
      throw Exception('Failed to load books');
    }
  }
}
