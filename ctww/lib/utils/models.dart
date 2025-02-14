class Lesson {
  final int lessonID;
  final List<Character> characters;

  Lesson({required this.lessonID, required this.characters});

  factory Lesson.fromJson(String lessonID, Map<String, dynamic> json) {
    var list = json['characters'] as List;
    int lessonNumber = int.parse(lessonID.replaceAll(RegExp(r'[^0-9]'), ''));
    List<Character> characterList = list.map((i) => Character.fromJson(i)).toList();
    
    return Lesson(
      lessonID: lessonNumber,
      characters: characterList,
    );
  }
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

  factory Character.fromJson(Map<String, dynamic> json) {
    var list = json['parts'] as List;
    List<Part> partList = list.map((i) => Part.fromJson(i)).toList();

    return Character(
      character: json['character'],
      unicode: json['unicode'],
      pinyin: json['pinyin'],
      definition: json['definition'],
      story: json['story'],
      strokeNum: json['strokeNum'],
      parts: partList,
    );
  }
}



class Part {
  final int partID;
  final List<int> strokeNums;
  final String story;

  Part({required this.partID, required this.strokeNums, required this.story});

  factory Part.fromJson(Map<String, dynamic> json) {
    return Part(
      partID: json['partID'],
      strokeNums: (json['strokeNums'] is List)
        ? List<int>.from(json['strokeNums'] as List)
        : [],
      story: json['story'],
    );
  }
}