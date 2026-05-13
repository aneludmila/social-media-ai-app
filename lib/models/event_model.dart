import 'dart:convert';
import 'package:flutter/material.dart';

enum EventCategory {
  story,
  feed,
  gravacao,
  edicao,
  planejamento,
  cliente,
  outro;

  String get label {
    switch (this) {
      case EventCategory.story:
        return 'Story';
      case EventCategory.feed:
        return 'Feed';
      case EventCategory.gravacao:
        return 'Gravação';
      case EventCategory.edicao:
        return 'Edição';
      case EventCategory.planejamento:
        return 'Planejamento';
      case EventCategory.cliente:
        return 'Cliente';
      case EventCategory.outro:
        return 'Outro';
    }
  }

  IconData get icon {
    switch (this) {
      case EventCategory.story:
        return Icons.auto_stories_rounded;
      case EventCategory.feed:
        return Icons.grid_on_rounded;
      case EventCategory.gravacao:
        return Icons.videocam_rounded;
      case EventCategory.edicao:
        return Icons.movie_edit;
      case EventCategory.planejamento:
        return Icons.event_note_rounded;
      case EventCategory.cliente:
        return Icons.person_rounded;
      case EventCategory.outro:
        return Icons.label_rounded;
    }
  }

  Color get color {
    switch (this) {
      case EventCategory.story:
        return const Color(0xFFFF6B9D);
      case EventCategory.feed:
        return const Color(0xFF6C63FF);
      case EventCategory.gravacao:
        return const Color(0xFFFF4757);
      case EventCategory.edicao:
        return const Color(0xFFFF9F43);
      case EventCategory.planejamento:
        return const Color(0xFF00D2D3);
      case EventCategory.cliente:
        return const Color(0xFF2ECC71);
      case EventCategory.outro:
        return const Color(0xFF8395A7);
    }
  }
}

class EventModel {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay? endTime;
  final EventCategory category;
  final bool isCompleted;
  final bool hasReminder;

  EventModel({
    required this.id,
    required this.title,
    this.description = '',
    required this.date,
    required this.startTime,
    this.endTime,
    this.category = EventCategory.outro,
    this.isCompleted = false,
    this.hasReminder = false,
  });

  EventModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    EventCategory? category,
    bool? isCompleted,
    bool? hasReminder,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      hasReminder: hasReminder ?? this.hasReminder,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'startTimeHour': startTime.hour,
      'startTimeMinute': startTime.minute,
      'endTimeHour': endTime?.hour,
      'endTimeMinute': endTime?.minute,
      'category': category.index,
      'isCompleted': isCompleted,
      'hasReminder': hasReminder,
    };
  }

  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String? ?? '',
      date: DateTime.parse(map['date'] as String),
      startTime: TimeOfDay(
        hour: map['startTimeHour'] as int,
        minute: map['startTimeMinute'] as int,
      ),
      endTime: map['endTimeHour'] != null
          ? TimeOfDay(
              hour: map['endTimeHour'] as int,
              minute: map['endTimeMinute'] as int,
            )
          : null,
      category: EventCategory.values[map['category'] as int],
      isCompleted: map['isCompleted'] as bool? ?? false,
      hasReminder: map['hasReminder'] as bool? ?? false,
    );
  }

  String toJson() => json.encode(toMap());
  factory EventModel.fromJson(String source) =>
      EventModel.fromMap(json.decode(source) as Map<String, dynamic>);

  String get formattedStartTime =>
      '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';

  String get formattedEndTime => endTime != null
      ? '${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}'
      : '';

  String get timeRange =>
      endTime != null ? '$formattedStartTime - $formattedEndTime' : formattedStartTime;
}

/// Templates rápidos para criação de eventos recorrentes
class EventTemplate {
  final String title;
  final String description;
  final TimeOfDay startTime;
  final TimeOfDay? endTime;
  final EventCategory category;
  final IconData icon;

  const EventTemplate({
    required this.title,
    required this.description,
    required this.startTime,
    this.endTime,
    required this.category,
    required this.icon,
  });

  static const List<EventTemplate> templates = [
    EventTemplate(
      title: 'Postar Stories',
      description: 'Stories do dia — conteúdo leve, bastidores, enquetes',
      startTime: TimeOfDay(hour: 8, minute: 0),
      endTime: TimeOfDay(hour: 9, minute: 0),
      category: EventCategory.story,
      icon: Icons.auto_stories_rounded,
    ),
    EventTemplate(
      title: 'Postar Feed',
      description: 'Post agendado — carrossel, reels ou imagem única',
      startTime: TimeOfDay(hour: 18, minute: 0),
      endTime: TimeOfDay(hour: 18, minute: 30),
      category: EventCategory.feed,
      icon: Icons.grid_on_rounded,
    ),
    EventTemplate(
      title: 'Gravação de Conteúdo',
      description: 'Gravação de reels, vídeos e conteúdo bruto',
      startTime: TimeOfDay(hour: 10, minute: 0),
      endTime: TimeOfDay(hour: 12, minute: 0),
      category: EventCategory.gravacao,
      icon: Icons.videocam_rounded,
    ),
    EventTemplate(
      title: 'Edição de Vídeos',
      description: 'Editar reels, cortes e montagem de conteúdo',
      startTime: TimeOfDay(hour: 14, minute: 0),
      endTime: TimeOfDay(hour: 16, minute: 0),
      category: EventCategory.edicao,
      icon: Icons.movie_edit,
    ),
    EventTemplate(
      title: 'Planejamento Semanal',
      description: 'Definir pautas, calendário e estratégia da semana',
      startTime: TimeOfDay(hour: 9, minute: 0),
      endTime: TimeOfDay(hour: 10, minute: 0),
      category: EventCategory.planejamento,
      icon: Icons.event_note_rounded,
    ),
    EventTemplate(
      title: 'Reunião com Cliente',
      description: 'Alinhamento, briefing ou aprovação de conteúdo',
      startTime: TimeOfDay(hour: 15, minute: 0),
      endTime: TimeOfDay(hour: 16, minute: 0),
      category: EventCategory.cliente,
      icon: Icons.person_rounded,
    ),
  ];
}
