import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../utils/colors.dart';
import '../utils/models.dart';

class LessonBar extends StatefulWidget {
  final bool isVisible;
  final VoidCallback toggleVisibility;
  final Function(Character) onCharacterSelected;
  final Function(List<Lesson>) onLessonsLoaded;



  LessonBar({
    required this.isVisible,
    required this.toggleVisibility,
    required this.onCharacterSelected,
    required this.onLessonsLoaded,
  });



  @override
  _LessonBarState createState() => _LessonBarState();
}



class _LessonBarState extends State<LessonBar> {
  late Future<List<Lesson>> lessons;



  @override
  void initState() {
    super.initState();
    lessons = loadLessons();
    lessons.then((loadedLessons) {
      widget.onLessonsLoaded(loadedLessons);
    });
  }



  Future<List<Lesson>> loadLessons() async {
    final String jsonString = await rootBundle.loadString('assets/charset.json');
    final Map<String, dynamic> data = jsonDecode(jsonString);

    return data.entries.map((entry) {
      return Lesson.fromJson(entry.key, entry.value);
    }).toList();
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
                    children: lessons.map((lesson) {
                      return Column(
                        children: [

                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('Lesson ${int.parse(lesson.lessonName.replaceAll(RegExp(r'[^0-9]'), ''))}',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: colorGOLD)),
                          ),

                          ...lesson.characters.map((character) {
                            return ListTile(
                              title: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  character.character,
                                  style:
                                      TextStyle(fontSize: 18, color: colorGOLD),
                                ),
                              ),
                              onTap: () {
                                widget.onCharacterSelected(character);
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
