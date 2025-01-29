import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('Quran Simple'),
          centerTitle: true,
          backgroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('Hello World!',style: TextStyle(
            backgroundColor: Color(0xFF00FF00),
          ),),
        ),
      ),
    );
  }
}
