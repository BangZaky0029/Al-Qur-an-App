import 'package:alquran_app/screens/main_screen.dart/Kompas/compass_screen.dart';
import 'package:alquran_app/screens/main_screen.dart/MainHome/jadwalSholat.dart';
import 'package:alquran_app/utils/colors.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
// import 'package:alquran_app/screens/main_screen.dart/HOME/home_screen.dart';
// import 'package:alquran_app/screens/main_screen.dart/tasbih_screen.dart';
import 'package:alquran_app/screens/profile_screen.dart';
import 'package:flutter/services.dart';
// import 'package:get/get.dart';
import 'dart:ui';
import 'getBooks.dart';
import 'getHadithRange.dart';
// import 'getSpecificHadith.dart';

class HadistScreen extends StatefulWidget {
  @override
  _HadistScreenState createState() => _HadistScreenState();
}

class _HadistScreenState extends State<HadistScreen> {
  String selectedSource = "bukhari";
  String selectedSourceName = ""; // Tambahkan variabel ini
  List<Map<String, String>> hadithList = [];
  List<Map<String, String>> mainHadithList = [];
  List<Map<String, String>> filteredHadithList = [];
  bool isLoading = false;
  TextEditingController searchController = TextEditingController();

  final GetBooks _getBooks = GetBooks();
  final GetHadistRange _getHadithRange = GetHadistRange();

  @override
  void initState() {
    super.initState();
    fetchMainHadithList(); // Load daftar sumber hadith utama
    fetchInitialHadithList(); // Load hadith awal dari beberapa sumber
  }

  Future<void> fetchMainHadithList() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await _getBooks.getBooks();
      setState(() {
        mainHadithList = response.map<Map<String, String>>((item) {
          return {
            "name": item["name"] ?? "",
            "id": item["id"] ?? "",
          };
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching main hadist list: $e");
    }
  }

  Future<void> fetchInitialHadithList() async {
    setState(() {
      isLoading = true;
      hadithList = [];
    });

    try {
      // Misalnya, mengambil 50 hadith pertama dari setiap sumber
      List<String> initialSources = [
        "abu-daud",
        "ahmad",
        "bukhari",
        "darimi",
        "ibnu-majah",
        "malik",
        "muslim",
        "nasai",
        "tirmidzi"
      ];

      for (String source in initialSources) {
        final hadithsResponse =
            await _getHadithRange.getHadithRange(source, 1, 50);

        if (hadithsResponse.containsKey("hadiths") &&
            hadithsResponse["hadiths"] is List) {
          final hadiths = hadithsResponse["hadiths"] as List;
          hadiths.forEach((item) {
            hadithList.add({
              "source": source.toUpperCase(),
              "arab": item["arab"] ?? "",
              "translation": item["translation"] ?? "",
              "id": item["id"] ?? "",
            });
          });
        }
      }
      filteredHadithList = hadithList;
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching initial Hadist: $e");
    }
  }

  void _showMainHadithSelectionDialog() {
    showDialog(
      context: context,
      barrierColor:
          Colors.black.withOpacity(0.5), // Warna gelap semi transparan
      builder: (BuildContext context) {
        return Stack(
          children: [
            AlertDialog(
              title: const Text("Pilih Sumber Hadits"),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: mainHadithList.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        mainHadithList[index]["name"] ?? "",
                        style: const TextStyle(
                            fontSize: 14, color: Colors.black87),
                      ),
                      onTap: () {
                        _updateHadithList(mainHadithList[index]["id"] ?? "",
                            mainHadithList[index]["name"] ?? "");
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _updateHadithList(String source, String name) {
    setState(() {
      selectedSource = source;
      selectedSourceName =
          name; // Update selectedSourceName sesuai pilihan user
      fetchHadithList(source, name);
    });
  }

  Future<void> fetchHadithList(String source, String name) async {
    setState(() {
      isLoading = true;
      hadithList = [];
    });

    try {
      final hadithsResponse =
          await _getHadithRange.getHadithRange(source, 1, 10);

      if (hadithsResponse.containsKey("hadiths") &&
          hadithsResponse["hadiths"] is List) {
        final hadiths = hadithsResponse["hadiths"] as List;

        setState(() {
          hadithList = hadiths.map<Map<String, String>>((item) {
            return {
              "arab": item["arab"] ?? "Teks Arab tidak tersedia",
              "id": item["id"] ?? "ID tidak tersedia",
              "source": name,
            };
          }).toList();
          filteredHadithList = hadithList;
          isLoading = false;
        });
      } else {
        throw Exception("Unexpected response format: $hadithsResponse");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching hadiths: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to fetch hadiths. Please try again."),
        ),
      );
    }
  }

  // int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      // _selectedIndex = index;
    });

    // Navigasi berdasarkan index
    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProfileScreen()),
      );
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CompassScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // double screenHeight = MediaQuery.of(context).size.height;
    // double heightPercentage = (100 / screenHeight);
    return Scaffold(
      body: isLoading
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(), // Loading circle
                  SizedBox(height: 16), // Jarak antara circle dan teks
                  Text(
                    "Loading data, please wait...", // Label teks di bawah circle
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey, // Warna teks
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.29,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.cardBackground, AppColors.textPrimary],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(150),
                      bottomRight: Radius.circular(150),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(150),
                      bottomRight: Radius.circular(150),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Image.asset(
                            'assets/images/masjid-2.png',
                            width: 500,
                            height: 500,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 40.0,
                          left: 16.0,
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 28.0,
                            ),
                            onPressed: () {
                              Navigator.pop(
                                  context); // Kembali ke layar sebelumnya
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _showMainHadithSelectionDialog,
                      child: const Text("Pilih Sumber Hadist",
                          style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 10),
                    if (selectedSourceName
                        .isNotEmpty) // Tampilkan button jika ada pilihan
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.cardBackground,
                          foregroundColor: AppColors.textPrimary,
                        ),
                        child: Text(selectedSourceName),
                      ),
                  ],
                ),
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          itemCount: filteredHadithList.length,
                          itemBuilder: (context, index) {
                            return _buildAnimatedCard(index);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildAnimatedCard(int index) {
    final hadith = filteredHadithList[index];
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 300 + index * 100),
      tween: Tween<double>(begin: 0, end: 1),
      curve: Curves.easeOut,
      builder: (context, double value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 50 * (1 - value)),
            child: child,
          ),
        );
      },
      child: InkWell(
        onTap: () => _showHadithDetailDialog(hadith), // Aksi ketika card diklik
        child: Card(
          margin: const EdgeInsets.symmetric(
              vertical: 4.0), // Mengurangi jarak antar kartu
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.all(12.0), // Mengurangi padding dalam kartu
            title: Text(
              "${hadith["source"]}: ${hadith["arab"] ?? ""}",
              style: const TextStyle(fontSize: 16, color: Colors.black87),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              hadith["id"] ?? "",
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: IconButton(
              icon: const Icon(Icons.book, color: AppColors.textPrimary),
              onPressed: () => _showHadithDetailDialog(hadith),
            ),
          ),
        ),
      ),
    );
  }

