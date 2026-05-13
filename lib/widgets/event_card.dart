import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../theme/app_theme.dart';

class EventCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback onTap;
  final VoidCallback onToggleComplete;
  final VoidCallback onDelete;

  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
    required this.onToggleComplete,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(event.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: AppTheme.danger.withAlpha(40),
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        ),
        child: const Icon(
          Icons.delete_rounded,
          color: AppTheme.danger,
          size: 28,
        ),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            border: Border.all(
              color: event.isCompleted
                  ? AppTheme.success.withAlpha(60)
                  : event.category.color.withAlpha(30),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: event.category.color.withAlpha(15),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  // Color accent bar
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 4,
                    decoration: BoxDecoration(
                      color: event.isCompleted
                          ? AppTheme.success
                          : event.category.color,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(AppTheme.radiusLarge),
                        bottomLeft: Radius.circular(AppTheme.radiusLarge),
                      ),
                    ),
                  ),
                  // Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Time column
                          SizedBox(
                            width: 52,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  event.formattedStartTime,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: event.isCompleted
                                        ? AppTheme.textHint
                                        : AppTheme.textPrimary,
                                  ),
                                ),
                                if (event.endTime != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    event.formattedEndTime,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: event.isCompleted
                                          ? AppTheme.textHint
                                          : AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Divider
                          Container(
                            width: 1,
                            height: 40,
                            color: AppTheme.surfaceLight,
                          ),
                          const SizedBox(width: 12),
                          // Event info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: event.category.color.withAlpha(25),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            event.category.icon,
                                            size: 12,
                                            color: event.category.color,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            event.category.label,
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: event.category.color,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (event.hasReminder) ...[
                                      const SizedBox(width: 6),
                                      Icon(
                                        Icons.notifications_active_rounded,
                                        size: 14,
                                        color: AppTheme.accent3.withAlpha(180),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  event.title,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: event.isCompleted
                                        ? AppTheme.textHint
                                        : AppTheme.textPrimary,
                                    decoration: event.isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                    decorationColor: AppTheme.textHint,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (event.description.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    event.description,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: event.isCompleted
                                          ? AppTheme.textHint
                                          : AppTheme.textSecondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          // Complete checkbox
                          GestureDetector(
                            onTap: onToggleComplete,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: event.isCompleted
                                    ? AppTheme.success
                                    : Colors.transparent,
                                border: Border.all(
                                  color: event.isCompleted
                                      ? AppTheme.success
                                      : AppTheme.textHint,
                                  width: 2,
                                ),
                              ),
                              child: event.isCompleted
                                  ? const Icon(
                                      Icons.check_rounded,
                                      size: 18,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
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
