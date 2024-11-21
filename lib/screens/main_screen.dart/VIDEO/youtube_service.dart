import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class YouTubeService {
  final String apiKey =
      dotenv.env['YOUTUBE_API_KEY'] ?? ''; // Gunakan key dari .env
  final String channelId =
      'UClvc6c04-xEYKFFyeP3yjKA'; // Channel ID yang ingin digunakan

  Future<List<dynamic>> fetchVideos() async {
    if (apiKey.isEmpty) {
      throw Exception('API Key is missing. Please check your .env file.');
    }

    if (channelId.isEmpty) {
      throw Exception('Channel ID is missing.');
    }

    final String url =
        'https://www.googleapis.com/youtube/v3/search?part=snippet&channelId=$channelId&maxResults=10&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null && data['items'] != null) {
          return data['items']; // Mengembalikan daftar video
        } else {
          throw Exception('No data found from the API response.');
        }
      } else {
        throw Exception(
            'Failed to fetch videos: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Error fetching videos: $e');
    }
  }
}
