import 'dart:convert';
import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AppTheme {
  static const Color background = Color(0xFFFFFBEE);
  static const Color cardColor = Color.fromRGBO(22, 196, 127, 0.8);
  static const Color buttonColor = Color(0xFFEB5A3C);
  static const TextStyle titleStyle = TextStyle(
    fontSize: 20,
    color: Colors.black,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle subtitleStyle = TextStyle(
      fontSize: 16, color: Colors.black54, fontWeight: FontWeight.w600);
  static const TextStyle buttonTextStyle = TextStyle(
      fontSize: 16, color: Colors.black54, fontWeight: FontWeight.bold);
  static const TextStyle fontArabStyle = TextStyle(
      fontSize: 30,
      color: Colors.black,
      fontWeight: FontWeight.bold,
      fontFamily: 'LPMQIsepMisbah',
      wordSpacing: 2.0,
      height: 2.25);
  static const TextStyle fontLatinStyle = TextStyle(
      fontSize: 15,
      color: Colors.black,
      fontWeight: FontWeight.w700,
      fontStyle: FontStyle.italic);
}

Future<List<Surah>> fetchListSurah() async {
  final response = await http.get(Uri.parse('https://equran.id/api/v2/surat'));
  if (response.statusCode == 200) {
    final SurahResponse jsonMap =
        SurahResponse.fromJson(jsonDecode(response.body));
    return jsonMap.data;
  } else {
    throw Exception('Failed to load surah');
  }
}

Future<SurahDetail> fetchListSurahDetail(int nomor) async {
  final response =
      await http.get(Uri.parse('https://equran.id/api/v2/surat/$nomor'));
  if (response.statusCode == 200) {
    final SurahDetailResponse jsonMap =
        SurahDetailResponse.fromJson(jsonDecode(response.body));
    return jsonMap.data;
  } else {
    throw Exception('Failed to load surah');
  }
}

class Surah {
  final int nomor;
  final String nama;
  final String namaLatin;
  final int jumlahAyat;
  final String tempatTurun;
  final String arti;
  final String deskripsi;
  final Map<String, String> audioFull;

  Surah({
    required this.nomor,
    required this.nama,
    required this.namaLatin,
    required this.jumlahAyat,
    required this.tempatTurun,
    required this.arti,
    required this.deskripsi,
    required this.audioFull,
  });

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      nomor: json['nomor'],
      nama: json['nama'],
      namaLatin: json['namaLatin'],
      jumlahAyat: json['jumlahAyat'],
      tempatTurun: json['tempatTurun'],
      arti: json['arti'],
      deskripsi: json['deskripsi'],
      audioFull: Map<String, String>.from(json['audioFull']),
    );
  }
}

class Ayat {
  final int nomorAyat;
  final String teksArab;
  final String teksLatin;
  final String teksIndonesia;
  final Map<String, String> audio;

  Ayat({
    required this.nomorAyat,
    required this.teksArab,
    required this.teksLatin,
    required this.teksIndonesia,
    required this.audio,
  });

  factory Ayat.fromJson(Map<String, dynamic> json) {
    return Ayat(
      nomorAyat: json['nomorAyat'],
      teksArab: json['teksArab'],
      teksLatin: json['teksLatin'],
      teksIndonesia: json['teksIndonesia'],
      audio: Map<String, String>.from(json['audio']),
    );
  }
}

class SurahPrevNext {
  final int nomor;
  final String nama;
  final String namaLatin;
  final int jumlahAyat;

  SurahPrevNext({
    required this.nomor,
    required this.nama,
    required this.namaLatin,
    required this.jumlahAyat,
  });

  factory SurahPrevNext.fromJson(Map<String, dynamic> json) {
    return SurahPrevNext(
      nomor: json['nomor'],
      nama: json['nama'],
      namaLatin: json['namaLatin'],
      jumlahAyat: json['jumlahAyat'],
    );
  }
}

