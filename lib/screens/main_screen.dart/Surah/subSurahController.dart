import 'dart:convert';
import 'package:alquran_app/models/subSurah.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class SubSurahController extends GetxController {
  // Variabel observable untuk menyimpan data SubSurah
  var subSurah = SubSurah(
    code: 0,
    status: '',
    message: '',
    data: Data(
      number: 0,
      sequence: 0,
      numberOfVerses: 0,
      name: Name(
        short: '',
        long: '',
        transliteration: Translation(en: '', id: ''),
        translation: Translation(en: '', id: ''),
      ),
      revelation: Revelation(arab: '', en: '', id: ''),
      tafsir: DataTafsir(id: ''),
      preBismillah: null,
      verses: [],
    ),
  ).obs;

  // Loading indicator
  var isLoading = true.obs;

  // Fungsi untuk mengambil data subSurah berdasarkan nomor surah
  Future<void> fetchSubSurah(int surahNumber) async {
    try {
      isLoading(true);
      final response = await http
          .get(Uri.parse('https://api.quran.gading.dev/surah/$surahNumber'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        subSurah.value = SubSurah.fromJson(data);
      } else {
        Get.snackbar('Error', 'Failed to load surah');
      }
    } catch (e) {
      print("Error fetching subSurah data: $e");
      Get.snackbar('Error', 'An error occurred while fetching the data');
    } finally {
      isLoading(false);
    }
  }
}
