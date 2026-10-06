class GameConfig {
  // --- הגדרות זמנים (בשניות) ---
  
  /// כל כמה שניות מתחלף המעגל (A, B, C) באזור התשובות
  static const int rotationInterval = 5; 
  
  /// הזמן המקסימלי לכל דיאגרמת ון (שלב) לפני פסילה אוטומטית
  static const int maxLevelTime = 60; 
  
  /// רף הזמן לקבלת בונוס מהירות (אם ענו על כל ה-3 נכון מתחת לזמן הזה)
  static const int bonusTimeLimit = 15; 

  // --- הגדרות ניקוד ---
  
  /// נקודות על כל מעגל נכון (מתעדכן מיד)
  static const int pointsPerCorrectCircle = 5;
  
  /// בונוס מהירות - ניתן בסוף השאלה אם כל 3 נכונים מתחת לזמן
  static const int speedBonus = 15;
}