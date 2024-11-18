import 'dart:convert';
import 'package:http/http.dart' as http;

class GetHadistRange {
  static const String baseUrl = "https://api.hadith.gading.dev/books";

  /// Mengambil hadith berdasarkan rentang angka tertentu
  Future<Map<String, dynamic>> getHadithRange(
      String bookName, int start, int end) async {
    final url = Uri.parse("$baseUrl/$bookName?range=$start-$end");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'] ?? {};
    } else {
      throw Exception('Failed to load hadith range');
    }
  }
}
