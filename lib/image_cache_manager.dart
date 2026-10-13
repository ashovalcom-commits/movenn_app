import 'package:flutter/widgets.dart';

/// Configures the global [ImageCache] and provides helpers
/// for pre-warming game images.
class ImageCacheManager {
  ImageCacheManager._();

  /// Call once from [main] before [runApp].
  /// Sets a generous image-cache budget so all 10 game images
  /// (+ logo) stay decoded in memory throughout a session.
  static void configure() {
    final cache = PaintingBinding.instance.imageCache;
    // 15 images decoded at once is more than enough for a 10-question game
    cache.maximumSize = 30;
    // ~60 KB PNG × ~4x decoded ≈ 240 KB each → 30 × 240 KB ≈ 7 MB
    cache.maximumSizeBytes = 50 * 1024 * 1024; // 50 MB headroom
  }

  /// Pre-cache a batch of question images so transitions feel instant.
  /// Call after selecting the 10 random questions for a game.
  static Future<void> precacheGameImages(
    BuildContext context,
    List<dynamic> questions, {
    int startIndex = 0,
    int count = 3,
  }) async {
    final end = (startIndex + count).clamp(0, questions.length);
    final futures = <Future<void>>[];
    for (var i = startIndex; i < end; i++) {
      final file = questions[i]['image_file'] as String;
      futures.add(
        precacheImage(AssetImage('assets/images/$file'), context)
            .catchError((_) {}),
      );
    }
    await Future.wait(futures);
  }

  /// Pre-cache a single image by asset path.
  static Future<void> precacheSingle(
    BuildContext context,
    String assetPath,
  ) {
    return precacheImage(AssetImage(assetPath), context).catchError((_) {});
  }
}
