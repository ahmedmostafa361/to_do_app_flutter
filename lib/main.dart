// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_do_app_flutter/ui/home/home_screen.dart';
import 'package:to_do_app_flutter/ui/note/create_note_screen.dart';
import 'package:to_do_app_flutter/utils/app_routes.dart';

import 'core/services/ai_service.dart';
import 'core/services/local_storage_service.dart';
import 'core/services/speech_service.dart';
import 'providers/notes_provider.dart';
import 'providers/search_provider.dart';

// Put your fresh Groq API key here (starts with gsk_)
const _groqApiKey = '';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<LocalStorageService>(create: (_) => InMemoryStorageService()),
        ChangeNotifierProvider<NotesProvider>(
          create: (context) =>
              NotesProvider(context.read<LocalStorageService>())..loadNotes(),
        ),
        ChangeNotifierProvider<SearchProvider>(create: (_) => SearchProvider()),

        // ── Switched to Free Groq API Service ──
        Provider<AiService>(create: (_) => GroqAiService(apiKey: _groqApiKey)),

        Provider<SpeechService>(
          create: (_) => RealSpeechService(),
          dispose: (_, service) => service.dispose(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: AppRoutes.todoHomeScreen,
        routes: {
          AppRoutes.todoHomeScreen: (context) => const TodoHomeScreen(),
          AppRoutes.createTaskScreen: (context) => const CreateTaskScreen(),
        },
      ),
    );
  }
}
