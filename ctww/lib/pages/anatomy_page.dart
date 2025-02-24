import 'package:ctww/utils/colors.dart';
import 'package:flutter/material.dart';
import '../utils/nav_bar.dart';
import '../utils/lesson_bar.dart';
import '../utils/models.dart';

class AnatomyPage extends StatefulWidget {
  @override
  AnatomyPageState createState() => AnatomyPageState();
}

class AnatomyPageState extends State<AnatomyPage> {
  bool _isLessonBarVisible = false;
  Character? selectedCharacter;


  void _onLessonsLoaded(List<Lesson> lessons) {
    if (lessons.isNotEmpty && lessons[0].characters.isNotEmpty) {
      _onCharacterSelected(lessons[0].characters[0]);
    }
  }


   // Function to update the selected character
  void _onCharacterSelected(Character character) {
    setState(() {
      selectedCharacter = character;
    });
  }



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
            child: LessonBar(
              isVisible: _isLessonBarVisible,
              toggleVisibility: _toggleLessonBar,
              onCharacterSelected: _onCharacterSelected,
              onLessonsLoaded: _onLessonsLoaded,
            ),
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