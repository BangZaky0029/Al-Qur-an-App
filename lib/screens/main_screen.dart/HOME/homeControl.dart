import 'dart:convert';
import 'package:alquran_app/models/surah.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class HomeController extends GetxController {
  // Menyimpan semua surah
  var allSurah = <Surah>[].obs;
  // Menyimpan surah yang difilter
  var filteredSurah = <Surah>[].obs;
  // Indikator loading dan pencarian aktif
  var isLoading = true.obs;
  var isSearching = false.obs;

  @override
  void onInit() {
    super.onInit();
    getAllSurah(); // Memuat semua surah saat controller diinisialisasi
  }

  // Fungsi untuk mengambil semua surah dari API
  Future<void> getAllSurah() async {
    try {
      Uri url = Uri.parse('https://api.quran.gading.dev/surah');
      var res = await http.get(url);

      if (res.statusCode == 200) {
        List data = (json.decode(res.body) as Map<String, dynamic>)["data"];
        if (data.isNotEmpty) {
          allSurah.value = data.map((e) => Surah.fromJson(e)).toList();
          filteredSurah.value = allSurah; // Menampilkan semua surah di awal
        }
      } else {
        throw Exception('Failed to load surah data');
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      isLoading.value = false; // Sembunyikan loading setelah data dimuat
    }
  }

  // Fungsi untuk memfilter surah berdasarkan nama
  void filterSurah(String query) {
    if (query.isEmpty) {
      isSearching.value = false;
      filteredSurah.value = allSurah; // Tampilkan semua surah jika query kosong
    } else {
      isSearching.value = true;
      filteredSurah.value = allSurah
          .where((surah) => surah.name.transliteration.id
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    }
  }
}
