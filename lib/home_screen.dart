import 'package:flutter/material.dart';

import 'main.dart';
import 'instructions_screen.dart';
import 'stats_screen.dart';
import 'app_theme.dart';
import 'responsive.dart';
import 'close_window_stub.dart'
    if (dart.library.js_interop) 'close_window_web.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primaryDark, AppColors.primary],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: r.maxContentWidth),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: r.horizontalPadding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),

                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(r.sp(28)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(60),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(r.sp(28)),
                        child: Image.asset(
                          'assets/images/logo.jpeg',
                          width: r.logoSize,
                          height: r.logoSize,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    const Spacer(flex: 2),

                    SizedBox(
                      width: double.infinity,
                      height: r.buttonHeight,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const GameScreen(),
                            ),
                          );
                        },
                        icon: Icon(Icons.play_arrow_rounded, size: r.sp(26)),
                        label: Text(
                          'התחל משחק',
                          style: TextStyle(fontSize: r.sp(20)),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: AppColors.textPrimary,
                          textStyle: TextStyle(
                            fontSize: r.sp(20),
                            fontWeight: FontWeight.w700,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: r.sp(14)),

                    SizedBox(
                      width: double.infinity,
                      height: r.buttonHeight,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const InstructionsScreen(),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(
                            color: Colors.white54,
                            width: 1.5,
                          ),
                          textStyle: TextStyle(
                            fontSize: r.sp(18),
                            fontWeight: FontWeight.w600,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.help_outline_rounded, size: r.sp(22)),
                            const SizedBox(width: 8),
                            Text(
                              '?איך משחקים',
                              style: TextStyle(fontSize: r.sp(18)),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: r.sp(14)),

                    SizedBox(
                      width: double.infinity,
                      height: r.buttonHeight,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const StatsScreen(),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(
                            color: Colors.white54,
                            width: 1.5,
                          ),
                          textStyle: TextStyle(
                            fontSize: r.sp(18),
                            fontWeight: FontWeight.w600,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.bar_chart_rounded, size: r.sp(22)),
                            const SizedBox(width: 8),
                            Text(
                              'סטטיסטיקות',
                              style: TextStyle(fontSize: r.sp(18)),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: r.sp(14)),

                    SizedBox(
                      width: double.infinity,
                      height: r.buttonHeight,
                      child: OutlinedButton(
                        onPressed: () {
                          closeWindow();
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(
                            color: Colors.white54,
                            width: 1.5,
                          ),
                          textStyle: TextStyle(
                            fontSize: r.sp(18),
                            fontWeight: FontWeight.w600,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.exit_to_app_rounded, size: r.sp(22)),
                            const SizedBox(width: 8),
                            Text(
                              'יציאה',
                              style: TextStyle(fontSize: r.sp(18)),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Spacer(flex: 1),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
