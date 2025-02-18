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

  @override
  void initState() {
    super.initState();
    loadCharacters();
  }

  Future<void> loadCharacters() async {
    String jsonString = await rootBundle.loadString('assets/charset.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);

    List<String> tempWords = [];
    List<String> tempCharacters = [];
    Map<String, String> characterToDeftemp = {};

    for (var lesson in jsonData['charset']) {
      if (lesson['lessonID'] == 1) {
        for (var character in lesson['characters']) {
          tempCharacters.add(character['character']);
          characterToDeftemp[character['character']] = character['definition'];
          tempWords.add(character['definition']);
        }
        break;
      }
    }
    setState(() {
      wordBank = tempWords;
      characterToDef = characterToDeftemp;
      chineseCharacters = tempCharacters;
    });
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
              difficulty: GameDifficulty.easy, // Set initial difficulty
              lives: lives,
              onLessonChange: (newLesson) {
                setState(() {
                  lessonID = newLesson;
                  loadCharacters(); // Reload characters for new lesson
                });
              },
              onDifficultyChange: (newDifficulty) {
                setState(() {
                  // Handle difficulty change
                  // You might want to adjust game parameters based on difficulty
                });
              },
            ),
            // Word Pool spanning top 20%
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
                child: ListView.builder(
                  itemCount: chineseCharacters.length,
                  itemBuilder: (context, index) {
                    return MatchRow(
                        chineseCharacter: chineseCharacters[index],
                        characterToDef: characterToDef);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildWordBank() {
    double screenWidth = MediaQuery.of(context).size.width;
    double cardWidth = screenWidth *
        (1 / wordBank.length) *
        .9; // Each card takes 20% of the screen width
    double cardHeight = 50; // Fixed height

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
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
