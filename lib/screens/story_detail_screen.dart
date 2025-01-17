import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../models/story.dart';

class StoryDetailScreen extends StatelessWidget {
  final Story? story; // Optionaler Parameter

  StoryDetailScreen({super.key, this.story});

  final fallbackStoryTitle = 'fallback_story_title'.tr();
  final fallbackStorySummary = 'fallback_story_summary'.tr();
  final storyChapterPrefix = 'story_chapter_prefix'.tr();

  @override
  Widget build(BuildContext context) {
    // Fallback, falls story null ist
    final fallbackStory = Story(
      title: fallbackStoryTitle,
      summary: fallbackStorySummary,
      chapters: [],
    );

    final displayedStory = story ?? fallbackStory;

    return Scaffold(
      appBar: AppBar(
        title: Text(displayedStory.title),
      ),
      body: displayedStory.chapters.isEmpty
          ? Center(child: Text(displayedStory.summary))
          : ListView.builder(
              itemCount: displayedStory.chapters.length,
              itemBuilder: (context, index) {
                final chapter = displayedStory.chapters[index];
                return ListTile(
                  title: Text('$storyChapterPrefix ${index + 1}'),
                  subtitle: Text(chapter.text),
                  trailing: chapter.media != null
                      ? Icon(Icons.image, color: Colors.green)
                      : null,
                );
              },
            ),
    );
  }
}
