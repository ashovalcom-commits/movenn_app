import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'responsive.dart';

class InstructionsScreen extends StatelessWidget {
  const InstructionsScreen({super.key});

  static Widget _buildBullet(String boldPart, String rest) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 7),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              textDirection: TextDirection.rtl,
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
                children: [
                  TextSpan(
                    text: '$boldPart ',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(
                    text: rest,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildSection({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 22),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ...children,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('הוראות המשחק', textDirection: TextDirection.rtl),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: r.maxContentWidth),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: r.sp(16),
                vertical: r.sp(20),
              ),
              child: Column(
                children: [
                  _buildSection(
                    icon: Icons.flag_rounded,
                    title: 'מטרת המשחק',
                    children: [
                      const Text(
                        'לזהות את הסרטים המסתתרים מאחורי המעגלים בדיאגרמה, בהתבסס על השחקנים המופיעים בהם, ולצבור את מספר הנקודות המירבי לאורך 10 שלבי המשחק.',
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildSection(
                    icon: Icons.sports_esports_rounded,
                    title: 'איך משחקים?',
                    children: [
                      _buildBullet(
                        'פענוח הדיאגרמה:',
                        'בכל שלב תוצג תמונה עם 3 מעגלים, כאשר כל מעגל מייצג סרט. השחקנים שמופיעים באזורי החיתוך הם אלו ששיחקו במשותף בסרטים החופפים.',
                      ),
                      _buildBullet(
                        'בחירת התשובות:',
                        'המשחק יעבור בין המעגלים, ועבור כל מעגל תצטרכו לבחור את הסרט הנכון מתוך האפשרויות שיוצגו בחלק התחתון של המסך.',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildSection(
                    icon: Icons.star_rounded,
                    title: 'שיטת הניקוד',
                    children: [
                      _buildBullet(
                        '5 נקודות',
                        'יוענקו לכם על כל זיהוי נכון של סרט בודד.',
                      ),
                      _buildBullet(
                        'בונוס מהירות:',
                        'זיהיתם נכון את כל שלושת הסרטים באותה תמונה תוך 15 שניות או פחות? תקבלו 30 נקודות בונוס. בין 15 ל-30 שניות? תקבלו 15 נקודות בונוס.',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
