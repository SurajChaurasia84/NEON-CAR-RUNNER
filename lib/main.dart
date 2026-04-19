import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/game_state.dart';
import 'screens/home_screen.dart';
import 'services/ad_service.dart';
import 'services/audio_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Audio
  AudioService().init();

  // Set Orientation to Portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Set Fullscreen
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  // Initialize Ads
  await AdService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameState()),
      ],
      child: const EndlessRunnerApp(),
    ),
  );
}

class EndlessRunnerApp extends StatelessWidget {
  const EndlessRunnerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Neon Car Runner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.cyan,
      ),
      builder: (context, child) {
        final data = MediaQuery.of(context);
        // Clamp text scaling between 1.0 and 1.15 for UI stability
        return MediaQuery(
          data: data.copyWith(
            textScaler: data.textScaler.clamp(minScaleFactor: 1.0, maxScaleFactor: 1.15),
          ),
          child: child!,
        );
      },
      home: const HomeScreen(),
    );
  }
}
