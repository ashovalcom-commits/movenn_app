/// Detects images in assets/images/ that are not referenced by the
/// question JSON or source code.  Run before release builds to keep
/// the APK lean:
///
///   dart run tool/check_orphaned_images.dart
///   dart run tool/check_orphaned_images.dart --delete
///
import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  final projectRoot = _findProjectRoot();
  final imagesDir = Directory('$projectRoot/assets/images');
  final jsonFile = File('$projectRoot/assets/venn_questions_edit3_6.json');

  if (!imagesDir.existsSync()) {
    stderr.writeln('❌  assets/images/ directory not found.');
    exit(1);
  }
  if (!jsonFile.existsSync()) {
    stderr.writeln('❌  venn_questions_edit3_6.json not found.');
    exit(1);
  }

  // 1. Collect all image filenames on disk
  final diskImages = imagesDir
      .listSync()
      .whereType<File>()
      .map((f) => f.uri.pathSegments.last)
      .toSet();

  // 2. Collect image_file references from JSON
  final questions = json.decode(jsonFile.readAsStringSync()) as List;
  final jsonImages = questions.map((q) => q['image_file'] as String).toSet();

  // 3. Collect images referenced in Dart source code
  final libDir = Directory('$projectRoot/lib');
  final codeRefs = <String>{};
  if (libDir.existsSync()) {
    for (final file in libDir.listSync(recursive: true).whereType<File>()) {
      if (!file.path.endsWith('.dart')) continue;
      final content = file.readAsStringSync();
      for (final img in diskImages) {
        if (content.contains(img)) codeRefs.add(img);
      }
    }
  }

  // 4. Identify orphaned images
  final referencedImages = jsonImages.union(codeRefs);
  final orphaned = diskImages.difference(referencedImages).toList()..sort();

  // 5. Report
  print('📦  Images on disk:        ${diskImages.length}');
  print('📝  Referenced in JSON:     ${jsonImages.length}');
  print('💻  Referenced in code:     ${codeRefs.length}');
  print('🗑️  Orphaned images:        ${orphaned.length}');

  if (orphaned.isEmpty) {
    print('\n✅  No orphaned images found — APK is clean.');
    exit(0);
  }

  var totalBytes = 0;
  print('\nOrphaned files:');
  for (final name in orphaned) {
    final file = File('${imagesDir.path}/$name');
    final sizeKB = (file.lengthSync() / 1024).toStringAsFixed(1);
    totalBytes += file.lengthSync();
    print('  • $name  ($sizeKB KB)');
  }

  final totalKB = (totalBytes / 1024).toStringAsFixed(1);
  print('\n💡  Removing these would save ~$totalKB KB from the APK.');

  if (args.contains('--delete')) {
    for (final name in orphaned) {
      File('${imagesDir.path}/$name').deleteSync();
      print('   🗑️  Deleted $name');
    }
    print('\n✅  Cleaned up ${orphaned.length} orphaned images.');
  } else {
    print('    Run with --delete to remove them automatically.');
  }

  exit(orphaned.isNotEmpty ? 1 : 0);
}

String _findProjectRoot() {
  var dir = Directory.current;
  while (true) {
    if (File('${dir.path}/pubspec.yaml').existsSync()) return dir.path;
    final parent = dir.parent;
    if (parent.path == dir.path) break;
    dir = parent;
  }
  return Directory.current.path;
}
