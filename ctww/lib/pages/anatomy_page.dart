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
  bool _isLessonBarVisible = true;
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
      body: SizedBox.expand(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(50, 20, 50, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  Center(
                    child: Container(
                      width: 500,
                      alignment: Alignment.centerLeft, // Align text to the left within the container
                      child: Text(
                        selectedCharacter != null
                            ? '${selectedCharacter!.character}  :  ${selectedCharacter!.definition}'
                            : '',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),

                  SizedBox(height: 5),

                  // Middle section, centered horizontally
                  Container(
                    height: 500,
                    width: 500,
                    alignment: Alignment.center,
                    color: Colors.grey,
                    // child: _buildStrokeOrderAnimationAndControls(),
                  ),

                ],
              ),
            ),

            // Lesson bar (Right side)
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
      ),

      // Lesson Bar Toggle Button (bottom right corner)
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleLessonBar,
        backgroundColor: colorGOLD,
        foregroundColor: colorWHITE,
        child: Icon(Icons.menu_book),
      ),
    );
  }
}