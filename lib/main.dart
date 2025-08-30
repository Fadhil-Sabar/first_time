import 'dart:convert';
import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import 'package:flutter_animate/flutter_animate.dart';

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

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

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

class CustomPageRoute extends PageRouteBuilder {
  final Widget child;

  CustomPageRoute({required this.child})
      : super(
            pageBuilder: (context, animation, secondaryAnimation) => child,
            transitionDuration: const Duration(milliseconds: 200),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOut;

              final tween = Tween(begin: begin, end: end);
              final curvedAnimation =
                  CurvedAnimation(parent: animation, curve: curve);

              return SlideTransition(
                position: tween.animate(curvedAnimation),
                child: child,
              );
            });
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorObservers: [routeObserver],
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

Future<int> getLastReadSurah() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt('lastReadSurahNomor') ?? 1;
}

void updateLastReadSurah(int nomor) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('lastReadSurahNomor', nomor);
}

class _HomePageState extends State<HomePage> with RouteAware {
  late Future<List<Surah>> futureSurah;
  bool isSearching = false;
  Timer? _searchTimer;
  String searchQuery = '';
  Future<List<Surah>> filteredSurahList = Future.value([]);
  int lastReadSurahNomor = 1;
  final _searchController = TextEditingController();

  _onSearchChanged(String query) {
    if (_searchTimer?.isActive ?? false) _searchTimer!.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        searchQuery = query;
        filteredSurahList = futureSurah.then((surahList) {
          return surahList.where((surah) {
            return surah.namaLatin
                    .toLowerCase()
                    .contains(query.toLowerCase()) ||
                surah.nomor.toString().contains(query.toLowerCase());
          }).toList();
        });
      });
    });
  }

  _fetchLastReadSurah() async {
    getLastReadSurah().then(
      (value) {
        if (mounted) {
          setState(() {
            lastReadSurahNomor = value;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    futureSurah = fetchListSurah();
    _fetchLastReadSurah();
  }

  @override
  void didPopNext() {
    super.didPopNext();
    _fetchLastReadSurah();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // This will now work correctly because the context is inside the MaterialApp
    final modalRoute = ModalRoute.of(context);
    if (modalRoute != null) {
      routeObserver.subscribe(this, modalRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: isSearching || searchQuery.isNotEmpty
              ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  onChanged: _onSearchChanged,
                  decoration: const InputDecoration(
                    hintText: 'Search Surah...',
                    border: InputBorder.none,
                  ),
                )
              : Text('Quran Simple'),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.background,
        actions: [
          IconButton(
            icon: Icon(!isSearching ? Icons.search : Icons.close),
            onPressed: () {
              setState(() {
                isSearching = !isSearching;
                if (!isSearching) {
                  searchQuery = '';
                  _searchController.clear();
                }
              });
            },
            tooltip: !isSearching ? 'Search' : 'Close',
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
              Surah lastReadSurah = Surah(
                  nomor: 0,
                  nama: '',
                  namaLatin: '',
                  jumlahAyat: 0,
                  tempatTurun: '',
                  arti: '',
                  deskripsi: '',
                  audioFull: {});
              if (lastReadSurahNomor > 0 && surahList.isNotEmpty) {
                lastReadSurah = surahList.firstWhere(
                  (surah) => surah.nomor == lastReadSurahNomor,
                  orElse: () => lastReadSurah,
                );
              }
              return ResponsiveLayout(
                  mobileWidget: ListView.builder(
                    cacheExtent: 1000,
                    itemCount: surahList.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Column(
                          children: [
                            Container(
                              margin: const EdgeInsets.all(10),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: const Border(
                                  left:
                                      BorderSide(color: Colors.black, width: 3),
                                  right:
                                      BorderSide(color: Colors.black, width: 7),
                                  top:
                                      BorderSide(color: Colors.black, width: 3),
                                  bottom:
                                      BorderSide(color: Colors.black, width: 7),
                                ),
                                color: AppTheme.cardColor,
                              ),
                              child: !(isSearching || searchQuery.isNotEmpty)
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Terakhir Dibaca',
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
                                              CustomPageRoute(
                                                child: SurahDetailPage(
                                                    surah: SurahPrevNext(
                                                  nomor: lastReadSurah.nomor,
                                                  nama: lastReadSurah.nama,
                                                  namaLatin:
                                                      lastReadSurah.namaLatin,
                                                  jumlahAyat:
                                                      lastReadSurah.jumlahAyat,
                                                )),
                                              ),
                                            );
                                            updateLastReadSurah(
                                                lastReadSurah.nomor);
                                            getLastReadSurah().then((value) {
                                              setState(() {
                                                lastReadSurahNomor = value;
                                              });
                                            });
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                AppTheme.buttonColor,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
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
                                    )
                                  : null,
                            ),
                            Divider(
                              height: 20,
                              thickness: 3,
                              indent: 11,
                              endIndent: 11,
                              color: Colors.black54,
                            )
                          ],
                        );
                      }
                      final surah = surahList[index - 1];
                      return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              CustomPageRoute(
                                child: SurahDetailPage(
                                    surah: SurahPrevNext(
                                  nomor: surah.nomor,
                                  nama: surah.nama,
                                  namaLatin: surah.namaLatin,
                                  jumlahAyat: surah.jumlahAyat,
                                )),
                              ),
                            );
                            updateLastReadSurah(surah.nomor);
                            getLastReadSurah().then((value) {
                              setState(() {
                                lastReadSurahNomor = value;
                              });
                            });
                          },
                          child: CardSurah(surah: surah));
                    },
                  ),
                  desktopWidget: ContainerSurahDesktop(surahList: surahList));
            }
            return const Center(child: Text('No data available'));
          },
        ),
      ),
    );
  }
}

