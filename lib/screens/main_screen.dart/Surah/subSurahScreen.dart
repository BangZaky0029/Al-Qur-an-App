import 'dart:async';
import 'dart:ui';
import 'package:alquran_app/screens/main_screen.dart/Surah/subSurahController.dart';
import 'package:alquran_app/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart'; // Import untuk clipboard
import 'package:another_flushbar/flushbar.dart';

class SubSurahScreen extends StatefulWidget {
  final int surahNumber;

  SubSurahScreen({Key? key, required this.surahNumber}) : super(key: key);

  @override
  _SubSurahScreenState createState() => _SubSurahScreenState();
}

class FadeInTafsirDialog extends StatelessWidget {
  final String tafsirText;

  const FadeInTafsirDialog({Key? key, required this.tafsirText})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Tafsir Ayat",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF718355)),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, color: Color(0xFF718355)),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: tafsirText));
                    Flushbar(
                      messageText: const Text(
                        "Text disalin!",
                        style: TextStyle(
                          color: Colors.white, // Warna teks
                          fontSize: 16, // Ukuran teks
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
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  tafsirText,
                  style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  "Tutup",
                  style: TextStyle(
                      color: Color(0xFF718355), fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubSurahScreenState extends State<SubSurahScreen> {
  final SubSurahController subSurahController = Get.put(SubSurahController());
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> _cardKeys = []; // Menyimpan GlobalKey untuk setiap card

  int? playingVerseIndex;
  bool isPlayingAll = false;
  bool showScrollToTopButton = false;

  Map<int, String> currentDurationTexts = {};
  Map<int, double> currentProgresses = {};
  Map<int, double> maxDurations = {};
  StreamSubscription? positionSubscription;
  StreamSubscription? durationSubscription;
  Duration totalDuration = Duration.zero;
  Timer? appBarTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      subSurahController.fetchSubSurah(widget.surahNumber).then((_) {
        if (subSurahController.subSurah.value.data?.verses != null) {
          setState(() {
            _initializeKeys(
                subSurahController.subSurah.value.data.verses.length);
          });
        }
      });
    });

    // Listener untuk menampilkan tombol scroll ke atas
    _scrollController.addListener(() {
      if (_scrollController.offset > 300 && !showScrollToTopButton) {
        setState(() {
          showScrollToTopButton = true;
        });
      } else if (_scrollController.offset <= 100 && showScrollToTopButton) {
        setState(() {
          showScrollToTopButton = false;
        });
      }
    });

    // Listeners untuk AudioPlayer
    positionSubscription = _audioPlayer.onPositionChanged.listen((duration) {
      if (playingVerseIndex != null && !isPlayingAll) {
        setState(() {
          currentProgresses[playingVerseIndex!] = duration.inSeconds.toDouble();
          currentDurationTexts[playingVerseIndex!] =
              "${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}";
        });
      }
    });

    durationSubscription = _audioPlayer.onDurationChanged.listen((duration) {
      if (playingVerseIndex != null) {
        setState(() {
          maxDurations[playingVerseIndex!] = duration.inSeconds.toDouble();
        });
      }
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      setState(() {
        if (isPlayingAll) {
          _playNextVerseInAll();
        } else {
          if (playingVerseIndex != null) {
            currentDurationTexts[playingVerseIndex!] = "0:00";
            currentProgresses[playingVerseIndex!] = 0.0;
            playingVerseIndex = null;
          }
        }
      });
    });
  }

  @override
  void didUpdateWidget(covariant SubSurahScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.surahNumber != widget.surahNumber) {
      // Jika surahNumber berubah, lakukan fetch ulang data
      subSurahController.fetchSubSurah(widget.surahNumber).then((_) {
        if (subSurahController.subSurah.value.data?.verses != null) {
          setState(() {
            _initializeKeys(
                subSurahController.subSurah.value.data.verses.length);
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    positionSubscription?.cancel();
    durationSubscription?.cancel();
    appBarTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  // Inisialisasi GlobalKey untuk setiap card
  void _initializeKeys(int itemCount) {
    _cardKeys.clear();
    for (int i = 0; i < itemCount; i++) {
      _cardKeys.add(GlobalKey());
    }
  }

  Future<void> _playVerse(String url, int index) async {
    if (playingVerseIndex != null && playingVerseIndex != index) {
      await _audioPlayer.stop();
    }
    await _audioPlayer.play(UrlSource(url));
    setState(() {
      playingVerseIndex = index;
      currentDurationTexts[index] = "0:00";
      currentProgresses[index] = 0.0;
      maxDurations[index] = 1.0;
    });
  }

  void _playAllAyat(List<dynamic> verses) async {
    if (verses.isEmpty) return; // Cek jika verses kosong

    setState(() {
      isPlayingAll = true;
      playingVerseIndex = 0;
      totalDuration = Duration.zero; // Reset total durasi
    });

    appBarTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        totalDuration = Duration(seconds: totalDuration.inSeconds + 1);
      });
    });

    _playVerse(verses[0].audio.primary, 0);
  }

  void _playNextVerseInAll() async {
    final verses = subSurahController.subSurah.value.data.verses;
    if (verses.isNotEmpty &&
        playingVerseIndex != null &&
        playingVerseIndex! + 1 < verses.length) {
      int nextIndex = playingVerseIndex! + 1;
      _playVerse(verses[nextIndex].audio.primary, nextIndex);
    } else {
      setState(() {
        isPlayingAll = false;
        playingVerseIndex = null;
        totalDuration = Duration.zero;
      });
      appBarTimer?.cancel();
    }
  }

  void _stopAllAyat() async {
    await _audioPlayer.stop();
    setState(() {
      isPlayingAll = false;
      playingVerseIndex = null;
      currentDurationTexts.clear();
      currentProgresses.clear();
      totalDuration = Duration.zero;
    });
    appBarTimer?.cancel();
  }

  void _stopVerse() async {
    await _audioPlayer.stop();
    setState(() {
      if (playingVerseIndex != null) {
        currentDurationTexts[playingVerseIndex!] = "0:00";
        currentProgresses[playingVerseIndex!] = 0.0;
        playingVerseIndex = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final surahData = subSurahController.subSurah.value.data;
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
              subSurahController.isLoading.value
                  ? "Memuat..."
                  : isPlayingAll
                      ? "${surahData.name.long} - ${_formatDuration(totalDuration)}"
                      : surahData.name.long,
              style: const TextStyle(color: Colors.white),
            )),
        actions: [
          IconButton(
            icon: Icon(
                isPlayingAll ? Icons.stop_circle : Icons.play_circle_fill,
                size: 30),
            color: Colors.white,
            onPressed: () {
              final verses = subSurahController.subSurah.value.data.verses;
              if (verses != null && verses.isNotEmpty) {
                if (isPlayingAll) {
                  _stopAllAyat();
                } else {
                  _playAllAyat(verses);
                }
              }
            },
          ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFB5C99A),
                Color(0xFF718355),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 5,
      ),
      body: Obx(() {
        if (subSurahController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        } else if (surahData?.verses == null || surahData.verses.isEmpty) {
          return const Center(child: Text("Data tidak tersedia"));
        } else {
          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16.0),
            itemCount: surahData.verses.length,
            itemBuilder: (context, index) {
              final key = _cardKeys[index];
              final verse = surahData.verses[index];
              bool isThisVersePlaying = playingVerseIndex == index;

              // Modifikasi pada widget card di _SubSurahScreenState
              return Card(
                key: key,
                color:
                    isThisVersePlaying ? const Color(0xFFB5C99A) : Colors.white,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: isThisVersePlaying
                                ? AppColors.background
                                : const Color(0xFFB5C99A),
                            child: Text(
                              "${verse.number.inSurah}",
                              style: TextStyle(
                                  color: isThisVersePlaying
                                      ? AppColors.textPrimary
                                      : Colors.white),
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.copy,
                                    color: Color(0xFF718355)),
                                onPressed: () {
                                  // Menyalin teks arab dan terjemahannya
                                  Clipboard.setData(ClipboardData(
                                    text:
                                        "${verse.text.arab}\n\nArtinya:\n${verse.translation.id}",
                                  ));
                                  Flushbar(
                                    // Menggunakan widget Container untuk membuat background gradient
                                    messageText: const Text(
                                      "Text disalin!",
                                      style: TextStyle(
                                        color: Colors
                                            .white, // Ubah warna teks sesuai kebutuhan
                                        fontSize: 16,
                                      ),
                                    ),
                                    duration: const Duration(seconds: 3),
                                    margin: const EdgeInsets.all(8),
                                    borderRadius: BorderRadius.circular(8),
                                    flushbarPosition: FlushbarPosition
                                        .TOP, // Muncul di atas layar
                                    backgroundGradient: const LinearGradient(
                                      colors: [
                                        AppColors
                                            .textPrimary, // Warna awal gradient
                                        AppColors
                                            .cardBackground, // Warna akhir gradient
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ).show(context);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.menu_book,
                                    color: Color(0xFF718355)),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Dialog(
                                        backgroundColor: Colors.transparent,
                                        child: BackdropFilter(
                                          filter: ImageFilter.blur(
                                              sigmaX: 2, sigmaY: 2),
                                          child: FadeInTafsirDialog(
                                              tafsirText: verse.tafsir.id.long),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        verse.text.arab,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color:
                              isThisVersePlaying ? Colors.white : Colors.black,
                        ),
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        verse.translation.id,
                        style: TextStyle(
                            fontSize: 16,
                            color: isThisVersePlaying
                                ? const Color.fromARGB(255, 255, 255, 255)
                                : Colors.grey[700]),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            currentDurationTexts[index] ?? "0:00",
                            style: const TextStyle(fontSize: 14),
                          ),
                          CircleAvatar(
                            radius: 15,
                            backgroundColor: const Color(0xFF718355),
                            child: GestureDetector(
                              onTap: () async {
                                if (isThisVersePlaying) {
                                  _stopVerse();
                                } else {
                                  await _playVerse(verse.audio.primary, index);
                                }
                              },
                              child: Icon(
                                isThisVersePlaying
                                    ? Icons.stop
                                    : Icons.play_arrow,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
      }),
      floatingActionButton: showScrollToTopButton
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 17),
                FloatingActionButton(
                  backgroundColor: const Color(0xFF718355),
                  onPressed: () {
                    _scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: const Icon(Icons.arrow_upward, color: Colors.white),
                ),
              ],
            )
          : null,
    );
  }
}

// Fungsi untuk memformat durasi
String _formatDuration(Duration duration) {
  return "${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}";
}
