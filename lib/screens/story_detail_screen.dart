import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_storytime/models/chapter.dart';
import 'package:flutter_storytime/screens/story_editor_screen.dart';
import '../models/story.dart';
import 'chapter_editor_screen.dart';

class StoryDetailScreen extends StatelessWidget {
  final Story? story;
  final List<Chapter>? chapters;

  StoryDetailScreen({super.key, this.story, this.chapters});

  final fallbackStoryTitle = 'fallback_story_title'.tr();
  final fallbackStorySummary = 'fallback_story_summary'.tr();
  final storyChapterPrefix = 'story_chapter_prefix'.tr();

  @override
  Widget build(BuildContext context) {
    final fallbackStory = Story(
      title: fallbackStoryTitle,
      summary: fallbackStorySummary,
    );

    final fallbackChapters = [];

    final displayedStory = story ?? fallbackStory;
    final displayedChapters = chapters ?? fallbackChapters;

    return Scaffold(
      appBar: AppBar(
        title: Text(displayedStory.title),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StoryEditorScreen(
                    story: displayedStory,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: displayedChapters.isEmpty
          ? Center(child: Text(displayedStory.summary))
          : ListView.builder(
              itemCount: displayedChapters.length,
              itemBuilder: (context, index) {
                final chapter = displayedChapters[index];
                return ListTile(
                  title: Text('$storyChapterPrefix ${index + 1}'),
                  subtitle: Text(chapter.text),
                  trailing: IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      // Navigiere zum Chapter-Editor
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChapterEditorScreen(
                            chapterIndex: index,
                            chapter: chapter,
                            onSave: (updatedText) {
                              Navigator.pop(context); // Zurückkehren
                            },
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
