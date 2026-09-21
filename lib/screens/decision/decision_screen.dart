import 'package:flutter/material.dart';

import '../../models/app_models.dart';
import '../../services/storage_service.dart';

class DecisionScreen extends StatefulWidget {
  const DecisionScreen({super.key});

  @override
  State<DecisionScreen> createState() => _DecisionScreenState();
}

class _DecisionScreenState extends State<DecisionScreen> {
  List<DecisionEntry> _decisions = [];

  @override
  void initState() {
    super.initState();
    _loadDecisions();
  }

  void _loadDecisions() {
    setState(() {
      _decisions = StorageService.getDecisions();
    });
  }

  Future<void> _openAddDecision() async {
    await _showDecisionEditor();
  }

  Future<void> _openEditDecision(DecisionEntry decision) async {
    await _showDecisionEditor(existing: decision);
  }

  Future<void> _showDecisionEditor({
    DecisionEntry? existing,
  }) async {
    final questionController =
        TextEditingController(text: existing?.question ?? '');
    final optionsController =
        TextEditingController(text: existing?.options ?? '');
    final chosenController =
        TextEditingController(text: existing?.chosen ?? '');
    final reasoningController =
        TextEditingController(text: existing?.reasoning ?? '');
    final predictionController =
        TextEditingController(text: existing?.prediction ?? '');
    final resultController =
        TextEditingController(text: existing?.result ?? '');

    DateTime? reviewDate = existing?.reviewDate;

    final formKey = GlobalKey<FormState>();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 14,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 42,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade400,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          existing == null
                              ? 'New Decision'
                              : 'Edit Decision',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Record the decision, your reasoning and what you expect to happen.',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 22),
                        _buildField(
                          controller: questionController,
                          label: 'Decision Question',
                          hint: 'What decision do I need to make?',
                          icon: Icons.help_outline_rounded,
                          maxLines: 3,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter the decision question.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        _buildField(
                          controller: optionsController,
                          label: 'Options',
                          hint: 'What options am I considering?',
                          icon: Icons.alt_route_rounded,
                          maxLines: 4,
                        ),
                        const SizedBox(height: 14),
                        _buildField(
                          controller: chosenController,
                          label: 'Chosen Option',
                          hint: 'What did I decide?',
                          icon: Icons.check_circle_outline_rounded,
                          maxLines: 3,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter what you chose.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        _buildField(
                          controller: reasoningController,
                          label: 'Reasoning',
                          hint: 'Why did I choose this option?',
                          icon: Icons.psychology_alt_outlined,
                          maxLines: 5,
                        ),
                        const SizedBox(height: 14),
                        _buildField(
                          controller: predictionController,
                          label: 'Prediction',
                          hint: 'What result do I expect?',
                          icon: Icons.auto_graph_rounded,
                          maxLines: 4,
                        ),
                        const SizedBox(height: 14),
                        _buildField(
                          controller: resultController,
                          label: 'Result',
                          hint: 'What actually happened? Add this later during review.',
                          icon: Icons.flag_outlined,
                          maxLines: 5,
                        ),
                        const SizedBox(height: 18),
                        _buildReviewDateSelector(
                          context: context,
                          reviewDate: reviewDate,
                          onChanged: (date) {
                            setSheetState(() {
                              reviewDate = date;
                            });
                          },
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: () async {
                              if (!formKey.currentState!.validate()) {
                                return;
                              }

                              final now = DateTime.now();

                              final entry = DecisionEntry(
                                id: existing?.id ??
                                    now.microsecondsSinceEpoch.toString(),
                                question: questionController.text.trim(),
                                options: optionsController.text.trim(),
                                chosen: chosenController.text.trim(),
                                reasoning: reasoningController.text.trim(),
                                prediction:
                                    predictionController.text.trim(),
                                result: resultController.text.trim(),
                                createdAt: existing?.createdAt ?? now,
                                reviewDate: reviewDate,
                              );

                              await StorageService.saveDecision(entry);

                              if (!mounted) {
                                return;
                              }

                              Navigator.of(sheetContext).pop();
                              _loadDecisions();
                            },
                            icon: Icon(
                              existing == null
                                  ? Icons.add_rounded
                                  : Icons.save_rounded,
                            ),
                            label: Text(
                              existing == null
                                  ? 'Save Decision'
                                  : 'Save Changes',
                            ),
                            style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(54),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
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
          },
        );
      },
    );

