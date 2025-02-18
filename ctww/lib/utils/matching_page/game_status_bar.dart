import 'package:flutter/material.dart';
import 'dart:async';

enum GameDifficulty { easy, medium, hard }

class GameStatusBar extends StatefulWidget {
  final int currentLesson;
  final GameDifficulty difficulty;
  final int lives;
  final Function(int) onLessonChange;
  final Function(GameDifficulty) onDifficultyChange;

  const GameStatusBar({
    super.key,
    required this.currentLesson,
    required this.difficulty,
    required this.lives,
    required this.onLessonChange,
    required this.onDifficultyChange,
  });

  @override
  GameStatusBarState createState() => GameStatusBarState();
}

class GameStatusBarState extends State<GameStatusBar> {
  int _timeRemaining = 300; // 5 minutes in seconds
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeRemaining > 0) {
          _timeRemaining--;
        } else {
          _timer?.cancel();
        }
      });
    });
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous Lesson Button
          IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () => widget.onLessonChange(widget.currentLesson - 1 > 0
                ? widget.currentLesson - 1
                : widget.currentLesson),
          ),

          // Lesson Display
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Text(
              'Lesson ${widget.currentLesson}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),

          // Difficulty Buttons
          Row(
            children: [
              _buildDifficultyButton('Easy', Colors.green, GameDifficulty.easy),
              SizedBox(width: 8),
              _buildDifficultyButton(
                  'Medium', Colors.yellow[700]!, GameDifficulty.medium),
              SizedBox(width: 8),
              _buildDifficultyButton('Hard', Colors.red, GameDifficulty.hard),
            ],
          ),

          // Lives Display
          Row(
            children: List.generate(
              3,
              (index) => Icon(
                index < widget.lives ? Icons.favorite : Icons.favorite_border,
                color: Colors.red,
                size: 24,
              ),
            ),
          ),

          // Timer Display
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Text(
              formatTime(_timeRemaining),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _timeRemaining < 60 ? Colors.red : Colors.black,
              ),
            ),
          ),

          // Next Lesson Button
          IconButton(
            icon: Icon(Icons.arrow_forward_ios),
            onPressed: () =>
                widget.currentLesson + 1 <
                widget.onLessonChange(widget.currentLesson + 1),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyButton(
      String text, Color color, GameDifficulty difficulty) {
    bool isSelected = widget.difficulty == difficulty;
    return GestureDetector(
      onTap: () {
        setState(() {
          widget.onDifficultyChange(difficulty); // Updates difficulty state
        });

        // Additional actions to trigger on tap
        print("Difficulty changed to: $difficulty");
        isSelected = !isSelected;
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withAlpha((0.3 * 255).toInt()),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? color.darker() : Colors.grey[300]!,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

// Extension to darken colors
extension ColorExtension on Color {
  Color darker() {
    return Color.fromARGB(
      a.toInt(),
      (r * 0.8).toInt(),
      (g * 0.8).toInt(),
      (b * 0.8).toInt(),
    );
  }
}
