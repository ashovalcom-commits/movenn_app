class GameConfig {
  // --- הגדרות זמנים (בשניות) ---
  
  /// כל כמה שניות מתחלף המעגל (A, B, C) באזור התשובות
  static const int rotationInterval = 10; 
  
  /// הזמן המקסימלי לכל דיאגרמת ון (שלב) לפני פסילה אוטומטית
  static const int maxLevelTime = 120; 
  
  /// רף הזמן לקבלת בונוס מהירות (אם ענו על כל ה-3 נכון מתחת לזמן הזה)
  static const int bonusTimeLimit = 30; 

  // --- הגדרות ניקוד ---
  
  /// נקודות על מעגל אחד נכון
  static const int pointsForOne = 5; 
  
  /// נקודות על שני מעגלים נכונים
  static const int pointsForTwo = 10; 
  
  /// נקודות על שלושה מעגלים נכונים (ללא בונוס זמן)
  static const int pointsForThree = 20; 
  
  /// נקודות על שלושה מעגלים נכונים + עמידה ביעד המהירות
  static const int pointsForThreeWithBonus = 30; 
}