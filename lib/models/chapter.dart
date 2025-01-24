class Chapter {
  final int? id;
  final int storyId;
  late final String text;
  final String? media;

  Chapter({this.id, required this.storyId, required this.text, this.media});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'story_id': storyId,
      'text': text,
      'media': media,
    };
  }

  static Chapter fromMap(Map<String, dynamic> map) {
    return Chapter(
      id: map['id'],
      storyId: map['story_id'],
      text: map['text'],
      media: map['media'],
    );
  }
}
