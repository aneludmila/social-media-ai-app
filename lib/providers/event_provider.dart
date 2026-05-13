import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/event_model.dart';

class EventProvider extends ChangeNotifier {
  List<EventModel> _events = [];
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  static const String _storageKey = 'agenda_events_v2';
  final _uuid = const Uuid();

  List<EventModel> get events => _events;
  DateTime get selectedDay => _selectedDay;
  DateTime get focusedDay => _focusedDay;

  List<EventModel> get selectedDayEvents {
    return _events.where((event) {
      return event.date.year == _selectedDay.year &&
          event.date.month == _selectedDay.month &&
          event.date.day == _selectedDay.day;
    }).toList()
      ..sort((a, b) {
        final aMinutes = a.startTime.hour * 60 + a.startTime.minute;
        final bMinutes = b.startTime.hour * 60 + b.startTime.minute;
        return aMinutes.compareTo(bMinutes);
      });
  }

  List<EventModel> getEventsForDay(DateTime day) {
    return _events.where((event) {
      return event.date.year == day.year &&
          event.date.month == day.month &&
          event.date.day == day.day;
    }).toList();
  }

  int get completedTodayCount {
    return selectedDayEvents.where((e) => e.isCompleted).length;
  }

  int get totalTodayCount => selectedDayEvents.length;

  double get todayProgress {
    if (totalTodayCount == 0) return 0;
    return completedTodayCount / totalTodayCount;
  }

  /// Stats for the week summary
  Map<EventCategory, int> get weekCategoryStats {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    final weekEvents = _events.where((e) {
      final d = e.date;
      return d.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
          d.isBefore(endOfWeek.add(const Duration(days: 1)));
    });

    final Map<EventCategory, int> stats = {};
    for (final event in weekEvents) {
      stats[event.category] = (stats[event.category] ?? 0) + 1;
    }
    return stats;
  }

  int get weekCompletedCount {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return _events.where((e) {
      final d = e.date;
      return e.isCompleted &&
          d.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
          d.isBefore(endOfWeek.add(const Duration(days: 1)));
    }).length;
  }

  int get weekTotalCount {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return _events.where((e) {
      final d = e.date;
      return d.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
          d.isBefore(endOfWeek.add(const Duration(days: 1)));
    }).length;
  }

  // === CRUD Operations ===

