import 'dart:async';
import 'package:circle_rush/constants.dart';
import 'package:circle_rush/game_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameScreen extends StatefulWidget {
  final GameLevel level;
  final VoidCallback onHighScoreUpdate; // Add callback for high score updates

  const GameScreen({
    super.key,
    required this.level,
    required this.onHighScoreUpdate,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late EscapeGame game;
  late Timer gameTimer;
  late Timer spawnTimer;
  int highScore = 0;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    game = EscapeGame(widget.level);
    _loadHighScore();
    _setupPulseAnimation();
    startGame();
  }

  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      highScore = prefs.getInt('highScore_${widget.level.name}') ?? 0;
    });
  }

  Future<void> _updateHighScore(int newScore) async {
    final prefs = await SharedPreferences.getInstance();
    if (newScore > highScore) {
      await prefs.setInt('highScore_${widget.level.name}', newScore);
      setState(() {
        highScore = newScore;
      });
      widget.onHighScoreUpdate(); // Notify parent of high score update
    }
  }

  void updateGame() {
    if (!mounted || game.isGameOver) return;

    setState(() {
      game.update();
      if (game.score > highScore) {
        _updateHighScore(game.score);
      }
      if (game.isGameOver) {
        gameOver();
      }
    });
  }

  void _setupPulseAnimation() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }


  void startGame() {
    game.reset();

    const fps = 60;
    gameTimer = Timer.periodic(
      const Duration(milliseconds: 1000 ~/ fps),
          (timer) => updateGame(),
    );

    spawnTimer = Timer.periodic(
      game.config.spawnInterval,
          (timer) {
        if (!game.isGameOver && mounted) {
          game.spawnObject();
          setState(() {});
        } else {
          timer.cancel();
        }
      },
    );
  }


  void gameOver() {
    gameTimer.cancel();
    spawnTimer.cancel();

    if (game.score > highScore) {
      setState(() {
        highScore = game.score;
      });
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildGameOverDialog(),
    );
  }

  Widget _buildGameOverDialog() {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2C3F),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'GAME OVER',
              style: GoogleFonts.orbitron(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'SCORE',
              style: GoogleFonts.spaceMono(
                color: Colors.white70,
                fontSize: 14,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${game.score}',
              style: GoogleFonts.orbitron(
                color: const Color(0xFF00FF90),
                fontSize: 40,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: const Color(0xFF00FF90).withOpacity(0.5),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (game.score >= highScore) ...[
              Text(
                'NEW HIGH SCORE!',
                style: GoogleFonts.spaceMono(
                  color: const Color(0xFF00FF90),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ] else ...[
              Text(
                'HIGH SCORE: $highScore',
                style: GoogleFonts.spaceMono(
                  color: Colors.white60,
                  fontSize: 14,
                ),
              ),
            ],
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDialogButton(
                  label: 'MENU',
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  isPrimary: false,
                ),
                _buildDialogButton(
                  label: 'PLAY AGAIN',
                  onPressed: () {
                    Navigator.of(context).pop();
                    startGame();
                  },
                  isPrimary: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogButton({
    required String label,
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary
            ? const Color(0xFF00FF90)
            : Colors.white.withOpacity(0.1),
        foregroundColor: isPrimary ? Colors.black : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: isPrimary ? 4 : 0,
      ),
      child: Text(
        label,
        style: GoogleFonts.rubik(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }

  void onHorizontalDragUpdate(DragUpdateDetails details) {
    if (game.isGameOver) return;

    setState(() {
      final double deltaX = details.delta.dx / MediaQuery.of(context).size.width;
      game.updatePlayerPosition(deltaX);
    });
  }

  @override
  void dispose() {
    gameTimer.cancel();
    spawnTimer.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1929),
      body: GestureDetector(
        onHorizontalDragUpdate: onHorizontalDragUpdate,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Animated background gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF0A1929),
                    const Color(0xFF1A2C3F),
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
            ),

            // Grid overlay
            CustomPaint(
              painter: GridPainter(opacity: 0.05),
              size: Size.infinite,
            ),

            // Player
            Positioned(
              left: MediaQuery.of(context).size.width * game.playerX -
                  GameConstants.ballSize / 2,
              bottom: MediaQuery.of(context).size.height * 0.2,
              child: ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  width: GameConstants.ballSize,
                  height: GameConstants.ballSize,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00FF90),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00FF90).withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Track with gradient
            Positioned(
              left: 0,
              right: 0,
              bottom: MediaQuery.of(context).size.height * 0.2 +
                  GameConstants.ballSize / 2,
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      const Color(0xFF00FF90).withOpacity(0.5),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Falling Objects
            ...game.fallingObjects.map((object) => Positioned(
              left: MediaQuery.of(context).size.width * object.x -
                  GameConstants.obstacleSize / 2,
              top: MediaQuery.of(context).size.height * object.y,
              child: Transform.rotate(
                angle: object.rotation,
                child: Container(
                  width: GameConstants.obstacleSize,
                  height: GameConstants.obstacleSize,
                  decoration: BoxDecoration(
                    color: object.isGreen
                        ? const Color(0xFF00FF90)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: (object.isGreen
                            ? const Color(0xFF00FF90)
                            : Colors.white)
                            .withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            )),

            // Score Display
            Positioned(
              top: 50,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Text(
                    widget.level.name.toUpperCase(),
                    style: GoogleFonts.spaceMono(
                      color: GameColors.levelColors[widget.level],
                      fontSize: 18,
                      letterSpacing: 4,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: GameColors.levelColors[widget.level]!
                              .withOpacity(0.5),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.symmetric(horizontal: 32),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildScoreColumn('HIGH SCORE', highScore),
                        Container(
                          height: 40,
                          width: 1,
                          color: Colors.white.withOpacity(0.2),
                        ),
                        _buildScoreColumn('SCORE', game.score),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Instructions
            if (!game.isGameOver) ...[
              Positioned(
                bottom: MediaQuery.of(context).size.height * 0.1,
                left: 0,
                right: 0,
                child: Text(
                  'Collect green squares • Avoid white squares',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.rubik(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 14,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildScoreColumn(String label, int value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: GoogleFonts.spaceMono(
            color: Colors.white.withOpacity(0.6),
            fontSize: 12,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.toString(),
          style: GoogleFonts.orbitron(
            color: Colors.white,
            fontSize: label == 'SCORE' ? 32 : 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class GridPainter extends CustomPainter {
  final double opacity;

  GridPainter({this.opacity = 0.1});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(opacity)
      ..strokeWidth = 0.5;

    const spacing = 30.0;

    for (var i = 0.0; i < size.width; i += spacing) {
      canvas.drawLine(
          Offset(i.toDouble(), 0), Offset(i.toDouble(), size.height), paint);
    }

    for (var i = 0.0; i < size.height; i += spacing) {
      canvas.drawLine(
          Offset(0, i.toDouble()), Offset(size.width, i.toDouble()), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}