import 'package:alquran_app/utils/colors.dart';
import 'package:flutter/material.dart';
import 'modelVideo.dart';
import 'package:webview_flutter/webview_flutter.dart';

class VideoWatchingPage extends StatefulWidget {
  final Video video;

  // Menggunakan 'const' pada konstruktor untuk widget immutable
  const VideoWatchingPage({super.key, required this.video});

  @override
  State<VideoWatchingPage> createState() => _VideoWatchingPageState();
}

class _VideoWatchingPageState extends State<VideoWatchingPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    // Inisialisasi WebViewController untuk platform Android/iOS
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) {
            debugPrint('Page finished loading: $url');
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('Error occurred: $error');
          },
        ),
      )
      ..loadRequest(
          Uri.parse('https://www.youtube.com/watch?v=${widget.video.id}'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "YouTube",
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        backgroundColor: AppColors.cardBackground,
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
