class Story {
  final int? id;
  late final String title;
  late final String summary;

  Story({this.id, required this.title, required this.summary});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'summary': summary,
    };
  }

  static Story fromMap(Map<String, dynamic> map) {
    return Story(
      id: map['id'],
      title: map['title'],
      summary: map['summary'],
    );
  }
}
