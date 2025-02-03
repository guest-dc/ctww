import 'package:flutter/material.dart';

import 'utils/colors.dart';

import 'pages/lessons_page.dart';
// import 'pages/story_walk_page.dart';
// import 'pages/anatomy_page.dart';
// import 'pages/matching_page.dart';

void main() {
  runApp(CtwwApp());
}

class CtwwApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CtWW - Chinese the "Write" Way',
      theme: ThemeData(
        primaryColor: colorRED,
      ),
      home: LessonsPage(),
    );
  }
}