// POP-UP / Method Untuk menampilkan Detail Hadist
  void _showHadithDetailDialog(Map<String, String> hadith) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "Detail Hadist (${hadith["source"]})",
                  style: const TextStyle(
                    overflow:
                        TextOverflow.ellipsis, // Menghindari overflow teks
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy, color: Color(0xFF718355)),
                onPressed: () {
                  // Menyalin teks Arab dan terjemahan ke clipboard
                  Clipboard.setData(ClipboardData(
                    text:
                        "${hadith["arab"] ?? ""}\n\nArtinya: ${hadith["id"] ?? ""}",
                  ));

                  // Menampilkan notifikasi dengan Flushbar
                  Flushbar(
                    messageText: const Text(
                      "Text disalin!",
                      style: TextStyle(
                        color: Colors.white, // Ubah warna teks sesuai kebutuhan
                        fontSize: 16,
                        // fontWeight: FontWeight.bold,
                      ),
                    ),
                    duration: const Duration(seconds: 3),
                    margin: const EdgeInsets.all(8),
                    borderRadius: BorderRadius.circular(8),
                    flushbarPosition:
                        FlushbarPosition.TOP, // Muncul di atas layar
                    backgroundGradient: const LinearGradient(
                      colors: [
                        AppColors.textPrimary, // Warna awal gradient
                        AppColors.cardBackground, // Warna akhir gradient
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ).show(context);
                },
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hadith["arab"] ?? "",
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                Text(
                  hadith["id"] ?? "",
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Tutup"),
            ),
          ],
        );
      },
    );
  }
}
