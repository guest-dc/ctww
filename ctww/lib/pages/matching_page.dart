import 'dart:convert';
import 'package:ctww/utils/colors.dart';

import '../utils/matching_page/game_status_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/nav_bar.dart';
import '../utils/matching_page/match_row.dart';

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
  GameDifficulty difficulty = GameDifficulty.easy;

  @override
  void initState() {
    super.initState();
    loadCharacters();
  }

  void showEndGamePopup(BuildContext context, bool isVictory) {
    showDialog(
      context: context,
      barrierDismissible:
          false, // Prevents closing the popup by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isVictory ? "Victory!" : "Game Over"),
          content: Text(isVictory
              ? "Congratulations! You completed the game!"
              : "You ran out of lives. Try again!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Closes the popup
              },
              child: Text("Play Again"),
            ),
          ],
        );
      },
    );
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
                          onLoseLife: () {
                            setState(() {
                              lives--;
                              print('Lives remaining: $lives');
                              if (lives == 0) {
                                // Game over
                                showEndGamePopup(context, false);
                                print('Game over');
                              }
                            });
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
                  // Handle difficulty change
                });
              },
              onGameOver: () {
                showEndGamePopup(context, false);
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
        children: wordBank
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
}
