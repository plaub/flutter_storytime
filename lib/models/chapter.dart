import 'package:hive/hive.dart';

part 'chapter.g.dart';

@HiveType(typeId: 1)
class Chapter {
  @HiveField(0)
  String text;

  @HiveField(1)
  String? media; // Optional

  Chapter({
    required this.text,
    this.media,
  });
}