class SurahDetail extends Surah {
  final List<Ayat> ayat;
  final SurahPrevNext? suratSelanjutnya;
  final SurahPrevNext? suratSebelumnya;
  SurahDetail({
    required super.nomor,
    required super.nama,
    required super.namaLatin,
    required super.jumlahAyat,
    required super.tempatTurun,
    required super.arti,
    required super.deskripsi,
    required super.audioFull,
    required this.ayat,
    required this.suratSelanjutnya,
    required this.suratSebelumnya,
  });
  factory SurahDetail.fromJson(Map<String, dynamic> json) {
    log(json.toString());
    return SurahDetail(
      nomor: json['nomor'],
      nama: json['nama'],
      namaLatin: json['namaLatin'],
      jumlahAyat: json['jumlahAyat'],
      tempatTurun: json['tempatTurun'],
      arti: json['arti'],
      deskripsi: json['deskripsi'],
      audioFull: Map<String, String>.from(json['audioFull']),
      ayat: List<Ayat>.from(json['ayat'].map((x) => Ayat.fromJson(x))),
      suratSelanjutnya: json['suratSelanjutnya'] == false
          ? SurahPrevNext(nomor: 0, nama: '', namaLatin: '', jumlahAyat: 0)
          : SurahPrevNext.fromJson(json['suratSelanjutnya']),
      suratSebelumnya: json['suratSebelumnya'] == false
          ? SurahPrevNext(nomor: 0, nama: '', namaLatin: '', jumlahAyat: 0)
          : SurahPrevNext.fromJson(json['suratSebelumnya']),
    );
  }
}

class BaseResponse {
  final int code;
  final String message;

  BaseResponse({
    required this.code,
    required this.message,
  });

  factory BaseResponse.fromJson(Map<String, dynamic> json) {
    return BaseResponse(
      code: json['code'],
      message: json['message'],
    );
  }
}

class SurahResponse extends BaseResponse {
  final List<Surah> data;

  SurahResponse({
    required super.code,
    required super.message,
    required this.data,
  });

  factory SurahResponse.fromJson(Map<String, dynamic> json) {
    return SurahResponse(
      code: json['code'],
      message: json['message'],
      data: List<Surah>.from(json['data'].map((x) => Surah.fromJson(x))),
    );
  }
}

class SurahDetailResponse extends BaseResponse {
  final SurahDetail data;

  SurahDetailResponse({
    required super.code,
    required super.message,
    required this.data,
  });

