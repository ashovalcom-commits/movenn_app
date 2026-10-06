import 'package:flutter/material.dart';

enum ScreenType { smallPhone, phone, largePhone, tablet }

class Responsive {
  final BuildContext context;
  late final double screenWidth;
  late final double screenHeight;
  late final ScreenType screenType;

  Responsive(this.context) {
    final mq = MediaQuery.of(context);
    screenWidth = mq.size.width;
    screenHeight = mq.size.height;
    final shortSide = mq.size.shortestSide;

    if (shortSide < 360) {
      screenType = ScreenType.smallPhone;
    } else if (shortSide < 400) {
      screenType = ScreenType.phone;
    } else if (shortSide < 600) {
      screenType = ScreenType.largePhone;
    } else {
      screenType = ScreenType.tablet;
    }
  }

  bool get isTablet => screenType == ScreenType.tablet;
  bool get isSmallPhone => screenType == ScreenType.smallPhone;

  // Scale factor relative to a 390px-wide reference phone
  double get scaleFactor {
    switch (screenType) {
      case ScreenType.smallPhone:
        return screenWidth / 390 * 0.95;
      case ScreenType.phone:
        return 1.0;
      case ScreenType.largePhone:
        return screenWidth / 390;
      case ScreenType.tablet:
        return (screenWidth / 390).clamp(1.0, 1.45);
    }
  }

  double sp(double size) => size * scaleFactor;

  double get logoSize => isTablet ? 360 : (screenWidth * 0.6).clamp(160, 300);

  double get buttonHeight => sp(52);

  double get horizontalPadding => isTablet ? 64 : sp(28);

  // Game screen: flex ratio for image vs answer panel
  int get imageFlex => isTablet ? 5 : (isSmallPhone ? 3 : 4);
  int get answerFlex => isTablet ? 5 : (isSmallPhone ? 5 : 5);

  double get optionButtonHeight => sp(46);

  double get maxContentWidth => isTablet ? 600 : double.infinity;
}
