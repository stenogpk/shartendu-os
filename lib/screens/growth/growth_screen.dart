import 'package:flutter/material.dart';

import '../../models/app_models.dart';
import '../../services/storage_service.dart';

class GrowthScreen extends StatelessWidget {
  const GrowthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final knowledge = StorageService.getKnowledge();
    final reflections = StorageService.getReflections();
    final decisions = StorageService.getDecisions();
    final tasks = StorageService.getTasks();
    final focus = StorageService.getFocusSessions();
    final ideas = StorageService.getIdeas();

    final completedTasks =
        tasks.where((task) => task.completed).length;

    final actionedKnowledge =
        knowledge.where((item) => item.actionCompleted).length;

    final actionedIdeas =
        ideas.where((idea) => idea.convertedToAction).length;

    final focusMinutes = focus.fold<int>(
      0,
      (sum, session) => sum + session.durationMinutes,
    );

    final actionRate = knowledge.isEmpty
        ? 0
        : ((actionedKnowledge / knowledge.length) * 100).round();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Growth Dashboard',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          _heroCard(context),
          const SizedBox(height: 20),
          Text(
            'Your Activity',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.45,
            children: [
              _statCard(
                context,
                Icons.menu_book_outlined,
                '${knowledge.length}',
                'Knowledge',
              ),
              _statCard(
                context,
                Icons.task_alt_rounded,
                '$completedTasks',
                'Tasks Done',
              ),
              _statCard(
                context,
                Icons.self_improvement_outlined,
                '${reflections.length}',
                'Reflections',
              ),
              _statCard(
                context,
                Icons.account_balance_outlined,
                '${decisions.length}',
                'Decisions',
              ),
              _statCard(
                context,
                Icons.center_focus_strong_rounded,
                '$focusMinutes',
                'Focus Minutes',
              ),
              _statCard(
                context,
                Icons.lightbulb_outline_rounded,
                '${ideas.length}',
                'Ideas',
              ),
            ],
          ),
          const SizedBox(height: 24),
          _actionSection(
            context,
            title: 'Knowledge → Action',
            subtitle:
                'How much of your saved knowledge has moved toward action?',
            value: '$actionRate%',
            progress: actionRate / 100,
            icon: Icons.auto_awesome_outlined,
          ),
          const SizedBox(height: 16),
          _actionSection(
            context,
            title: 'Ideas → Action',
            subtitle:
                'Ideas marked as converted into something actionable.',
            value: ideas.isEmpty
                ? '0%'
                : '${((actionedIdeas / ideas.length) * 100).round()}%',
            progress:
                ideas.isEmpty ? 0 : actionedIdeas / ideas.length,
            icon: Icons.lightbulb_outline_rounded,
          ),
          const SizedBox(height: 24),
          _growthPrinciple(context),
        ],
      ),
    );
  }

  Widget _heroCard(BuildContext context) {
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
            Icons.insights_rounded,
            size: 42,
            color: theme.colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Growth is not just information.',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'It is what you repeatedly turn into action and review.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer
                        .withValues(alpha: 0.8),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(
    BuildContext context,
    IconData icon,
    String value,
    String label,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.65),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: theme.colorScheme.primary,
          ),
          const Spacer(),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionSection(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String value,
    required double progress,
    required IconData icon,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: Column(
        children: [
          Row(
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
                ),
              ),
              Text(
                value,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress.clamp(0, 1),
              minHeight: 9,
            ),
          ),
        ],
      ),
    );
  }

  Widget _growthPrinciple(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.65),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'The Shartendu OS Loop',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'FACT  →  INSIGHT  →  BELIEF  →  ACTION  →  RESULT',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'The dashboard measures activity, but the real goal is better decisions and better behaviour.',
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
