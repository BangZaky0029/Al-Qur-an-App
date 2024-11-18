import 'dart:ffi';
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
import 'package:animations/animations.dart';

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
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    JadwalSholatScreen(), // Halaman Utama Jadwal Sholat
    CompassScreen(), // Halaman Kompas
    ProfileScreen(), // Halaman Profil
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  bool isUserLoggedIn = false;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomNavigationBar(screenWidth, context),
    );
  }

  Widget _buildBottomNavigationBar(double screenWidth, BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final isUserLoggedIn = Provider.of<AuthProvider>(context).isLoggedIn;

    return Container(
      height: 110,
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Animated Indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (int i = 0; i < _pages.length; i++)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIndex = i;
                    });
                  },
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(
                        begin: _selectedIndex == i ? 1.0 : 0.0,
                        end: _selectedIndex == i ? 1.0 : 0.0),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeInOut,
                    builder: (context, value, child) {
                      double width = 70 + (screenWidth / 6 - 70) * value;
                      double colorOpacity = value;

                      return Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: width,
                          height: screenWidth * 0.023,
                          decoration: BoxDecoration(
                            color: _selectedIndex == i
                                ? AppColors.background.withOpacity(colorOpacity)
                                : AppColors.cardBackground.withOpacity(0),
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),

          BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Icon(Icons.home),
                ),
                label: 'Jadwal Sholat',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Icon(Icons.explore),
                ),
                label: 'Kompas',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Icon(Icons.person),
                ),
                label: 'Profil',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: AppColors.background,
            unselectedItemColor: AppColors.cardBackground,
            backgroundColor: Colors.transparent,
            type: BottomNavigationBarType.fixed,
            onTap: (int index) {
              if (index == 2) {
                if (isUserLoggedIn) {
                  // Jika pengguna sudah login, cukup panggil _onItemTapped untuk navigasi
                  _onItemTapped(index);
                } else {
                  // Jika pengguna belum login, arahkan ke halaman login
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                }
              } else {
                _onItemTapped(index);
              }
            },
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class JadwalSholatScreen extends StatefulWidget {
  @override
  _JadwalSholatScreenState createState() => _JadwalSholatScreenState();
}

class _JadwalSholatScreenState extends State<JadwalSholatScreen> {
  String selectedCity = "Jakarta";
  List<Map<String, String>> cities = [];
  List<dynamic> prayerTimes = [];
  bool isLoading = true;
  bool isFetching = false;
  bool isSearching = false;
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

  void searchCity(String query) {
    setState(() {
      if (query.isEmpty) {
        // Jika pencarian kosong, tampilkan semua kota
        filteredCities = cities;
        errorMessage = "";
      } else {
        // Menampilkan hanya kota yang dimulai dengan huruf yang sesuai query
        filteredCities = cities
            .where((city) =>
                city["city"]!.toLowerCase().startsWith(query.toLowerCase()))
            .toList();

        // Set error message jika tidak ada hasil pencarian
        errorMessage = filteredCities.isEmpty ? "Kota tidak ada" : "";
      }
    });
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
            ],
          ),
          _buildMiddleNavigation(),
          if (isSearching) _buildSearchResults(),
        ],
      ),
    );
  }

  Widget _buildTopContainer(String userName) {
    // Isi dari kontainer top (sama seperti sebelumnya)
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
      padding: const EdgeInsets.symmetric(vertical: 13.0, horizontal: 10.0),
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

  Widget _buildHeaderWithSearch() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: Text(
            "Jadwal Sholat",
            style: TextStyle(
              fontSize: 24,
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
                      hintText: "Provinsi?",
                      hintStyle: TextStyle(color: AppTheme.background),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                "Periksa Jaringan Internet Anda!",
                style: TextStyle(color: Color.fromARGB(255, 204, 23, 23)),
              );
  }

  Widget _buildPrayerTimeItem(String label, String time, IconData icon) {
    double width = MediaQuery.of(context).size.width;
    return Container(
      width: width * 0.25,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Flexible(
            child: Icon(
              icon,
              size: 28,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Flexible(
            child: Text(
              time,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiddleNavigation() {
    double screenHeight = MediaQuery.of(context).size.height;
    double heightPercentage = (100 / screenHeight);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 135.0),
      child: Container(
        height: screenHeight *
            heightPercentage, // Tetapkan tinggi secara fix agar konsisten di semua perangkat
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
    // Nilai tetap untuk posisi dan ukuran container
    double rightValue = 40.0; // Jarak tetap dari kanan
    double leftValue = 250.0; // Jarak tetap dari kiri
    double topValue = 300.0; // Jarak tetap dari atas

    double screenHeight = MediaQuery.of(context).size.height;
    double heightPercentage = (165 / screenHeight);

    return Positioned(
      top: topValue,
      left: leftValue,
      right: rightValue,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            // width: widthPercentage * screenwidth,
            height: heightPercentage * screenHeight,
            decoration: BoxDecoration(
              color: AppColors.background.withOpacity(0.9),
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
                            vertical:
                                4.0, // Mengatur jarak atas dan bawah ListTile agar lebih terlihat
                            horizontal: 16.0),
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
            fontSize: 14,
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
