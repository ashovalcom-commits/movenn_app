import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'dart:async';
import 'game_config.dart'; // ייבוא קובץ הפרמטרים החדש שיצרנו

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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
        fontFamily: 'Assistant',
      ),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  List<dynamic> levels = [];
  List<dynamic> gameQuestions = []; // 10 random questions for this game
  int currentLevelIndex = 0;
  bool isLoaded = false;
  
  List<String> allMoviesPool = [];
  List<String> currentOptions = [];
  
  int totalScore = 0;
  Map<String, bool> circleResults = {};
  String currentTarget = 'A'; 
  final List<String> allCircles = ['A', 'B', 'C'];
  
  Timer? _rotationTimer;
  Timer? _levelTimer;
  DateTime? levelStartTime;

  @override
  void initState() {
    super.initState();
    loadGameData();
  }

  @override
  void dispose() {
    _rotationTimer?.cancel();
    _levelTimer?.cancel();
    super.dispose();
  }

  Future<void> loadGameData() async {
    final String response = await rootBundle.loadString('assets/venn_questions_edit3_5.json');
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
    _rotationTimer = Timer.periodic(Duration(seconds: GameConfig.rotationInterval), (timer) {
      setState(() {
        moveToNextUnanswered();
      });
    });

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

  void moveToNextUnanswered() {
    List<String> remaining = allCircles.where((c) => !circleResults.containsKey(c)).toList();
    if (remaining.isEmpty) return;
    
    int currentIndex = remaining.indexOf(currentTarget);
    int nextIndex = (currentIndex + 1) % remaining.length;
    
    currentTarget = remaining[nextIndex];
    generateOptions();
  }

  void generateOptions() {
    if (gameQuestions.isEmpty) return;
    
    String correctAnswer = gameQuestions[currentLevelIndex]['movies'][currentTarget];
    List<String> distractors = allMoviesPool.where((m) => m != correctAnswer).toList();
    
    distractors.shuffle();
    currentOptions = [correctAnswer, distractors[0], distractors[1], distractors[2]];
    currentOptions.shuffle();
  }

  void checkAnswer(String selectedMovie) {
    String correctAnswer = gameQuestions[currentLevelIndex]['movies'][currentTarget];
    bool isCorrect = (selectedMovie == correctAnswer);
    
    circleResults[currentTarget] = isCorrect;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isCorrect ? 'תשובה נכונה!' : 'טעות...'), 
        duration: const Duration(milliseconds: 800),
        backgroundColor: isCorrect ? Colors.green : Colors.red,
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
    int timeTakenInSeconds = DateTime.now().difference(levelStartTime!).inSeconds;
    
    int pointsEarned = 0;
    
    // שימוש בפרמטרי הניקוד המיובאים
    if (correctCount == 1) {
      pointsEarned = GameConfig.pointsForOne;
    } else if (correctCount == 2) {
      pointsEarned = GameConfig.pointsForTwo;
    } else if (correctCount == 3) {
      if (timeTakenInSeconds < GameConfig.bonusTimeLimit) {
        pointsEarned = GameConfig.pointsForThreeWithBonus;
      } else {
        pointsEarned = GameConfig.pointsForThree;
      }
    }
    
    setState(() {
      totalScore += pointsEarned;
    });

    if (currentLevelIndex < gameQuestions.length - 1) {
      setState(() {
        currentLevelIndex++;
        startLevel();
      });
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('סיום משחק!', textAlign: TextAlign.center),
          content: Text(
            'הניקוד הסופי שלך: $totalScore',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    setState(() {
                      startNewGame();
                    });
                  },
                  child: const Text('משחק חדש'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    // Exit - close the app or go back to initial state
                    SystemNavigator.pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                  ),
                  child: const Text('יציאה'),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }

  Color getTargetColor() {
    switch (currentTarget) {
      case 'A': return Colors.red.shade50;
      case 'B': return Colors.green.shade50;
      case 'C': return Colors.blue.shade50;
      default: return Colors.grey.shade50;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final String imageName = gameQuestions[currentLevelIndex]['image_file'];
    final imagePath = 'assets/images/$imageName';
    int remainingCircles = 3 - circleResults.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('שאלה ${currentLevelIndex + 1} מתוך ${gameQuestions.length}'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
              ),
            ),
          ),
          
          const Divider(thickness: 2),

          Expanded(
            flex: 4,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width: double.infinity,
              color: getTargetColor(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'איזה סרט מסתתר מאחורי עיגול $currentTarget?',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'נותרו $remainingCircles תשובות לשלב זה',
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 15),
                  
                  ...currentOptions.map((movie) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () => checkAnswer(movie),
                        style: ElevatedButton.styleFrom(
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                        child: Text(movie),
                      ),
                    ),
                  )).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}