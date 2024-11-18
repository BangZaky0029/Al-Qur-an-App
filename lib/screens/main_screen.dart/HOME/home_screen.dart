import 'package:alquran_app/screens/main_screen.dart/HOME/homeControl.dart';
import 'package:alquran_app/screens/main_screen.dart/MainHome/jadwalSholat.dart';
import 'package:alquran_app/screens/main_screen.dart/hadist/hadist_screen.dart';
import 'package:alquran_app/screens/main_screen.dart/tasbih_screen.dart';
import 'package:alquran_app/screens/profile_screen.dart';
import 'package:alquran_app/screens/main_screen.dart/Surah/subSurahScreen.dart';
import 'package:alquran_app/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  // Inisialisasi HomeController di dalam HomeView
  final HomeController controller = Get.put(HomeController());
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigasi berdasarkan index
    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PrayerScheduleScreen()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProfileScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Al-Quran',
          style: TextStyle(
              color: Colors.white), // Sesuaikan warna teks jika diperlukan
        ),
        centerTitle: true,
        flexibleSpace: Container(
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
        ),
        backgroundColor:
            Colors.transparent, // Supaya background mengikuti gradient
        elevation: 0, // Sesuaikan jika ingin tanpa bayangan
      ),
      body: Column(
        children: [
          // TextField untuk Pencarian Surah
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                controller.filterSurah(
                    value); // Memanggil fungsi filter di controller
              },
              decoration: InputDecoration(
                hintText: 'Cari Surah...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              // Cek apakah data surah sudah dimuat
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (controller.filteredSurah.isEmpty &&
                  controller.isSearching.value) {
                return const Center(
                  child: Text("Surah tidak ditemukan."),
                );
              } else {
                // Menampilkan semua surah atau hasil pencarian
                return ListView.builder(
                  itemCount: controller.filteredSurah.length,
                  itemBuilder: (context, index) {
                    final surah = controller.filteredSurah[index];
                    return InkWell(
                      splashColor: AppColors.textPrimary
                          .withOpacity(0.2), // Warna efek klik
                      onTap: () {
                        // Navigasi ke SubSurahScreen dengan nomor surah
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                SubSurahScreen(surahNumber: surah.number),
                          ),
                        );
                      },
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.cardBackground,
                          child: Text(
                            "${surah.number}",
                            style: const TextStyle(color: Color(0xFFE9F5DB)),
                          ),
                        ),
                        title: Text(
                          'Surah ~ ${surah.name.transliteration.id}', // Nama surah dalam transliterasi
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${surah.numberOfVerses} Ayat | ${surah.revelation.id}', // Jumlah ayat dan tempat turunnya surah
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              surah.name.short, // Nama surah dalam tulisan Arab
                              style: const TextStyle(fontSize: 20),
                            ),
                            const Icon(
                              Icons
                                  .arrow_forward_ios, // Ikon anak panah ke kanan
                              color:
                                  Color(0xFF718355), // Warna hijau sesuai tema
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
            }),
          ),
        ],
      ),
      bottomNavigationBar: Container(
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
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.explore),
              label: 'Kompas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Account',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: AppColors.background,
          unselectedItemColor: AppColors.cardBackground,
          backgroundColor: AppColors.cardBackground.withOpacity(0.36),
          type: BottomNavigationBarType.fixed,
          onTap: _onItemTapped,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold, // Ketebalan teks ketika dipilih
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight:
                FontWeight.normal, // Ketebalan teks ketika tidak dipilih
          ),
        ),
      ),
    );
  }
}
