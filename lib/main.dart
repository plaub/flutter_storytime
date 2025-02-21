import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_storytime/repositories/chapter_repository.dart';
import 'package:flutter_storytime/repositories/story_repository.dart';
import 'package:flutter_storytime/services/database_service.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/story_detail_screen.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  await dotenv.load();

  // Setze den API-Schlüssel
  OpenAI.apiKey = dotenv.env['OPENAI_API_KEY']!;

  runApp(
    EasyLocalization(
      supportedLocales: [
        Locale('en'),
        Locale('de'),
      ],
      path: 'assets/translations',
      fallbackLocale: Locale('en'),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'greeting'.tr(),
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/home': (context) => HomeScreen(),
        '/storyDetail': (context) => StoryDetailScreen(),
      },
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
    );
  }
}
