import 'package:shared_preferences/shared_preferences.dart';

class StatsService {
  static const _keyHighScore = 'high_score';
  static const _keyGamesCompleted = 'games_completed';
  static const _keyTotalScore = 'total_score';
  static const _keyTotalCorrect = 'total_correct';
  static const _keyTotalQuestions = 'total_questions';
  static const _keyLastScores = 'last_scores';
  static const int _maxLastScores = 10;

  static final StatsService _instance = StatsService._();
  factory StatsService() => _instance;
  StatsService._();

  SharedPreferencesAsync? _prefs;

  Future<SharedPreferencesAsync> get _sp async {
    _prefs ??= SharedPreferencesAsync();
    return _prefs!;
  }

  /// Records the result of one completed game.
  Future<void> recordGame({
    required int score,
    required int correctAnswers,
    required int totalQuestions,
  }) async {
    final sp = await _sp;

    // High score
    final prev = await sp.getInt(_keyHighScore) ?? 0;
    if (score > prev) {
      await sp.setInt(_keyHighScore, score);
    }

    // Games completed
    final games = (await sp.getInt(_keyGamesCompleted) ?? 0) + 1;
    await sp.setInt(_keyGamesCompleted, games);

    // Cumulative score (for average calculation)
    final cumScore = (await sp.getInt(_keyTotalScore) ?? 0) + score;
    await sp.setInt(_keyTotalScore, cumScore);

    // Correct answers
    final cumCorrect =
        (await sp.getInt(_keyTotalCorrect) ?? 0) + correctAnswers;
    await sp.setInt(_keyTotalCorrect, cumCorrect);

    // Total questions answered
    final cumQuestions =
        (await sp.getInt(_keyTotalQuestions) ?? 0) + totalQuestions;
    await sp.setInt(_keyTotalQuestions, cumQuestions);

    // Last N scores history
    final raw = await sp.getStringList(_keyLastScores) ?? [];
    raw.insert(0, score.toString());
    if (raw.length > _maxLastScores) {
      raw.removeRange(_maxLastScores, raw.length);
    }
    await sp.setStringList(_keyLastScores, raw);
  }

  Future<GameStats> getStats() async {
    final sp = await _sp;
    final highScore = await sp.getInt(_keyHighScore) ?? 0;
    final gamesCompleted = await sp.getInt(_keyGamesCompleted) ?? 0;
    final totalScore = await sp.getInt(_keyTotalScore) ?? 0;
    final totalCorrect = await sp.getInt(_keyTotalCorrect) ?? 0;
    final totalQuestions = await sp.getInt(_keyTotalQuestions) ?? 0;
    final lastScoresRaw = await sp.getStringList(_keyLastScores) ?? [];
    final lastScores =
        lastScoresRaw.map((s) => int.tryParse(s) ?? 0).toList();

    return GameStats(
      highScore: highScore,
      gamesCompleted: gamesCompleted,
      totalScore: totalScore,
      totalCorrect: totalCorrect,
      totalQuestions: totalQuestions,
      lastScores: lastScores,
    );
  }

  Future<void> resetStats() async {
    final sp = await _sp;
    await sp.remove(_keyHighScore);
    await sp.remove(_keyGamesCompleted);
    await sp.remove(_keyTotalScore);
    await sp.remove(_keyTotalCorrect);
    await sp.remove(_keyTotalQuestions);
    await sp.remove(_keyLastScores);
  }
}

class GameStats {
  final int highScore;
  final int gamesCompleted;
  final int totalScore;
  final int totalCorrect;
  final int totalQuestions;
  final List<int> lastScores;

  const GameStats({
    required this.highScore,
    required this.gamesCompleted,
    required this.totalScore,
    required this.totalCorrect,
    required this.totalQuestions,
    required this.lastScores,
  });

  double get averageScore =>
      gamesCompleted > 0 ? totalScore / gamesCompleted : 0;

  double get correctRate =>
      totalQuestions > 0 ? totalCorrect / totalQuestions * 100 : 0;
}
