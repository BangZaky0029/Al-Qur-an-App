import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TasbihScreen extends StatefulWidget {
  @override
  _TasbihScreenState createState() => _TasbihScreenState();
}

class _TasbihScreenState extends State<TasbihScreen> {
  int counter = 0;
  int set = 0;
  int range = 99;
  bool _isDarkMode = true;
  int _imageIndex = 0;
  bool _isImageVisible = true;
  Timer? _timer;
  int _elapsedSeconds = 0;

  // Daftar gambar tasbih
  final List<String> _images = [
    '/Users/rizkicahya/alquran_app/assets/images/Subhanallah.png',
    '/Users/rizkicahya/alquran_app/assets/images/Alhamdulillah.png',
    '/Users/rizkicahya/alquran_app/assets/images/Allahuakbar.png',
    '/Users/rizkicahya/alquran_app/assets/images/Lailahaillallah.png'
  ];

  @override
  void initState() {
    super.initState();
    _loadCounter();
  }

  Future<void> _saveCounter() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('counter', counter);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Counter saved!")),
    );
  }

  Future<void> _loadCounter() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      counter = prefs.getInt('counter') ?? 0;
    });
  }

  void _resetCounter() {
    setState(() {
      counter = 0;
      _stopTimer();
      _elapsedSeconds = 0;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Counter reset!")),
    );
  }

  void _loopCounter() {
    setState(() {
      if (counter == 0 && _timer == null) {
        _startTimer();
      }

      if (counter >= range - 1) {
        _toggleImageVisibility(false);

        Future.delayed(const Duration(milliseconds: 300), () {
          setState(() {
            counter = 0;
            set++;
            _imageIndex = (_imageIndex + 1) % _images.length;
          });
          _toggleImageVisibility(true);
        });
      } else {
        counter++;
      }
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _resetTimer() {
    _stopTimer();
    setState(() {
      _elapsedSeconds = 0;
    });
  }

  void _toggleImageVisibility(bool isVisible) {
    setState(() {
      _isImageVisible = isVisible;
    });
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  void _changeRange(int newRange) {
    setState(() {
      range = newRange;
      counter = 0;
    });
  }

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        _isDarkMode ? const Color(0xFF1A3A34) : Colors.white;
    final textColor = _isDarkMode ? Colors.white : Colors.black;
    final counterColor = _isDarkMode ? const Color(0xFFF9D342) : Colors.orange;
    final iconColor = _isDarkMode ? Colors.white : Colors.black;
    final buttonColor = _isDarkMode ? Colors.blue[700] : Colors.blue;
    final imageColor =
        _isDarkMode ? const Color.fromARGB(255, 252, 252, 13) : Colors.black;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: Text(
          "Tasbih Counter",
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: iconColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Set: $set",
                  style: TextStyle(fontSize: 14, color: textColor),
                ),
                const SizedBox(height: 4),
                Text(
                  "Range: $range",
                  style: TextStyle(fontSize: 14, color: textColor),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              '/Users/rizkicahya/alquran_app/assets/images/background.png',
              fit: BoxFit.cover,
              color: _isDarkMode
                  ? Colors.black.withOpacity(0.5)
                  : Colors.white.withOpacity(0.3),
              colorBlendMode: BlendMode.darken,
            ),
          ),
          // Main Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => _changeRange(33),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            range == 33 ? Colors.green : buttonColor,
                      ),
                      child: const Text("33 Times",
                          style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () => _changeRange(99),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            range == 99 ? Colors.green : buttonColor,
                      ),
                      child: const Text("99 Times",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Gambar tasbih dengan animasi
                AnimatedOpacity(
                  opacity: _isImageVisible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Image.asset(
                    _images[_imageIndex],
                    height: 150,
                    width: 200,
                    fit: BoxFit.cover,
                    color: imageColor,
                  ),
                ),
                const SizedBox(height: 20),

                // Timer Display
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: _isDarkMode
                        ? Colors.black.withOpacity(0.3)
                        : Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    _formatTime(_elapsedSeconds),
                    style: TextStyle(
                      fontSize: 18,
                      color: textColor,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  "Tasbih Counter",
                  style: TextStyle(
                    fontSize: 20,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  counter.toString().padLeft(0, '0'),
                  style: TextStyle(
                    fontSize: 60,
                    fontWeight: FontWeight.bold,
                    color: counterColor,
                  ),
                ),
                const SizedBox(height: 20),

                GestureDetector(
                  onTap: _loopCounter,
                  child: Container(
                    height: 80,
                    width: 180,
                    decoration: BoxDecoration(
                      color: buttonColor,
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          color: buttonColor!.withOpacity(0.3),
                          spreadRadius: 5,
                          blurRadius: 20,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.fiber_manual_record,
                        color: Colors.white,
                        size: 70,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(30.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(Icons.refresh, color: iconColor),
                onPressed: _resetCounter,
              ),
              IconButton(
                icon: Icon(Icons.save, color: iconColor),
                onPressed: _saveCounter,
              ),
              IconButton(
                icon: Icon(Icons.timer_off, color: iconColor),
                onPressed: _resetTimer,
              ),
              IconButton(
                icon: Icon(
                  _isDarkMode ? Icons.nightlight_round : Icons.wb_sunny,
                  color: iconColor,
                ),
                onPressed: _toggleTheme,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
