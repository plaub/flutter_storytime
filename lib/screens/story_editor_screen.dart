import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:geschichten_magie/repositories/chapter_repository.dart';
import 'package:geschichten_magie/repositories/story_repository.dart';
import '../models/story.dart';

class StoryEditorScreen extends StatefulWidget {
  final Story story;

  const StoryEditorScreen({super.key, required this.story});

  @override
  _StoryEditorScreenState createState() => _StoryEditorScreenState();
}

class _StoryEditorScreenState extends State<StoryEditorScreen> {
  final storyRepo = StoryRepository();
  final chapterRepo = ChapterRepository();

  late TextEditingController _titleController;
  late TextEditingController _summaryController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _initializeStory();
  }

  Future<void> _initializeStory() async {
    setState(() {
      _isLoading = true;
    });

    final storyFuture = await storyRepo.getStory(widget.story.id!);

    setState(() {
      _titleController = TextEditingController(text: storyFuture.title);
      _summaryController = TextEditingController(text: storyFuture.summary);
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _summaryController.dispose();
    super.dispose();
  }

  Future<void> _saveStory() async {
    final updatedStory = Story(
      id: widget.story.id,
      title: _titleController.text.trim(),
      summary: _summaryController.text.trim(),
    );

    await storyRepo.updateStory(updatedStory);

    // Zurück zum vorherigen Screen
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('page_title_story_edit'.tr())),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('page_title_story_edit'.tr()),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveStory,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'label_titel'.tr(),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _summaryController,
              decoration: InputDecoration(
                labelText: 'label_text'.tr(),
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
}
