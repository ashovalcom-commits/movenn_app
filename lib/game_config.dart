class GameConfig {
  // --- הגדרות זמנים (בשניות) ---
  
  /// כל כמה שניות מתחלף המעגל (A, B, C) באזור התשובות
  static const int rotationInterval = 10; 
  
  /// הזמן המקסימלי לכל דיאגרמת ון (שלב) לפני פסילה אוטומטית
  static const int maxLevelTime = 60; 
  
  static const int bonusTimeTier1 = 15;
  static const int bonusTimeTier2 = 30;

  // --- הגדרות ניקוד ---
  
  /// נקודות על כל מעגל נכון (מתעדכן מיד)
  static const int pointsPerCorrectCircle = 5;
  
  static const int speedBonusTier1 = 30;
  static const int speedBonusTier2 = 15;
}