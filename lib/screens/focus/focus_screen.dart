import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/app_models.dart';
import '../../services/storage_service.dart';

class FocusScreen extends StatefulWidget {
  const FocusScreen({super.key});

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> {
  Timer? _timer;

  int _selectedMinutes = 25;
  int _remainingSeconds = 25 * 60;

  bool _isRunning = false;
  bool _hasStarted = false;

  DateTime? _startedAt;

  List<FocusSession> _sessions = [];

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _loadSessions() {
    _sessions = StorageService.getFocusSessions();
  }

  void _selectDuration(int minutes) {
    if (_isRunning) return;

    setState(() {
      _selectedMinutes = minutes;
      _remainingSeconds = minutes * 60;
      _hasStarted = false;
      _startedAt = null;
    });
  }

  void _startTimer() {
    if (_isRunning) return;

    if (!_hasStarted) {
      _startedAt = DateTime.now();
      _hasStarted = true;
    }

    setState(() {
      _isRunning = true;
    });

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (_remainingSeconds <= 1) {
          _timer?.cancel();

          setState(() {
            _remainingSeconds = 0;
            _isRunning = false;
          });

          _completeSession();
          return;
        }

        setState(() {
          _remainingSeconds--;
        });
      },
    );
  }

  void _pauseTimer() {
    _timer?.cancel();

    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();

    setState(() {
      _isRunning = false;
      _hasStarted = false;
      _startedAt = null;
      _remainingSeconds = _selectedMinutes * 60;
    });
  }

  Future<void> _completeSession() async {
    final startedAt = _startedAt;

    if (startedAt == null) return;

    final session = FocusSession(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      durationMinutes: _selectedMinutes,
      startedAt: startedAt,
      completedAt: DateTime.now(),
    );

    await StorageService.saveFocusSession(session);

    if (!mounted) return;

    setState(() {
      _sessions = StorageService.getFocusSessions();
      _hasStarted = false;
      _startedAt = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Focus session completed.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remaining = seconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${remaining.toString().padLeft(2, '0')}';
  }

  double get _progress {
    final totalSeconds = _selectedMinutes * 60;

    if (totalSeconds == 0) return 0;

    return 1 - (_remainingSeconds / totalSeconds);
  }

  int get _totalFocusMinutes {
    return _sessions.fold(
      0,
      (sum, session) => sum + session.durationMinutes,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Focus'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            _buildIntroCard(theme),
            const SizedBox(height: 20),
            _buildTimerCard(theme),
            const SizedBox(height: 20),
            _buildDurationSection(theme),
            const SizedBox(height: 20),
            _buildStatsCard(theme),
            const SizedBox(height: 20),
            _buildRecentSessions(theme, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: theme.colorScheme.onPrimaryContainer
                  .withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.center_focus_strong_rounded,
              color: theme.colorScheme.onPrimaryContainer,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Deep Focus',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'One session. One priority. No distractions.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer
                        .withValues(alpha: 0.78),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerCard(ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.65),
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            offset: const Offset(0, 8),
            color: colorScheme.shadow.withValues(alpha: 0.06),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            width: 220,
            height: 220,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 210,
                  height: 210,
                  child: CircularProgressIndicator(
                    value: _progress,
                    strokeWidth: 10,
                    backgroundColor:
                        colorScheme.surfaceContainerHighest,
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTime(_remainingSeconds),
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _isRunning
                          ? 'FOCUSING'
                          : _hasStarted
                              ? 'PAUSED'
                              : 'READY',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _resetTimer,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Reset'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: _isRunning ? _pauseTimer : _startTimer,
                  icon: Icon(
                    _isRunning
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                  ),
                  label: Text(
                    _isRunning
                        ? 'Pause'
                        : _hasStarted
                            ? 'Resume'
                            : 'Start Focus',
                  ),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDurationSection(ThemeData theme) {
    final presets = [25, 45, 60];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Session Length',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            ...presets.map(
              (minutes) => ChoiceChip(
                label: Text('$minutes min'),
                selected: _selectedMinutes == minutes,
                onSelected: (_) => _selectDuration(minutes),
              ),
            ),
            ActionChip(
              avatar: const Icon(Icons.tune_rounded, size: 18),
              label: const Text('Custom'),
              onPressed: _showCustomDuration,
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _showCustomDuration() async {
    final controller = TextEditingController(
      text: _selectedMinutes.toString(),
    );

    final result = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Custom Focus'),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Minutes',
              hintText: 'Enter 1–180 minutes',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final minutes = int.tryParse(controller.text.trim());

                if (minutes == null || minutes < 1 || minutes > 180) {
                  return;
                }

                Navigator.pop(context, minutes);
              },
              child: const Text('Set'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (result == null || !mounted) return;

    _selectDuration(result);
  }

  Widget _buildStatsCard(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            theme,
            icon: Icons.check_circle_outline_rounded,
            value: '${_sessions.length}',
            label: 'Sessions',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            theme,
            icon: Icons.schedule_rounded,
            value: '$_totalFocusMinutes',
            label: 'Minutes',
          ),
        ),
      ],
    );
  }

  Widget _statCard(
    ThemeData theme, {
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
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
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSessions(
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    if (_sessions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.6),
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.hourglass_empty_rounded,
              size: 34,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 10),
            Text(
              'No completed sessions yet',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Complete your first focus session to start building your record.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    final recent = _sessions.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Sessions',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        ...recent.map(
          (session) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.55),
              ),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor:
                    colorScheme.primaryContainer,
                child: Icon(
                  Icons.check_rounded,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              title: Text(
                '${session.durationMinutes} minute focus',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
              subtitle: Text(
                _formatDateTime(session.completedAt),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final local = dateTime.toLocal();

    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour >= 12 ? 'PM' : 'AM';

    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/'
        '${local.year} • $hour:$minute $period';
  }
}
