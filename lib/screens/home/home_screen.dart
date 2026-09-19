import 'package:flutter/material.dart';

import '../knowledge/knowledge_screen.dart';
import '../reflection/reflection_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openKnowledge(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const KnowledgeScreen(),
      ),
    );
  }

  void _openReflection(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ReflectionScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Shartendu OS',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGreeting(),
              const SizedBox(height: 24),

              _sectionTitle('Today'),
              const SizedBox(height: 12),

              _dashboardCard(
                context: context,
                icon: Icons.task_alt_rounded,
                title: "Today's Priorities",
                subtitle: 'Focus on what actually matters today.',
                onTap: () {},
              ),

              const SizedBox(height: 12),

              _dashboardCard(
                context: context,
                icon: Icons.timer_outlined,
                title: 'Focus',
                subtitle: 'One important thing at a time.',
                onTap: () {},
              ),

              const SizedBox(height: 28),

              _sectionTitle('Personal Growth'),
              const SizedBox(height: 12),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _smallCard(
                      context: context,
                      icon: Icons.auto_awesome_outlined,
                      title: 'Knowledge',
                      subtitle: 'Learn → Apply',
                      onTap: () => _openKnowledge(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _smallCard(
                      context: context,
                      icon: Icons.psychology_outlined,
                      title: 'Reflection',
                      subtitle: 'Think → Improve',
                      onTap: () => _openReflection(context),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              _dashboardCard(
                context: context,
                icon: Icons.explore_outlined,
                title: 'Decision Journal',
                subtitle: 'Understand your decisions and their results.',
                onTap: () {},
              ),

              const SizedBox(height: 28),

              _sectionTitle('Quick Capture'),
              const SizedBox(height: 12),

              _quickCaptureCard(
                context: context,
                onKnowledgeTap: () => _openKnowledge(context),
                onReflectionTap: () => _openReflection(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGreeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Good Morning, Shartendu',
          style: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.w700,
            height: 1.15,
            letterSpacing: -0.7,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          'आज क्या महत्वपूर्ण है?',
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey.shade600,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      ),
    );
  }

  Widget _dashboardCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(
          color: Colors.grey.shade200,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(17),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  icon,
                  color: colorScheme.primary,
                  size: 23,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.35,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 15,
                color: Colors.grey.shade500,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _smallCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(
          color: Colors.grey.shade200,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: colorScheme.primary,
                  size: 22,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.35,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _quickCaptureCard({
    required BuildContext context,
    required VoidCallback onKnowledgeTap,
    required VoidCallback onReflectionTap,
  }) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(
          color: Colors.grey.shade200,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Expanded(
              child: _quickAction(
                context: context,
                icon: Icons.add_task_rounded,
                label: 'Task',
                onTap: () {},
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _quickAction(
                context: context,
                icon: Icons.lightbulb_outline_rounded,
                label: 'Idea',
                onTap: () {},
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _quickAction(
                context: context,
                icon: Icons.auto_awesome_outlined,
                label: 'Knowledge',
                onTap: onKnowledgeTap,
                highlight: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickAction({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool highlight = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: highlight
          ? colorScheme.primary.withValues(alpha: 0.07)
          : Colors.grey.shade50,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 14,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 22,
                color: highlight
                    ? colorScheme.primary
                    : Colors.grey.shade700,
              ),
              const SizedBox(height: 7),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: highlight
                      ? colorScheme.primary
                      : Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
