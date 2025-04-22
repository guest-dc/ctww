import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../utils/colors.dart';
import '../utils/models.dart';
import '../utils/nav_bar.dart';
import '../pages/story_walk_page.dart';

class LessonsPage extends StatefulWidget {
  const LessonsPage({Key? key}) : super(key: key);

  @override
  State<LessonsPage> createState() => LessonsPageState();
}

class LessonsPageState extends State<LessonsPage> {
  bool showSecondButton = false;
  late Future<List<Lesson>> lessons;

  int? selectedLessonIndex;


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

  //build the webpage
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
                  width: 700.0,
                  height: 500.0,
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: ListView(
                          shrinkWrap: true,
                          children: <Widget>[
                        const Text(
                                'Tap on a lesson to display characters',
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: colorGOLD,
                                ),
                              ),
                            Buttons(), //displays buttons
                          ],
                        ),
                      ),
                // displays the character
                if (selectedLessonIndex != null)
                Align(
                alignment: Alignment.topRight,
                child: buildCharacterButtons(snapshot.data![selectedLessonIndex!]),
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

  //build buttons and handle error
  Widget Buttons() {
    return FutureBuilder<List<Lesson>>(
      future: lessons,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text('No lessons available');
        }

        final loadedLessons = snapshot.data!;

        return Align(
          alignment: Alignment.topLeft, //  Align vertically to the left
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // : Left align buttons
            children: [
              // Loop through lessons and create buttons
              ...List.generate(loadedLessons.length, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                     backgroundColor: colorWHITE,
                      foregroundColor: colorGOLD,
                    ),
                    child: Text('Lesson ${index + 1}'),
                    onPressed: () {
                      setState(() {
                        selectedLessonIndex = index;
                      });
                    },
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }


//Design for each button
  Widget buildCharacterButtons(Lesson lesson) {
    return Align(
      alignment: Alignment.topRight,
      child: Container(
        width: 70,
        height: 500,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: colorWHITE,
          border: Border.all(color: colorGOLD),
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListView(
          children: lesson.characters.map((character) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
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
          }).toList(),
        ),
      ),
    );
  }

  //Displays character information in a Alert dialog box
  void showCharacterDetails(BuildContext context, Character character) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          // when the character title is taped, it will navigate to the story Walkthrough page
          title: GestureDetector(
            onTap: () {
              Navigator.of(context).pop(); // Close the dialog first
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StoryWalkPage(initialCharacter: character),
                ),
              );
            },

            //information in the dialog box
            child: Text(
              '${character.character}       Tap character to view animation',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Character: ${character.character}", style: TextStyle(fontSize: 18)),
                Text("Unicode: ${character.unicode}", style: TextStyle(fontSize: 18)),
                Text("Pinyin: ${character.pinyin}", style: TextStyle(fontSize: 18)),
                Text("Definition: ${character.definition}", style: TextStyle(fontSize: 18)),
                Text("Strokes: ${character.strokeNum}", style: TextStyle(fontSize: 18)),
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
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}
