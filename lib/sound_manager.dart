import 'dart:math';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';

class SoundManager {
  static final SoundManager _instance = SoundManager._internal();
  factory SoundManager() => _instance;
  SoundManager._internal();

  final AudioPlayer _correctPlayer = AudioPlayer();
  final AudioPlayer _wrongPlayer = AudioPlayer();
  final AudioPlayer _switchPlayer = AudioPlayer();
  final AudioPlayer _bellPlayer = AudioPlayer();

  Uint8List? _correctSound;
  Uint8List? _wrongSound;
  Uint8List? _switchSound;
  Uint8List? _bellSound;

  Future<void> init() async {
    _correctSound = _generateCorrectSound();
    _wrongSound = _generateWrongSound();
    _switchSound = _generateSwitchSound();
    _bellSound = _generateBellSound();

    try {
      await _correctPlayer.setVolume(0.5);
      await _wrongPlayer.setVolume(0.5);
      await _switchPlayer.setVolume(0.4);
      await _bellPlayer.setVolume(0.6);
    } catch (_) {
      // Audio plugin unavailable (e.g. during tests).
    }
  }

  // Correct answer: bright ascending three-note chime
  Uint8List _generateCorrectSound() {
    const sampleRate = 44100;
    const duration = 0.45;
    final samples = (sampleRate * duration).toInt();
    final data = Int16List(samples);

    for (int i = 0; i < samples; i++) {
      double t = i / sampleRate;
      double freq;
      if (t < 0.15) {
        freq = 523.25; // C5
      } else if (t < 0.30) {
        freq = 659.25; // E5
      } else {
        freq = 783.99; // G5
      }
      double envelope = (1.0 - (i / samples)) * 0.85;
      double wave = sin(2 * pi * freq * t) + 0.3 * sin(2 * pi * freq * 2 * t);
      data[i] = (wave * envelope * 24000).toInt().clamp(-32767, 32767);
    }

    return _createWav(data, sampleRate);
  }

  // Wrong answer: harsh low buzzer with dissonance
  Uint8List _generateWrongSound() {
    const sampleRate = 44100;
    const duration = 0.5;
    final samples = (sampleRate * duration).toInt();
    final data = Int16List(samples);

    for (int i = 0; i < samples; i++) {
      double t = i / sampleRate;
      double freq = 180.0 - (t * 60);
      double envelope = (1.0 - (i / samples) * 0.7) * 0.75;
      // Dissonant buzz with multiple harmonics
      double wave = sin(2 * pi * freq * t)
          + 0.5 * sin(2 * pi * freq * 1.5 * t)
          + 0.3 * sin(2 * pi * freq * 3 * t);
      data[i] = (wave * envelope * 16000).toInt().clamp(-32767, 32767);
    }

    return _createWav(data, sampleRate);
  }

  // Switch / next question: quick click-pop
  Uint8List _generateSwitchSound() {
    const sampleRate = 44100;
    const duration = 0.12;
    final samples = (sampleRate * duration).toInt();
    final data = Int16List(samples);

    for (int i = 0; i < samples; i++) {
      double t = i / sampleRate;
      double envelope = exp(-t * 40) * 0.7;
      double wave = sin(2 * pi * 1200 * t) + 0.5 * sin(2 * pi * 600 * t);
      data[i] = (wave * envelope * 24000).toInt().clamp(-32767, 32767);
    }

    return _createWav(data, sampleRate);
  }

  // Bell sound for bonus notification
  Uint8List _generateBellSound() {
    const sampleRate = 44100;
    const duration = 0.4;
    final samples = (sampleRate * duration).toInt();
    final data = Int16List(samples);

    for (int i = 0; i < samples; i++) {
      double t = i / sampleRate;
      double envelope = exp(-t * 8) * 0.9;
      // Bell-like: fundamental + inharmonic partials
      double wave = sin(2 * pi * 1567.98 * t)       // G6
          + 0.6 * sin(2 * pi * 2093.0 * t)          // C7
          + 0.3 * sin(2 * pi * 2637.02 * t)         // E7
          + 0.15 * sin(2 * pi * 3135.96 * t);       // G7
      data[i] = (wave * envelope * 18000).toInt().clamp(-32767, 32767);
    }

    return _createWav(data, sampleRate);
  }

  Uint8List _createWav(Int16List samples, int sampleRate) {
    final dataSize = samples.length * 2;
    final fileSize = 36 + dataSize;
    final buffer = ByteData(44 + dataSize);

    // RIFF header
    buffer.setUint8(0, 0x52); // R
    buffer.setUint8(1, 0x49); // I
    buffer.setUint8(2, 0x46); // F
    buffer.setUint8(3, 0x46); // F
    buffer.setUint32(4, fileSize, Endian.little);
    buffer.setUint8(8, 0x57);  // W
    buffer.setUint8(9, 0x41);  // A
    buffer.setUint8(10, 0x56); // V
    buffer.setUint8(11, 0x45); // E

    // fmt subchunk
    buffer.setUint8(12, 0x66); // f
    buffer.setUint8(13, 0x6D); // m
    buffer.setUint8(14, 0x74); // t
    buffer.setUint8(15, 0x20); // (space)
    buffer.setUint32(16, 16, Endian.little); // subchunk size
    buffer.setUint16(20, 1, Endian.little);  // PCM
    buffer.setUint16(22, 1, Endian.little);  // mono
    buffer.setUint32(24, sampleRate, Endian.little);
    buffer.setUint32(28, sampleRate * 2, Endian.little); // byte rate
    buffer.setUint16(32, 2, Endian.little); // block align
    buffer.setUint16(34, 16, Endian.little); // bits per sample

    // data subchunk
    buffer.setUint8(36, 0x64); // d
    buffer.setUint8(37, 0x61); // a
    buffer.setUint8(38, 0x74); // t
    buffer.setUint8(39, 0x61); // a
    buffer.setUint32(40, dataSize, Endian.little);

    for (int i = 0; i < samples.length; i++) {
      buffer.setInt16(44 + i * 2, samples[i], Endian.little);
    }

    return buffer.buffer.asUint8List();
  }

  Future<void> playCorrect() async {
    if (_correctSound == null) return;
    try {
      await _correctPlayer.stop();
      await _correctPlayer.play(BytesSource(_correctSound!));
    } catch (_) {}
  }

  Future<void> playWrong() async {
    if (_wrongSound == null) return;
    try {
      await _wrongPlayer.stop();
      await _wrongPlayer.play(BytesSource(_wrongSound!));
    } catch (_) {}
  }

  Future<void> playSwitch() async {
    if (_switchSound == null) return;
    try {
      await _switchPlayer.stop();
      await _switchPlayer.play(BytesSource(_switchSound!));
    } catch (_) {}
  }

  Future<void> playBell() async {
    if (_bellSound == null) return;
    try {
      await _bellPlayer.stop();
      await _bellPlayer.play(BytesSource(_bellSound!));
    } catch (_) {}
  }

  void dispose() {
    try {
      _correctPlayer.dispose();
      _wrongPlayer.dispose();
      _switchPlayer.dispose();
      _bellPlayer.dispose();
    } catch (_) {}
  }
}
