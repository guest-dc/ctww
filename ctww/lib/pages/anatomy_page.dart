import 'package:ctww/utils/colors.dart';
import 'package:flutter/material.dart';
import '../utils/nav_bar.dart';
import '../utils/lesson_bar.dart';

class AnatomyPage extends StatefulWidget {
  @override
  _AnatomyPageState createState() => _AnatomyPageState();
}

class _AnatomyPageState extends State<AnatomyPage> {
  bool _isLessonBarVisible = false;

  void _toggleLessonBar() {
    setState(() {
      _isLessonBarVisible = !_isLessonBarVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NavBar(),
      body: Stack(
        children: [
          Center(
            child: Text(
              'Anatomy page stuff goes here',
              style: TextStyle(fontSize: 20),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: LessonBar(isVisible: _isLessonBarVisible, toggleVisibility: _toggleLessonBar),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleLessonBar,
        backgroundColor: colorGOLD,
        foregroundColor: colorWHITE,
        child: Icon(Icons.menu_book),
      ),
    );
  }
}