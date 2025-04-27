import 'package:flutter/material.dart';
import 'dart:async';

enum GameDifficulty { easy, medium, hard }

class GameStatusBar extends StatefulWidget implements PreferredSizeWidget {
  final int currentLesson;
  final GameDifficulty difficulty;
  final int lives;
  final bool isStarted;
  final Function(int) onLessonChange;
  final Function(GameDifficulty) onDifficultyChange;
  final VoidCallback onGameOver;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final int score;
  final int maxLesson;

  const GameStatusBar(
      {super.key,
      required this.currentLesson,
      required this.difficulty,
      required this.lives,
      required this.isStarted,
      required this.onLessonChange,
      required this.onDifficultyChange,
      required this.onGameOver,
      required this.scaffoldKey,
      required this.score,
      required this.maxLesson});

  @override
  GameStatusBarState createState() => GameStatusBarState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class GameStatusBarState extends State<GameStatusBar> {
  final int maxLesson = 10; // the maximum number of lessons
  int get timeRemaining => _timeRemaining;
  final int easyTime = 60;
  final int mediumTime = 45;
  final int hardTime = 30;
  int _timeRemaining = 60; // 1 minute default time
  Timer? _timer;
  bool _wasStarted = false;

  @override
  void didUpdateWidget(GameStatusBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!widget.isStarted && oldWidget.isStarted) {
      _timer?.cancel();
      setState(() {
        if (widget.difficulty == GameDifficulty.easy) {
          _timeRemaining = easyTime;
        } else if (widget.difficulty == GameDifficulty.medium) {
          _timeRemaining = mediumTime;
        } else {
          _timeRemaining = hardTime;
        }
        _wasStarted = false; // Reset the tracking flag
      });
    }

    // Check if isStarted changed from false to true
    if (widget.isStarted && !_wasStarted) {
      startTimer();
      _wasStarted = true;
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.isStarted) {
      startTimer();
      _wasStarted = true;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timeRemaining > 0) {
        setState(() {
          _timeRemaining--;
        });
      } else {
        timer.cancel();
        widget.onGameOver();
      }
    });
    print("Timer started!");
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.grey[200],
      elevation: 4,
      leading: IconButton(
        icon: Icon(Icons.arrow_drop_down_circle, color: Colors.black87),
        onPressed: () {
          print("Lesson Selector Tapped");
          widget.scaffoldKey.currentState?.openDrawer();
        },
      ),
      title: Row(children: [
        (widget.currentLesson == 1)
            ? SizedBox(width: 8)
            : IconButton(
                icon:
                    Icon(Icons.arrow_back_ios, size: 18, color: Colors.black87),
                onPressed: () {
                  if (widget.currentLesson > 1) {
                    widget.onLessonChange(widget.currentLesson - 1);
                  }
                },
              ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Text(
            'Lesson ${widget.currentLesson}',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87),
          ),
        ),
        (widget.currentLesson == widget.maxLesson)
            ? SizedBox(width: 8)
            : IconButton(
                icon: Icon(Icons.arrow_forward_ios,
                    size: 18, color: Colors.black87),
                onPressed: () {
                  if (widget.currentLesson < maxLesson) {
                    widget.onLessonChange(widget.currentLesson + 1);
                  }
                },
              ),
      ]),
      actions: [
        // Score Display
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Score: ${widget.score}",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        // Lives Display
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              3,
              (index) => Icon(
                index < widget.lives ? Icons.favorite : Icons.favorite_border,
                color: Colors.red,
                size: 20,
              ),
            ),
          ),
        ),

        // Difficulty Buttons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDifficultyButton('E', Colors.green, GameDifficulty.easy),
              SizedBox(width: 4),
              _buildDifficultyButton(
                  'M', Colors.yellow[700]!, GameDifficulty.medium),
              SizedBox(width: 4),
              _buildDifficultyButton('H', Colors.red, GameDifficulty.hard),
            ],
          ),
        ),
        // Timer Display
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Text(
              formatTime(_timeRemaining),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: _timeRemaining < 15
                    ? Colors.red
                    : _timeRemaining < 30
                        ? Colors.orange
                        : Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDifficultyButton(
      String text, Color color, GameDifficulty difficulty) {
    bool isSelected = widget.difficulty == difficulty;

    return GestureDetector(
      onTap: () {
        if (isSelected) return;

        setState(() {
          widget.onDifficultyChange(difficulty);
          _timeRemaining = 60; // Reset timer
        });

        print("Difficulty changed to: $difficulty");
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withAlpha((0.3 * 255).toInt()),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color.darker() : Colors.grey[300]!,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
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