class ContainerSurah extends StatelessWidget {
  const ContainerSurah({
    super.key,
    required this.surah,
  });

  final Surah surah;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 10),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${surah.nomor}. ${surah.namaLatin}',
                  style: AppTheme.titleStyle),
              Text(
                surah.nama,
                style: AppTheme.fontArabStyle,
              )
            ],
          ),
          Text(surah.arti, style: AppTheme.subtitleStyle),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${surah.tempatTurun} | ${surah.jumlahAyat} ayat',
                  style: AppTheme.subtitleStyle),
              Icon(
                Icons.keyboard_arrow_right,
                color: AppTheme.buttonColor,
              )
            ],
          ),
        ],
      ),
    );
  }
}

class ContainerSurahDesktop extends StatelessWidget {
  final List<Surah> surahList;
  const ContainerSurahDesktop({
    super.key,
    required this.surahList,
  });

  void _navigateToDetail(BuildContext context, Surah surah) {
    Navigator.push(
      context,
      CustomPageRoute(
        child: SurahDetailPage(
          surah: SurahPrevNext(
            nomor: surah.nomor,
            nama: surah.nama,
            namaLatin: surah.namaLatin,
            jumlahAyat: surah.jumlahAyat,
          ),
        ),
      ),
    );
    updateLastReadSurah(surah.nomor);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 600,
          crossAxisSpacing: 10,
          mainAxisSpacing: 5,
          childAspectRatio: 2.5,
        ),
        itemCount: surahList.length,
        itemBuilder: (context, index) {
          final surah = surahList[index];
          return MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => _navigateToDetail(context, surah),
              child: CardSurah(surah: surah),
            ),
          );
        },
      ),
    );
  }
}

class CardSurah extends StatelessWidget {
  const CardSurah({
    super.key,
    required this.surah,
  });

  final Surah surah;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 10),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${surah.nomor}. ${surah.namaLatin}',
                  style: AppTheme.titleStyle),
              Text(
                surah.nama,
                style: AppTheme.fontArabStyle,
              )
            ],
          ),
          Text(surah.arti, style: AppTheme.subtitleStyle),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${surah.tempatTurun} | ${surah.jumlahAyat} ayat',
                  style: AppTheme.subtitleStyle),
              Icon(
                Icons.keyboard_arrow_right,
                color: AppTheme.buttonColor,
              )
            ],
          ),
        ],
      ),
    );
  }
}

class ContainerSurahDetail extends StatelessWidget {
  const ContainerSurahDetail({
    super.key,
    required this.surah,
  });

