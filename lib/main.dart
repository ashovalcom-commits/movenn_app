import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

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
  int currentLevelIndex = 0;
  bool isLoaded = false;

  @override
  void initState() {
    super.initState();
    loadGameData();
  }

  Future<void> loadGameData() async {
    // טעינת קובץ ה-JSON מתיקיית הנכסים
    // שים לב ששם הקובץ תואם בדיוק למה שהגדרת
    final String response = await rootBundle.loadString('assets/venn_levels_edit3_4.json');
    final data = await json.decode(response);
    
    setState(() {
      levels = data;
      isLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    // מסך טעינה בזמן שה-JSON נטען
    if (!isLoaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // הגדרת נתיב התמונה בהתאם לשלב (מניח שהתמונות נקראות level_1.png וכו')
    final imagePath = 'assets/images/level_${currentLevelIndex + 1}.png';

    return Scaffold(
      appBar: AppBar(
        title: Text('Movenn - שלב ${currentLevelIndex + 1}'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // החלק העליון - דיאגרמת הון
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
          
          // קו הפרדה
          const Divider(thickness: 2),

          // החלק התחתון - אזור התשובות (כרגע רק שלד כדי לוודא מעבר שלבים)
          Expanded(
            flex: 4,
            child: Container(
              width: double.infinity,
              color: Colors.grey[100],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'תשובות יופיעו כאן',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (currentLevelIndex < levels.length - 1) {
                        setState(() {
                          currentLevelIndex++;
                        });
                      }
                    },
                    child: const Text('לשלב הבא'),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}