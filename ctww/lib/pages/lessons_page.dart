import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

import '../utils/colors.dart';
import '../utils/models.dart';
import '../utils/nav_bar.dart';

class LessonsPage extends StatefulWidget {
  // final Function(Character) onCharacterSelected;

  // LessonsPage({
  //   required this.onCharacterSelected,
  // });

  @override
  LessonsPageState createState() => LessonsPageState();
}



class LessonsPageState extends State<LessonsPage> {
  late Future<List<Lesson>> lessons;

  @override
  void initState() {
    super.initState();
    lessons = loadLessons();
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
    return Scaffold(
      appBar: NavBar(),
      body: SizedBox.expand(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(50, 20, 50, 20),
              child: FutureBuilder<List<Lesson>>(
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

                    return Padding(
                      padding: const EdgeInsets.fromLTRB(50, 20, 50, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: lessons.map((lesson) {
                          return Column(
                            children: [

                              Center(
                                child: Container(
                                  width: 500,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Lesson ${int.parse(lesson.lessonName.replaceAll(RegExp(r'[^0-9]'), ''))}',
                                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colorGOLD),
                                    textAlign: TextAlign.left,
                                    
                                  ),
                                ),
                              ),

                              
                              
                              // ...lesson.characters.map((character) {
                              //   return ListTile(
                              //     title: Align(
                              //       alignment: Alignment.center,
                              //       child: Text(
                              //         character.character,
                              //         style: TextStyle(fontSize: 18, color: colorGOLD),
                              //       ),
                              //     ),
                              //   );
                              // }),

                              SizedBox(height: 5),
                              
                              Center(
                                child: SizedBox(
                                    width: 500,  // Set a specific width if necessary
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: lesson.characters.map((character) {
                                        return Padding(
                                          padding: const EdgeInsets.only(right: 20.0), // Space between characters
                                          child: Text(
                                            character.character,
                                            style: TextStyle(fontSize: 20),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                              )
                              
                            ],
                          );
                        }).toList(),
                      )
                    );


                  }
                },
              )
            ),
          ],
        ),
      ),
    );
  }
}


