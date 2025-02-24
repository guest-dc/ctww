import 'package:flutter/material.dart';

class MatchRow extends StatefulWidget {
  final String chineseCharacter;
  final Map<String, String> characterToDef;
  final double matchRowWidth;
  final VoidCallback onLoseLife;

  MatchRow(
      {required this.chineseCharacter,
      required this.characterToDef,
      required this.matchRowWidth,
      required this.onLoseLife});

  @override
  MatchRowState createState() => MatchRowState();
}

class MatchRowState extends State<MatchRow> {
  String? droppedWord;
  Color? answerColor = Colors.grey;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      // Let this row take full space in parent
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Row(
          children: [
            // Chinese Character Box
            Expanded(
              flex: 1, // Takes equal space
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.cyan[100],
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.chineseCharacter,
                  style: TextStyle(fontSize: 22),
                ),
              ),
            ),

            SizedBox(width: 10),

            // Drag-and-Drop Answer Box
            Expanded(
              flex: 1,
              child: DragTarget<String>(
                builder: (context, candidateData, rejectedData) => Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: answerColor,
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    droppedWord ?? 'Drop Here',
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                onAcceptWithDetails: (data) {
                  setState(() {
                    droppedWord = data.data;
                    if (droppedWord ==
                        widget.characterToDef[widget.chineseCharacter]) {
                      answerColor = Colors.green;
                    } else {
                      widget.onLoseLife();
                      answerColor = Colors.red;
                    }
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
