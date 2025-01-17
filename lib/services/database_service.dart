import 'package:hive/hive.dart';
import '../models/chapter.dart';
import '../models/story.dart';

class DatabaseService {
  static const String _boxName = 'storiesBox';

  /// Ruft die Box ab, ohne sie erneut zu öffnen
  Box<Story> get storiesBox {
    if (!Hive.isBoxOpen(_boxName)) {
      throw HiveError(
          'Box $_boxName is not open. Did you forget to call Hive.openBox()?');
    }
    return Hive.box<Story>(_boxName);
  }

  /// Initialisiert den DatabaseService
  static Future<void> initDatabaseService() async {
    // Adapter registrieren
    Hive.registerAdapter(StoryAdapter());
    Hive.registerAdapter(ChapterAdapter());

    // Box für Geschichten öffnen
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<Story>(_boxName);
    } else {
      print('Box already open');
    }
  }

  /// Fügt eine neue Story hinzu
  Future<void> addStory(Story story) async {
    await storiesBox.add(story);
  }

  /// Ruft alle gespeicherten Geschichten ab
  Future<List<Story>> getStories() async {
    return storiesBox.values.toList();
  }

  /// Aktualisiert eine bestehende Geschichte
  Future<void> updateStory(int index, Story story) async {
    await storiesBox.putAt(index, story);
  }

  /// Löscht eine Geschichte
  Future<void> deleteStory(int index) async {
    await storiesBox.deleteAt(index);
  }
}
