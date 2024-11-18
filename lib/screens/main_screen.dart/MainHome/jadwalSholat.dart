import 'package:alquran_app/providers/auth_provider.dart';
import 'package:alquran_app/screens/login_screen.dart';
import 'package:alquran_app/screens/main_screen.dart/HOME/home_screen.dart';
import 'package:alquran_app/screens/main_screen.dart/Kompas/compass_screen.dart';
import 'package:alquran_app/screens/main_screen.dart/hadist/hadist_screen.dart';
import 'package:alquran_app/screens/main_screen.dart/tasbih_screen.dart';
import 'package:alquran_app/screens/profile_screen.dart';
import 'package:alquran_app/utils/colors.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jadwal Sholat Berdasarkan Kota',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: PrayerScheduleScreen(),
    );
  }
}

class PrayerScheduleScreen extends StatefulWidget {
  @override
  _PrayerScheduleScreenState createState() => _PrayerScheduleScreenState();
}

class _PrayerScheduleScreenState extends State<PrayerScheduleScreen> {
  String selectedCity = "Jakarta";
  List<Map<String, String>> cities = [];
  List<dynamic> prayerTimes = [];
  bool isLoading = true;
  bool isFetching = false;
  bool isSearching = false;
  DateTime? selectedDate;
  TextEditingController searchController = TextEditingController();
  List<Map<String, String>> filteredCities = [];
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    loadCities();
    fetchPrayerTimes(selectedCity);
  }

  Future<void> loadCities() async {
    try {
      final String response =
          await rootBundle.loadString('assets/cityOfIndonesia.json');
      final List<dynamic> data = json.decode(response);
      setState(() {
        cities = data.map<Map<String, String>>((city) {
          return {"city": city["city"], "country": city["country"]};
        }).toList();
        filteredCities = cities;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchPrayerTimes(String city, {DateTime? date}) async {
    final String apiUrl = "https://api.aladhan.com/v1/calendarByCity";
    final String country = "Indonesia";
    final int month = date?.month ?? DateTime.now().month;
    final int year = date?.year ?? DateTime.now().year;
    final int method = 5;
    final String requestUrl =
        "$apiUrl?city=$city&country=$country&month=$month&year=$year&method=$method";

    try {
      setState(() {
        isFetching = true;
      });
      final response = await http.get(Uri.parse(requestUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          prayerTimes = data["data"];
          isFetching = false;
        });
      } else {
        setState(() {
          isFetching = false;
          errorMessage = "Gagal memuat jadwal sholat. Coba lagi nanti.";
        });
      }
    } catch (e) {
      setState(() {
        isFetching = false;
        errorMessage =
            "Terjadi kesalahan. Pastikan koneksi internet Anda stabil.";
      });
    }
  }

  void searchCity(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredCities = cities;
        errorMessage = "";
      } else {
        filteredCities = cities
            .where((city) =>
                city["city"]!.toLowerCase().contains(query.toLowerCase()))
            .toList();
        errorMessage = filteredCities.isEmpty ? "Kota tidak ada" : "";
      }
    });
  }

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Mendapatkan instance dari AuthProvider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (index == 2) {
      // Icon "Account"
      if (authProvider.userId != null) {
        // Jika user sudah login, arahkan ke ProfileScreen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfileScreen()),
        );
      } else {
        // Jika user belum login, arahkan ke LoginScreen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    } else if (index == 1) {
      // Icon "Kompas"
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CompassScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userName = Provider.of<AuthProvider>(context).userName ?? "User";
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              _buildTopContainer(userName),
              const SizedBox(height: 6.0),
              _buildBottomContainer(),
              const SizedBox(height: 20.0),
            ],
          ),
          _buildMiddleNavigation(),
          if (isSearching) _buildSearchResults(),
        ],
      ),
      bottomNavigationBar: Container(
        height: 100, // Tinggi Container
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
              icon: Padding(
                padding: EdgeInsets.only(
                    top: 8), // Menyesuaikan posisi vertikal ikon
                child: Icon(Icons.home),
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(
                    top: 8), // Menyesuaikan posisi vertikal ikon
                child: Icon(Icons.explore),
              ),
              label: 'Kompas',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(
                    top: 8), // Menyesuaikan posisi vertikal ikon
                child: Icon(Icons.person),
              ),
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

  Widget _buildTopContainer(String userName) {
    return Container(
      margin: const EdgeInsets.all(0.1),
      padding: const EdgeInsets.symmetric(vertical: 90.0, horizontal: 30.0),
      decoration: const BoxDecoration(
        gradient: AppTheme.gradientGreen,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(80.0),
          bottomRight: Radius.circular(80.0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(
                Icons.person,
                color: Colors.white,
              ),
              const SizedBox(width: 8.0),
              AnimatedTextKit(
                animatedTexts: [
                  TypewriterAnimatedText(
                    userName,
                    textStyle: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    speed: const Duration(milliseconds: 100),
                  ),
                ],
                totalRepeatCount: 1,
                pause: const Duration(milliseconds: 500),
                displayFullTextOnTap: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomContainer() {
    return Container(
      margin: const EdgeInsets.all(30.0),
      padding: const EdgeInsets.symmetric(vertical: 13.0, horizontal: 25.0),
      decoration: const BoxDecoration(
        gradient: AppTheme.gradientGreen,
        borderRadius: BorderRadius.all(
          Radius.circular(20.0),
        ),
        border: Border.fromBorderSide(
          BorderSide(
            color: AppTheme.textPrimary,
            width: 2.0,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderWithSearch(),
          const SizedBox(
            height: 16.0,
          ),
          _buildPrayerTimes(),
          const SizedBox(height: 16.0),
          _buildCityInfo(),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${_dayOfWeek(date.weekday)}, ${date.day}-${date.month}-${date.year}";
  }

  String _dayOfWeek(int weekday) {
    switch (weekday) {
      case 1:
        return "Senin";
      case 2:
        return "Selasa";
      case 3:
        return "Rabu";
      case 4:
        return "Kamis";
      case 5:
        return "Jumat";
      case 6:
        return "Sabtu";
      case 7:
        return "Minggu";
      default:
        return "";
    }
  }

  Widget _buildHeaderWithSearch() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: Text(
            "Jadwal Sholat",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: isSearching ? 140.0 : 73.0,
          height: 37.0,
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          decoration: BoxDecoration(
            color: AppTheme.background.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppTheme.cardBackground.withOpacity(0.9),
                blurRadius: 4.0,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (isSearching)
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: const InputDecoration(
                      hintText: "Cari Kota",
                      hintStyle: TextStyle(color: AppTheme.textPrimary),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.only(bottom: 12),
                    ),
                    style: const TextStyle(color: AppTheme.textPrimary),
                    textAlignVertical: TextAlignVertical.center,
                    onChanged: searchCity,
                  ),
                ),
              IconButton(
                icon: Icon(
                  isSearching ? Icons.close : Icons.search,
                  color: AppTheme.textPrimary,
                ),
                onPressed: () {
                  setState(() {
                    if (isSearching) {
                      searchController.clear();
                      searchCity("");
                    }
                    isSearching = !isSearching;
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPrayerTimes() {
    return isFetching
        ? const Center(child: CircularProgressIndicator())
        : prayerTimes.isNotEmpty
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Flexible(
                    child: _buildPrayerTimeItem(
                        "Imsak",
                        prayerTimes[0]["timings"]["Imsak"],
                        Icons.nightlight_round),
                  ),
                  Flexible(
                    child: _buildPrayerTimeItem("Fajr",
                        prayerTimes[0]["timings"]["Fajr"], Icons.brightness_5),
                  ),
                  Flexible(
                    child: _buildPrayerTimeItem("Dhuhr",
                        prayerTimes[0]["timings"]["Dhuhr"], Icons.wb_sunny),
                  ),
                  Flexible(
                    child: _buildPrayerTimeItem(
                        "Asr", prayerTimes[0]["timings"]["Asr"], Icons.cloud),
                  ),
                  Flexible(
                    child: _buildPrayerTimeItem(
                        "Maghrib",
                        prayerTimes[0]["timings"]["Maghrib"],
                        Icons.night_shelter),
                  ),
                  Flexible(
                    child: _buildPrayerTimeItem("Isha",
                        prayerTimes[0]["timings"]["Isha"], Icons.brightness_3),
                  ),
                ],
              )
            : const Text(
                "Tidak ada jadwal sholat untuk kota ini.",
                style: TextStyle(color: Color.fromARGB(255, 204, 23, 23)),
              );
  }

  Widget _buildPrayerTimeItem(String label, String time, IconData icon) {
    return Container(
      width: 60,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Icon(
            icon,
            size: 28,
            color: Colors.white,
          ),
          const SizedBox(height: 6),
          Text(
            time,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiddleNavigation() {
    return Positioned(
      top: 150.0,
      left: 30.0,
      right: 30.0,
      child: Container(
        height: 85.0,
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: AppTheme.textPrimary,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.background,
            width: 2.0,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.3),
              blurRadius: 4.0,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavigationItem(
              iconPath: 'assets/logo/tasbih.png',
              label: "Tasbih",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TasbihScreen()),
                );
              },
            ),
            _buildNavigationItem(
              iconPath: 'assets/logo/quran-iqro.png',
              label: "Al Qur'an",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomeView()),
                );
              },
            ),
            _buildNavigationItem(
              iconPath: 'assets/logo/quran.png',
              label: "Hadits",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HadistScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationItem({
    String? iconPath,
    IconData? iconData,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (iconPath != null)
            Image.asset(
              iconPath,
              height: 30,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.error, color: Colors.white);
              },
            )
          else if (iconData != null)
            Icon(
              iconData,
              color: Colors.white,
              size: 30,
            ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return Positioned(
      top: 310,
      left: 232,
      right: 58,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            width: 50,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6.0,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: filteredCities.isNotEmpty
                ? ListView.builder(
                    padding: const EdgeInsets.all(1.0),
                    itemCount: filteredCities.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 0.1,
                            horizontal: 16.0), // Jarak atas dan bawah
                        title: Text(
                          filteredCities[index]["city"]!,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            selectedCity = filteredCities[index]["city"]!;
                            isSearching = false;
                          });
                          fetchPrayerTimes(selectedCity);
                        },
                      );
                    },
                  )
                : Center(
                    child: Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildCityInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Berdasarkan Wilayah Anda",
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.background.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppTheme.cardBackground.withOpacity(0.9),
                blurRadius: 4.0,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: Text(
            selectedCity,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class AppTheme {
  static const gradientGreen = LinearGradient(
    colors: [Color(0xFFB5C99A), Color(0xFF718355)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const Color background = Color(0xFFE9F5DB);
  static const Color cardBackground = Color(0xFFB5C99A);
  static const Color textPrimary = Color(0xFF718355);
  static const Color textSecondary = Color(0xFF87886A);
}
