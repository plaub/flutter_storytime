import 'package:hive/hive.dart';

import 'chapter.dart';

part 'story.g.dart';

@HiveType(typeId: 0)
class Story {
  @HiveField(0)
  String title;

  @HiveField(1)
  String summary;

  @HiveField(2)
  List<Chapter> chapters;

  Story({
    required this.title,
    required this.summary,
    required this.chapters,
  });
}
