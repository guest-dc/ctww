import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../utils/colors.dart';
import '../utils/models.dart';

class LessonBar extends StatefulWidget {
  final bool isVisible;
  final VoidCallback toggleVisibility;

  LessonBar({required this.isVisible, required this.toggleVisibility});

  @override
  _LessonBarState createState() => _LessonBarState();
}

class _LessonBarState extends State<LessonBar> {
  late Future<List<Lesson>> lessons;

  @override
  void initState() {
    super.initState();
    lessons = loadLessons();
  }

  // Function to load JSON data from the asset file
  Future<List<Lesson>> loadLessons() async {
    final String jsonString = await rootBundle.loadString('assets/charset.json');
    final Map<String, dynamic> data = jsonDecode(jsonString);
    return (data['charset'] as List).map((json) => Lesson.fromJson(json)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      width: widget.isVisible ? 90 : 0,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          if (widget.isVisible)
            BoxShadow(
              color: Colors.black26,
              blurRadius: 5,
              spreadRadius: 2,
            ),
        ],
      ),
      child: widget.isVisible
          ? FutureBuilder<List<Lesson>>(
              future: lessons,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No lessons available'));
                } else {
                  final lessons = snapshot.data!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center, // Align horizontally to the center
                    children: lessons.map((lesson) {
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('Lesson ${lesson.lessonID}', style: TextStyle(fontWeight: FontWeight.bold, color: colorGOLD)),
                          ),
                          ...lesson.characters.map((character) {
                            return ListTile(
                              title: Text(character.character, style: TextStyle(fontSize: 18, color: colorGOLD)),
                              onTap: () {
                                print('Selected: ${character.character}');
                              },
                            );
                          }),
                        ],
                      );
                    }).toList(),
                  );
                }
              },
            )
          : null,
    );
  }
}