import 'package:flutter/material.dart';

//import '../utils/colors.dart';
import '../utils/nav_bar.dart';
import '../utils/match_row.dart';

class MatchingPage extends StatelessWidget {
  final List<String> wordBank;
  final List<String> chineseCharacters; // List of Chinese characters

  MatchingPage({required this.wordBank, required this.chineseCharacters});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: NavBar(),
      body: Column(
        children: [
          // Word Pool spanning top 20%
          Container(
            height: screenHeight * 0.2,
            color: Colors.blue[100],
            child: Center(
              child: buildWordBank(),
            ),
          ),
          // Matching rows
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: List.generate(
                    chineseCharacters.length,
                    (index) =>
                        MatchRow(chineseCharacter: chineseCharacters[index])),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildWordBank() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: wordBank.map((word) => buildWordCard(word)).toList(),
      ),
    );
  }

  Widget buildWordCard(String word) {
    return Draggable<String>(
      data: word,
      feedback: Material(
        child: Container(
          padding: EdgeInsets.all(8.0),
          margin: EdgeInsets.symmetric(horizontal: 4.0),
          decoration: BoxDecoration(
            color: Colors.orange,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black),
          ),
          child: Text(
            word,
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ),
      child: Container(
        padding: EdgeInsets.all(8.0),
        margin: EdgeInsets.symmetric(horizontal: 4.0),
        decoration: BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black),
        ),
        child: Text(
          word,
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }
}
