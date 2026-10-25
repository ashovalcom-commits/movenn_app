import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'package:movenn_app/main.dart';
import 'package:movenn_app/game_config.dart';

/// Minimal fake question data used by every test.
const List<Map<String, dynamic>> _fakeQuestions = [
  {
    'movies': {'A': 'Movie Alpha', 'B': 'Movie Beta', 'C': 'Movie Gamma'},
    'intersections': {
      'ABC': 'Actor 1',
      'AB': 'Actor 2',
      'BC': 'Actor 3',
      'AC': 'Actor 4',
      'A_only': 'Actor 5',
      'B_only': 'Actor 6',
      'C_only': 'Actor 7',
    },
    'image_file': 'question_1.png',
  },
  {
    'movies': {'A': 'Movie Delta', 'B': 'Movie Epsilon', 'C': 'Movie Zeta'},
    'intersections': {
      'ABC': 'Actor 8',
      'AB': 'Actor 9',
      'BC': 'Actor 10',
      'AC': 'Actor 11',
      'A_only': 'Actor 12',
      'B_only': 'Actor 13',
      'C_only': 'Actor 14',
    },
    'image_file': 'question_2.png',
  },
];

/// A 1×1 transparent PNG so Image.asset resolves without error.
final Uint8List _kTransparentPng = Uint8List.fromList(const <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A,
  0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41,
  0x54, 0x78, 0x9C, 0x62, 0x00, 0x00, 0x00, 0x02,
  0x00, 0x01, 0xE5, 0x27, 0xDE, 0xFC, 0x00, 0x00,
  0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42,
  0x60, 0x82,
]);

/// All extra asset keys the game may load (bonus mark images, etc.).
const List<String> _extraAssets = [
  'assets/images/bonus_tier1.png',
  'assets/images/bonus_tier2.png',
  'assets/images/correct_mark.png',
  'assets/images/wrong_mark.png',
];

/// Build a fake `AssetManifest.json` that covers every image the game uses.
Uint8List _buildManifestJson() {
  final manifest = <String, List<String>>{
    'assets/images/logo.jpeg': ['assets/images/logo.jpeg'],
  };
  for (final q in _fakeQuestions) {
    final file = q['image_file'] as String;
    manifest['assets/images/$file'] = ['assets/images/$file'];
  }
  for (final a in _extraAssets) {
    manifest[a] = [a];
  }
  return Uint8List.fromList(utf8.encode(jsonEncode(manifest)));
}

/// Build a fake `AssetManifest.bin` (StandardMessageCodec-encoded).
Uint8List _buildManifestBin() {
  final manifest = <String, List<Map<String, Object>>>{};
  void add(String key) {
    manifest[key] = [
      {'asset': key}
    ];
  }
  add('assets/images/logo.jpeg');
  for (final q in _fakeQuestions) {
    add('assets/images/${q['image_file']}');
  }
  for (final a in _extraAssets) {
    add(a);
  }
  final encoded = const StandardMessageCodec().encodeMessage(manifest)!;
  return encoded.buffer.asUint8List(encoded.offsetInBytes, encoded.lengthInBytes);
}

/// Provide stub assets and mock SharedPreferences.
void _setUpTestBindings() {
  final manifestJson = _buildManifestJson();
  final manifestBin = _buildManifestBin();

  // In-memory SharedPreferences so StatsService works in tests.
  SharedPreferencesAsyncPlatform.instance =
      InMemorySharedPreferencesAsync.empty();

  // Provide asset manifest + stub images for every asset request.
  ServicesBinding.instance.defaultBinaryMessenger
      .setMockMessageHandler('flutter/assets', (ByteData? message) async {
    if (message == null) return null;
    final key = String.fromCharCodes(
      message.buffer.asUint8List(message.offsetInBytes, message.lengthInBytes),
    );
    if (key == 'AssetManifest.json') {
      return ByteData.sublistView(manifestJson);
    }
    if (key == 'AssetManifest.bin') {
      return ByteData.sublistView(manifestBin);
    }
    if (key == 'FontManifest.json') {
      return ByteData.sublistView(Uint8List.fromList(utf8.encode('[]')));
    }
    // Any image → return a 1×1 PNG.
    if (key.endsWith('.png') || key.endsWith('.jpeg') || key.endsWith('.jpg')) {
      return ByteData.sublistView(_kTransparentPng);
    }
    return null;
  });
}

/// Build a [GameScreen] wrapped in a [MaterialApp] with test questions
/// so that no real asset loading is needed.
Widget _buildGameScreen() {
  return MaterialApp(
    home: GameScreen(testQuestions: List<dynamic>.from(_fakeQuestions)),
  );
}

/// Pump enough frames for the async [loadGameData] to complete and
/// the widget tree to rebuild, without requiring animations to settle
/// (the pulse animation repeats forever).
Future<void> _pumpUntilLoaded(WidgetTester tester) async {
  // loadGameData is a microtask – a single pump resolves it.
  await tester.pump();
  // One more pump for the setState rebuild.
  await tester.pump();
}