  Future<void> loadEvents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? data = prefs.getString(_storageKey);
      if (data != null) {
        final List<dynamic> jsonList = json.decode(data);
        _events = jsonList
            .map((e) => EventModel.fromMap(e as Map<String, dynamic>))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading events: $e');
    }
  }

  Future<void> _saveEvents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String data = json.encode(_events.map((e) => e.toMap()).toList());
      await prefs.setString(_storageKey, data);
    } catch (e) {
      debugPrint('Error saving events: $e');
    }
  }

  Future<void> addEvent({
    required String title,
    String description = '',
    required DateTime date,
    required TimeOfDay startTime,
    TimeOfDay? endTime,
    EventCategory category = EventCategory.outro,
    bool hasReminder = false,
  }) async {
    final event = EventModel(
      id: _uuid.v4(),
      title: title,
      description: description,
      date: DateTime(date.year, date.month, date.day),
      startTime: startTime,
      endTime: endTime,
      category: category,
      hasReminder: hasReminder,
    );
    _events.add(event);
    notifyListeners();
    await _saveEvents();
  }

  Future<void> addFromTemplate(EventTemplate template, DateTime date) async {
    final event = EventModel(
      id: _uuid.v4(),
      title: template.title,
      description: template.description,
      date: DateTime(date.year, date.month, date.day),
      startTime: template.startTime,
      endTime: template.endTime,
      category: template.category,
      hasReminder: true,
    );
    _events.add(event);
    notifyListeners();
    await _saveEvents();
  }

  Future<void> updateEvent(EventModel updatedEvent) async {
    final index = _events.indexWhere((e) => e.id == updatedEvent.id);
    if (index != -1) {
      _events[index] = updatedEvent;
      notifyListeners();
      await _saveEvents();
    }
  }

  Future<void> toggleComplete(String eventId) async {
    final index = _events.indexWhere((e) => e.id == eventId);
    if (index != -1) {
      _events[index] = _events[index].copyWith(
        isCompleted: !_events[index].isCompleted,
      );
      notifyListeners();
      await _saveEvents();
    }
  }

  Future<void> deleteEvent(String eventId) async {
    _events.removeWhere((e) => e.id == eventId);
    notifyListeners();
    await _saveEvents();
  }

  void setSelectedDay(DateTime day) {
    _selectedDay = day;
    notifyListeners();
  }

  void setFocusedDay(DateTime day) {
    _focusedDay = day;
    notifyListeners();
  }

  // === Sample Data — Rotina Social Media ===
  Future<void> addSampleData() async {
    if (_events.isNotEmpty) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekday = now.weekday; // 1=seg, 7=dom

    // Gerar semana inteira de eventos baseados na rotina
    for (int i = 0; i < 7; i++) {
      final day = today.subtract(Duration(days: weekday - 1 - i));
      final dow = day.weekday;

      // TODOS OS DIAS: Story de manhã
      _events.add(EventModel(
        id: _uuid.v4(),
        title: 'Postar Stories',
        description: _getStoryDescription(dow),
        date: day,
        startTime: const TimeOfDay(hour: 8, minute: 0),
        endTime: const TimeOfDay(hour: 9, minute: 0),
        category: EventCategory.story,
        hasReminder: true,
        isCompleted: day.isBefore(today),
      ));

      // TODOS OS DIAS: Post Feed às 18h
      _events.add(EventModel(
        id: _uuid.v4(),
        title: 'Postar Feed',
        description: _getFeedDescription(dow),
        date: day,
        startTime: const TimeOfDay(hour: 18, minute: 0),
        endTime: const TimeOfDay(hour: 18, minute: 30),
        category: EventCategory.feed,
        hasReminder: true,
        isCompleted: day.isBefore(today),
      ));

      // SEG, QUA, SEX: Gravação de conteúdo
      if (dow == 1 || dow == 3 || dow == 5) {
        _events.add(EventModel(
          id: _uuid.v4(),
          title: 'Gravação de Conteúdo',
          description: _getGravacaoDescription(dow),
          date: day,
          startTime: const TimeOfDay(hour: 10, minute: 0),
          endTime: const TimeOfDay(hour: 12, minute: 0),
          category: EventCategory.gravacao,
          hasReminder: true,
          isCompleted: day.isBefore(today),
        ));
      }

      // TER, QUI: Edição de vídeos
      if (dow == 2 || dow == 4) {
        _events.add(EventModel(
          id: _uuid.v4(),
          title: 'Edição de Vídeos',
          description: 'Editar reels e conteúdo gravado',
          date: day,
          startTime: const TimeOfDay(hour: 14, minute: 0),
          endTime: const TimeOfDay(hour: 16, minute: 0),
          category: EventCategory.edicao,
          isCompleted: day.isBefore(today),
        ));
      }

      // SEG: Planejamento semanal
      if (dow == 1) {
        _events.add(EventModel(
          id: _uuid.v4(),
          title: 'Planejamento Semanal',
          description: 'Definir pautas, calendário e estratégia da semana',
          date: day,
          startTime: const TimeOfDay(hour: 9, minute: 0),
          endTime: const TimeOfDay(hour: 10, minute: 0),
          category: EventCategory.planejamento,
          hasReminder: true,
          isCompleted: day.isBefore(today),
        ));
      }

      // QUA: Reunião com cliente
      if (dow == 3) {
        _events.add(EventModel(
          id: _uuid.v4(),
          title: 'Reunião com Cliente',
          description: 'Alinhamento e aprovação de conteúdo',
          date: day,
          startTime: const TimeOfDay(hour: 15, minute: 0),
          endTime: const TimeOfDay(hour: 16, minute: 0),
          category: EventCategory.cliente,
          isCompleted: day.isBefore(today),
        ));
      }
    }

    notifyListeners();
    await _saveEvents();
  }

  String _getStoryDescription(int weekday) {
    switch (weekday) {
      case 1:
        return 'Bom dia + rotina da semana';
      case 2:
        return 'Bastidores do trabalho';
      case 3:
        return 'Enquete / Interação com público';
      case 4:
        return 'Dica rápida sobre o nicho';
      case 5:
        return 'Prova social / Resultado de cliente';
      case 6:
        return 'Conteúdo leve + caixinha de perguntas';
      case 7:
        return 'Dia livre — conteúdo pessoal';
      default:
        return 'Stories do dia';
    }
  }

  String _getFeedDescription(int weekday) {
    switch (weekday) {
      case 1:
        return 'Post motivacional / início de semana';
      case 2:
        return 'Carrossel educativo';
      case 3:
        return 'Reels de engajamento';
      case 4:
        return 'Post de autoridade / dica';
      case 5:
        return 'Reels de venda / CTA';
      case 6:
        return 'Post de prova social / depoimento';
      case 7:
        return 'Conteúdo leve ou repost';
      default:
        return 'Post do dia';
    }
  }

  String _getGravacaoDescription(int weekday) {
    switch (weekday) {
      case 1:
        return 'Gravar reels da semana + conteúdo educativo';
      case 3:
        return 'Gravar conteúdo de engajamento + trends';
      case 5:
        return 'Gravar conteúdo de venda + depoimentos';
      default:
        return 'Gravação geral';
    }
  }
}
