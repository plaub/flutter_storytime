import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geschichten_magie/models/RiddleEvents.dart';
import 'package:geschichten_magie/repositories/chapter_repository.dart';
import 'package:geschichten_magie/repositories/story_repository.dart';
import 'package:geschichten_magie/widgets/RiddleWebViewComponent.dart';
import '../models/story.dart';
import '../models/chapter.dart';
import '../services/database_service.dart';

class CreateStoryScreen extends StatefulWidget {
  const CreateStoryScreen({super.key});

  @override
  _CreateStoryScreenState createState() => _CreateStoryScreenState();
}

class _CreateStoryScreenState extends State<CreateStoryScreen> {
  final storyRepo = StoryRepository();
  final chapterRepo = ChapterRepository();

  final _promptController = TextEditingController();
  bool _isGenerating = false;
  String? _generatedStory;
  FocusNode _focusNode = FocusNode();
  final List<RiddleEvent> _riddleEvents =
      []; // Liste zum Speichern der RiddleEvents
  final GlobalKey<RiddleWebViewComponentState> _webViewKey =
      GlobalKey<RiddleWebViewComponentState>();

  final String riddleId = dotenv.env['RIDDLE_ID']!;

  final appBarTitle = 'page_title_story_create'.tr();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }

      final webViewState = _webViewKey.currentState;
      if (webViewState != null) {
        if (kDebugMode) {
          debugPrint('WebViewState found: $webViewState');
        }
        _subscribeToRiddleEvents(webViewState);
      } else {
        if (kDebugMode) {
          debugPrint('WebViewState is not available');
        }
      }
    });
  }

  @override
  void dispose() {
    _promptController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Subscribe to the stream of the RiddleWebViewComponent and save events
  void _subscribeToRiddleEvents(RiddleWebViewComponentState webViewState) {
    if (kDebugMode) {
      debugPrint('Subscribing to Riddle events');
    }

    webViewState.riddleEventStream.listen((event) {
      if (event.action == 'Form_Submit') {
        if (kDebugMode) {
          debugPrint('Riddle-riddleEventStream: ${event.formAnswers}');
        }
      }

      if (event.action == 'CoreMetrics' && event.name == 'Finish') {
        if (kDebugMode) {
          debugPrint('Riddle finished. Generating story...');
        }

        _generateStory(); // Generiere die Geschichte

        return;
      }

      setState(() {
        _riddleEvents.add(event); // Füge das Event zur Liste hinzu
      });
      if (kDebugMode) {
        debugPrint('Received event: ${event.category}');
      }
    });
  }

  Future<void> _generateStory() async {
    // Filter all Block_Submit and Form_Submit events
    final blockSubmitEvents = _riddleEvents
        .where((event) =>
            event.action == 'Block_Submit' || event.action == 'Form_Submit')
        .toList();

    var prompt = 'promt_first_line'.tr();

    // Iterate over all Block_Submit events and add them to the prompt
    for (final event in blockSubmitEvents) {
      if (event.action == 'Block_Submit') {
        // event.blockContent.title can be html content. convert it to plain text
        final plainTextTitle =
            event.blockContent?.title?.replaceAll(RegExp(r'<[^>]*>'), '');

        prompt += '\n\n$plainTextTitle: ${event.answer}';
      } else if (event.action == 'Form_Submit') {
        for (final formAnswer in event.formAnswers!) {
          // formAnswer.blockTitle can be html content. convert it to plain text
          final plainTitle =
              formAnswer.blockTitle?.replaceAll(RegExp(r'<[^>]*>'), '');

          prompt += '\n\n$plainTitle: ${formAnswer.data}';
        }
      }
    }

    prompt += 'promt_last_line'.tr();

    setState(() => _isGenerating = true);

    if (kDebugMode) {
      debugPrint('Prompt: $prompt');
    }

    try {
      // OpenAI API call
      final response = await OpenAI.instance.chat
          .create(
        model: "gpt-4o",
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.system,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(
                  "promt_role_system".tr())
            ], // String for the message
          ),
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.user,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(prompt)
            ], // Prompt for the story
          ),
        ],
        maxTokens: 1000,
      )
          .timeout(
        const Duration(seconds: 300), // Timeout to 5 minutes
        onTimeout: () {
          throw Exception("request_timeout".tr());
        },
      );

      // Access to the generated response
      final message = response.choices.first.message;
      String generatedStory;

      // Check whether `content` is a list or a string
      if (message.content is String) {
        generatedStory = message.content as String;
      } else if (message.content
          is List<OpenAIChatCompletionChoiceMessageContentItemModel>) {
        generatedStory = (message.content
                as List<OpenAIChatCompletionChoiceMessageContentItemModel>)
            .map((item) => item.text)
            .join('\n');
      } else {
        throw Exception('unknown_content_type'
            .tr(args: [message.content.runtimeType.toString()]));
      }

      if (kDebugMode) {
        debugPrint("Generated Story: $generatedStory");
      }

      setState(() {
        _generatedStory = generatedStory;
        _isGenerating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('story_generated_success'.tr())),
      );

      // Save the story
      await _saveStory();
    } catch (e) {
      setState(() => _isGenerating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('story_generation_error'.tr(args: [e.toString()]))),
      );
    }
  }

  Future<void> _saveStory() async {
    if (_generatedStory == null || _generatedStory!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('no_story_to_save'.tr())),
      );
      return;
    }

    final story = Story(
      title: "generated_story_title".tr(),
      summary: _generatedStory!.split('\n').take(3).join('\n'), // First 3 lines
    );

    final storyId = await storyRepo.addStory(story);
    final chapters = [
      Chapter(text: _generatedStory!, media: null, storyId: storyId)
    ];

    await chapterRepo.addChapters(chapters);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('story_saved_success'.tr())),
    );

    // Navigate to the HomeScreen
    Navigator.pushNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
      ),
      body: RiddleWebViewComponent(
        key: _webViewKey,
        riddleId: riddleId,
      ),
    );
  }
}
