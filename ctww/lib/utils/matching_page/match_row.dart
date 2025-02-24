import 'package:flutter/material.dart';

class MatchRow extends StatefulWidget {
  final String chineseCharacter;

  MatchRow({required this.chineseCharacter});

  @override
  _MatchRowState createState() => _MatchRowState();
}

class _MatchRowState extends State<MatchRow> {
  String? droppedWord;
  Color? answerColor = Colors.grey;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        children: [
          // Chinese Character Box
          Container(
            width: screenWidth * 0.4, // 40% of screen width
            height: 80,
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
          SizedBox(width: 10),
          // Drag-and-Drop Answer Box
          Container(
            width: screenWidth * 0.5, // 50% of screen width
            height: 80,
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
                  if (droppedWord == widget.chineseCharacter) {
                    answerColor = Colors.green;
                  } else {
                    answerColor = Colors.red;
                  }
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
