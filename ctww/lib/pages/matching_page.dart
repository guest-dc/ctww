import 'dart:convert';
import 'package:ctww/utils/colors.dart';

import '../utils/matching_page/game_status_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/nav_bar.dart';
import '../utils/matching_page/match_row.dart';
import 'package:lottie/lottie.dart';

class MatchingPage extends StatefulWidget {
  @override
  MatchingPageState createState() => MatchingPageState();
}

class MatchingPageState extends State<MatchingPage> {
  List<String> wordBank = [];
  List<String> chineseCharacters = [];
  Map<String, String> characterToDef = {};
  int lessonID = 1;
  int score = 0;
  int lives = 3;
  bool isGameStarted = false;
  GameDifficulty difficulty = GameDifficulty.easy;
  List<String> shuffledWordBank = [];
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showLandingPopup(context);
    });
    loadCharacters();
  }

  void showEndGamePopup(BuildContext context, bool isVictory, bool isTimeOut) {
    showDialog(
      context: context,
      barrierDismissible:
          false, // Prevents closing the popup by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isVictory ? "Victory!" : "Game Over"),
          content: Text(isVictory
              ? "Congratulations! You completed the game!"
              : (isTimeOut)
                  ? "You ran out of time. Try again!"
                  : "You ran out of lives. Try again!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Closes the popup
                resetGame();
              },
              child: Text("Play Again"),
            ),
          ],
        );
      },
    );
  }

  void resetGame() {
    setState(() {
      score = 0;
      lives = 3;
      isGameStarted = false;
      loadCharacters();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showLandingPopup(context);
      });
    });
  }

  Future<void> loadCharacters() async {
    String jsonString = await rootBundle.loadString('assets/charset.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);

    List<String> tempWords = [];
    List<String> tempCharacters = [];
    Map<String, String> characterToDeftemp = {};

    String lessonKey = 'lesson-$lessonID';

    if (jsonData.containsKey(lessonKey)) {
      for (var character in jsonData[lessonKey]['characters']) {
        tempCharacters.add(character['character']);
        characterToDeftemp[character['character']] = character['definition'];
        tempWords.add(character['definition']);
      }
    }

    setState(() {
      wordBank = tempWords;
      characterToDef = characterToDeftemp;
      chineseCharacters = tempCharacters;
      shuffledWordBank = List.from(wordBank)..shuffle();
    });
  }

  Widget buildMatchRows() {
    int itemsPerColumn = 5;
    int numColumns = (chineseCharacters.length / itemsPerColumn).ceil();

    double totalWidth = MediaQuery.of(context).size.width;
    double matchRowWidth = totalWidth / numColumns; // Ensure equal distribution

    // Chunk characters into sublists
    List<List<String>> chunkedCharacters = [];
    for (int i = 0; i < chineseCharacters.length; i += itemsPerColumn) {
      chunkedCharacters.add(
        chineseCharacters.sublist(
          i,
          (i + itemsPerColumn > chineseCharacters.length)
              ? chineseCharacters.length
              : i + itemsPerColumn,
        ),
      );
    }

    return SizedBox(
      width: totalWidth,
      child: SingleChildScrollView(
        scrollDirection:
            Axis.horizontal, // Allows scrolling if too many columns
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: chunkedCharacters.map((chunk) {
            return SizedBox(
              width: matchRowWidth, // Ensure each column has a width
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8.0), // Space between columns
                child: Column(
                  children: chunk
                      .map((character) => MatchRow(
                          chineseCharacter: character,
                          characterToDef: characterToDef,
                          matchRowWidth: matchRowWidth,
                          isStarted: isGameStarted,
                          onLoseLife: () {
                            setState(() {
                              lives--;
                              print('Lives remaining: $lives');
                              if (lives == 0) {
                                // Game over
                                showEndGamePopup(context, false, false);
                                print('Game over');
                              }
                            });
                          },
                          onCorrectAnswer: () {
                            onCorrectMatch();
                          }))
                      .toList(),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NavBar(),
      body: Container(
        color: colorGOLD,
        child: Column(
          children: [
            GameStatusBar(
              currentLesson: lessonID,
              difficulty: difficulty,
              lives: lives,
              isStarted: isGameStarted,
              onLessonChange: (newLesson) {
                setState(() {
                  lessonID = newLesson;
                  print('New lesson: $lessonID');
                  loadCharacters();
                  for (var i = 0; i < chineseCharacters.length; i++) {
                    print(chineseCharacters[i]);
                  }
                });
              },
              onDifficultyChange: (newDifficulty) {
                setState(() {
                  difficulty = newDifficulty;
                  print('new difficulty = $newDifficulty');
                  resetGame();
                  // Handle difficulty change
                });
              },
              onGameOver: () {
                showEndGamePopup(context, false, true);
              },
            ),

            Container(
              height: MediaQuery.of(context).size.height * .15,
              decoration: BoxDecoration(color: Colors.red, boxShadow: [
                BoxShadow(
                  color: Colors.black,
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3),
                ),
              ]),
              child: Center(
                child: buildWordBank(),
              ),
            ),
            // Matching rows (Scrollable)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: buildMatchRows(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildWordBank() {
    double screenWidth = MediaQuery.of(context).size.width;
    double cardWidth = screenWidth / 5 * 0.9; // 5 cards per row with padding
    double cardHeight = 50; // Fixed height

    return SingleChildScrollView(
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: shuffledWordBank
            .map((word) => buildWordCard(word, cardWidth, cardHeight))
            .toList(),
      ),
    );
  }

  Widget buildWordCard(String word, double width, double height) {
    return Draggable<String>(
      data: word,
      feedback: Material(
        child: Container(
          width: width,
          height: height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.orange,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black),
          ),
          child: Text(
            word,
            style: TextStyle(fontSize: 18, color: Colors.black),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      child: Container(
        width: width,
        height: height,
        alignment: Alignment.center,
        margin: EdgeInsets.symmetric(horizontal: 4.0),
        decoration: BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black),
        ),
        child: Text(
          word,
          style: TextStyle(fontSize: 18, color: Colors.black),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  void onCorrectMatch() {
    setState(() {
      score++;
      print('Score: $score');
      if (score == chineseCharacters.length) {
        showEndGamePopup(context, true, false);
      }
    });
  }

  void showLandingPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevents clicking outside to dismiss
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Example Animation (Replace with Lottie.asset() if needed)
              Container(
                height: 200,
                width: 200,
                child: Lottie.asset(
                  'assets/animations/dragAnimation.json',
                  fit: BoxFit.fill,
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Welcome to the Matching Game!",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                "Match the Chinese characters with their meanings by dragging the correct pairs together. Try to get them all right before running out of lives or time!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isGameStarted = true;
                  });
                  Navigator.of(context).pop(); // Close the popup
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "START",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
