import 'package:flutter/material.dart';

import '../decision/decision_screen.dart';
import '../focus/focus_screen.dart';
import '../growth/growth_screen.dart';
import '../ideas/ideas_screen.dart';
import '../knowledge/knowledge_screen.dart';
import '../reflection/reflection_screen.dart';
import '../review/smart_review_screen.dart';
import '../settings/settings_screen.dart';
import '../tasks/tasks_screen.dart';
import '../today/today_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _open(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => screen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Shartendu OS',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Settings',
            onPressed: () {
              _open(context, const SettingsScreen());
            },
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            Text(
              'Good Morning, Shartendu',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Learn something useful. Take action. Review your day.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            _sectionTitle(
              context,
              'Today',
              'Your command center',
            ),
            const SizedBox(height: 12),

            _featureCard(
              context,
              Icons.today_rounded,
              'Today Dashboard',
              'Priorities, overdue work, focus and reviews.',
              () => _open(context, const TodayScreen()),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: _actionCard(
                    context,
                    Icons.flag_outlined,
                    'Priorities',
                    'Tasks',
                    () => _open(context, const TasksScreen()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _actionCard(
                    context,
                    Icons.center_focus_strong_rounded,
                    'Focus',
                    'Deep work',
                    () => _open(context, const FocusScreen()),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            _featureCard(
              context,
              Icons.auto_awesome_outlined,
              'Smart Review',
              'Close old loops and learn from outcomes.',
              () => _open(context, const SmartReviewScreen()),
            ),

            const SizedBox(height: 28),

            _sectionTitle(
              context,
              'Personal Growth',
              'Build awareness through practice',
            ),
            const SizedBox(height: 12),

            _featureCard(
              context,
              Icons.insights_rounded,
              'Growth Dashboard',
              'See your learning, action and progress.',
              () => _open(context, const GrowthScreen()),
            ),
            const SizedBox(height: 10),

            _featureCard(
              context,
              Icons.menu_book_outlined,
              'Knowledge Vault',
              'Capture knowledge and turn it into action.',
              () => _open(context, const KnowledgeScreen()),
            ),
            const SizedBox(height: 10),

            _featureCard(
              context,
              Icons.self_improvement_outlined,
              'Daily Reflection',
              'Understand your day and improve tomorrow.',
              () => _open(context, const ReflectionScreen()),
            ),
            const SizedBox(height: 10),

            _featureCard(
              context,
              Icons.account_balance_outlined,
              'Decision Journal',
              'Record decisions, reasoning and results.',
              () => _open(context, const DecisionScreen()),
            ),

            const SizedBox(height: 28),

            _sectionTitle(
              context,
              'Quick Capture',
              'Put the thought somewhere useful',
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _smallCard(
                    context,
                    Icons.check_circle_outline_rounded,
                    'Task',
                    () => _open(context, const TasksScreen()),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _smallCard(
                    context,
                    Icons.lightbulb_outline_rounded,
                    'Idea',
                    () => _open(context, const IdeasScreen()),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _smallCard(
                    context,
                    Icons.school_outlined,
                    'Knowledge',
                    () => _open(context, const KnowledgeScreen()),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.loop_rounded,
                    color: colors.onPrimaryContainer,
                    size: 28,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Growth Loop',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: colors.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Knowledge → Insight → Action → Result → Review',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.onPrimaryContainer
                                .withValues(alpha: 0.82),
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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

  Widget _featureCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.6),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                icon,
                color: colors.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              color: colors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        constraints: const BoxConstraints(
          minHeight: 110,
        ),
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.6),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: colors.primary,
              size: 26,
            ),
            const Spacer(),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _smallCard(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 8,
        ),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.6),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: colors.primary,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
