import 'package:flutter/material.dart';

class MatchRow extends StatefulWidget {
  final String chineseCharacter;

  MatchRow({required this.chineseCharacter});

  @override
  _MatchRowState createState() => _MatchRowState();
}

class _MatchRowState extends State<MatchRow> {
  String? droppedWord;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          // Chinese Character Box
          Expanded(
            child: Container(
              height: 60,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.red[100],
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
            child: DragTarget<String>(
              builder: (context, candidateData, rejectedData) => Container(
                height: 60,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  droppedWord ?? 'Drop Here',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              onAcceptWithDetails: (data) {
                setState(() {
                  droppedWord = data
                      .data; // Set the dropped word answer box to the answer that is dropped on it
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
