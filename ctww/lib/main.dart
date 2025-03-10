import 'package:flutter/material.dart';
import 'pages/lessons_page.dart';

void main() {
  runApp(CtwwApp());
}

class CtwwApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CtWW',
      home: LessonsPage(),
    );
  }
}