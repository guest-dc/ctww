import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/nav_bar.dart';
import '../utils/lesson_bar.dart';
import '../utils/models.dart';

class StoryWalkPage extends StatefulWidget {
  @override
  _StoryWalkPageState createState() => _StoryWalkPageState();
}

class _StoryWalkPageState extends State<StoryWalkPage> {
  bool _isLessonBarVisible = true;
  Character? selectedCharacter;



  void _onLessonsLoaded(List<Lesson> lessons) {
    if (lessons.isNotEmpty && lessons[0].characters.isNotEmpty) {
      _onCharacterSelected(lessons[0].characters[0]);
    }
  }



  void _toggleLessonBar() {
    setState(() {
      _isLessonBarVisible = !_isLessonBarVisible;
    });
  }



  void _onCharacterSelected(Character character) {
    setState(() {
      selectedCharacter = character;
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NavBar(),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(50, 20, 50, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedCharacter != null 
                          ? '${selectedCharacter!.character}   ${selectedCharacter!.definition}' 
                          : '',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(height: 15),
                    Text(
                      selectedCharacter?.story ?? '[Overall Story]',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(height: 30),
                  ],
                ),
                Column(
                  children: [
                    Container(
                      height: 200,
                      width: 200,
                      color: Colors.grey[300],
                      alignment: Alignment.center,
                      child: selectedCharacter != null 
                          ? Image.asset('assets/animations/${selectedCharacter!.animation}') 
                          : Text('Animation Placeholder'),
                    ),
                    SizedBox(height: 8),
                    Container(
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {},
                            child: Icon(Icons.arrow_back_ios),
                          ),
                          SizedBox(width: 16),
                          Text("..."), // Placeholder for keyframe selection
                          SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: () {},
                            child: Icon(Icons.arrow_forward_ios),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      selectedCharacter?.story ?? '[Meaning of current stroke]',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                  ],
                )
              ],
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