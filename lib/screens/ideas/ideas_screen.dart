import 'package:flutter/material.dart';

import '../../models/app_models.dart';
import '../../services/storage_service.dart';

class IdeasScreen extends StatefulWidget {
  const IdeasScreen({super.key});

  @override
  State<IdeasScreen> createState() => _IdeasScreenState();
}

class _IdeasScreenState extends State<IdeasScreen> {
  List<IdeaItem> _ideas = [];

  @override
  void initState() {
    super.initState();
    _loadIdeas();
  }

  void _loadIdeas() {
    _ideas = StorageService.getIdeas();
  }

  Future<void> _showEditor({IdeaItem? existing}) async {
    final titleController =
        TextEditingController(text: existing?.title ?? '');
    final descriptionController =
        TextEditingController(text: existing?.description ?? '');

    String category = existing?.category ?? 'General';

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
                padding: EdgeInsets.fromLTRB(
                  20,
                  16,
                  20,
                  MediaQuery.of(context).viewInsets.bottom + 20,
                ),
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
                      Text(
                        existing == null ? 'New Idea' : 'Edit Idea',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: titleController,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: 'Idea',
                          hintText: 'What is the idea?',
                          prefixIcon:
                              const Icon(Icons.lightbulb_outline_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: descriptionController,
                        maxLines: 5,
                        decoration: InputDecoration(
                          labelText: 'Details',
                          hintText: 'Capture the thought while it is fresh',
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Category',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final value in [
                            'General',
                            'Work',
                            'Personal',
                            'Content',
                            'Learning',
                          ])
                            ChoiceChip(
                              label: Text(value),
                              selected: category == value,
                              onSelected: (_) {
                                setSheetState(() {
                                  category = value;
                                });
                              },
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () async {
                            final title = titleController.text.trim();

                            if (title.isEmpty) {
                              return;
                            }

                            final now = DateTime.now();

                            final idea = IdeaItem(
                              id: existing?.id ??
                                  now.microsecondsSinceEpoch.toString(),
                              title: title,
                              description:
                                  descriptionController.text.trim(),
                              category: category,
                              convertedToAction:
                                  existing?.convertedToAction ?? false,
                              createdAt: existing?.createdAt ?? now,
                            );

                            await StorageService.saveIdea(idea);

                            if (!mounted) return;

                            Navigator.pop(sheetContext);

                            setState(() {
                              _loadIdeas();
                            });
                          },
                          icon: Icon(
                            existing == null
                                ? Icons.add_rounded
                                : Icons.save_rounded,
                          ),
                          label: Text(
                            existing == null
                                ? 'Save Idea'
                                : 'Save Changes',
                          ),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(54),
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
      },
    );

    titleController.dispose();
    descriptionController.dispose();
  }

  Future<void> _toggleAction(IdeaItem idea) async {
    final updated = IdeaItem(
      id: idea.id,
      title: idea.title,
      description: idea.description,
      category: idea.category,
      convertedToAction: !idea.convertedToAction,
      createdAt: idea.createdAt,
    );

    await StorageService.saveIdea(updated);

    setState(() {
      _loadIdeas();
    });
  }

  Future<void> _deleteIdea(IdeaItem idea) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Idea?'),
        content: const Text(
          'This idea will be permanently removed from this device.',
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
      ),
    );

    if (confirmed == true) {
      await StorageService.deleteIdea(idea.id);

      setState(() {
        _loadIdeas();
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ideas',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEditor(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Idea'),
      ),
      body: _ideas.isEmpty
          ? _emptyState()
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: _ideas.length,
              itemBuilder: (context, index) {
                return _ideaCard(_ideas[index]);
              },
            ),
    );
  }

  Widget _ideaCard(IdeaItem idea) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.65),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lightbulb_outline_rounded,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    idea.title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditor(existing: idea);
                    } else if (value == 'delete') {
                      _deleteIdea(idea);
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'edit',
                      child: Text('Edit'),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ],
                ),
              ],
            ),
            if (idea.description.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                idea.description,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _chip(idea.category),
                _chip(_formatDate(idea.createdAt)),
                ActionChip(
                  avatar: Icon(
                    idea.convertedToAction
                        ? Icons.check_rounded
                        : Icons.arrow_forward_rounded,
                    size: 17,
                  ),
                  label: Text(
                    idea.convertedToAction
                        ? 'Actioned'
                        : 'Turn into Action',
                  ),
                  onPressed: () => _toggleAction(idea),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lightbulb_outline_rounded,
              size: 58,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 18),
            const Text(
              'No ideas yet',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Capture ideas quickly. Decide later which ones deserve action.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: () => _showEditor(),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Capture First Idea'),
            ),
          ],
        ),
      ),
    );
  }
}
