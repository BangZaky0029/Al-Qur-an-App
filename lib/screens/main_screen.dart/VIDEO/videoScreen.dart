import 'package:alquran_app/utils/colors.dart';
import 'package:flutter/material.dart';
import 'youtube_service.dart';
import 'modelVideo.dart';
import 'videoWatching.dart';

class VideoDakwahPage extends StatelessWidget {
  final YouTubeService youTubeService = YouTubeService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Video Dakwah',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF718355),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: youTubeService.fetchVideos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}',
                  style: TextStyle(color: Colors.red)),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No videos found',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            );
          } else {
            final List<Video> videos = snapshot.data!
                .map((item) => Video.fromJson(item))
                .where((video) => video.id.isNotEmpty)
                .toList();

            return ListView.builder(
              itemCount: videos.length,
              itemBuilder: (context, index) {
                final video = videos[index];
                return GestureDetector(
                  onTap: () {
                    // Navigasi ke halaman menonton video
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VideoWatchingPage(video: video),
                      ),
                    );
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.cardBackground,
                          AppColors.background,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      // borderRadius: BorderRadius.circular(12),
                    ),
                    child: Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 8.0), // Memberikan jarak antar card
                      color: AppColors
                          .background, // Set warna Card menjadi transparan agar gradien terlihat
                      elevation: 3, // Sedikit elevation untuk efek bayangan
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            12), // Sesuaikan dengan Container di luar
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(
                            8.0), // Tambahkan padding untuk ruang di dalam card
                        child: ListTile(
                          leading: video.thumbnailUrl.isNotEmpty
                              ? Image.network(video.thumbnailUrl)
                              : const Icon(Icons.image_not_supported, size: 40),
                          title: Text(
                            video.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          trailing: const Icon(
                            Icons.play_circle,
                            color: AppColors.textPrimary,
                            size: 35,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
