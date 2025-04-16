import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../utils/colors.dart';
import '../utils/models.dart';
import '../utils/nav_bar.dart';

class LessonsPage extends StatefulWidget {
  const LessonsPage({Key? key}) : super(key: key);

  @override
  State<LessonsPage> createState() => LessonsPageState();
}

class LessonsPageState extends State<LessonsPage> {
  bool showSecondButton = false;
  late Future<List<Lesson>> lessons;

  @override
  void initState() {
    super.initState();
    lessons = loadLessons();
  }

  Future<List<Lesson>> loadLessons() async {
    final String Jsonlesson = await rootBundle.loadString('assets/charset.json');
    final Map<String, dynamic> data = jsonDecode(Jsonlesson);

    return data.entries.map((entry) {
      return Lesson.fromJson(entry.key, entry.value);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NavBar(),
      body: Center(
        child: Container(
          child: Padding (
            padding: const EdgeInsets.fromLTRB(50, 20, 50, 20),
            child: FutureBuilder<List<Lesson>>(
              future: lessons,
              builder: (context, snapshot) {
                return Container(
                  color: colorRED,
                  alignment: Alignment.center,
                  width: 500.0,
                  height: 500.0,
                  child: Column(
                    children: <Widget>[
                      Flexible(
                        child: ListView(
                          shrinkWrap: true,
                          children: <Widget>[
                            const Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                'Lessons',
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: colorGOLD,
                                ),
                              ),
                            ),
                            Buttons(),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget Buttons() {
    return OverflowBar(
      alignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        ElevatedButton(
          child: const Text('Lesson1'),
          onPressed: () {
            setState(() {
              showSecondButton = !showSecondButton;
            });
          },
        ),
        if (showSecondButton) Lesson1(), // Displays lesson button
      ],
    );
  }

  Widget Lesson1() {
    return FutureBuilder<List<Lesson>>(
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

        /**  return Column(
            children: lessons.map((lesson) {
              return Column(
                children: [
                  SizedBox(height: 10), */

                  // Character Buttons
              /**    Right(
                    alignment: Alignment.centerRight, // Align to the right
                    //crossAxisAlignment: CrossAxisAlignment.end,
                    child: SizedBox(
                      width: 500,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center, // Align to center
                        children: lesson.characters.map((character) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10.0), // Space between characters
                            child: TextButton(
                              child: Text(
                                character.character, // Import character from JSON
                                style: TextStyle(fontSize: 20,  color: colorGOLD,),

                              ),
                              onPressed: () {
                                showCharacterDetails(context, character); // Pops up a dialog bar containing character information
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          );
        }
      },
    );
  }*/
          return Align(
            alignment: Alignment.centerRight, // Align container to the right
            child: Container(
              width: 70,
              height: 500, // Set a fixed width for the container
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colorWHITE,
                border: Border.all(color: colorGOLD),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, // Center vertically
                crossAxisAlignment: CrossAxisAlignment.center, // Center text inside
                children: lessons.expand((lesson) {
                  return lesson.characters.map((character) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: TextButton(
                        onPressed: () {
                          showCharacterDetails(context, character);
                        },
                        child: Text(
                          character.character,
                          style: TextStyle(fontSize: 20, color: colorGOLD),
                        ),
                      ),
                    );
                  }).toList();
                }).toList(),
              ),
            ),
          );
        }
      },
    );
  }


  void showCharacterDetails(BuildContext context, Character character) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            character.character,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView( // Ensures content doesn't overflow
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,

              // Displays all information
              children: [
                Text("Character: ${character.character}",
                    style: TextStyle(fontSize: 18)),
                Text("Unicode: ${character.unicode}",
                    style: TextStyle(fontSize: 18)),
                Text("Pinyin: ${character.pinyin}",
                    style: TextStyle(fontSize: 18)),
                Text("Definition: ${character.definition}",
                    style: TextStyle(fontSize: 18)),
                Text("Strokes: ${character.strokeNum}",
                    style: TextStyle(fontSize: 18)),
                SizedBox(height: 10),
                Text("Parts", style: TextStyle(fontSize: 20)),
                Column(
                  children: character.parts.map((part) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        "Part ID: ${part.partID}, Stroke Nums: ${part.strokeNums}, Story: ${part.story}",
                        style: TextStyle(fontSize: 16),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );






}
}
