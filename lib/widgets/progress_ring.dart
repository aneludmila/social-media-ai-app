import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ProgressRing extends StatelessWidget {
  final double progress;
  final int completed;
  final int total;

  const ProgressRing({
    super.key,
    required this.progress,
    required this.completed,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.surfaceLight.withAlpha(120),
            AppTheme.surface.withAlpha(200),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
        border: Border.all(
          color: AppTheme.surfaceLighter.withAlpha(80),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Ring
          SizedBox(
            width: 60,
            height: 60,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: progress),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background circle
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(
                        value: 1,
                        strokeWidth: 6,
                        strokeCap: StrokeCap.round,
                        valueColor: AlwaysStoppedAnimation(
                          AppTheme.surfaceLight.withAlpha(100),
                        ),
                      ),
                    ),
                    // Progress circle
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(
                        value: value,
                        strokeWidth: 6,
                        strokeCap: StrokeCap.round,
                        valueColor: AlwaysStoppedAnimation(
                          value == 1.0 ? AppTheme.success : AppTheme.primary,
                        ),
                      ),
                    ),
                    // Percentage text
                    Text(
                      '${(value * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Progresso do dia',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  total == 0
                      ? 'Nenhuma tarefa ainda'
                      : '$completed de $total concluídas',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: progress == 1.0 && total > 0
                  ? AppTheme.success.withAlpha(30)
                  : AppTheme.primary.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: Icon(
              progress == 1.0 && total > 0
                  ? Icons.celebration_rounded
                  : Icons.trending_up_rounded,
              color: progress == 1.0 && total > 0
                  ? AppTheme.success
                  : AppTheme.primary,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}
