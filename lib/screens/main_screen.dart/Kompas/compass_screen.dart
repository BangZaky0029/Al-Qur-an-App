import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:alquran_app/utils/colors.dart';

class CompassScreen extends StatefulWidget {
  @override
  _CompassScreenState createState() => _CompassScreenState();
}

class _CompassScreenState extends State<CompassScreen> {
  double? _qiblaDirection;
  StreamSubscription<Position>? _positionStream;

  @override
  void initState() {
    super.initState();
    _fetchLocationAndCalculateQibla();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  Future<void> _fetchLocationAndCalculateQibla() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print("Layanan lokasi tidak diaktifkan.");
        _showPermissionDialog();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print("Izin lokasi ditolak.");
          _showPermissionDialog();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print("Izin lokasi ditolak secara permanen.");
        _showPermissionDialog();
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        _qiblaDirection =
            _calculateQiblaDirection(position.latitude, position.longitude);
        print("Arah kiblat dihitung: $_qiblaDirection");
      });
    } catch (e) {
      print("Error mendapatkan lokasi: $e");
    }
  }

  double _calculateQiblaDirection(double lat, double lng) {
    const double kaabaLat = 21.4225;
    const double kaabaLng = 39.8262;

    double latRad = lat * (pi / 180.0);
    double lngRad = lng * (pi / 180.0);
    double kaabaLatRad = kaabaLat * (pi / 180.0);
    double kaabaLngRad = kaabaLng * (pi / 180.0);

    double dLng = kaabaLngRad - lngRad;
    double y = sin(dLng) * cos(kaabaLatRad);
    double x = cos(latRad) * sin(kaabaLatRad) -
        sin(latRad) * cos(kaabaLatRad) * cos(dLng);
    double qiblaRad = atan2(y, x);

    double qiblaDeg = qiblaRad * (180.0 / pi);
    return (qiblaDeg + 360.0) % 360.0;
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Izin Lokasi Diperlukan"),
          content: const Text(
              "Aplikasi membutuhkan akses lokasi untuk menentukan arah Qiblat."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Geolocator.openAppSettings(); // Buka pengaturan aplikasi
              },
              child: const Text("Buka Pengaturan"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double? qiblaDirection = _qiblaDirection;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          'Kompas Qiblat',
          style: TextStyle(
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SafeArea(
        child: Center(
          child: qiblaDirection != null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset(
                          'assets-1/images/kompas-2.png',
                          height: 250,
                          width: 250,
                        ),
                        Transform.rotate(
                          angle: (qiblaDirection * (pi / 180) * -1),
                          child: Image.asset(
                            'assets-1/images/arrow.png',
                            height: 100,
                            width: 100,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Putar perangkat Anda hingga arah Ka’bah berada di tengah',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                  ],
                )
              : const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text(
                      'Memuat lokasi...',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
