import 'package:ctww/utils/colors.dart';
import 'package:flutter/material.dart';
import '../utils/nav_bar.dart';
import '../utils/lesson_bar.dart';
import '../utils/models.dart';
import 'package:http/http.dart' as http;
import 'package:stroke_order_animator/stroke_order_animator.dart';



class AnatomyPage extends StatefulWidget {

  final Character? initialCharacter;
  const AnatomyPage({Key? key, this.initialCharacter}) : super(key: key);

  @override
  AnatomyPageState createState() => AnatomyPageState();
}



class AnatomyPageState extends State<AnatomyPage> with TickerProviderStateMixin {
  bool _isLessonBarVisible = true;
  Character? selectedCharacter;

  final _httpClient = http.Client();
  StrokeOrderAnimationController? _completedController;
  late Future<StrokeOrderAnimationController>? _animationController;



  @override
  void initState() {
    super.initState();

    if (widget.initialCharacter != null) {
      _animationController = _loadStrokeOrder(widget.initialCharacter!.character);
    } else {
      _animationController = _loadStrokeOrder('一');
      
    }
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
        this,
        // onQuizCompleteCallback: (summary) {
        //   Fluttertoast.showToast(
        //     msg: 'Quiz finished. ${summary.nTotalMistakes} mistakes',
        //   );

        //   setState(() {});
        // },
      );

      return controller;
    });
  }



   void _onLessonsLoaded(List<Lesson> lessons) {
    if (widget.initialCharacter != null) {
      _onCharacterSelected(widget.initialCharacter!);
    }

    else if (lessons.isNotEmpty && lessons[0].characters.isNotEmpty) {
      _onCharacterSelected(lessons[0].characters[0]);
    }
  }



  // Loads a new character when selected from the Lesson Bar.
  void _onCharacterSelected(Character character) {
    setState(() {
      selectedCharacter = character;

      print("selected character: ${character.character}");

      _animationController = _loadStrokeOrder(character.character);
      _animationController!.then((a) => _completedController = a);
    });
  }


  // Toggles the visibility of the Lesson Bar.
  void _toggleLessonBar() {
    setState(() {
      _isLessonBarVisible = !_isLessonBarVisible;
    });
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
                _buildStrokeOrderAnimation(snapshot.data!),
                _buildAnimationControls(snapshot.data!),
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



  Widget _buildAnimationControls(StrokeOrderAnimationController controller) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) => Flexible(
        child: GridView(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            childAspectRatio: 3,
            crossAxisCount: 2,
            mainAxisSpacing: 10,
          ),
          primary: false,
          children: <Widget>[
            MaterialButton(
              onPressed: controller.isQuizzing
                  ? null
                  : (controller.isAnimating
                      ? controller.stopAnimation
                      : controller.startAnimation),
              child: controller.isAnimating
                  ? Text('Stop animation')
                  : Text('Start animation'),
            ),
            MaterialButton(
              onPressed: controller.isQuizzing
                  ? controller.stopQuiz
                  : controller.startQuiz,
              child: controller.isQuizzing
                  ? Text('Stop quiz')
                  : Text('Start quiz'),
            ),
            MaterialButton(
              onPressed: controller.isQuizzing ? null : controller.nextStroke,
              child: Text('Next stroke'),
            ),
            MaterialButton(
              onPressed:
                  controller.isQuizzing ? null : controller.previousStroke,
              child: Text('Previous stroke'),
            ),
            MaterialButton(
              onPressed:
                  controller.isQuizzing ? null : controller.showFullCharacter,
              child: Text('Show full character'),
            ),
            MaterialButton(
              onPressed: controller.reset,
              child: Text('Reset'),
            ),
            MaterialButton(
              onPressed: () {
                controller.setShowOutline(!controller.showOutline);
              },
              child: controller.showOutline
                  ? Text('Hide outline')
                  : Text('Show outline'),
            ),
            MaterialButton(
              onPressed: () {
                controller.setShowBackground(!controller.showBackground);
              },
              child: controller.showBackground
                  ? Text('Hide background')
                  : Text('Show background'),
            ),
            MaterialButton(
              onPressed: () {
                controller.setShowMedian(!controller.showMedian);
              },
              child: controller.showMedian
                  ? Text('Hide medians')
                  : Text('Show medians'),
            ),
            MaterialButton(
              onPressed: () {
                controller.setHighlightRadical(!controller.highlightRadical);
              },
              child: controller.highlightRadical
                  ? Text('Unhighlight radical')
                  : Text('Highlight radical'),
            ),
            MaterialButton(
              onPressed: () {
                controller.setShowUserStroke(!controller.showUserStroke);
              },
              child: controller.showUserStroke
                  ? Text('Hide user strokes')
                  : Text('Show user strokes'),
            ),
          ],
        ),
      ),
    );
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

                  SizedBox(height: 5),

                  Container(
                    height: 500,
                    width: 500,
                    alignment: Alignment.center,
                    child: _buildStrokeOrderAnimationAndControls(),
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

            Positioned(
              right: _isLessonBarVisible ? 90 + 16 : 16,
              bottom: 16,
              child: FloatingActionButton(
                onPressed: _toggleLessonBar,
                backgroundColor: colorGOLD,
                foregroundColor: colorWHITE,
                child: Icon(Icons.menu_book),
              ),
            )

          ],
        ),
      ),
    );
  }

  
}