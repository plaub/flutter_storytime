import 'package:geschichten_magie/models/chapter.dart';
import 'package:geschichten_magie/services/database_service.dart';

class ChapterRepository {
  final DatabaseService _dbService = DatabaseService();

  Future<int> addChapter(Chapter chapter) async {
    final db = await _dbService.database;
    return await db.insert('chapters', chapter.toMap());
  }

  Future<List<Chapter>> addChapters(List<Chapter> chapters) async {
    final db = await _dbService.database;
    final batch = db.batch();
    for (final chapter in chapters) {
      batch.insert('chapters', chapter.toMap());
    }
    await batch.commit(noResult: true);
    return chapters;
  }

  Future<Chapter> getChapter(int id) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'chapters',
      where: 'id = ?',
      whereArgs: [id],
    );

    return Chapter.fromMap(maps.first);
  }

  Future<List<Chapter>> getChapters(int storyId) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'chapters',
      where: 'story_id = ?',
      whereArgs: [storyId],
    );

    return List.generate(maps.length, (i) {
      return Chapter.fromMap(maps[i]);
    });
  }

  Future<void> updateChapter(Chapter chapter) async {
    final db = await _dbService.database;
    await db.update(
      'chapters',
      chapter.toMap(),
      where: 'id = ?',
      whereArgs: [chapter.id],
    );
  }

  Future<void> updateChapters(List<Chapter> chapters) async {
    final db = await _dbService.database;
    final batch = db.batch();
    for (final chapter in chapters) {
      batch.update(
        'chapters',
        chapter.toMap(),
        where: 'id = ?',
        whereArgs: [chapter.id],
      );
    }
    await batch.commit(noResult: true);
  }

  Future<void> deleteChapter(int id) async {
    final db = await _dbService.database;
    await db.delete(
      'chapters',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
