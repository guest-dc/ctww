import 'dart:convert';
import 'package:flutter/services.dart';

class Lesson {
  final String lessonName;
  final List<Character> characters;

  Lesson({
    required this.lessonName,
    required this.characters,
  });

  factory Lesson.fromJson(String lessonName, Map<String, dynamic> json) => Lesson(
        lessonName: lessonName,
        characters: (json['characters'] as List)
            .map((characterJson) => Character.fromJson(characterJson))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'lessonName': lessonName,
        'characters': characters.map((character) => character.toJson()).toList(),
      };
}


Future<List<Lesson>> loadLessons() async {
  final String jsonString = await rootBundle.loadString('assets/charset.json');
  final Map<String, dynamic> data = jsonDecode(jsonString);

  return data.entries.map((entry) {
    return Lesson.fromJson(entry.key, entry.value);
  }).toList();
}



class Character {
  final String character;
  final String unicode;
  final String pinyin;
  final String definition;
  final String story;
  final int strokeNum;
  final List<Part> parts;

  Character({
    required this.character,
    required this.unicode,
    required this.pinyin,
    required this.definition,
    required this.story,
    required this.strokeNum,
    required this.parts,
  });

  factory Character.fromJson(Map<String, dynamic> json) => Character(
    character: json['character'] as String,
    unicode: json['unicode'] as String,
    pinyin: json['pinyin'] as String,
    definition: json['definition'] as String,
    story: json['story'] as String,
    strokeNum: json['strokeNum'] as int,
    parts: (json['parts'] as List)
        .map((partJson) => Part.fromJson(partJson))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'character': character,
    'unicode': unicode,
    'pinyin': pinyin,
    'definition': definition,
    'story': story,
    'strokeNum': strokeNum,
    'parts': parts.map((part) => part.toJson()).toList(),
  };
}



class Part {
  final int partID;
  final List<int> strokeNums;
  final String story;

  Part({
    required this.partID,
    required this.strokeNums,
    required this.story
  });

  factory Part.fromJson(Map<String, dynamic> json) => Part(
    partID: json['partID'] as int,
    strokeNums: List<int>.from(json['strokeNums'] as List),
    story: json['story'] as String,
  );

  Map<String, dynamic> toJson() => {
    'partID': partID,
    'strokeNums': strokeNums,
    'story': story,
  };
}