import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AppTheme {
  static const Color background = Color(0xFFFAEDCA);
  static const Color cardColor = Color(0xFF16C47F);
  static const Color buttonColor = Color(0xFFEB5A3C);
  static const TextStyle titleStyle = TextStyle(
    fontSize: 20,
    color: Colors.black,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle subtitleStyle = TextStyle(
      fontSize: 16, color: Colors.black54, fontWeight: FontWeight.w800);
}

Future<List<Surah>> fetchListSurah() async {
  final response = await http.get(Uri.parse('https://equran.id/api/v2/surat'));
  if (response.statusCode == 200) {
    final SurahResponse jsonMap = SurahResponse.fromJson(jsonDecode(response.body));
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

class SurahResponse {
  final int code;
  final String message;
  final List<Surah> data;

  SurahResponse({
    required this.code,
    required this.message,
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

void main() {
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

  _onSearchChanged(String query) {
    if (_searchTimer?.isActive ?? false) _searchTimer!.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        searchQuery = query;
        filteredSurahList = futureSurah.then((surahList) {
          return surahList
            .where((surah) => surah.namaLatin.toLowerCase().contains(query.toLowerCase()))
            .toList();
        });
      });
    });
  }

  @override
  void initState() {
    super.initState();
    futureSurah = fetchListSurah();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: isSearching || searchQuery.isNotEmpty ? TextField(
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
            ) : const Text('Quran Simple'),
          ),
          centerTitle: true,
          backgroundColor: AppTheme.background,
          actions: [
            IconButton(
              icon: Icon(!isSearching || searchQuery.isNotEmpty ? Icons.search : Icons.close),
              onPressed: () {
                // Implement search functionality here
                setState(() {
                  isSearching = !isSearching;

                  if(isSearching) {
                    searchQuery = '';
                  }
                });
              },
            ),
          ],
        ),
        body: ColoredBox(
          color: AppTheme.background,
          child: FutureBuilder<List<Surah>>(
            future: isSearching || searchQuery.isNotEmpty ? filteredSurahList : futureSurah,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData) {
                final surahList = snapshot.data!;
                return ListView.builder(
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
                              onPressed: () {},
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
                                  style: AppTheme.subtitleStyle),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
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
