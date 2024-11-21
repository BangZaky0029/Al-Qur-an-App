import 'dart:convert';
import 'package:flutter/material.dart';
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
      } else if (response.statusCode == 403) {
        throw Exception(
            'Kuota terlampaui: Batas harian untuk permintaan API telah tercapai. Silakan coba lagi besok atau kurangi frekuensi permintaan API.');
      } else {
        throw Exception(
            'Failed to fetch videos: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Error fetching videos: $e');
    }
  }

  // Menghemat penggunaan API YouTube dengan caching
  Future<List<dynamic>> fetchVideosWithCache(
      Map<String, List<dynamic>> cache) async {
    final cacheKey = 'youtube_videos';
    if (cache.containsKey(cacheKey)) {
      // Menggunakan data dari cache jika ada
      return cache[cacheKey]!;
    }

    // Jika tidak ada dalam cache, lakukan permintaan API
    final videos = await fetchVideos();

    // Simpan data di cache untuk digunakan di masa mendatang
    cache[cacheKey] = videos;

    return videos;
  }
}

// Penggunaan Cache dalam Fetch Video
final Map<String, List<dynamic>> _cache = {};

class ExampleUsageWidget extends StatelessWidget {
  final YouTubeService youtubeService = YouTubeService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('YouTube Videos Example'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: youtubeService.fetchVideosWithCache(_cache),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                textAlign: TextAlign.center, // Menjadikan teks rata tengah
                style: const TextStyle(fontSize: 18, color: Colors.red),
              ),
            );
          } else if (snapshot.hasData) {
            final videos = snapshot.data;
            return ListView.builder(
              itemCount: videos!.length,
              itemBuilder: (context, index) {
                final video = videos[index];
                return ListTile(
                  title: Text(video['snippet']['title']),
                  subtitle: Text(video['snippet']['description']),
                );
              },
            );
          } else {
            return const Center(
              child: Text(
                'Tidak ada video ditemukan.',
                textAlign: TextAlign.center, // Menjadikan teks rata tengah
                style: TextStyle(fontSize: 18),
              ),
            );
          }
        },
      ),
    );
  }
}

void main() async {
  await dotenv.load(); // Pastikan file .env sudah diload
  runApp(MaterialApp(
    home: ExampleUsageWidget(),
  ));
}
