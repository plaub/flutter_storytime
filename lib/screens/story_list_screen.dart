import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../models/chapter.dart';
import '../models/story.dart';
import '../services/database_service.dart';
import 'create_story_screen.dart';
import 'story_detail_screen.dart';

class StoryListScreen extends StatefulWidget {
  const StoryListScreen({Key? key}) : super(key: key);

  @override
  _StoryListScreenState createState() => _StoryListScreenState();
}

class _StoryListScreenState extends State<StoryListScreen> {
  final DatabaseService _databaseService = DatabaseService();
  late Future<List<Story>> _storiesFuture;

  final appBarTitle = 'page_title_story_list'.tr();
  final errorLoadingStories = 'error_story_could_not_be_loaded'.tr();
  final errorStoriesNotFound = 'error_no_stories_found'.tr();

  @override
  void initState() {
    super.initState();
    _loadStories();
  }

  void _loadStories() {
    setState(() {
      _storiesFuture = _databaseService.getStories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
      ),
      body: FutureBuilder<List<Story>>(
        future: _storiesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // print error message
            debugPrint(snapshot.error.toString());

            return Center(
                child: Text(errorLoadingStories);
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text(errorStoriesNotFound));
          }

          final stories = snapshot.data!;
          return ListView.builder(
            itemCount: stories.length,
            itemBuilder: (context, index) {
              final story = stories[index];
              return ListTile(
                title: Text(story.title),
                subtitle: Text(story.summary),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StoryDetailScreen(story: story),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  CreateStoryScreen(databaseService: _databaseService),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
