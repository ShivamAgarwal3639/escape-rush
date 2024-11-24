import 'package:circle_rush/constants.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'game_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {


  Map<GameLevel, int> highScores = {};

  @override
  void initState() {
    super.initState();
    _loadHighScores();
  }

  Future<void> _loadHighScores() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      highScores = {
        for (var level in GameLevel.values)
          level: prefs.getInt('highScore_${level.name}') ?? 0
      };
    });
  }

  void _startGame(BuildContext context, GameLevel level) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GameScreen(
          level: level,
          onHighScoreUpdate: () {
            _loadHighScores(); // Reload high scores when updated
          },
        ),
      ),
    );
  }

  Widget _buildHighScores() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2C3F),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'HIGH SCORES',
            style: GoogleFonts.spaceMono(
              color: Colors.white,
              fontSize: 18,
              letterSpacing: 3,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          ...GameLevel.values.map((level) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    level.name.toUpperCase(),
                    style: GoogleFonts.rubik(
                      color: GameColors.levelColors[level]!.withOpacity(0.9),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Text(
                    '${highScores[level] ?? 0}',
                    style: GoogleFonts.spaceMono(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1929), // Darker, richer background
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Animated background gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF0A1929),
                    const Color(0xFF1A2C3F),
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
            ),

            // Grid overlay with reduced opacity
            CustomPaint(
              painter: GridPainter(opacity: 0.05),
              size: Size.infinite,
            ),

            // Main content
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    const _AnimatedTitle(),
                    const SizedBox(height: 24),
                    Text(
                      'SELECT LEVEL',
                      style: GoogleFonts.spaceMono(
                        fontSize: 18,
                        color: Colors.white70,
                        letterSpacing: 4,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildLevelButtons(context),
                    const SizedBox(height: 24),
                    _buildHighScores(),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelButtons(BuildContext context) {
    return Column(
      children: GameLevel.values.map((level) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: LevelButton(
            level: level,
            onPressed: () => _startGame(context, level),
          ),
        );
      }).toList(),
    );
  }

}

class _AnimatedTitle extends StatefulWidget {
  const _AnimatedTitle();

  @override
  State<_AnimatedTitle> createState() => _AnimatedTitleState();
}

class _AnimatedTitleState extends State<_AnimatedTitle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.1, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ScaleTransition(
          scale: _scaleAnimation,
          child: Text(
            'ESCAP\nE',
            style: GoogleFonts.orbitron(
              fontSize: 64,
              color: const Color(0xFF00FF90),
              fontWeight: FontWeight.bold,
              height: 1,
              shadows: [
                Shadow(
                  color: const Color(0xFF00FF90).withOpacity(0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
                Shadow(
                  color: const Color(0xFF00FF90).withOpacity(0.3),
                  blurRadius: 40,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'RUSH',
          style: GoogleFonts.orbitron(
            fontSize: 32,
            color: Colors.white70,
            fontWeight: FontWeight.w500,
            letterSpacing: 12,
          ),
        ),
      ],
    );
  }
}

class LevelButton extends StatelessWidget {
  final GameLevel level;
  final VoidCallback onPressed;

  const LevelButton({
    super.key,
    required this.level,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 65,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: GameColors.levelColors[level]!.withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: GameColors.levelColors[level]!.withOpacity(0.9),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          elevation: 0,
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              level.name.toUpperCase(),
              style: GoogleFonts.rubik(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            Icon(
              Icons.arrow_forward_rounded,
              color: Colors.white.withOpacity(0.9),
              size: 24,
            ),
          ],
        ),
      ),
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