import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'services/sound_service.dart';
import 'services/storage.dart';
import 'theme/palettes.dart';
import 'ui/screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Storage.init();
  await soundService.init();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const ArrowPuzzleApp());
}

class ArrowPuzzleApp extends StatelessWidget {
  const ArrowPuzzleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeController,
      builder: (context, _) {
        final p = themeController.palette;
        final brightness = p.background.computeLuminance() < 0.2
            ? Brightness.dark
            : Brightness.light;
        return MaterialApp(
          title: 'Arrow Puzzle',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            scaffoldBackgroundColor: p.background,
            colorScheme: ColorScheme.fromSeed(
              seedColor: p.accent,
              brightness: brightness,
            ),
          ),
          home: const HomeScreen(),
        );
      },
    );
  }
}
