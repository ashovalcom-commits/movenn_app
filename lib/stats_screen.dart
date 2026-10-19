import 'package:flutter/material.dart';

import 'stats_service.dart';
import 'app_theme.dart';
import 'responsive.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  late Future<GameStats> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = StatsService().getStats();
  }

  void _reload() {
    setState(() {
      _statsFuture = StatsService().getStats();
    });
  }

  Future<void> _confirmReset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('איפוס סטטיסטיקות', textAlign: TextAlign.center),
        content: const Text(
          'כל הנתונים יימחקו. האם להמשיך?',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('ביטול'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.wrong,
              foregroundColor: Colors.white,
            ),
            child: const Text('איפוס'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await StatsService().resetStats();
      _reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('הסטטיסטיקות שלי'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: 'איפוס סטטיסטיקות',
            onPressed: _confirmReset,
          ),
        ],
      ),
      body: FutureBuilder<GameStats>(
        future: _statsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final stats = snapshot.data ??
              const GameStats(
                highScore: 0,
                gamesCompleted: 0,
                totalScore: 0,
                totalCorrect: 0,
                totalQuestions: 0,
                lastScores: [],
              );

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: r.maxContentWidth),
              child: ListView(
                padding: EdgeInsets.all(r.sp(20)),
                children: [
                  // High score hero card
                  _HeroCard(
                    icon: Icons.emoji_events_rounded,
                    iconColor: AppColors.accent,
                    title: 'שיא ניקוד',
                    value: '${stats.highScore}',
                    r: r,
                  ),
                  SizedBox(height: r.sp(16)),

                  // Stats grid
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.sports_esports_rounded,
                          label: 'משחקים שהושלמו',
                          value: '${stats.gamesCompleted}',
                          r: r,
                        ),
                      ),
                      SizedBox(width: r.sp(12)),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.trending_up_rounded,
                          label: 'ניקוד ממוצע',
                          value: stats.averageScore.toStringAsFixed(1),
                          r: r,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: r.sp(12)),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.check_circle_outline_rounded,
                          label: 'תשובות נכונות',
                          value: '${stats.totalCorrect}',
                          r: r,
                        ),
                      ),
                      SizedBox(width: r.sp(12)),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.percent_rounded,
                          label: 'אחוז הצלחה',
                          value: '${stats.correctRate.toStringAsFixed(0)}%',
                          r: r,
                        ),
                      ),
                    ],
                  ),

                  if (stats.gamesCompleted == 0)
                    Padding(
                      padding: EdgeInsets.only(top: r.sp(40)),
                      child: Column(
                        children: [
                          Icon(
                            Icons.videogame_asset_off_rounded,
                            size: r.sp(56),
                            color: AppColors.textSecondary.withAlpha(100),
                          ),
                          SizedBox(height: r.sp(12)),
                          Text(
                            'עדיין אין סטטיסטיקות\nשחקו משחק כדי להתחיל!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: r.sp(16),
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _HeroCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final Responsive r;

  const _HeroCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.r,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: r.sp(24), horizontal: r.sp(16)),
        child: Column(
          children: [
            Icon(icon, size: r.sp(48), color: iconColor),
            SizedBox(height: r.sp(8)),
            Text(
              title,
              style: TextStyle(
                fontSize: r.sp(16),
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: r.sp(4)),
            Text(
              value,
              style: TextStyle(
                fontSize: r.sp(40),
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Responsive r;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.r,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: r.sp(16), horizontal: r.sp(12)),
        child: Column(
          children: [
            Icon(icon, size: r.sp(28), color: AppColors.primary),
            SizedBox(height: r.sp(8)),
            Text(
              value,
              style: TextStyle(
                fontSize: r.sp(24),
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: r.sp(4)),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: r.sp(12),
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

