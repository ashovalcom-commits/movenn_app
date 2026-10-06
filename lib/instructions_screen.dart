import 'package:flutter/material.dart';

class InstructionsScreen extends StatelessWidget {
  const InstructionsScreen({super.key});

  static Widget _buildBullet(String boldPart, String rest) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('• ', style: TextStyle(fontSize: 16)),
        Expanded(
          child: RichText(
            textDirection: TextDirection.rtl,
            text: TextSpan(
              style: const TextStyle(fontSize: 16, color: Colors.black),
              children: [
                TextSpan(
                  text: '$boldPart ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: rest),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('הוראות המשחק', textDirection: TextDirection.rtl),
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'מטרת המשחק',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'לזהות את הסרטים המסתתרים מאחורי המעגלים בדיאגרמה, בהתבסס על השחקנים המופיעים בהם, ולצבור את מספר הנקודות המירבי לאורך 10 שלבי המשחק.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              const Text(
                'איך משחקים?',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildBullet(
                'פענוח הדיאגרמה:',
                'בכל שלב תוצג תמונה עם 3 מעגלים, כאשר כל מעגל מייצג סרט. השחקנים שמופיעים באזורי החיתוך הם אלו ששיחקו במשותף בסרטים החופפים.',
              ),
              const SizedBox(height: 8),
              _buildBullet(
                'בחירת התשובות:',
                'המשחק יעבור בין המעגלים, ועבור כל מעגל תצטרכו לבחור את הסרט הנכון מתוך האפשרויות שיוצגו בחלק התחתון של המסך.',
              ),
              const SizedBox(height: 24),
              const Text(
                'שיטת הניקוד',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildBullet(
                '5 נקודות',
                'יוענקו לכם על כל זיהוי נכון של סרט בודד.',
              ),
              const SizedBox(height: 8),
              _buildBullet(
                'בונוס מהירות:',
                'זיהיתם נכון את כל שלושת הסרטים באותה תמונה תוך פחות מ-15 שניות? תקבלו תוספת של 15 נקודות בונוס.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
