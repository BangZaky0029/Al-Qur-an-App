import 'package:alquran_app/screens/main_screen.dart/MainHome/jadwalSholat.dart';
import 'package:alquran_app/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:alquran_app/utils/colors.dart';

class CompassScreen extends StatefulWidget {
  @override
  _CompassScreenState createState() => _CompassScreenState();
}

class _CompassScreenState extends State<CompassScreen> {
  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProfileScreen()),
      );
    } else if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PrayerScheduleScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.cardBackground,
              AppColors.textPrimary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.explore,
                size: 100,
                color: Colors.white,
              ),
              const SizedBox(height: 20),
              const Text(
                "Coming Soon",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Fitur ini akan segera tersedia!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.textPrimary,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 30.0, vertical: 12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  "Kembali",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    double screenHeight = MediaQuery.of(context).size.height;
    double heightPercentage = (100 / screenHeight);
    return Container(
      height: heightPercentage * screenHeight,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.cardBackground,
            AppColors.textPrimary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: BottomNavigationBar(
        items: [
          _buildBottomNavigationBarItem(Icons.home, 'Home'),
          _buildBottomNavigationBarItem(Icons.explore, 'Kompas'),
          _buildBottomNavigationBarItem(Icons.person, 'Account'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.background,
        unselectedItemColor: AppColors.cardBackground,
        backgroundColor: AppColors.cardBackground.withOpacity(0.36),
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildBottomNavigationBarItem(
      IconData icon, String label) {
    return BottomNavigationBarItem(
      icon: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Icon(icon),
      ),
      label: label,
    );
  }
}
