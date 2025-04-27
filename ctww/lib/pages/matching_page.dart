import 'dart:convert';
import 'package:ctww/utils/colors.dart';

import '../utils/matching_page/game_status_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/nav_bar.dart';
import '../utils/matching_page/match_row.dart';
import 'package:lottie/lottie.dart';
import 'package:audioplayers/audioplayers.dart';

final audioPlayer = AudioPlayer();

class MatchingPage extends StatefulWidget {
  @override
  MatchingPageState createState() => MatchingPageState();
}

class MatchingPageState extends State<MatchingPage> {
  int maxLessons = 4;
  List<String> wordBank = [];
  List<String> chineseCharacters = [];
  Map<String, String> characterToDef = {};
  Set<String> matchedWords = {};
  int lessonID = 1;
  int score = 0;
  int lives = 3;
  bool isGameStarted = false;
  GameDifficulty difficulty = GameDifficulty.easy;
  List<String> shuffledWordBank = [];
  Map<int, bool> completedLessons = {};
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  AudioPlayer audioPlayer = AudioPlayer();
  bool isAudioPlaying = false;
  Set<String> matchedCharacters = {};
  static const String COMPLETED_LESSONS_KEY = 'completed_lessons';
  bool isStorageReady = false;
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    _initStorage();
    loadCharacters();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showLandingPopup(context);
    });
  }

  Future<void> _initStorage() async {
    try {
      prefs = await SharedPreferences.getInstance();
      loadLessonProgress();
    } catch (e) {
      print('Error initializing SharedPreferences: $e');
      setState(() {
        completedLessons = {}; // Fallback to empty map if we get an error
      });
    }
  }

  bool isLessonCompleted(int lessonID) {
    return completedLessons[lessonID] ?? false;
  }

  void loadLessonProgress() {
    try {
      final savedLessons = prefs.getString(COMPLETED_LESSONS_KEY);
      if (savedLessons != null) {
        // Decode JSON string to Map<String, dynamic>
        final Map<String, dynamic> decodedLessons = json.decode(savedLessons);
        // Convert to Map<int, bool>
        final Map<int, bool> loadedLessons = {};
        decodedLessons.forEach((key, value) {
          loadedLessons[int.parse(key)] = value as bool;
        });
        setState(() {
          completedLessons = loadedLessons;
          print('Loaded lesson progress: $completedLessons');
        });
      } else {
        // No data found, initialize empty map
        setState(() {
          completedLessons = {};
          print('No lesson progress found, initialized empty map');
        });
      }
    } catch (e) {
      // Handle JSON parsing or other errors
      print('Error loading lesson progress: $e');
      setState(() {
        completedLessons = {};
      });
    }
  }

  void saveLessonProgress() {
    try {
      final Map<String, bool> lessonMapForStorage = {};
      completedLessons.forEach((key, value) {
        lessonMapForStorage[key.toString()] = value;
      });
      prefs.setString(COMPLETED_LESSONS_KEY, json.encode(lessonMapForStorage));
      print('Saved lesson progress: $completedLessons');
    } catch (e) {
      print('Error saving lesson progress: $e');
    }
  }

  void showEndGamePopup(BuildContext context, bool isVictory, bool isTimeOut) {
    try {
      isVictory
          ? audioPlayer.play(AssetSource('sounds/win.mp3'))
          : audioPlayer.play(AssetSource('sounds/failure.mp3'));
    } catch (e) {
      print('Audio playback error: $e');
    }

    showDialog(
      context: context,
      barrierDismissible:
          false, // Prevents closing the popup by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isVictory ? "Victory!" : "Game Over"),
          content: Text(isVictory
              ? "Congratulations! You completed the game!"
              : (isTimeOut)
                  ? "You ran out of time. Try again!"
                  : "You ran out of lives. Try again!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Closes the popup
                audioPlayer.stop(); // Stop the audio
                resetGame();
              },
              child: Text("Play Again"),
            ),
          ],
        );
      },
    );
  }

  void resetGame() {
    setState(() {
      score = 0;
      lives = 3;
      isGameStarted = false;
      matchedWords = {}; // Clear matched words
      loadCharacters();
      matchedCharacters = {}; // Clear matched characters
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showLandingPopup(context);
      });
    });
  }

  Future<void> loadCharacters() async {
    String jsonString = await rootBundle.loadString('assets/charset.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);

    List<String> tempWords = [];
    List<String> tempCharacters = [];
    Map<String, String> characterToDeftemp = {};

    String lessonKey = 'lesson-$lessonID';

    if (jsonData.containsKey(lessonKey)) {
      for (var character in jsonData[lessonKey]['characters']) {
        tempCharacters.add(character['character']);
        characterToDeftemp[character['character']] = character['definition'];
        tempWords.add(character['definition']);
      }
    }

    setState(() {
      wordBank = tempWords;
      characterToDef = characterToDeftemp;
      chineseCharacters = tempCharacters;
      matchedWords = {}; // Reset matched words
      shuffledWordBank = List.from(wordBank)..shuffle();
    });
  }

  Widget buildMatchRows() {
    int itemsPerColumn = 5;
    int numColumns = (chineseCharacters.length / itemsPerColumn).ceil();

    double totalWidth = MediaQuery.of(context).size.width;
    double matchRowWidth = totalWidth / numColumns; // Ensure equal distribution

    // Chunk characters into sublists
    List<List<String>> chunkedCharacters = [];
    for (int i = 0; i < chineseCharacters.length; i += itemsPerColumn) {
      chunkedCharacters.add(
        chineseCharacters.sublist(
          i,
          (i + itemsPerColumn > chineseCharacters.length)
              ? chineseCharacters.length
              : i + itemsPerColumn,
        ),
      );
    }

    return SizedBox(
      width: totalWidth,
      child: SingleChildScrollView(
        scrollDirection:
            Axis.horizontal, // Allows scrolling if too many columns
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: chunkedCharacters.map((chunk) {
            return SizedBox(
              width: matchRowWidth, // Ensure each column has a width
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8.0), // Space between columns
                child: Column(
                  children: chunk
                      .map((character) => MatchRow(
                          chineseCharacter: character,
                          characterToDef: characterToDef,
                          matchRowWidth: matchRowWidth,
                          isStarted: isGameStarted,
                          isMatched: matchedCharacters.contains(character),
                          onLoseLife: () {
                            lives--;
                            setState(() {
                              if (lives > 0) {
                                // Play incorrect sound
                                try {
                                  audioPlayer.play(AssetSource(
                                      '../assets/sounds/incorrect.mp3'));
                                } catch (e) {
                                  print('Audio playback error: $e');
                                }
                              }
                              print('Lives remaining: $lives');
                              if (lives == 0) {
                                // Game over
                                showEndGamePopup(context, false, false);
                                print('Game over');
                              }
                            });
                          },
                          onCorrectAnswer: () {
                            onCorrectMatch(character);
                          }))
                      .toList(),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void goToLesson(int newLessonID) {
    setState(() {
      lessonID = newLessonID;
      loadCharacters();
      Navigator.of(context).pop(); // Close the drawer
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NavBar(),
      body: Container(
        color: colorGOLD,
        child: Scaffold(
          backgroundColor: colorGOLD,
          key: _scaffoldKey,
          drawer: Drawer(
            backgroundColor: Colors.grey[800],
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(color: colorGOLD),
                  child: Text('Lessons',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                ),
                for (int i = 1; i < maxLessons + 1; i++)
                  ListTile(
                    title: Text(
                      'Lesson ${i}',
                      style: TextStyle(
                        color: isLessonCompleted(i) ? Colors.green : colorWHITE,
                        fontWeight: isLessonCompleted(i)
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    trailing: isLessonCompleted(i)
                        ? Icon(Icons.check, color: Colors.green)
                        : null,
                    onTap: () => goToLesson(i),
                  ),
              ],
            ),
          ),
          appBar: GameStatusBar(
            currentLesson: lessonID,
            difficulty: difficulty,
            lives: lives,
            isStarted: isGameStarted,
            onLessonChange: (newLesson) {
              setState(() {
                lessonID = newLesson;
                print('New lesson: $lessonID');
                loadCharacters();
                for (var i = 0; i < chineseCharacters.length; i++) {
                  print(chineseCharacters[i]);
                }
                resetGame();
              });
            },
            onDifficultyChange: (newDifficulty) {
              setState(() {
                difficulty = newDifficulty;
                print('new difficulty = $newDifficulty');
                resetGame();
                // Handle difficulty change
              });
            },
            onGameOver: () {
              showEndGamePopup(context, false, true);
            },
            scaffoldKey: _scaffoldKey,
            score: score,
            maxLesson: maxLessons,
          ),
          body: Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * .15,
                decoration: BoxDecoration(color: Colors.red, boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3),
                  ),
                ]),
                child: Center(
                  child: buildWordBank(),
                ),
              ),
              // Matching rows (Scrollable)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: buildMatchRows(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildWordBank() {
    // Filter out matched words
    List<String> availableWords =
        shuffledWordBank.where((word) => !matchedWords.contains(word)).toList();

    double screenWidth = MediaQuery.of(context).size.width;
    double cardWidth = screenWidth / 5 * 0.9; // 5 cards per row with padding
    double cardHeight = 50; // Fixed height

    return SingleChildScrollView(
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: availableWords
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
            style: TextStyle(fontSize: 18, color: Colors.black),
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
          style: TextStyle(fontSize: 18, color: Colors.black),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  void onCorrectMatch(String character) {
    // Get the definition that was matched
    String matchedDefinition = characterToDef[character]!;

    setState(() {
      // Add the definition to our matched words set
      matchedWords.add(matchedDefinition);
      matchedCharacters.add(character); // Track matched characters

      // Play correct sound
      try {
        audioPlayer.play(AssetSource('sounds/correct.mp3'));
      } catch (e) {
        print('Audio playback error: $e');
      }

      score++;
      print('Score: $score');
      if (score == chineseCharacters.length) {
        completedLessons[lessonID] = true;
        saveLessonProgress(); // Save progress
        showEndGamePopup(context, true, false);
      }
    });
  }

  void onIncorrectMatch() {
    setState(() {
      lives--;
      print('Lives remaining: $lives');
      if (lives == 0) {
        // Game over
        showEndGamePopup(context, false, false);
        print('Game over');
      }
    });
  }

  void showLandingPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevents clicking outside to dismiss
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Example Animation (Replace with Lottie.asset() if needed)
              Container(
                height: 200,
                width: 200,
                child: Lottie.asset(
                  'assets/animations/dragAnimation.json',
                  fit: BoxFit.fill,
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Welcome to the Matching Game!",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                "Match the Chinese characters with their meanings by dragging the correct pairs together. Try to get them all right before running out of lives or time!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isGameStarted = true;
                  });
                  Navigator.of(context).pop(); // Close the popup
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "START",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
