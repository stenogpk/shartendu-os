import 'package:flutter/material.dart';

import '../../models/app_models.dart';
import '../../services/storage_service.dart';

class SmartReviewScreen extends StatefulWidget {
  const SmartReviewScreen({super.key});

  @override
  State<SmartReviewScreen> createState() => _SmartReviewScreenState();
}

class _SmartReviewScreenState extends State<SmartReviewScreen> {
  List<KnowledgeItem> _knowledge = [];
  List<DecisionEntry> _decisions = [];
  List<TaskItem> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _knowledge = StorageService.getKnowledge();
    _decisions = StorageService.getDecisions();
    _tasks = StorageService.getTasks();
  }

  bool _needsKnowledgeReview(KnowledgeItem item) {
    return item.reviewDate != null &&
        !item.reviewDate!.isAfter(DateTime.now()) &&
        item.action.trim().isNotEmpty &&
        !item.actionCompleted;
  }

  bool _needsDecisionReview(DecisionEntry item) {
    return item.reviewDate != null &&
        !item.reviewDate!.isAfter(DateTime.now()) &&
        item.result.trim().isEmpty;
  }

  bool _isOverdue(TaskItem task) {
    if (task.completed || task.dueDate == null) {
      return false;
    }

    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final due = DateTime(
      task.dueDate!.year,
      task.dueDate!.month,
      task.dueDate!.day,
    );

    return due.isBefore(today);
  }

  List<KnowledgeItem> get _knowledgeReviews {
    return _knowledge.where(_needsKnowledgeReview).toList();
  }

  List<DecisionEntry> get _decisionReviews {
    return _decisions.where(_needsDecisionReview).toList();
  }

  List<TaskItem> get _overdueTasks {
    return _tasks.where(_isOverdue).toList();
  }

  int get _totalReviews {
    return _knowledgeReviews.length +
        _decisionReviews.length +
        _overdueTasks.length;
  }

  Future<void> _completeKnowledge(KnowledgeItem item) async {
    final updated = KnowledgeItem(
      id: item.id,
      title: item.title,
      learned: item.learned,
      category: item.category,
      source: item.source,
      insight: item.insight,
      action: item.action,
      result: item.result,
      actionCompleted: true,
      createdAt: item.createdAt,
      reviewDate: item.reviewDate,
    );

    await StorageService.saveKnowledge(updated);

    setState(_loadData);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Knowledge action marked complete.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _completeTask(TaskItem task) async {
    final updated = TaskItem(
      id: task.id,
      title: task.title,
      description: task.description,
      priority: task.priority,
      completed: true,
      createdAt: task.createdAt,
      dueDate: task.dueDate,
    );

    await StorageService.saveTask(updated);

    setState(_loadData);
  }

  Future<void> _addDecisionResult(DecisionEntry decision) async {
    final controller = TextEditingController(
      text: decision.result,
    );

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Decision Result'),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'What actually happened?',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final text = controller.text.trim();

                if (text.isEmpty) return;

                Navigator.pop(context, text);
              },
              child: const Text('Save Result'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (result == null || result.isEmpty) return;

    final updated = DecisionEntry(
      id: decision.id,
      question: decision.question,
      options: decision.options,
      chosen: decision.chosen,
      reasoning: decision.reasoning,
      prediction: decision.prediction,
      result: result,
      createdAt: decision.createdAt,
      reviewDate: decision.reviewDate,
    );

    await StorageService.saveDecision(updated);

    setState(_loadData);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Smart Review',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          _header(context),
          const SizedBox(height: 20),
          if (_totalReviews == 0)
            _emptyState(context)
          else ...[
            if (_knowledgeReviews.isNotEmpty) ...[
              _sectionTitle(
                context,
                'Knowledge Actions',
                'Turn learning into behaviour.',
              ),
              const SizedBox(height: 10),
              ..._knowledgeReviews.map(
                (item) => _knowledgeCard(context, item),
              ),
              const SizedBox(height: 22),
            ],
            if (_overdueTasks.isNotEmpty) ...[
              _sectionTitle(
                context,
                'Overdue Tasks',
                'Close old loops before adding more.',
              ),
              const SizedBox(height: 10),
              ..._overdueTasks.map(
                (task) => _taskCard(context, task),
              ),
              const SizedBox(height: 22),
            ],
            if (_decisionReviews.isNotEmpty) ...[
              _sectionTitle(
                context,
                'Decision Reviews',
                'Compare what you predicted with what happened.',
              ),
              const SizedBox(height: 10),
              ..._decisionReviews.map(
                (decision) => _decisionCard(context, decision),
              ),
            ],
          ],
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lightbulb_outline_rounded,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Review is where information becomes experience. Finish old loops before creating new ones.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Row(
        children: [
          Icon(
            Icons.auto_awesome_rounded,
            size: 38,
            color: theme.colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _totalReviews == 0
                      ? 'All clear'
                      : '$_totalReviews review item(s)',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Close loops. Learn from outcomes. Move forward.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer
                        .withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(
    BuildContext context,
    String title,
    String subtitle,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _knowledgeCard(
    BuildContext context,
    KnowledgeItem item,
  ) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant
              .withValues(alpha: 0.6),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.menu_book_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              item.action,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _completeKnowledge(item),
                icon: const Icon(Icons.check_rounded),
                label: const Text('Mark Action Done'),
              ),
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
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: theme.colorScheme.error.withValues(alpha: 0.25),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 4,
        ),
        leading: Icon(
          Icons.warning_amber_rounded,
          color: theme.colorScheme.error,
        ),
        title: Text(
          task.title,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: Text(
          'Priority: ${task.priority}',
        ),
        trailing: IconButton(
          tooltip: 'Complete',
          onPressed: () => _completeTask(task),
          icon: const Icon(Icons.check_circle_outline_rounded),
        ),
      ),
    );
  }

  Widget _decisionCard(
    BuildContext context,
    DecisionEntry decision,
  ) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant
              .withValues(alpha: 0.6),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              decision.question,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (decision.chosen.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Chosen: ${decision.chosen}',
                style: theme.textTheme.bodyMedium,
              ),
            ],
            if (decision.prediction.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                'Prediction: ${decision.prediction}',
                style: theme.textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _addDecisionResult(decision),
                icon: const Icon(Icons.rate_review_outlined),
                label: const Text('Add Actual Result'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Icon(
            Icons.check_circle_rounded,
            size: 58,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          const Text(
            'Nothing needs review',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You have no overdue tasks or pending review loops right now.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
