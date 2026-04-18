import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/game_state.dart';
import '../services/ad_service.dart';
import 'game_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
              ),
            ),
          ),

          // Music Toggle at Top Right
          Positioned(
            top: 60,
            right: 25,
            child: Consumer<GameState>(
              builder: (context, state, child) {
                return GestureDetector(
                  onTap: () => state.toggleMusic(),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    color: Colors.transparent, // Ensures the entire padded area is tappable
                    child: Icon(
                      state.isMusicEnabled ? Icons.music_note_rounded : Icons.music_off_rounded,
                      color: state.isMusicEnabled ? Colors.yellowAccent : Colors.white24,
                      size: 36,
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Total Coins Display at Top Left
          Positioned(
            top: 60,
            left: 25,
            child: Consumer<GameState>(
              builder: (context, state, child) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.yellowAccent.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset('assets/images/coin.png', width: 24, height: 24),
                      const SizedBox(width: 8),
                      Text(
                        '${state.totalCoins}',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Main Menu Content
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 80),
                  // Title above the image
                  Text(
                    'NEON CAR RUNNER',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      color: Colors.cyanAccent,
                      fontSize: 56,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                      shadows: [
                        const Shadow(color: Colors.cyan, blurRadius: 20),
                        const Shadow(color: Colors.cyan, blurRadius: 40),
                      ],
                    ),
                  ),

                  // Highest Score Display
                  Consumer<GameState>(
                    builder: (context, state, child) {
                      return Text(
                        'HIGHEST: ${state.highScore}',
                        style: GoogleFonts.outfit(
                          color: Colors.white70,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 20),

                  // Transport Image in the middle
                  Opacity(
                    opacity: 0.3,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.height * 0.35,
                      child: Image.asset(
                        'assets/images/transport.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Watch Ad Button (Earn Coins)
                  Consumer<GameState>(
                    builder: (context, state, child) {
                      final remaining = state.adCooldownRemaining;
                      final bool isCooldown = remaining != null;
                      
                      String formatDuration(Duration d) {
                        String twoDigits(int n) => n.toString().padLeft(2, "0");
                        String mm = twoDigits(d.inMinutes.remainder(60));
                        String ss = twoDigits(d.inSeconds.remainder(60));
                        return "$mm:$ss";
                      }

                      return Opacity(
                        opacity: isCooldown ? 0.6 : 1.0,
                        child: OutlinedButton(
                          onPressed: isCooldown ? null : () {
                            AdService.showRewardedAd(onRewardComplete: () {
                              state.addBonusCoins(10);
                              state.recordAdWatch();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('earned 10 coins reward')),
                              );
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: isCooldown ? Colors.grey : Colors.pinkAccent, width: 2),
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset('assets/images/money-bag.png', width: 32, height: 32),
                              const SizedBox(width: 15),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'WATCH AD TO EARN 10 COINS',
                                    style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Text(
                                      isCooldown ? 'Available in ${formatDuration(remaining)}' : 'Available',
                                      style: GoogleFonts.outfit(
                                        color: isCooldown ? Colors.white70 : Colors.greenAccent,
                                        fontSize: 12,
                                        fontWeight: isCooldown ? FontWeight.normal : FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 25),

                  // Start Button - Now below
                  ElevatedButton(
                    onPressed: () {
                      context.read<GameState>().setGameOver(false);
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          transitionDuration: const Duration(milliseconds: 50),
                          pageBuilder: (context, animation, secondaryAnimation) => const GameScreen(),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            return FadeTransition(
                              opacity: CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeIn,
                              ),
                              child: child,
                            );
                          },
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyanAccent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 10,
                    ),
                    child: Text(
                      'START GAME',
                      style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