  factory SurahDetailResponse.fromJson(Map<String, dynamic> json) {
    return SurahDetailResponse(
      code: json['code'],
      message: json['message'],
      data: SurahDetail.fromJson(json['data']),
    );
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late Future<List<Surah>> futureSurah;
  bool isSearching = false;
  Timer? _searchTimer;
  String searchQuery = '';
  Future<List<Surah>> filteredSurahList = Future.value([]);
  int lastReadSurahNomor = 1;

  Future<void> _loadLastReadSurah() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      lastReadSurahNomor = prefs.getInt('lastReadSurahNomor') ?? 1; // Default to 1
    });
  }

  void _updateLastReadSurah(int nomor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lastReadSurahNomor', nomor);
    setState(() {
      lastReadSurahNomor = nomor;
    });
  }

  _onSearchChanged(String query) {
    if (_searchTimer?.isActive ?? false) _searchTimer!.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        searchQuery = query;
        filteredSurahList = futureSurah.then((surahList) {
          return surahList
              .where((surah) =>
                  surah.namaLatin.toLowerCase().contains(query.toLowerCase()))
              .toList();
        });
      });
    });
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    futureSurah = fetchListSurah();
    _loadLastReadSurah();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: isSearching || searchQuery.isNotEmpty
                ? TextField(
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'Search...',
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(color: Colors.black),
                    onTapOutside: (_) {
                      setState(() {
                        isSearching = false;
                      });
                    },
                    onChanged: _onSearchChanged,
                  )
                : const Text('Quran Simple'),
          ),
          centerTitle: true,
          backgroundColor: AppTheme.background,
          actions: [
            IconButton(
              icon: Icon(!isSearching || searchQuery.isNotEmpty
                  ? Icons.search
                  : Icons.close),
              onPressed: () {
                // Implement search functionality here
                setState(() {
                  isSearching = !isSearching;

                  if (isSearching) {
                    searchQuery = '';
                  }
                });
              },
              tooltip: !isSearching || searchQuery.isNotEmpty
                  ? 'Search'
                  : 'Close',
            ),
          ],
        ),
        body: ColoredBox(
          color: AppTheme.background,
          child: FutureBuilder<List<Surah>>(
            future: isSearching || searchQuery.isNotEmpty
                ? filteredSurahList
                : futureSurah,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData) {
                final surahList = snapshot.data!;
                final lastReadSurah = surahList.firstWhere(
                  (surah) => surah.nomor == lastReadSurahNomor,
                  orElse: () => surahList[0],
                );
                return Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(10),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: const Border(
                          left: BorderSide(color: Colors.black, width: 3),
                          right: BorderSide(color: Colors.black, width: 7),
                          top: BorderSide(color: Colors.black, width: 3),
                          bottom: BorderSide(color: Colors.black, width: 7),
                        ),
                        color: AppTheme.cardColor,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Last Read',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black54,
                                ),
                              ),
                              Text(
                                lastReadSurah.namaLatin,
                                style: AppTheme.titleStyle,
                              ),
                              Text(
                                lastReadSurah.arti,
                                style: AppTheme.subtitleStyle,
                              ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      SurahDetailPage(surah: lastReadSurah),
                                ),
                              );
                              _updateLastReadSurah(lastReadSurah.nomor);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.buttonColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: const BorderSide(
                                  color: Colors.black,
                                  width: 2,
                                ),
                              ),
                              foregroundColor: Colors.black,
                            ),
                            child: Text('Lanjutkan',
                                style: AppTheme.buttonTextStyle),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        cacheExtent: 1000,
                        itemCount: surahList.length,
                        itemBuilder: (context, index) {
                          final surah = surahList[index];
                          return Container(
                            margin: const EdgeInsets.all(10),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border(
                                left: BorderSide(color: Colors.black, width: 3),
                                right: BorderSide(color: Colors.black, width: 7),
                                top: BorderSide(color: Colors.black, width: 3),
                                bottom: BorderSide(color: Colors.black, width: 7),
                              ),
                              color: AppTheme.cardColor,
                            ),
                            child: Column(
                              children: [
                                Text(surah.namaLatin, style: AppTheme.titleStyle),
                                Text(surah.arti, style: AppTheme.subtitleStyle),
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              SurahDetailPage(surah: surah),
                                        ),
                                      );
                                      _updateLastReadSurah(surah.nomor);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.buttonColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        side: BorderSide(
                                          color: Colors.black,
                                          width: 2,
                                        ),
                                      ),
                                      foregroundColor: Colors.black,
                                    ),
                                    child: Text('Baca Surah',
                                        style: AppTheme.buttonTextStyle),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              }
              return const Center(child: Text('No data available'));
            },
          ),
        ),
      ),
    );
  }
}

class SurahDetailPage extends StatefulWidget {
  final Surah surah;

  const SurahDetailPage({super.key, required this.surah});

  @override
  State<SurahDetailPage> createState() => _SurahDetailPageState();
}

class _SurahDetailPageState extends State<SurahDetailPage> {
  late Future<SurahDetail> futureSurahDetail;
  int fontSizeArab = AppTheme.fontArabStyle.fontSize!.toInt();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    futureSurahDetail = fetchListSurahDetail(widget.surah.nomor);

    _scrollController.addListener(_saveScrollPosition);
    
