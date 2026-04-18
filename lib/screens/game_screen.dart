import 'dart:async';
import 'dart:math';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';
import '../game/runner_game.dart';
import '../providers/game_state.dart';
import '../services/ad_service.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late RunnerGame game;
  UniqueKey _bannerKey = UniqueKey();
  Timer? _bannerTimer;

  @override
  void initState() {
    super.initState();
    game = RunnerGame(gameState: context.read<GameState>());
    _startBannerRefreshTimer();
    // Sync audio state when entering the game
    context.read<GameState>().updateAudio();
  }

  void _startBannerRefreshTimer() {
    _bannerTimer?.cancel();
    // Random interval between 60 and 90 seconds
    final int nextRefresh = 60 + Random().nextInt(31);
    
    _bannerTimer = Timer(Duration(seconds: nextRefresh), () {
      if (mounted) {
        setState(() {
          _bannerKey = UniqueKey();
        });
        _startBannerRefreshTimer();
      }
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, dynamic result) async {
          if (didPop) return;

          // Pause game engine
          game.pauseEngine();
          context.read<GameState>().setPaused(true);

          // Show confirmation dialog
          final bool? shouldExit = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: const Color(0xFF1B1B2F),
              title: Text(
                'EXIT GAME?',
                style: GoogleFonts.outfit(color: Colors.cyanAccent, fontWeight: FontWeight.bold),
              ),
              content: Text(
                'Are you sure you want to quit this run?',
                style: GoogleFonts.outfit(color: Colors.white70),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('NO', style: GoogleFonts.outfit(color: Colors.grey)),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text('YES', style: GoogleFonts.outfit(color: Colors.redAccent)),
                ),
              ],
            ),
          );

          if (shouldExit == true) {
            if (context.mounted) {
              AdService.showInterstitialAd();
              Navigator.of(context).pop(); // Perform the actual pop to home
            }
          } else {
            // Resume if user decides to stay
            game.resumeEngine();
            context.read<GameState>().setPaused(false);
          }
        },
        child: Stack(
          children: [
            GameWidget(
              game: game,
              overlayBuilderMap: {
                'GameOver': (context, RunnerGame game) => GameOverOverlay(game: game),
                'HUD': (context, RunnerGame game) => HUDOverlay(game: game),
              },
              initialActiveOverlays: const ['HUD'],
            ),
            // Game Over Overlay is triggered by GameState
            Consumer<GameState>(
              builder: (context, state, child) {
                if (state.isGameOver) {
                  return GameOverOverlay(game: game);
                }
                return const SizedBox.shrink();
              },
            ),
            
            // Bottom Banner Ad
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: UnityBannerAd(
                  key: _bannerKey,
                  placementId: AdService.bannerPlacement,
                  onLoad: (placementId) => print('Banner Loaded: $placementId'),
                  onClick: (placementId) => print('Banner Clicked: $placementId'),
                  onFailed: (placementId, error, message) => print('Banner Ad Failed: $placementId $error $message'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HUDOverlay extends StatelessWidget {
  final RunnerGame game;
  const HUDOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 50,
      left: 20,
      right: 20,
      child: Consumer<GameState>(
        builder: (context, state, child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SCORE: ${state.currentRunScore}',
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'COINS: ${state.currentRunCoins}',
                    style: GoogleFonts.outfit(color: Colors.yellowAccent, fontSize: 16),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(10)),
                    child: Text(
                      'SPEED: ${(game.gameSpeed / 10).floor()}',
                      style: GoogleFonts.outfit(color: Colors.cyanAccent, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Music Toggle
                  GestureDetector(
                    onTap: () => state.toggleMusic(),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: state.isMusicEnabled ? Colors.yellowAccent : Colors.white24,
                        shape: BoxShape.circle,
                        boxShadow: state.isMusicEnabled ? [
                          BoxShadow(
                            color: Colors.yellowAccent.withOpacity(0.4),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ] : [],
                      ),
                      child: Icon(
                        state.isMusicEnabled ? Icons.music_note_rounded : Icons.music_off_rounded,
                        color: state.isMusicEnabled ? Colors.black : Colors.white54,
                        size: 36,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Play/Pause Toggle
                  GestureDetector(
                    onTap: () {
                      if (game.paused) {
                        game.resumeEngine();
                        state.setPaused(false);
                      } else {
                        game.pauseEngine();
                        state.setPaused(true);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.yellowAccent,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.yellowAccent.withOpacity(0.4),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        state.isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                        color: Colors.black,
                        size: 36,
                      ),
                    ),
                  ),
                ],
              )
            ],
          );
        },
      ),
    );
  }
}

class GameOverOverlay extends StatelessWidget {
  final RunnerGame game;
  const GameOverOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameState>(); // Use watch for reactive UI

    return Container(
      color: Colors.black.withOpacity(0.85),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'GAME OVER',
              style: GoogleFonts.outfit(
                color: Colors.redAccent,
                fontSize: 48,
                fontWeight: FontWeight.bold,
                shadows: [const Shadow(color: Colors.red, blurRadius: 20)],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'CURRENT SCORE: ${state.currentRunScore}',
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 24),
            ),
            const SizedBox(height: 20),
            
            // Continue Options (Only one use per run)
            if (!state.hasContinuedInRun) ...[
              Opacity(
                opacity: state.totalCoins >= 20 ? 1.0 : 0.5,
                child: OutlinedButton(
                  onPressed: state.totalCoins >= 20 
                    ? () {
                        if (state.spendCoins(20)) {
                          game.resume();
                          game.gameSpeed *= 0.8;
                        }
                      }
                    : null,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: state.totalCoins >= 20 ? Colors.yellowAccent : Colors.grey, 
                      width: 2
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        state.totalCoins >= 20 ? 'USE 20 ' : 'NEED 20 ',
                        style: GoogleFonts.outfit(
                          color: state.totalCoins >= 20 ? Colors.yellowAccent : Colors.grey, 
                          fontSize: 18, 
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      Opacity(
                        opacity: state.totalCoins >= 20 ? 1.0 : 0.5,
                        child: Image.asset('assets/images/coin.png', width: 24, height: 24),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Text(
                '— OR —',
                style: GoogleFonts.outfit(color: Colors.white54, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              ElevatedButton.icon(
                onPressed: () {
                  AdService.showRewardedAd(onRewardComplete: () {
                    game.resume();
                    game.gameSpeed *= 0.8;
                  });
                },
                icon: const Icon(Icons.video_library_rounded),
                label: Text(
                  'Watch Ad',
                  style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Navigation Buttons in a Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Restart Button
                ElevatedButton.icon(
                  onPressed: () => game.restart(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('RESTART'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
                const SizedBox(width: 20),
                // Home Button
                ElevatedButton.icon(
                  onPressed: () {
                    AdService.showInterstitialAd();
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.home),
                  label: const Text('HOME'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white24,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
