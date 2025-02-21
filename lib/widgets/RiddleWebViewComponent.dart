import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_storytime/models/RiddleEvents.dart';
import 'package:webview_flutter/webview_flutter.dart';

class RiddleWebViewComponent extends StatefulWidget {
  late final String url;

  RiddleWebViewComponent({
    super.key,
    required riddleId,
  }) {
    url = 'https://www.riddle.com/embed/a/$riddleId';
  }

  @override
  RiddleWebViewComponentState createState() => RiddleWebViewComponentState();
}

class RiddleWebViewComponentState extends State<RiddleWebViewComponent> {
  late final WebViewController _controller;
  late final List<RiddleEvent> _riddleEvents = [];
  final _riddleEventController = StreamController<RiddleEvent>.broadcast();

  /// Exposed stream for RiddleEvents
  Stream<RiddleEvent> get riddleEventStream => _riddleEventController.stream;

  @override
  void initState() {
    super.initState();

    // Configure WebViewController
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            debugPrint('Page is loading: $url');
          },
          onPageFinished: (String url) {
            debugPrint('Page fully loaded: $url');
            _injectJavaScript(); // Inject JavaScript
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('Error loading the page: ${error.description}');
          },
        ),
      )
      ..addJavaScriptChannel(
        'postMessageHandler', // Channelname
        onMessageReceived: (message) {
          _handleJavaScriptEvent(message.message); // Call up dart function
        },
      )
      ..loadRequest(
        Uri.parse(widget.url),
      );
  }

  @override
  void dispose() {
    _riddleEventController.close();
    super.dispose();
  }

  /// Dart function that is triggered by JavaScript events
  void _handleJavaScriptEvent(String jsonMessage) {
    // Example: Processing JSON data
    try {
      debugPrint('Received JavaScript event Json: $jsonMessage');
      final riddleEventJson = jsonDecode(jsonMessage);
      final riddleEvent = RiddleEvent.fromJson(riddleEventJson);

      debugPrint('Riddle-Event: ${riddleEvent.action}');

      setState(() {
        _riddleEvents.add(riddleEvent);
      });

      // Emit event via the stream
      _riddleEventController.add(riddleEvent);
    } catch (e) {
      debugPrint('Error when processing JavaScript data: $e');
    }
  }

  /// JavaScript injizieren
  Future<void> _injectJavaScript() async {
    final script = """
      // Sample JavaScript: Send message to Flutter
      window.addEventListener("message", (event) => {
        if (
          event.origin !== "https://www.riddle.com" ||
          !event.data.isRiddle2Event ||
          !event.data.category ||
          !event.data.category.startsWith("RiddleTrackEvent")
        ) {
          return;
        }

        window.postMessageHandler.postMessage(JSON.stringify(event.data));
      });
    """;

    await _controller.runJavaScript(script);
    debugPrint('JavaScript was injected.');
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller);
  }
}
