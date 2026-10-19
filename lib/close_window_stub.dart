import 'package:flutter/services.dart';

/// Exit the app on non-web platforms (Android / iOS / desktop).
void closeWindow() {
  SystemNavigator.pop();
}
