class Video {
  final String id; // ID video (videoId dari API)
  final String title; // Judul video
  final String thumbnailUrl; // URL gambar thumbnail video

  // Constructor
  Video({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
  });

  // Factory method untuk membuat objek Video dari JSON
  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id'] != null && json['id']['videoId'] != null
          ? json['id']['videoId']
          : '', // Ambil videoId (kosongkan jika tidak ada)
      title: json['snippet'] != null
          ? json['snippet']['title'] ?? 'No title'
          : 'No title', // Ambil judul dari snippet
      thumbnailUrl:
          json['snippet'] != null && json['snippet']['thumbnails'] != null
              ? json['snippet']['thumbnails']['high']['url'] ?? ''
              : '', // Ambil URL thumbnail
    );
  }
}
