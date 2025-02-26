import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/nav_bar.dart';
import '../utils/lesson_bar.dart';
import '../utils/models.dart';

import 'package:http/http.dart' as http;
import 'package:stroke_order_animator/stroke_order_animator.dart';

class StoryWalkPage extends StatefulWidget {
  @override
  StoryWalkPageState createState() => StoryWalkPageState();
}

class StoryWalkPageState extends State<StoryWalkPage> with TickerProviderStateMixin {
  bool _isLessonBarVisible = true;
  Character? selectedCharacter;
  int charPart = -1;
  int maxPartNum = 0;

  final _httpClient = http.Client();
  StrokeOrderAnimationController? _completedController;
  late Future<StrokeOrderAnimationController>? _animationController;



  @override
  void initState() {
    super.initState();
    _animationController = _loadStrokeOrder('一');
    _animationController!.then((a) => _completedController = a);
  }



  @override
  void dispose() {
    _httpClient.close();
    _completedController?.dispose();
    super.dispose();
  }



  Future<StrokeOrderAnimationController> _loadStrokeOrder(String character) async {
    return downloadStrokeOrder(character, _httpClient).then((value) {
      final controller = StrokeOrderAnimationController(
        StrokeOrder(value),
        this
      );
      controller.setShowMedian(false);
      controller.setShowOutline(false);
      controller.startAnimation();

      return controller;
    });
  }



  void _onLessonsLoaded(List<Lesson> lessons) {
    if (lessons.isNotEmpty && lessons[0].characters.isNotEmpty) {
      _onCharacterSelected(lessons[0].characters[0]);
    }
  }



  // Toggles the visibility of the Lesson Bar.
  void _toggleLessonBar() {
    setState(() {
      _isLessonBarVisible = !_isLessonBarVisible;
    });
  }



  // Loads a new character when selected from the Lesson Bar.
  void _onCharacterSelected(Character character) {
    setState(() {
      charPart = -1;
      maxPartNum = character.parts.length;
      selectedCharacter = character;

      print("selected character: ${character.character}");

      for (var i = 0; i < (selectedCharacter!.parts.length); i++) {
        print('Part ${i + 1}: ${selectedCharacter!.parts[i].story}');
      }

      _animationController = _loadStrokeOrder(character.character);
      _animationController!.then((a) => _completedController = a);
    });
  }



  // Builds the page.
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

                  // Character : definition
                  Center(
                    child: Container(
                      width: 500,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        selectedCharacter != null
                            ? '${selectedCharacter!.character}  :  ${selectedCharacter!.definition}'
                            : '',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),

                  SizedBox(height: 30),

                  // Stroke animation and controls
                  Container(
                    height: 400,
                    width: 500,
                    alignment: Alignment.center,
                    child: _buildStrokeOrderAnimationAndControls(),
                  ),

                  SizedBox(height: 15),

                  // Part stories
                  Center(
                    child: Container(
                      width: 500,
                      alignment: Alignment.centerLeft,
                      child: Column(
                        children: List.generate(
                          selectedCharacter?.parts.length ?? 0,
                          (index) => Text(
                            'Part ${index + 1}: ${selectedCharacter!.parts[index].story}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    )
                  )

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



  FutureBuilder<StrokeOrderAnimationController> _buildStrokeOrderAnimationAndControls() {
    return FutureBuilder(
      future: _animationController,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return CircularProgressIndicator();
        }
        if (snapshot.hasData) {
          return Column(
            children: [
              _buildAnimationControlsTop(snapshot.data!),
              _buildStrokeOrderAnimation(snapshot.data!),
              _buildAnimationControlsBottom(snapshot.data!),
            ],
          );
        }

        if (snapshot.hasError) return Text(snapshot.error.toString());

        return SizedBox.shrink();
      },
    );
  }



  Widget _buildStrokeOrderAnimation(StrokeOrderAnimationController controller) {
    return StrokeOrderAnimator(
      controller,
      size: Size(300, 300),
      key: UniqueKey(),
    );
  }



  Widget _buildAnimationControlsTop(StrokeOrderAnimationController controller) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {

        return Stack(
          children: [

            Row(
              children: <Widget>[

                Text(charPart != -1 ? 'Part: ${(charPart + 1)}' : 'Part: FULL',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.left,
                ),

              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[

                ElevatedButton(
                  onPressed: () { fullReset(controller); },
                  child: Icon(Icons.refresh, size: 25, color: colorGOLD)
                ),

              ],
            ),

          ]
        );
      },
    );
  }



  Widget _buildAnimationControlsBottom(StrokeOrderAnimationController controller) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {

        return Flexible(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[

              ElevatedButton(
                onPressed: () {

                  if (charPart == 0 || charPart == -1) {
                    fullReset(controller);
                  }
                  else {
                    previousPart(controller);
                  }

                },
                child: Icon(Icons.arrow_back_ios, size: 25, color: colorGOLD)
              ),

              SizedBox(width: 50),

              ElevatedButton(
                onPressed: () {

                  if (charPart == -1) {
                    controller.reset();
                  }
                  else if (charPart == maxPartNum - 1) {
                    return;
                  }
                  nextPart(controller);

                },
                child: Icon(Icons.arrow_forward_ios, size: 25, color: colorGOLD)
              ),

            ],
          ),
        );
      },
    );
  }


  // Resets controller, starts the animation again, and sets the charPart back to -1.
  void fullReset(StrokeOrderAnimationController controller) {
    controller.reset();
    controller.startAnimation();
    charPart = -1;
  }


  // Performs .previousStroke() based on the amount of strokes a part has.
  void previousPart(StrokeOrderAnimationController controller) {
    int partDelta = selectedCharacter!.parts[charPart].strokeNums.length;

    for (int i = 0; i < partDelta; i++) {
      controller.previousStroke();
    }

    charPart--;
  }


  // Performs .nextStroke() based on the amount of strokes the next part has.
  void nextPart(StrokeOrderAnimationController controller) {
    int nextPart = charPart + 1; 
    int partDelta = selectedCharacter!.parts[nextPart].strokeNums.length;

    for (int i = 0; i < partDelta; i++) {
      controller.nextStroke();
    }

    charPart++;
  }

}