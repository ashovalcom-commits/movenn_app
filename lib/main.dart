import 'package:flutter/material.dart';

import 'dart:convert';

import 'package:flutter/services.dart';

import 'dart:async';

import 'game_config.dart';
import 'sound_manager.dart';
import 'splash_screen.dart';
import 'app_theme.dart';
import 'responsive.dart';
import 'stats_service.dart';

void main() {
  runApp(const MovennApp());
}

class MovennApp extends StatelessWidget {
  const MovennApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Movenn',
      theme: AppTheme.theme,
      home: const SplashScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  List<dynamic> levels = [];
  List<dynamic> gameQuestions = []; // 10 random questions for this game
  int currentLevelIndex = 0;
  bool isLoaded = false;

  List<String> allMoviesPool = [];
  List<String> currentOptions = [];

  int totalScore = 0;
  int gameCorrectAnswers = 0;
  int gameTotalAnswers = 0;
  Map<String, bool> circleResults = {};
  String currentTarget = 'A';
  final List<String> allCircles = ['A', 'B', 'C'];

  Timer? _rotationTimer;
  Timer? _levelTimer;
  DateTime? levelStartTime;
  final SoundManager _soundManager = SoundManager();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.35, end: 0.75).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _soundManager.init();
    loadGameData();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationTimer?.cancel();
    _levelTimer?.cancel();
    _soundManager.dispose();
    super.dispose();
  }

  Future<void> loadGameData() async {
    final String response = await rootBundle.loadString(
      'assets/venn_questions_edit3_6.json',
    );
    final data = await json.decode(response);

    List<String> pool = [];
    for (var level in data) {
      pool.add(level['movies']['A']);
      pool.add(level['movies']['B']);
      pool.add(level['movies']['C']);
    }

    setState(() {
      levels = data;
      allMoviesPool = pool.toSet().toList();
      isLoaded = true;
      startNewGame();
    });
  }

  void startNewGame() {
    List<dynamic> shuffled = List.from(levels)..shuffle();
    gameQuestions = shuffled.take(10).toList();
    currentLevelIndex = 0;
    totalScore = 0;
    gameCorrectAnswers = 0;
    gameTotalAnswers = 0;
    startLevel();
  }

  void startLevel() {
    circleResults.clear();
    levelStartTime = DateTime.now();
    currentTarget = 'A';

    generateOptions();
    startTimers();
  }

  void startTimers() {
    _rotationTimer?.cancel();
    _levelTimer?.cancel();

    // שימוש בפרמטר מחזוריות ההחלפה
    _rotationTimer = Timer.periodic(
      Duration(seconds: GameConfig.rotationInterval),
      (timer) {
        setState(() {
          moveToNextUnanswered();
        });
      },
    );

    // שימוש בפרמטר הזמן המקסימלי לשלב
    _levelTimer = Timer(Duration(seconds: GameConfig.maxLevelTime), () {
      setState(() {
        for (var circle in allCircles) {
          if (!circleResults.containsKey(circle)) {
            circleResults[circle] = false;
          }
        }
        finishLevel();
      });
    });
  }

  void moveToNextUnanswered({bool playSound = true}) {
    List<String> remaining = allCircles
        .where((c) => !circleResults.containsKey(c))
        .toList();
    if (remaining.isEmpty) return;

    int currentIndex = remaining.indexOf(currentTarget);
    int nextIndex = (currentIndex + 1) % remaining.length;

    currentTarget = remaining[nextIndex];
    generateOptions();
    if (playSound) _soundManager.playSwitch();
  }

  void generateOptions() {
    if (gameQuestions.isEmpty) return;

    String correctAnswer =
        gameQuestions[currentLevelIndex]['movies'][currentTarget];
    List<String> distractors = allMoviesPool
        .where((m) => m != correctAnswer)
        .toList();

    distractors.shuffle();
    currentOptions = [
      correctAnswer,
      distractors[0],
      distractors[1],
      distractors[2],
    ];
    currentOptions.shuffle();
  }

  void checkAnswer(String selectedMovie) {
    String correctAnswer =
        gameQuestions[currentLevelIndex]['movies'][currentTarget];
    bool isCorrect = (selectedMovie == correctAnswer);

    circleResults[currentTarget] = isCorrect;

    if (isCorrect) {
      totalScore += GameConfig.pointsPerCorrectCircle;
      _soundManager.playCorrect();
    } else {
      _soundManager.playWrong();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(isCorrect ? 'תשובה נכונה!' : 'טעות...'),
          ],
        ),
        duration: const Duration(milliseconds: 800),
        backgroundColor: isCorrect ? AppColors.correct : AppColors.wrong,
      ),
    );

    if (circleResults.length == 3) {
      finishLevel();
    } else {
      setState(() {
        moveToNextUnanswered();
        startTimers();
      });
    }
  }

  void finishLevel() {
    _rotationTimer?.cancel();
    _levelTimer?.cancel();

    int correctCount = circleResults.values.where((v) => v).length;
    gameCorrectAnswers += correctCount;
    gameTotalAnswers += circleResults.length;
    int timeTakenInSeconds = DateTime.now()
        .difference(levelStartTime!)
        .inSeconds;

    if (correctCount == 3) {
      int bonus = 0;
      if (timeTakenInSeconds <= GameConfig.bonusTimeTier1) {
        bonus = GameConfig.speedBonusTier1;
      } else if (timeTakenInSeconds <= GameConfig.bonusTimeTier2) {
        bonus = GameConfig.speedBonusTier2;
      }
      if (bonus > 0) {
        setState(() {
          totalScore += bonus;
        });
      }
    }

    if (currentLevelIndex < gameQuestions.length - 1) {
      _soundManager.playSwitch();
      setState(() {
        currentLevelIndex++;
        startLevel();
      });
    } else {
      _saveAndShowEndDialog();
    }
  }

  Future<void> _saveAndShowEndDialog() async {
    final stats = StatsService();
    final prevStats = await stats.getStats();
    final isNewHighScore = totalScore > prevStats.highScore;

    await stats.recordGame(
      score: totalScore,
      correctAnswers: gameCorrectAnswers,
      totalQuestions: gameTotalAnswers,
    );

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Column(
          children: [
            Icon(
              isNewHighScore
                  ? Icons.star_rounded
                  : Icons.emoji_events_rounded,
              size: 48,
              color: AppColors.accent,
            ),
            const SizedBox(height: 8),
            Text(
              isNewHighScore ? '🎉 שיא חדש!' : 'סיום משחק!',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$totalScore',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            const Text('נקודות', textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text(
              '$gameCorrectAnswers/$gameTotalAnswers תשובות נכונות',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            if (!isNewHighScore) ...[
              const SizedBox(height: 4),
              Text(
                'שיא: ${prevStats.highScore}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            icon: const Icon(Icons.home_rounded),
            label: const Text('תפריט ראשי'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() {
                startNewGame();
              });
            },
            icon: const Icon(Icons.replay_rounded),
            label: const Text('משחק חדש'),
          ),
        ],
      ),
    );
  }

  Color getTargetColor() {
    switch (currentTarget) {
      case 'A':
        return AppColors.circleABg;
      case 'B':
        return AppColors.circleBBg;
      case 'C':
        return AppColors.circleCBg;
      default:
        return AppColors.surfaceVariant;
    }
  }

  Color getTargetAccent() {
    switch (currentTarget) {
      case 'A':
        return AppColors.circleA;
      case 'B':
        return AppColors.circleB;
      case 'C':
        return AppColors.circleC;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final r = Responsive(context);
    final String imageName = gameQuestions[currentLevelIndex]['image_file'];
    final imagePath = 'assets/images/$imageName';
    int remainingCircles = 3 - circleResults.length;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'שאלה ${currentLevelIndex + 1} מתוך ${gameQuestions.length}',
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$totalScore',
                  style: TextStyle(
                    fontSize: r.sp(18),
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: r.maxContentWidth),
          child: Column(
            children: [
              Flexible(
                flex: r.imageFlex,
                child: Padding(
                  padding: EdgeInsets.all(r.sp(12)),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset(imagePath, fit: BoxFit.contain),
                          AnimatedBuilder(
                            animation: _pulseAnimation,
                            builder: (context, child) {
                              return CustomPaint(
                                size: Size(
                                  constraints.maxWidth,
                                  constraints.maxHeight,
                                ),
                                painter: _SpotlightPainter(
                                  target: currentTarget,
                                  opacity: _pulseAnimation.value,
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),

              const Divider(thickness: 2),

              Expanded(
                flex: r.answerFlex,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: getTargetColor(),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: r.sp(20),
                    vertical: r.sp(10),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: r.sp(28),
                                    height: r.sp(28),
                                    decoration: BoxDecoration(
                                      color: getTargetAccent(),
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      currentTarget,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: r.sp(14),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      'איזה סרט מסתתר מאחורי עיגול \u2068$currentTarget\u2069\u200F?',
                                      style: TextStyle(
                                        fontSize: r.sp(18),
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                      textDirection: TextDirection.rtl,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: r.sp(2)),
                              Text(
                                'נותרו $remainingCircles תשובות לשלב זה',
                                style: TextStyle(
                                  fontSize: r.sp(12),
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              SizedBox(height: r.sp(8)),

                              ...currentOptions.map(
                                (movie) => Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: r.sp(4),
                                  ),
                                  child: SizedBox(
                                    width: double.infinity,
                                    height: r.optionButtonHeight,
                                    child: ElevatedButton(
                                      onPressed: () => checkAnswer(movie),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.surface,
                                        foregroundColor: AppColors.textPrimary,
                                        elevation: 1,
                                        shadowColor: getTargetAccent()
                                            .withAlpha(40),
                                        side: BorderSide(
                                          color: getTargetAccent().withAlpha(60),
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        textStyle: TextStyle(
                                          fontSize: r.sp(15),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(movie),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  final String target;
  final double opacity;

  _SpotlightPainter({required this.target, required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final double imgSide = size.width < size.height ? size.width : size.height;
    final double offsetX = (size.width - imgSide) / 2;
    final double offsetY = (size.height - imgSide) / 2;

    late double cx, cy;
    late Color color;
    const double r = 0.30;

    switch (target) {
      case 'A':
        cx = 0.38;
        cy = 0.39;
        color = AppColors.circleA;
        break;
      case 'B':
        cx = 0.62;
        cy = 0.39;
        color = AppColors.circleB;
        break;
      case 'C':
        cx = 0.50;
        cy = 0.6;
        color = AppColors.circleC;
        break;
      default:
        return;
    }

    final center = Offset(offsetX + cx * imgSide, offsetY + cy * imgSide);
    final radius = r * imgSide;

    // Dim everything outside the target circle
    final dimPaint = Paint()..color = Colors.black.withValues(alpha: 0.35);
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addOval(Rect.fromCircle(center: center, radius: radius))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, dimPaint);

    // Pulsing glow ring
    final glowPaint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;
    canvas.drawCircle(center, radius, glowPaint);
  }

  @override
  bool shouldRepaint(covariant _SpotlightPainter oldDelegate) =>
      oldDelegate.target != target || oldDelegate.opacity != opacity;
}
