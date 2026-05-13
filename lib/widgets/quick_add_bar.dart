import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/event_model.dart';
import '../providers/event_provider.dart';
import '../theme/app_theme.dart';

class QuickAddBar extends StatelessWidget {
  const QuickAddBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: EventTemplate.templates.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final template = EventTemplate.templates[index];
          return _QuickAddChip(template: template);
        },
      ),
    );
  }
}

class _QuickAddChip extends StatelessWidget {
  final EventTemplate template;

  const _QuickAddChip({required this.template});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final provider = Provider.of<EventProvider>(context, listen: false);
        provider.addFromTemplate(template, provider.selectedDay);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ "${template.title}" adicionado!'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: template.category.color.withAlpha(15),
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          border: Border.all(
            color: template.category.color.withAlpha(40),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: template.category.color.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: Icon(
                template.icon,
                color: template.category.color,
                size: 18,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              template.title,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: template.category.color,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