    // Load saved position after build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadScrollPosition();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_saveScrollPosition);
    _scrollController.dispose();
    super.dispose();
  }

  // Alternative approach using a different timing method
  void _loadScrollPosition() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'scroll_position_${widget.surah.nomor}';
    final savedPosition = prefs.getDouble(key);
    
    if (savedPosition != null) {
      // Store value for use after build completes
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Add a small delay to ensure rendering is complete
        Future.delayed(Duration(milliseconds: 500), () {
          if (_scrollController.hasClients) {
            try {
              _scrollController.animateTo(
                savedPosition,
                duration: Duration(milliseconds: 1000),
                curve: Curves.easeInOut
              );
            } catch (e) {
              debugPrint('Error scrolling: $e');
            }
          }
        });
      });
    }
  }

  // Save scroll position
  void _saveScrollPosition() {
    if (_scrollController.hasClients) {
      SharedPreferences.getInstance().then((prefs) {
        String key = 'scroll_position_${widget.surah.nomor}';
        prefs.setDouble(key, _scrollController.offset);
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.surah.namaLatin),
        backgroundColor: AppTheme.background,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return Container(
                      height: 200.00,
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.black,
                          width: 4,
                        ),
                        color: AppTheme.background,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Settings',
                            style: AppTheme.titleStyle,
                          ),
                          const SizedBox(height: 20),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border(
                                left: BorderSide(color: Colors.black, width: 3),
                                right:
                                    BorderSide(color: Colors.black, width: 7),
                                top: BorderSide(color: Colors.black, width: 3),
                                bottom:
                                    BorderSide(color: Colors.black, width: 7),
                              ),
                              color: AppTheme.buttonColor,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed: () {
                                    setState(() {
                                      if(fontSizeArab > 20) {
                                        fontSizeArab--;
                                      }
                                    });
                                  },
                                ),
                                Text('Font Size',
                                    style: AppTheme.buttonTextStyle),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () {
                                    setState(() {
                                      if(fontSizeArab < 40) {
                                        fontSizeArab++;
                                      }
                                    });
                                  },
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  });
            },
          ),
        ],
      ),
      body: ColoredBox(
        color: AppTheme.background,
        child: Center(
          child: FutureBuilder<SurahDetail>(
            future: futureSurahDetail,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (snapshot.hasData) {
                final surahDetail = snapshot.data!;
                return ListView.builder(
                  controller: _scrollController,
                  itemCount: surahDetail.ayat.length,
                  itemBuilder: (context, index) {
                    final ayat = surahDetail.ayat[index];
                    return Container(
                      margin: const EdgeInsets.all(10),
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, top: 30, bottom: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border(
                          left: BorderSide(color: Colors.black, width: 3),
                          right: BorderSide(color: Colors.black, width: 7),
                          top: BorderSide(color: Colors.black, width: 3),
                          bottom: BorderSide(color: Colors.black, width: 7),
                        ),
                        color: AppTheme.cardColor,
                      ),
                      constraints: const BoxConstraints(
                        minHeight: 150,
                        maxHeight: double.infinity,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${ayat.nomorAyat.toString()}.',
                                  style: AppTheme.titleStyle),
                              const SizedBox(width: 10),
                              Flexible(
                                child: Text(
                                  ayat.teksArab,
                                  style: AppTheme.fontArabStyle.copyWith(
                                    fontSize: fontSizeArab.toDouble(),
                                  ),
                                  textDirection: TextDirection
                                      .rtl, // Ensure RTL for Arabic
                                  softWrap:
                                      true, // Allow wrapping (default, but explicit)
                                  maxLines: 10, // Allow multiple lines
                                  overflow: TextOverflow
                                      .ellipsis, // Show ellipsis if still overflows
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ayat.teksLatin,
                                style: AppTheme.fontLatinStyle,
                              ),
                            const SizedBox(height: 20),
                              Text(ayat.teksIndonesia,
                                  style: AppTheme.subtitleStyle),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              }
              return const Text('No data available');
            },
          ),
        ),
      ),
    );
  }
}
