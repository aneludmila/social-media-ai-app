import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/event_model.dart';
import '../providers/event_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/add_event_sheet.dart';
import '../widgets/event_card.dart';
import '../widgets/event_detail_sheet.dart';
import '../widgets/progress_ring.dart';
import '../widgets/quick_add_bar.dart';
import '../widgets/week_summary.dart';
import '../widgets/ai_suggestions_modal.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  late AnimationController _fabController;
  late Animation<double> _fabAnimation;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabController,
      curve: Curves.elasticOut,
    );
    _fabController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<EventProvider>(context, listen: false);
      provider.loadEvents().then((_) {
        provider.addSampleData();
      });
    });
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  void _showAddEventSheet({EventModel? editEvent}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: Provider.of<EventProvider>(context, listen: false),
        child: AddEventSheet(editEvent: editEvent),
      ),
    );
  }

  void _showEventDetail(EventModel event) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => EventDetailSheet(
        event: event,
        onEdit: () => _showAddEventSheet(editEvent: event),
        onDelete: () {
          Provider.of<EventProvider>(context, listen: false)
              .deleteEvent(event.id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Evento excluído'),
              action: SnackBarAction(
                label: 'OK',
                textColor: AppTheme.primary,
                onPressed: () {},
              ),
            ),
          );
        },
        onToggleComplete: () {
          Provider.of<EventProvider>(context, listen: false)
              .toggleComplete(event.id);
        },
      ),
    );
  }

  String _getDayName(int weekday) {
    const names = ['', 'SEG', 'TER', 'QUA', 'QUI', 'SEX', 'SÁB', 'DOM'];
    return names[weekday];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<EventProvider>(
          builder: (context, provider, _) {
            final events = provider.selectedDayEvents;
            final now = DateTime.now();
            final isToday = provider.selectedDay.year == now.year &&
                provider.selectedDay.month == now.month &&
                provider.selectedDay.day == now.day;

            return CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getGreeting(),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Row(
                                children: [
                                  Icon(
                                    Icons.campaign_rounded,
                                    color: AppTheme.primary,
                                    size: 26,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Social Media',
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (!isToday)
                          GestureDetector(
                            onTap: () {
                              provider.setSelectedDay(DateTime.now());
                              provider.setFocusedDay(DateTime.now());
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                gradient: AppTheme.primaryGradient,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.today_rounded,
                                      color: Colors.white, size: 16),
                                  SizedBox(width: 6),
                                  Text(
                                    'Hoje',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        const SizedBox(width: 8),
                        // AI Suggestions button
                        GestureDetector(
                          onTap: () {
                            AiSuggestionsModal.show(
                                context, provider.selectedDay);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF8B5CF6),
                                  Color(0xFFEC4899)
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(
                                  AppTheme.radiusMedium),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xFF8B5CF6).withAlpha(40),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.auto_awesome_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _calendarFormat =
                                  _calendarFormat == CalendarFormat.week
                                      ? CalendarFormat.month
                                      : CalendarFormat.week;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceLight,
                              borderRadius: BorderRadius.circular(
                                  AppTheme.radiusMedium),
                            ),
                            child: Icon(
                              _calendarFormat == CalendarFormat.week
                                  ? Icons.calendar_month_rounded
                                  : Icons.view_week_rounded,
                              color: AppTheme.textSecondary,
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // Calendar
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusXLarge),
                      border: Border.all(
                        color: AppTheme.surfaceLighter.withAlpha(60),
                        width: 1,
                      ),
                    ),
                    child: TableCalendar(
                      firstDay: DateTime(2020),
                      lastDay: DateTime(2030),
                      focusedDay: provider.focusedDay,
                      selectedDayPredicate: (day) =>
                          isSameDay(provider.selectedDay, day),
                      calendarFormat: _calendarFormat,
                      startingDayOfWeek: StartingDayOfWeek.monday,
                      locale: 'pt_BR',
                      eventLoader: (day) => provider.getEventsForDay(day),
                      onDaySelected: (selectedDay, focusedDay) {
                        provider.setSelectedDay(selectedDay);
                        provider.setFocusedDay(focusedDay);
                      },
                      onFormatChanged: (format) {
                        setState(() {
                          _calendarFormat = format;
                        });
                      },
                      onPageChanged: (focusedDay) {
                        provider.setFocusedDay(focusedDay);
                      },
                      headerStyle: HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        leftChevronIcon: const Icon(
                          Icons.chevron_left_rounded,
                          color: AppTheme.textSecondary,
                        ),
                        rightChevronIcon: const Icon(
                          Icons.chevron_right_rounded,
                          color: AppTheme.textSecondary,
                        ),
                        titleTextFormatter: (date, locale) =>
                            DateFormat.yMMMM(locale).format(date),
                        titleTextStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                        headerPadding:
                            const EdgeInsets.symmetric(vertical: 12),
                      ),
                      daysOfWeekStyle: const DaysOfWeekStyle(
                        weekdayStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textHint,
                        ),
                        weekendStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textHint,
                        ),
                      ),
                      calendarStyle: CalendarStyle(
                        outsideDaysVisible: false,
                        weekendTextStyle: const TextStyle(
                          color: AppTheme.textSecondary,
                        ),
                        defaultTextStyle: const TextStyle(
                          color: AppTheme.textPrimary,
                        ),
                        todayTextStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        selectedTextStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        todayDecoration: BoxDecoration(
                          color: AppTheme.primary.withAlpha(60),
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: const BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          shape: BoxShape.circle,
                        ),
                        markerDecoration: const BoxDecoration(
                          color: AppTheme.accent1,
                          shape: BoxShape.circle,
                        ),
                        markersMaxCount: 3,
                        markerSize: 5,
                        markerMargin:
                            const EdgeInsets.symmetric(horizontal: 1),
                        cellMargin: const EdgeInsets.all(4),
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // Week Summary
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: WeekSummary(
                      stats: provider.weekCategoryStats,
                      completed: provider.weekCompletedCount,
                      total: provider.weekTotalCount,
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // Quick Add Templates
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Adicionar Rápido',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const QuickAddBar(),
                    ],
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 8)),

                // Progress
                if (events.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ProgressRing(
                        progress: provider.todayProgress,
                        completed: provider.completedTodayCount,
                        total: provider.totalTodayCount,
                      ),
                    ),
                  ),

                // Section header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 20,
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          isToday
                              ? 'Hoje — ${_getDayName(now.weekday)}'
                              : DateFormat('dd MMM — EEEE', 'pt_BR')
                                  .format(provider.selectedDay),
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withAlpha(30),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${events.length} tarefas',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Events list
                if (events.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceLight.withAlpha(80),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.event_available_rounded,
                              size: 48,
                              color: AppTheme.textHint,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Dia livre! 🎉',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Toque em + ou use os templates acima',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textHint,
                            ),
                          ),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final event = events[index];
                          return EventCard(
                            event: event,
                            onTap: () => _showEventDetail(event),
                            onToggleComplete: () =>
                                provider.toggleComplete(event.id),
                            onDelete: () {
                              provider.deleteEvent(event.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Evento excluído'),
                                ),
                              );
                            },
                          );
                        },
                        childCount: events.length,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppTheme.primaryShadow,
          ),
          child: FloatingActionButton(
            onPressed: () => _showAddEventSheet(),
            backgroundColor: Colors.transparent,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.add_rounded, size: 28),
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bom dia ☀️';
    if (hour < 18) return 'Boa tarde 🌤️';
    return 'Boa noite 🌙';
  }
}
