import 'package:flutter/material.dart';
import 'modelVideo.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:io';

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

    // Platform view untuk Android dan iOS
    if (Platform.isAndroid) {
      WebView.platform = SurfaceAndroidWebView();
    } else if (Platform.isIOS) {
      WebView.platform = WebKitWebView();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.video.title,
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
        backgroundColor: const Color(0xFF718355),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
