import 'package:flutter/material.dart';

import '../../models/app_models.dart';
import '../../services/storage_service.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  List<TaskItem> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() {
    setState(() {
      _tasks = StorageService.getTasks();
    });
  }

  List<TaskItem> get _pendingTasks {
    return _tasks.where((task) => !task.completed).toList();
  }

  List<TaskItem> get _completedTasks {
    return _tasks.where((task) => task.completed).toList();
  }

  Future<void> _showTaskEditor({
    TaskItem? existing,
  }) async {
    final titleController =
        TextEditingController(text: existing?.title ?? '');
    final descriptionController =
        TextEditingController(text: existing?.description ?? '');

    String priority = existing?.priority ?? 'Medium';
    DateTime? dueDate = existing?.dueDate;

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
                          existing == null ? 'New Task' : 'Edit Task',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: titleController,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: 'Task Title',
                            hintText: 'What needs to be done?',
                            prefixIcon:
                                const Icon(Icons.task_alt_rounded),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a task title.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: descriptionController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            labelText: 'Description',
                            hintText: 'Add useful details if needed',
                            alignLabelWithHint: true,
                            prefixIcon: const Padding(
                              padding: EdgeInsets.only(
                                left: 12,
                                right: 8,
                                top: 12,
                              ),
                              child: Icon(
                                Icons.notes_outlined,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'Priority',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _priorityChoice(
                              'High',
                              priority,
                              setSheetState,
                            ),
                            _priorityChoice(
                              'Medium',
                              priority,
                              setSheetState,
                            ),
                            _priorityChoice(
                              'Low',
                              priority,
                              setSheetState,
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Container(
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
                              const Icon(
                                Icons.event_outlined,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Due Date',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      dueDate == null
                                          ? 'No due date'
                                          : _formatDate(dueDate!),
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (dueDate != null)
                                IconButton(
                                  tooltip: 'Clear date',
                                  onPressed: () {
                                    setSheetState(() {
                                      dueDate = null;
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.close_rounded,
                                  ),
                                ),
                              TextButton(
                                onPressed: () async {
                                  final selected =
                                      await showDatePicker(
                                    context: context,
                                    initialDate:
                                        dueDate ?? DateTime.now(),
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime(2100),
                                  );

                                  if (selected != null) {
                                    setSheetState(() {
                                      dueDate = selected;
                                    });
                                  }
                                },
                                child: Text(
                                  dueDate == null ? 'Set' : 'Change',
                                ),
                              ),
                            ],
                          ),
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

                              final task = TaskItem(
                                id: existing?.id ??
                                    now.microsecondsSinceEpoch.toString(),
                                title: titleController.text.trim(),
                                description:
                                    descriptionController.text.trim(),
                                priority: priority,
                                completed: existing?.completed ?? false,
                                createdAt: existing?.createdAt ?? now,
                                dueDate: dueDate,
                              );

                              await StorageService.saveTask(task);

                              if (!mounted) {
                                return;
                              }

                              Navigator.of(sheetContext).pop();
                              _loadTasks();
                            },
                            icon: Icon(
                              existing == null
                                  ? Icons.add_rounded
                                  : Icons.save_rounded,
                            ),
                            label: Text(
                              existing == null
                                  ? 'Save Task'
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

    titleController.dispose();
    descriptionController.dispose();
  }

  Widget _priorityChoice(
    String value,
    String selected,
    StateSetter setSheetState,
  ) {
    final isSelected = value == selected;

    return ChoiceChip(
      label: Text(value),
      selected: isSelected,
      onSelected: (_) {
        setSheetState(() {
          // The parent editor owns this value.
        });
      },
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
    _loadTasks();
  }

  Future<void> _deleteTask(TaskItem task) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Task?'),
          content: const Text(
            'This task will be permanently removed from this device.',
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
      await StorageService.deleteTask(task.id);
      _loadTasks();
    }
  }

  String _formatDate(DateTime date) {
    final localDate = date.toLocal();

    return '${localDate.day.toString().padLeft(2, '0')}/'
        '${localDate.month.toString().padLeft(2, '0')}/'
        '${localDate.year}';
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

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'High':
        return Colors.red;
      case 'Low':
        return Colors.green;
      default:
        return Colors.orange;
    }
  }

  Widget _buildTaskCard(TaskItem task) {
    final overdue = _isOverdue(task);
    final priorityColor = _priorityColor(task.priority);

    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        await _deleteTask(task);
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
            color: overdue
                ? Colors.red.shade200
                : Colors.grey.shade200,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: task.completed,
                onChanged: (_) => _toggleTask(task),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: InkWell(
                  onTap: () => _showTaskEditor(existing: task),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            decoration: task.completed
                                ? TextDecoration.lineThrough
                                : null,
                            color: task.completed
                                ? Colors.grey.shade500
                                : null,
                          ),
                        ),
                        if (task.description.isNotEmpty) ...[
                          const SizedBox(height: 5),
                          Text(
                            task.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              height: 1.35,
                            ),
                          ),
                        ],
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _infoChip(
                              task.priority,
                              priorityColor,
                            ),
                            if (task.dueDate != null)
                              _infoChip(
                                overdue
                                    ? 'Overdue'
                                    : 'Due ${_formatDate(task.dueDate!)}',
                                overdue
                                    ? Colors.red
                                    : Colors.blueGrey,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Delete',
                onPressed: () => _deleteTask(task),
                icon: const Icon(
                  Icons.more_vert_rounded,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: color.withValues(alpha: 0.20),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildSection(
    String title,
    List<TaskItem> tasks,
  ) {
    if (tasks.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 10),
        ...tasks.map(_buildTaskCard),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = _completedTasks.length;
    final totalCount = _tasks.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tasks & Priorities',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTaskEditor(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Task'),
      ),
      body: _tasks.isEmpty
          ? _buildEmptyState()
          : ListView(
              padding: const EdgeInsets.fromLTRB(
                16,
                16,
                16,
                100,
              ),
              children: [
                _buildSummaryCard(
                  totalCount,
                  completedCount,
                ),
                const SizedBox(height: 22),
                _buildSection(
                  'Pending',
                  _pendingTasks,
                ),
                if (_completedTasks.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  _buildSection(
                    'Completed',
                    _completedTasks,
                  ),
                ],
              ],
            ),
    );
  }

  Widget _buildSummaryCard(
    int total,
    int completed,
  ) {
    final pending = total - completed;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .primaryContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: _summaryValue(
              'Total',
              total.toString(),
            ),
          ),
          Expanded(
            child: _summaryValue(
              'Pending',
              pending.toString(),
            ),
          ),
          Expanded(
            child: _summaryValue(
              'Done',
              completed.toString(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryValue(
    String label,
    String value,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
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
                Icons.task_alt_rounded,
                size: 40,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No tasks yet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create a task and start turning your priorities into action.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: () => _showTaskEditor(),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create First Task'),
            ),
          ],
        ),
      ),
    );
  }
}
