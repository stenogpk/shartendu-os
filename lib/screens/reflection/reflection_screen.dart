import 'package:flutter/material.dart';

import '../../models/app_models.dart';
import '../../services/storage_service.dart';

class ReflectionScreen extends StatefulWidget {
  const ReflectionScreen({super.key});

  @override
  State<ReflectionScreen> createState() => _ReflectionScreenState();
}

class _ReflectionScreenState extends State<ReflectionScreen> {
  List<ReflectionEntry> _entries = [];

  @override
  void initState() {
    super.initState();
    _loadReflections();
  }

  void _loadReflections() {
    setState(() {
      _entries = StorageService.getReflections();
    });
  }

  Future<void> _showAddReflection() async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ReflectionEditorSheet(),
    );

    if (saved == true) {
      _loadReflections();
    }
  }

  Future<void> _showEditReflection(ReflectionEntry entry) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ReflectionEditorSheet(
        entry: entry,
      ),
    );

    if (saved == true) {
      _loadReflections();
    }
  }

  Future<void> _deleteReflection(ReflectionEntry entry) async {
    await StorageService.deleteReflection(entry.id);
    _loadReflections();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reflection deleted'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _confirmDelete(ReflectionEntry entry) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete reflection?'),
          content: const Text(
            'This reflection will be permanently deleted.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      await _deleteReflection(entry);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Daily Reflection',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddReflection,
        icon: const Icon(Icons.edit_note_rounded),
        label: const Text('Reflect Today'),
      ),
      body: SafeArea(
        child: _entries.isEmpty
            ? _buildEmptyState()
            : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
      children: [
        _buildHeader(),
        const SizedBox(height: 22),
        _buildLatestReflection(),
        if (_entries.length > 1) ...[
          const SizedBox(height: 28),
          const Text(
            'Past Reflections',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          ..._entries.skip(1).map(_buildReflectionCard),
        ],
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pause. Think. Improve.',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          'एक दिन खत्म होने से पहले खुद से चार सवाल पूछो।',
          style: TextStyle(
            fontSize: 14,
            height: 1.45,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildLatestReflection() {
    final entry = _entries.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Latest Reflection',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            _dateChip(entry.date),
          ],
        ),
        const SizedBox(height: 12),
        _reflectionCard(entry, featured: true),
      ],
    );
  }

  Widget _buildReflectionCard(ReflectionEntry entry) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _reflectionCard(entry),
    );
  }

  Widget _reflectionCard(
    ReflectionEntry entry, {
    bool featured = false,
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
      child: InkWell(
        onTap: () => _showReflectionDetails(entry),
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!featured)
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _formatDate(entry.date),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _showEditReflection(entry),
                      tooltip: 'Edit',
                      icon: const Icon(
                        Icons.edit_outlined,
                        size: 19,
                      ),
                    ),
                    IconButton(
                      onPressed: () => _confirmDelete(entry),
                      tooltip: 'Delete',
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 19,
                      ),
                    ),
                  ],
                ),
              if (!featured) const SizedBox(height: 4),
              _previewQuestion(
                icon: Icons.emoji_events_outlined,
                title: 'Proud of',
                text: entry.proudOf,
              ),
              const SizedBox(height: 13),
              _previewQuestion(
                icon: Icons.hourglass_empty_rounded,
                title: 'Time wasted',
                text: entry.wastedTime,
              ),
              const SizedBox(height: 13),
              _previewQuestion(
                icon: Icons.lightbulb_outline_rounded,
                title: 'Learned',
                text: entry.learned,
              ),
              const SizedBox(height: 13),
              _previewQuestion(
                icon: Icons.trending_up_rounded,
                title: 'Tomorrow',
                text: entry.tomorrowImprovement,
              ),
              if (featured) ...[
                const SizedBox(height: 15),
                Row(
                  children: [
                    Text(
                      'Tap to open full reflection',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 13,
                      color: Colors.grey.shade500,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _previewQuestion({
    required IconData icon,
    required String title,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .primary
                .withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(
            icon,
            size: 18,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _dateChip(DateTime date) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Text(
        _formatDate(date),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(32, 20, 32, 110),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.psychology_alt_outlined,
                size: 38,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'Your reflection starts here',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Take a few minutes to understand your day and decide how tomorrow can be better.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _showAddReflection,
              icon: const Icon(Icons.edit_note_rounded),
              label: const Text('Reflect on Today'),
            ),
          ],
        ),
      ),
    );
  }

  void _showReflectionDetails(ReflectionEntry entry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _ReflectionDetailsSheet(
          entry: entry,
          onEdit: () async {
            Navigator.pop(context);
            await _showEditReflection(entry);
          },
          onDelete: () async {
            Navigator.pop(context);
            await _confirmDelete(entry);
          },
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _ReflectionEditorSheet extends StatefulWidget {
  final ReflectionEntry? entry;

  const _ReflectionEditorSheet({
    this.entry,
  });

  @override
  State<_ReflectionEditorSheet> createState() =>
      _ReflectionEditorSheetState();
}

class _ReflectionEditorSheetState
    extends State<_ReflectionEditorSheet> {
  final _formKey = GlobalKey<FormState>();

  final _proudController = TextEditingController();
  final _wastedController = TextEditingController();
  final _learnedController = TextEditingController();
  final _tomorrowController = TextEditingController();

  bool get _isEditing => widget.entry != null;

  @override
  void initState() {
    super.initState();

    final entry = widget.entry;

    if (entry != null) {
      _proudController.text = entry.proudOf;
      _wastedController.text = entry.wastedTime;
      _learnedController.text = entry.learned;
      _tomorrowController.text = entry.tomorrowImprovement;
    }
  }

  @override
  void dispose() {
    _proudController.dispose();
    _wastedController.dispose();
    _learnedController.dispose();
    _tomorrowController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final oldEntry = widget.entry;

    final entry = ReflectionEntry(
      id: oldEntry?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      date: oldEntry?.date ?? DateTime.now(),
      proudOf: _proudController.text.trim(),
      wastedTime: _wastedController.text.trim(),
      learned: _learnedController.text.trim(),
      tomorrowImprovement: _tomorrowController.text.trim(),
    );

    await StorageService.saveReflection(entry);

    if (!mounted) return;

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          10,
          20,
          20 + bottomInset,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  _isEditing
                      ? 'Edit Reflection'
                      : 'Today\'s Reflection',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Honest answers are more useful than perfect answers.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 22),
                _reflectionField(
                  controller: _proudController,
                  number: '01',
                  title: 'What am I proud of today?',
                  hint: 'A small win, good decision or meaningful action...',
                  icon: Icons.emoji_events_outlined,
                ),
                const SizedBox(height: 15),
                _reflectionField(
                  controller: _wastedController,
                  number: '02',
                  title: 'Where did I waste my time?',
                  hint: 'Be honest. What distracted or delayed you?',
                  icon: Icons.hourglass_empty_rounded,
                ),
                const SizedBox(height: 15),
                _reflectionField(
                  controller: _learnedController,
                  number: '03',
                  title: 'What did I learn today?',
                  hint: 'A fact, insight, mistake or experience...',
                  icon: Icons.lightbulb_outline_rounded,
                ),
                const SizedBox(height: 15),
                _reflectionField(
                  controller: _tomorrowController,
                  number: '04',
                  title: 'What will I improve tomorrow?',
                  hint: 'Choose one specific improvement...',
                  icon: Icons.trending_up_rounded,
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.check_rounded),
                    label: Text(
                      _isEditing
                          ? 'Save Changes'
                          : 'Save Reflection',
                    ),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _reflectionField({
    required TextEditingController controller,
    required String number,
    required String title,
    required String hint,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 31,
              height: 31,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                number,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 9),
        TextFormField(
          controller: controller,
          maxLines: 4,
          minLines: 3,
          textCapitalization: TextCapitalization.sentences,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please write something here';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Padding(
              padding: const EdgeInsets.only(
                left: 13,
                right: 4,
                bottom: 60,
              ),
              child: Icon(
                icon,
                size: 20,
              ),
            ),
            alignLabelWithHint: true,
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Colors.grey.shade200,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Colors.grey.shade200,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ReflectionDetailsSheet extends StatelessWidget {
  final ReflectionEntry entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ReflectionDetailsSheet({
    required this.entry,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Daily Reflection',
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _dateChip(context, entry.date),
              ],
            ),
            const SizedBox(height: 22),
            _detailSection(
              context,
              'What I am proud of',
              entry.proudOf,
              Icons.emoji_events_outlined,
            ),
            const SizedBox(height: 15),
            _detailSection(
              context,
              'Where I wasted time',
              entry.wastedTime,
              Icons.hourglass_empty_rounded,
            ),
            const SizedBox(height: 15),
            _detailSection(
              context,
              'What I learned',
              entry.learned,
              Icons.lightbulb_outline_rounded,
            ),
            const SizedBox(height: 15),
            _detailSection(
              context,
              'Tomorrow I will improve',
              entry.tomorrowImprovement,
              Icons.trending_up_rounded,
            ),
            const SizedBox(height: 26),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Delete'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor:
                          Theme.of(context).colorScheme.error,
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateChip(BuildContext context, DateTime date) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Text(
        '${date.day}/${date.month}/${date.year}',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  Widget _detailSection(
    BuildContext context,
    String title,
    String content,
    IconData icon,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 19,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              height: 1.55,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }
}
