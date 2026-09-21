import 'package:flutter/material.dart';

import '../../models/app_models.dart';
import '../../services/storage_service.dart';
import '../focus/focus_screen.dart';
import '../review/smart_review_screen.dart';
import '../tasks/tasks_screen.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  List<TaskItem> _tasks = [];
  List<FocusSession> _focusSessions = [];
  List<KnowledgeItem> _knowledge = [];
  List<DecisionEntry> _decisions = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _tasks = StorageService.getTasks();
    _focusSessions = StorageService.getFocusSessions();
    _knowledge = StorageService.getKnowledge();
    _decisions = StorageService.getDecisions();
  }

  bool _isSameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  bool _isOverdue(TaskItem task) {
    if (task.completed || task.dueDate == null) {
      return false;
    }

    final today = DateTime.now();

    final currentDay = DateTime(
      today.year,
      today.month,
      today.day,
    );

    final dueDay = DateTime(
      task.dueDate!.year,
      task.dueDate!.month,
      task.dueDate!.day,
    );

    return dueDay.isBefore(currentDay);
  }

  bool _needsReviewKnowledge(KnowledgeItem item) {
    return item.reviewDate != null &&
        !item.reviewDate!.isAfter(DateTime.now());
  }

  bool _needsReviewDecision(DecisionEntry item) {
    return item.reviewDate != null &&
        !item.reviewDate!.isAfter(DateTime.now()) &&
        item.result.trim().isEmpty;
  }

  List<TaskItem> get _todayTasks {
    final result = _tasks.where((task) {
      if (task.completed) return false;

      if (task.dueDate != null &&
          _isSameDay(task.dueDate!, DateTime.now())) {
        return true;
      }

      return task.priority == 'High';
    }).toList();

    result.sort((a, b) {
      if (_isOverdue(a) && !_isOverdue(b)) return -1;
      if (!_isOverdue(a) && _isOverdue(b)) return 1;

      const order = {
        'High': 0,
        'Medium': 1,
        'Low': 2,
      };

      return (order[a.priority] ?? 1)
          .compareTo(order[b.priority] ?? 1);
    });

    return result;
  }

  List<KnowledgeItem> get _reviewKnowledge {
    return _knowledge
        .where(_needsReviewKnowledge)
        .where((item) => item.action.trim().isNotEmpty)
        .toList();
  }

  List<DecisionEntry> get _reviewDecisions {
    return _decisions.where(_needsReviewDecision).toList();
  }

  int get _reviewCount {
    return _reviewKnowledge.length + _reviewDecisions.length;
  }

  int get _todayFocusMinutes {
    return _focusSessions
        .where(
          (session) => _isSameDay(
            session.completedAt,
            DateTime.now(),
          ),
        )
        .fold(
          0,
          (sum, session) => sum + session.durationMinutes,
        );
  }

  Future<void> _toggleTask(TaskItem task) async {
    final updated = TaskItem(
      id: task.id,
      title: task.title,
      description: task.description,
      priority: task.priority,
      completed: !task.completed,
      createdAt: task.createdAt,
      dueDate: task.dueDate,
    );

    await StorageService.saveTask(updated);

    setState(_loadData);
  }

  void _openTasks() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const TasksScreen(),
      ),
    ).then((_) {
      setState(_loadData);
    });
  }

  void _openFocus() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const FocusScreen(),
      ),
    ).then((_) {
      setState(_loadData);
    });
  }

  void _openReview() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SmartReviewScreen(),
      ),
    ).then((_) {
      setState(_loadData);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Today',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          Text(
            _weekday(today.weekday),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${today.day.toString().padLeft(2, '0')}/'
            '${today.month.toString().padLeft(2, '0')}/'
            '${today.year}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),

          _summaryCard(context),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _quickCard(
                  context,
                  Icons.center_focus_strong_rounded,
                  'Focus',
                  '$_todayFocusMinutes min',
                  _openFocus,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _quickCard(
                  context,
                  Icons.rate_review_outlined,
                  'Review',
                  '$_reviewCount items',
                  _openReview,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: Text(
                  'Today\'s Priorities',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              TextButton(
                onPressed: _openTasks,
                child: const Text('All Tasks'),
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (_todayTasks.isEmpty)
            _emptyCard(
              context,
              Icons.check_circle_outline_rounded,
              'No urgent priorities',
              'Your task list is clear for now.',
            )
          else
            ..._todayTasks.map(
              (task) => _taskCard(context, task),
            ),

          const SizedBox(height: 24),

          _reviewBanner(context),
        ],
      ),
    );
  }

  Widget _summaryCard(BuildContext context) {
    final theme = Theme.of(context);
    final pending = _tasks.where((task) => !task.completed).length;
    final overdue = _tasks.where(_isOverdue).length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: _summaryValue(
              context,
              'Pending',
              '$pending',
            ),
          ),
          Expanded(
            child: _summaryValue(
              context,
              'Overdue',
              '$overdue',
            ),
          ),
          Expanded(
            child: _summaryValue(
              context,
              'Reviews',
              '$_reviewCount',
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryValue(
    BuildContext context,
    String label,
    String value,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _quickCard(
    BuildContext context,
    IconData icon,
    String title,
    String value,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.colorScheme.outlineVariant
                .withValues(alpha: 0.65),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _taskCard(
    BuildContext context,
    TaskItem task,
  ) {
    final overdue = _isOverdue(task);
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: overdue
              ? theme.colorScheme.error.withValues(alpha: 0.35)
              : theme.colorScheme.outlineVariant
                  .withValues(alpha: 0.6),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 4,
        ),
        leading: Checkbox(
          value: task.completed,
          onChanged: (_) => _toggleTask(task),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            decoration:
                task.completed ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text(
          overdue ? 'Overdue • ${task.priority}' : task.priority,
          style: TextStyle(
            color: overdue
                ? theme.colorScheme.error
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _reviewBanner(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: _openReview,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            Icon(
              Icons.auto_awesome_outlined,
              color: theme.colorScheme.onSecondaryContainer,
              size: 30,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _reviewCount == 0
                        ? 'You are caught up'
                        : 'Smart Review',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _reviewCount == 0
                        ? 'Nothing currently needs your review.'
                        : '$_reviewCount item(s) need your attention.',
                    style: TextStyle(
                      color: theme.colorScheme.onSecondaryContainer
                          .withValues(alpha: 0.78),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: theme.colorScheme.onSecondaryContainer,
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _weekday(int weekday) {
    const names = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    return names[weekday - 1];
  }
}
