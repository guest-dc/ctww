import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/nav_bar.dart';
import '../utils/lesson_bar.dart';
import '../utils/models.dart';

import 'package:http/http.dart' as http;
import 'package:stroke_order_animator/stroke_order_animator.dart';

class StoryWalkPage extends StatefulWidget {
  @override
  _StoryWalkPageState createState() => _StoryWalkPageState();
}

class _StoryWalkPageState extends State<StoryWalkPage> with TickerProviderStateMixin {
  bool _isLessonBarVisible = true;
  Character? selectedCharacter;

  int charState = 0;

  final _httpClient = http.Client();
  StrokeOrderAnimationController? _completedController;
  late Future<StrokeOrderAnimationController>? _animationController;



  @override
  void initState() {
    super.initState();
    _animationController = _loadStrokeOrder('');
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



  void _toggleLessonBar() {
    setState(() {
      _isLessonBarVisible = !_isLessonBarVisible;
    });
  }



  void _onCharacterSelected(Character character) {
    setState(() {
      selectedCharacter = character;
      _animationController = _loadStrokeOrder(character.character);
      _animationController!.then((a) => _completedController = a);
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Top section, not centered horizontally
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // Selected character and definition (ex.  "一   one")
                      Text(
                        selectedCharacter != null
                            ? '${selectedCharacter!.character}   ${selectedCharacter!.definition}'
                            : '',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.left,
                      ),

                      SizedBox(height: 15),

                      // Overall character story
                      Text(
                        selectedCharacter?.story ?? '',
                        style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.left,
                      ),

                      SizedBox(height: 30),
                    ],
                  ),

                  // Middle section, centered horizontally
                  Column(
                    children: [
                      Container(
                        height: 400,
                        width: 500,
                        alignment: Alignment.center,
                        child: _buildStrokeOrderAnimationAndControls(),
                      ),

                      SizedBox(height: 15),

                    ],
                  ),

                  // Bottom section, not centered horizontally
                  Column(
                    children: [
                      Text(
                        selectedCharacter?.story ?? '',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )
                ],
              ),
            ),

            // Lesson bar on the right side of the screen
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

      // Floating button in bottom right corner to toggle lesson bar
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
          return Expanded(
            child: Column(
              children: [
                _buildAnimationControls1(snapshot.data!),
                _buildStrokeOrderAnimation(snapshot.data!),
                _buildAnimationControls2(snapshot.data!),
              ],
            ),
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


  Widget _buildAnimationControls1(StrokeOrderAnimationController controller) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {

        return Stack(
          children: [

            Row(
              children: <Widget>[

                Text(charState != 0 ? 'Part: $charState' : 'Part: FULL',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.left,
                ),

              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[

                ElevatedButton(
                  onPressed: () {
                    controller.reset();
                    controller.startAnimation();
                    charState = 0;
                  },
                  child: Icon(Icons.refresh, size: 25, color: colorGOLD)
                ),

              ],
            ),

          ]
        );
      },
    );
  }

  Widget _buildAnimationControls2(StrokeOrderAnimationController controller) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {

        return Flexible(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[

              ElevatedButton(
                onPressed: () {
                  if (controller.isAnimating) controller.reset();
                  controller.previousStroke;
                  charState--;
                },
                child: Icon(Icons.arrow_back_ios, size: 25, color: colorGOLD)
              ),

              SizedBox(width: 50),

              ElevatedButton(
                onPressed: () {
                  if (controller.isAnimating) controller.reset();
                  controller.nextStroke();
                  charState++;
                },
                child: Icon(Icons.arrow_forward_ios, size: 25, color: colorGOLD)
              ),


            ],
          ),
        );
      },
    );
  }

}