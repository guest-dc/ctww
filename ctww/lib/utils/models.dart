class Stroke {
  final int strokeID;
  final String stroke;
  final String story;

  Stroke({required this.strokeID, required this.stroke, required this.story});

  factory Stroke.fromJson(Map<String, dynamic> json) {
    return Stroke(
      strokeID: json['strokeID'],
      stroke: json['stroke'],
      story: json['story'],
    );
  }
}

class Character {
  final String character;
  final String unicode;
  final String pinyin;
  final String definition;
  final String story;
  final String animation;
  final int strokeNum;
  final List<Stroke> strokes;

  Character({
    required this.character,
    required this.unicode,
    required this.pinyin,
    required this.definition,
    required this.story,
    required this.animation,
    required this.strokeNum,
    required this.strokes,
  });

  factory Character.fromJson(Map<String, dynamic> json) {
    var list = json['strokes'] as List;
    List<Stroke> strokeList = list.map((i) => Stroke.fromJson(i)).toList();

    return Character(
      character: json['character'],
      unicode: json['unicode'],
      pinyin: json['pinyin'],
      definition: json['definition'],
      story: json['story'],
      animation: json['animation'],
      strokeNum: json['strokeNum'],
      strokes: strokeList,
    );
  }
}

class Lesson {
  final int lessonID;
  final List<Character> characters;

  Lesson({required this.lessonID, required this.characters});

  factory Lesson.fromJson(Map<String, dynamic> json) {
    var list = json['characters'] as List;
    List<Character> characterList = list.map((i) => Character.fromJson(i)).toList();

    return Lesson(
      lessonID: json['lessonID'],
      characters: characterList,
    );
  }
}
