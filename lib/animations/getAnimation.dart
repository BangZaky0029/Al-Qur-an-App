import 'package:flutter/material.dart';

class AnimatedIconButton extends StatefulWidget {
  final IconData icon;

  const AnimatedIconButton({Key? key, required this.icon}) : super(key: key);

  @override
  _AnimatedIconButtonState createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<AnimatedIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.85, // Skala lebih kecil saat ditekan
      upperBound: 1.0, // Skala normal
    );
    _scaleAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.reverse();
    setState(() {
      _isPressed = true;
    });
  }

  void _onTapUp(TapUpDetails details) {
    _controller.forward();
    setState(() {
      _isPressed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: () {
        _controller.forward();
        setState(() {
          _isPressed = false;
        });
      },
      onTap: () {
        // Aksi ketika tombol ditekan
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Icon(
          widget.icon,
          color: _isPressed
              ? Colors.yellow
              : Colors.white, // Warna berubah saat ditekan
          size: 30.0,
        ),
      ),
    );
  }
}
