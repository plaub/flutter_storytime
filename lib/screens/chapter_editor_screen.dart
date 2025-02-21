import 'package:flutter/material.dart';
import 'package:flutter_storytime/models/chapter.dart';
import 'package:flutter_storytime/repositories/chapter_repository.dart';

class ChapterEditorScreen extends StatefulWidget {
  final int chapterIndex;
  final Chapter chapter;
  final ValueChanged<void> onSave;

  const ChapterEditorScreen({
    super.key,
    required this.chapterIndex,
    required this.chapter,
    required this.onSave,
  });

  @override
  _ChapterEditorScreenState createState() => _ChapterEditorScreenState();
}

class _ChapterEditorScreenState extends State<ChapterEditorScreen> {
  final chapterRepo = ChapterRepository();
  late TextEditingController _textController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeChapter();
  }

  Future<void> _initializeChapter() async {
    setState(() {
      _isLoading = true;
    });

    final Chapter chapterFuture =
        await chapterRepo.getChapter(widget.chapter.id!);
    setState(() {
      _textController = TextEditingController(text: chapterFuture.text);
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _saveChapter() async {
    // Update the chapter with the new text
    final updatedChapter = Chapter(
      id: widget.chapter.id,
      storyId: widget.chapter.storyId,
      text: _textController.text.trim(),
      media: widget.chapter.media,
    );

    await chapterRepo.updateChapter(updatedChapter);

    widget.onSave(_textController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Kapitel bearbeiten')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Kapitel ${widget.chapterIndex + 1} bearbeiten'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              _saveChapter();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: _textController,
          maxLines: null,
          decoration: InputDecoration(
            labelText: 'Kapiteltext bearbeiten',
            border: OutlineInputBorder(),
          ),
        ),
      ),
    );
  }
}
