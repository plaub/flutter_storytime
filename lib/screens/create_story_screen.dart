import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geschichten_magie/models/RiddleEvents.dart';
import 'package:geschichten_magie/widgets/RiddleWebViewComponent.dart';
import '../models/story.dart';
import '../models/chapter.dart';
import '../services/database_service.dart';

class CreateStoryScreen extends StatefulWidget {
  final DatabaseService databaseService;

  const CreateStoryScreen({super.key, required this.databaseService});

  @override
  _CreateStoryScreenState createState() => _CreateStoryScreenState();
}

class _CreateStoryScreenState extends State<CreateStoryScreen> {
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
        debugPrint('WebViewState found: $webViewState');
        _subscribeToRiddleEvents(webViewState);
      } else {
        debugPrint('WebViewState is not available');
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
    debugPrint('Subscribing to Riddle events');

    webViewState.riddleEventStream.listen((event) {
      if (event.action == 'Form_Submit') {
        debugPrint('Riddle-riddleEventStream: ${event.formAnswers}');
      }

      if (event.action == 'CoreMetrics' && event.name == 'Finish') {
        debugPrint('Riddle finished. Generating story...');

        _generateStory(); // Generiere die Geschichte

        return;
      }

      setState(() {
        _riddleEvents.add(event); // Füge das Event zur Liste hinzu
      });
      debugPrint('Received event: ${event.category}');
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

    debugPrint('Prompt: $prompt');

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
                  "Du bist ein kreativer Geschichtenautor.")
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
          throw Exception("The request took too long and was canceled.");
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
        throw Exception(
            'Unknown type for content: ${message.content.runtimeType}');
      }

      debugPrint("Generated Story: $generatedStory");

      setState(() {
        _generatedStory = generatedStory;
        _isGenerating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Story successfully generated!')),
      );

      // Save the story
      await _saveStory();
    } catch (e) {
      setState(() => _isGenerating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error when generating the story: $e')),
      );
    }
  }

  Future<void> _saveStory() async {
    if (_generatedStory == null || _generatedStory!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No generated story to save.')),
      );
      return;
    }

    final story = Story(
      title: "Generierte Geschichte",
      summary:
          "Eine Geschichte basierend auf dem Prompt: ${_promptController.text.trim()}",
      chapters: [Chapter(text: _generatedStory!, media: null)],
    );

    await widget.databaseService.addStory(story);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('History successfully saved!')),
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
