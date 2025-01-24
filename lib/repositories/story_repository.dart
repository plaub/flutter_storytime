import 'package:geschichten_magie/models/story.dart';
import 'package:geschichten_magie/services/database_service.dart';

class StoryRepository {
  final DatabaseService _dbService = DatabaseService();

  Future<int> addStory(Story story) async {
    final db = await _dbService.database;
    return await db.insert('stories', story.toMap());
  }

  Future<Story> getStory(int id) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'stories',
      where: 'id = ?',
      whereArgs: [id],
    );

    return Story.fromMap(maps.first);
  }

  Future<List<Story>> getStories() async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query('stories');

    return List.generate(maps.length, (i) {
      return Story.fromMap(maps[i]);
    });
  }

  Future<void> updateStory(Story story) async {
    final db = await _dbService.database;
    await db.update(
      'stories',
      story.toMap(),
      where: 'id = ?',
      whereArgs: [story.id],
    );
  }

  Future<void> deleteStory(int id) async {
    final db = await _dbService.database;
    await db.delete(
      'stories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