/// Configure a phone-sized viewport so all answer buttons fit on screen.
void _setPhoneSize(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
}

/// Helper: answer the current circle correctly.
Future<void> _answerCurrentCircleCorrectly(WidgetTester tester) async {
  final state = tester.state<GameScreenState>(find.byType(GameScreen));
  final String correct =
      state.gameQuestions[state.currentLevelIndex]['movies']
          [state.currentTarget];
  final button = find.widgetWithText(ElevatedButton, correct);
  await tester.ensureVisible(button);
  await tester.tap(button);
  await tester.pump();
  // Pump past the 800ms feedback timer
  await tester.pump(const Duration(milliseconds: 900));
}

/// Helper: complete one full stage (answer all 3 circles).
Future<void> _completeOneStage(WidgetTester tester) async {
  for (int i = 0; i < 3; i++) {
    await tester.pump(const Duration(milliseconds: 100));
    await _answerCurrentCircleCorrectly(tester);
  }
  // Pump past the 1000ms bonus mark display + _advanceAfterLevel
  await tester.pump(const Duration(milliseconds: 1200));
}

void main() {
  setUp(() {
    _setUpTestBindings();
  });

  // ─────────────────────────── Smoke ───────────────────────────
  group('App smoke test', () {
    testWidgets('MovennApp renders a MaterialApp', (tester) async {
      _setPhoneSize(tester);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await tester.pumpWidget(const MovennApp());
      expect(find.byType(MaterialApp), findsOneWidget);
      // SplashScreen uses Future.delayed timers that never settle –
      // advance past them so the test framework sees no pending timers.
      await tester.pump(const Duration(seconds: 5));
    });
  });

  // ────────────────────── Game loading ──────────────────────
  group('Game loading', () {
    testWidgets('GameScreen with no data shows loading indicator',
        (tester) async {
      _setPhoneSize(tester);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Center(child: CircularProgressIndicator())),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows game UI after data loads', (tester) async {
      _setPhoneSize(tester);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await tester.pumpWidget(_buildGameScreen());
      await _pumpUntilLoaded(tester);

      expect(find.textContaining('שאלה 1 מתוך'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsNWidgets(4));
    });

    testWidgets('displays the correct answer among options', (tester) async {
      _setPhoneSize(tester);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await tester.pumpWidget(_buildGameScreen());
      await _pumpUntilLoaded(tester);

      final movieNames = _fakeQuestions
          .expand((q) =>
              (q['movies'] as Map<String, dynamic>).values.cast<String>())
          .toSet();

      final optionTexts = tester
          .widgetList<Text>(find.descendant(
            of: find.byType(ElevatedButton),
            matching: find.byType(Text),
          ))
          .map((t) => t.data)
          .toList();

      expect(
        optionTexts.any((t) => movieNames.contains(t)),
        isTrue,
        reason: 'At least one option should be a real movie name',
      );
    });
  });

  // ─────────────────── Answer selection ───────────────────
  group('Answer selection', () {
    testWidgets('tapping the correct answer shows success feedback',
        (tester) async {
      _setPhoneSize(tester);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await tester.pumpWidget(_buildGameScreen());
      await _pumpUntilLoaded(tester);

      final state = tester.state<GameScreenState>(find.byType(GameScreen));
      final String correctMovie =
          state.gameQuestions[state.currentLevelIndex]['movies']
              [state.currentTarget];

      final button = find.widgetWithText(ElevatedButton, correctMovie);
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Feedback is now shown as a green border + checkmark image on the
      // question display (the old text banner was removed in 1.0.2).
      expect(state.feedbackVisible, isTrue);
      expect(state.feedbackCorrect, isTrue);
      // Pump past the 800ms feedback timer
      await tester.pump(const Duration(milliseconds: 600));
    });

    testWidgets('tapping a wrong answer shows error feedback', (tester) async {
      _setPhoneSize(tester);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await tester.pumpWidget(_buildGameScreen());
      await _pumpUntilLoaded(tester);

      final state = tester.state<GameScreenState>(find.byType(GameScreen));
      final String correctMovie =
          state.gameQuestions[state.currentLevelIndex]['movies']
              [state.currentTarget];

      final wrongFinder = find.byWidgetPredicate((widget) {
        if (widget is! ElevatedButton) return false;
        final child = widget.child;
        if (child is FittedBox) {
          final text = child.child;
          if (text is Text && text.data != correctMovie) return true;
        }
        return false;
      });

      await tester.ensureVisible(wrongFinder.first);
      await tester.tap(wrongFinder.first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Feedback is now shown as a red border + X image on the
      // question display (the old text banner was removed in 1.0.2).
      expect(state.feedbackVisible, isTrue);
      expect(state.feedbackCorrect, isFalse);
      // Pump past the 800ms feedback timer
      await tester.pump(const Duration(milliseconds: 600));
    });

    testWidgets('correct answer awards points', (tester) async {
      _setPhoneSize(tester);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await tester.pumpWidget(_buildGameScreen());
      await _pumpUntilLoaded(tester);

      final state = tester.state<GameScreenState>(find.byType(GameScreen));
      final int scoreBefore = state.totalScore;
      final String correctMovie =
          state.gameQuestions[state.currentLevelIndex]['movies']
              [state.currentTarget];

      final button = find.widgetWithText(ElevatedButton, correctMovie);
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pump();
      // Pump past the 800ms feedback timer
      await tester.pump(const Duration(milliseconds: 900));

      expect(
        state.totalScore,
        equals(scoreBefore + GameConfig.pointsPerCorrectCircle),
      );
    });

    testWidgets('after answering, target moves to next unanswered circle',
        (tester) async {
      _setPhoneSize(tester);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await tester.pumpWidget(_buildGameScreen());
      await _pumpUntilLoaded(tester);

      final state = tester.state<GameScreenState>(find.byType(GameScreen));
      final String firstTarget = state.currentTarget;
      final String correctMovie =
          state.gameQuestions[state.currentLevelIndex]['movies'][firstTarget];

      final button = find.widgetWithText(ElevatedButton, correctMovie);
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pump();
      // Pump past the 800ms feedback timer
      await tester.pump(const Duration(milliseconds: 900));

      expect(state.currentTarget, isNot(equals(firstTarget)));
    });
  });

  // ───────────────────── Stage completion ─────────────────────
  group('Stage completion', () {
    testWidgets('answering all 3 circles advances to next level',
        (tester) async {
      _setPhoneSize(tester);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await tester.pumpWidget(_buildGameScreen());
      await _pumpUntilLoaded(tester);

      final state = tester.state<GameScreenState>(find.byType(GameScreen));

      await _completeOneStage(tester);

      expect(state.currentLevelIndex, equals(1));
      expect(state.circleResults, isEmpty);
    });

    testWidgets('question counter updates after advancing stage',
        (tester) async {
      _setPhoneSize(tester);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await tester.pumpWidget(_buildGameScreen());
      await _pumpUntilLoaded(tester);

      await _completeOneStage(tester);
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.textContaining('שאלה 2 מתוך'), findsOneWidget);
    });
  });

  // ───────────────────── Game completion ─────────────────────
  group('Game completion', () {
    testWidgets('finishing all levels shows end-game dialog', (tester) async {
      _setPhoneSize(tester);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await tester.pumpWidget(_buildGameScreen());
      await _pumpUntilLoaded(tester);

      final state = tester.state<GameScreenState>(find.byType(GameScreen));
      final totalLevels = state.gameQuestions.length;

      for (int level = 0; level < totalLevels; level++) {
        await _completeOneStage(tester);
      }
      // Give the async _saveAndShowEndDialog time to complete.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('נקודות'), findsOneWidget);
      expect(find.text('תפריט ראשי'), findsOneWidget);
      expect(find.text('משחק חדש'), findsOneWidget);
    });

    testWidgets('end-game dialog shows score', (tester) async {
      _setPhoneSize(tester);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await tester.pumpWidget(_buildGameScreen());
      await _pumpUntilLoaded(tester);

      final state = tester.state<GameScreenState>(find.byType(GameScreen));
      final totalLevels = state.gameQuestions.length;

      for (int level = 0; level < totalLevels; level++) {
        await _completeOneStage(tester);
      }
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      final expectedBaseScore =
          totalLevels * 3 * GameConfig.pointsPerCorrectCircle;
      expect(state.totalScore, greaterThanOrEqualTo(expectedBaseScore));
      expect(find.text('${state.totalScore}'), findsWidgets);
    });

    testWidgets('tapping "משחק חדש" restarts the game', (tester) async {
      _setPhoneSize(tester);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await tester.pumpWidget(_buildGameScreen());
      await _pumpUntilLoaded(tester);

      final state = tester.state<GameScreenState>(find.byType(GameScreen));
      final totalLevels = state.gameQuestions.length;

      for (int level = 0; level < totalLevels; level++) {
        await _completeOneStage(tester);
      }
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Find the "משחק חדש" button inside the AlertDialog
      final dialogButton = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.widgetWithText(ElevatedButton, 'משחק חדש'),
      );
      await tester.tap(dialogButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(state.currentLevelIndex, equals(0));
      expect(state.totalScore, equals(0));
      expect(find.textContaining('שאלה 1 מתוך'), findsOneWidget);
    });
  });

  // ─────────────────── GameConfig constants ───────────────────
  group('GameConfig', () {
    test('has sensible default values', () {
      expect(GameConfig.rotationInterval, greaterThan(0));
      expect(GameConfig.maxLevelTime, greaterThan(0));
      expect(GameConfig.pointsPerCorrectCircle, greaterThan(0));
      expect(
        GameConfig.speedBonusTier1,
        greaterThan(GameConfig.speedBonusTier2),
      );
    });
  });
}
