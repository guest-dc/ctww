import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../utils/nav_bar.dart';
import '../utils/matching_page/match_row.dart';

class MatchingPage extends StatefulWidget {
  @override
  _MatchingPageState createState() => _MatchingPageState();
}

class _MatchingPageState extends State<MatchingPage> {
  List<String> wordBank = [];
  List<String> chineseCharacters = [];

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

    for (var lesson in jsonData['charset']) {
      if (lesson['lessonID'] == 1) {
        for (var character in lesson['characters']) {
          tempCharacters.add(character['character']);
          tempWords.add(character['definition']);
        }
        break;
      }
    }

    setState(() {
      wordBank = tempWords;
      chineseCharacters = tempCharacters;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NavBar(),
      body: Column(
        children: [
          // Word Pool spanning top 20%
          Container(
            height: MediaQuery.of(context).size.height * 0.2,
            color: Colors.blue[100],
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
                  return MatchRow(chineseCharacter: chineseCharacters[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildWordBank() {
    double screenWidth = MediaQuery.of(context).size.width;
    double cardWidth =
        screenWidth * 0.2; // Each card takes 20% of the screen width
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
            style: TextStyle(fontSize: 18, color: Colors.white),
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
          style: TextStyle(fontSize: 18, color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