  final Surah surah;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
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
      child: ExpansionTile(
        tilePadding: const EdgeInsets.only(left: 20, right: 20, top: 0),
        childrenPadding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
        expandedAlignment: Alignment.topLeft,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(surah.namaLatin, style: AppTheme.titleStyle),
                Text(
                  surah.nama,
                  style: AppTheme.fontArabStyle,
                )
              ],
            ),
          ],
        ),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(surah.arti, style: AppTheme.subtitleStyle),
              const SizedBox(height: 8),
              Text('${surah.tempatTurun} | ${surah.jumlahAyat} ayat',
                  style: AppTheme.subtitleStyle),
              Transform.translate(
                offset: const Offset(-8, 0),
                child: Html(
                  data: '<div> ${surah.deskripsi} </div>',
                  style: {
                    "div": Style(
                        textAlign: TextAlign.justify,
                        margin: Margins.zero,
                        fontSize:
                            FontSize(AppTheme.subtitleStyle.fontSize ?? 0),
                        fontWeight: FontWeight.w600,
                        color: Colors.black54),
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SurahDetailPage extends StatefulWidget {
  final SurahPrevNext surah;

  const SurahDetailPage({super.key, required this.surah});

  @override
  State<SurahDetailPage> createState() => _SurahDetailPageState();
}

class _SurahDetailPageState extends State<SurahDetailPage> {
  late Future<SurahDetail> futureSurahDetail;
  int fontSizeArab = AppTheme.fontArabStyle.fontSize!.toInt();
  late AutoScrollController _scrollController;
  bool _hasScrolledToSavedPosition = false; // Add this flag
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    futureSurahDetail = fetchListSurahDetail(widget.surah.nomor);
    _scrollController = AutoScrollController();
    _scrollController.addListener(_saveScrollPosition);
    _loadFontSize();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_saveScrollPosition);
    _scrollController.dispose();
    super.dispose();
  }

  // Load scroll position - called only when data is ready
  void _loadScrollPosition() async {
    if (_hasScrolledToSavedPosition) return; // Prevent multiple calls

    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'scroll_position_${widget.surah.nomor}';
      final savedPosition = prefs.getDouble(key);
      if (savedPosition != null && _scrollController.hasClients) {
        // Wait a bit more to ensure ListView is fully rendered
        await Future.delayed(const Duration(milliseconds: 100));

        if (_scrollController.hasClients) {
          final maxScroll = _scrollController.position.maxScrollExtent;
          final targetPosition =
              savedPosition > maxScroll ? maxScroll : savedPosition;

          await _scrollController.animateTo(
            targetPosition,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading scroll position: $e');
      }
    } finally {
      _hasScrolledToSavedPosition = true; // Set the flag to true
    }
  }

  // Save scroll position
  void _saveScrollPosition() {
    if (_scrollController.hasClients && _hasScrolledToSavedPosition) {
      SharedPreferences.getInstance().then((prefs) {
        String key = 'scroll_position_${widget.surah.nomor}';
        prefs.setDouble(key, _scrollController.offset);
      });
    }
  }

  void _scrollToAyat(int ayatNumber) {
    if (ayatNumber > 0) {
      final targetIndex = ayatNumber > widget.surah.jumlahAyat
          ? widget.surah.jumlahAyat + 1 // +1 for footer
          : ayatNumber; // Ayat index in ListView`

      _scrollController.scrollToIndex(
        targetIndex,
        preferPosition: AutoScrollPosition.begin,
        duration: const Duration(milliseconds: 10),
      );
    }
  }

  void _changeFontSize(int size) {
    SharedPreferences.getInstance().then((prefs) {
      String key = 'font_size_arab';
      prefs.setInt(key, size);
    });
  }

  void _loadFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    final savedFontSize = prefs.getInt('font_size_arab');
    if (savedFontSize != null && savedFontSize >= 20 && savedFontSize <= 40) {
      setState(() {
        fontSizeArab = savedFontSize;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Ayat',
            border: InputBorder.none,
          ),
          onChanged: (value) {
            // Handle search logic
            setState(() {
              searchQuery = value;
            });
          },
        ),
        backgroundColor: AppTheme.background,
        actions: [
          IconButton(
              onPressed: () {
                _scrollToAyat(int.tryParse(searchQuery) ?? 0);
              },
              icon: const Icon(Icons.arrow_forward)),
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
                                      if (fontSizeArab > 20) {
                                        fontSizeArab--;
                                        _changeFontSize(fontSizeArab);
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
                                      if (fontSizeArab < 40) {
                                        fontSizeArab++;
                                        _changeFontSize(fontSizeArab);
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

                // Load scroll position only when data is ready
                if (!_hasScrolledToSavedPosition) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _loadScrollPosition();
                  });
                }

                return ListView.builder(
                  controller: _scrollController,
                  itemCount:
                      surahDetail.ayat.length + 2, // +2 for header and footer
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      // Header
                      return AutoScrollTag(
                        key: ValueKey(index),
                        controller: _scrollController,
                        index: index,
                        child: Column(
                          children: [
                            ContainerSurahDetail(surah: surahDetail),
                            const Divider(
                              height: 20,
                              thickness: 3,
                              indent: 12,
                              endIndent: 12,
                              color: Colors.black54,
                            ),
                          ],
                        ),
                      );
                    } else if (index == surahDetail.ayat.length + 1) {
                      // Footer
                      return AutoScrollTag(
                        key: ValueKey(index),
                        controller: _scrollController,
                        index: index,
                        child: ButtonPrevNext(surahDetail: surahDetail),
                      );
                    } else {
                      // Ayat items
                      final ayatIndex = index - 1;
                      final ayatValue = surahDetail.ayat[ayatIndex];

                      return AutoScrollTag(
                        key: ValueKey(index),
                        controller: _scrollController,
                        index: index,
                        child: Container(
                          margin: const EdgeInsets.all(10),
                          padding: const EdgeInsets.only(
                              left: 20, right: 20, top: 30, bottom: 20),
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${ayatValue.nomorAyat}.',
                                      style: AppTheme.titleStyle),
                                  const SizedBox(width: 10),
                                  Flexible(
                                    child: Text(
                                      ayatValue.teksArab,
                                      style: AppTheme.fontArabStyle.copyWith(
                                        fontSize: fontSizeArab.toDouble(),
                                      ),
                                      textDirection: TextDirection.rtl,
                                      softWrap: true,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(ayatValue.teksLatin,
                                      style: AppTheme.fontLatinStyle),
                                  const SizedBox(height: 20),
                                  Text(ayatValue.teksIndonesia,
                                      style: AppTheme.subtitleStyle),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }
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

class ButtonPrevNext extends StatelessWidget {
  const ButtonPrevNext({
    super.key,
    required this.surahDetail,
  });

  final SurahDetail surahDetail;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      child: Row(
        spacing: 5,
        children: [
          // ignore: unrelated_type_equality_checks
          surahDetail.suratSebelumnya != false &&
                  surahDetail.suratSebelumnya?.nomor != 0
              ? Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: const Border(
                        left: BorderSide(color: Colors.black, width: 3),
                        right: BorderSide(color: Colors.black, width: 7),
                        top: BorderSide(color: Colors.black, width: 3),
                        bottom: BorderSide(color: Colors.black, width: 7),
                      ),
                      color: AppTheme.buttonColor,
                    ),
                    child: TextButton(
                      onPressed: () {
                        // Navigate to previous surah
                        Navigator.replace(context,
                            oldRoute: ModalRoute.of(context)!,
                            newRoute: CustomPageRoute(
                                child: SurahDetailPage(
                                    surah: surahDetail.suratSebelumnya!)));

                        updateLastReadSurah(surahDetail.suratSebelumnya!.nomor);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.arrow_back_ios_new_outlined,
                              size: 15),
                          const SizedBox(width: 8),
                          Text('Surat Sebelumnya',
                              style: AppTheme.buttonTextStyle
                                  .copyWith(fontSize: 14)),
                        ],
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
          // ignore: unrelated_type_equality_checks
          surahDetail.suratSelanjutnya != false &&
                  surahDetail.suratSelanjutnya?.nomor != 0
              ? Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: const Border(
                        left: BorderSide(color: Colors.black, width: 3),
                        right: BorderSide(color: Colors.black, width: 7),
                        top: BorderSide(color: Colors.black, width: 3),
                        bottom: BorderSide(color: Colors.black, width: 7),
                      ),
                      color: AppTheme.buttonColor,
                    ),
                    child: TextButton(
                      // ignore: unrelated_type_equality_checks
                      onPressed: () {
                        // Navigate to next surah
                        Navigator.replace(context,
                            oldRoute: ModalRoute.of(context)!,
                            newRoute: CustomPageRoute(
                                child: SurahDetailPage(
                                    surah: surahDetail.suratSelanjutnya!)));

                        updateLastReadSurah(
                            surahDetail.suratSelanjutnya!.nomor);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Surat Berikutnya',
                              style: AppTheme.buttonTextStyle
                                  .copyWith(fontSize: 14)),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_ios_outlined,
                              size: 15),
                        ],
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }
}

class ResponsiveLayout extends StatelessWidget {
  final Widget mobileWidget;
  final Widget desktopWidget;

  const ResponsiveLayout(
      {super.key, required this.mobileWidget, required this.desktopWidget});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth <= 900) {
        return mobileWidget;
      } else {
        return desktopWidget;
      }
    });
  }
}