    questionController.dispose();
    optionsController.dispose();
    chosenController.dispose();
    reasoningController.dispose();
    predictionController.dispose();
    resultController.dispose();
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      minLines: maxLines == 1 ? 1 : null,
      validator: validator,
      textInputAction:
          maxLines > 1 ? TextInputAction.newline : TextInputAction.next,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Padding(
          padding: const EdgeInsets.only(
            left: 12,
            right: 8,
            top: 12,
          ),
          child: Icon(icon),
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 48,
          minHeight: 48,
        ),
        alignLabelWithHint: maxLines > 1,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.grey.shade300,
          ),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildReviewDateSelector({
    required BuildContext context,
    required DateTime? reviewDate,
    required ValueChanged<DateTime?> onChanged,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.event_outlined),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Review Date',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  reviewDate == null
                      ? 'No review date set'
                      : _formatDate(reviewDate),
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          if (reviewDate != null)
            IconButton(
              tooltip: 'Clear date',
              onPressed: () => onChanged(null),
              icon: const Icon(Icons.close_rounded),
            ),
          TextButton(
            onPressed: () async {
              final selected = await showDatePicker(
                context: context,
                initialDate: reviewDate ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );

              if (selected != null) {
                onChanged(selected);
              }
            },
            child: Text(
              reviewDate == null ? 'Set' : 'Change',
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDecisionDetail(DecisionEntry decision) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Decision Review',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Edit',
                        onPressed: () {
                          Navigator.of(context).pop();
                          _openEditDecision(decision);
                        },
                        icon: const Icon(Icons.edit_outlined),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _detailSection(
                    'Decision Question',
                    decision.question,
                  ),
                  _detailSection(
                    'Options',
                    decision.options,
                  ),
                  _detailSection(
                    'Chosen Option',
                    decision.chosen,
                  ),
                  _detailSection(
                    'Reasoning',
                    decision.reasoning,
                  ),
                  _detailSection(
                    'Prediction',
                    decision.prediction,
                  ),
                  _detailSection(
                    'Actual Result',
                    decision.result.isEmpty
                        ? 'No result recorded yet.'
                        : decision.result,
                  ),
                  _detailSection(
                    'Created',
                    _formatDate(decision.createdAt),
                  ),
                  _detailSection(
                    'Review Date',
                    decision.reviewDate == null
                        ? 'Not set'
                        : _formatDate(decision.reviewDate!),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        await _confirmDelete(decision);
                      },
                      icon: const Icon(Icons.delete_outline_rounded),
                      label: const Text('Delete Decision'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red.shade700,
                        minimumSize: const Size.fromHeight(50),
                        side: BorderSide(
                          color: Colors.red.shade200,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _detailSection(String title, String value) {
    final displayValue =
        value.trim().isEmpty ? 'Not added yet.' : value.trim();

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            displayValue,
            style: const TextStyle(
              fontSize: 16,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(DecisionEntry decision) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Decision?'),
          content: const Text(
            'This decision record will be permanently removed from this device.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red.shade700,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      await StorageService.deleteDecision(decision.id);
      _loadDecisions();
    }
  }

  Future<void> _confirmSwipeDelete(DecisionEntry decision) async {
    await _confirmDelete(decision);
  }

  String _formatDate(DateTime date) {
    final localDate = date.toLocal();

    return '${_twoDigits(localDate.day)}/'
        '${_twoDigits(localDate.month)}/'
        '${localDate.year}';
  }

  String _twoDigits(int value) {
    return value.toString().padLeft(2, '0');
  }

  bool _isReviewDue(DecisionEntry decision) {
    if (decision.reviewDate == null) {
      return false;
    }

    final today = DateTime.now();

    final review = DateTime(
      decision.reviewDate!.year,
      decision.reviewDate!.month,
      decision.reviewDate!.day,
    );

    final currentDay = DateTime(
      today.year,
      today.month,
      today.day,
    );

    return !review.isAfter(currentDay);
  }

  @override
  Widget build(BuildContext context) {
    final dueCount =
        _decisions.where(_isReviewDue).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Decision Journal',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddDecision,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Decision'),
      ),
      body: _decisions.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: () async {
                _loadDecisions();
              },
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                children: [
                  _buildIntroCard(),
                  if (dueCount > 0) ...[
                    const SizedBox(height: 14),
                    _buildReviewBanner(dueCount),
                  ],
                  const SizedBox(height: 20),
                  Text(
                    'Your Decisions',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 10),
                  ..._decisions.map(_buildDecisionCard),
                ],
              ),
            ),
    );
  }

  Widget _buildIntroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.surfaceContainerHighest,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context)
              .colorScheme
              .primary
              .withValues(alpha: 0.10),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .primary
                  .withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.balance_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Think before, learn after.',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Record why you made an important decision, what you expected and what actually happened.',
                  style: TextStyle(
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewBanner(int dueCount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.amber.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.rate_review_outlined,
            color: Colors.amber.shade900,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$dueCount decision${dueCount == 1 ? '' : 's'} ready for review.',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.amber.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecisionCard(DecisionEntry decision) {
    final reviewDue = _isReviewDue(decision);

    return Dismissible(
      key: ValueKey(decision.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        await _confirmSwipeDelete(decision);
        return false;
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          Icons.delete_outline_rounded,
          color: Colors.red.shade700,
        ),
      ),
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: reviewDue
                ? Colors.amber.shade300
                : Colors.grey.shade200,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showDecisionDetail(decision),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        decision.question,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: 'More',
                      onPressed: () => _showDecisionDetail(decision),
                      icon: const Icon(Icons.more_horiz_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.check_circle_outline_rounded,
                  'Chosen',
                  decision.chosen,
                ),
                if (decision.prediction.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.auto_graph_rounded,
                    'Expected',
                    decision.prediction,
                  ),
                ],
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildChip(
                      Icons.calendar_today_outlined,
                      _formatDate(decision.createdAt),
                    ),
                    if (decision.reviewDate != null)
                      _buildChip(
                        Icons.rate_review_outlined,
                        reviewDue
                            ? 'Review due'
                            : 'Review ${_formatDate(decision.reviewDate!)}',
                        highlighted: reviewDue,
                      ),
                    if (decision.result.trim().isNotEmpty)
                      _buildChip(
                        Icons.flag_outlined,
                        'Result added',
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 19,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 9),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: DefaultTextStyle.of(context).style.copyWith(
                    height: 1.35,
                  ),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(
                  text: value.trim().isEmpty
                      ? 'Not added'
                      : value.trim(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChip(
    IconData icon,
    String label, {
    bool highlighted = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: highlighted
            ? Colors.amber.shade50
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: highlighted
              ? Colors.amber.shade200
              : Colors.grey.shade200,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: highlighted
                ? Colors.amber.shade900
                : Colors.grey.shade700,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: highlighted
                  ? Colors.amber.shade900
                  : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.balance_rounded,
                size: 40,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No decisions yet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Use Decision Journal for important choices. Record your reasoning now and review the outcome later.',
              style: TextStyle(
                color: Colors.grey.shade600,
                height: 1.45,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: _openAddDecision,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Record First Decision'),
            ),
          ],
        ),
      ),
    );
  }
}
