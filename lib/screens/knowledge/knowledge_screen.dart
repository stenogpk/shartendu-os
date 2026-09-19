import 'package:flutter/material.dart';

import '../../models/app_models.dart';
import '../../services/storage_service.dart';

class KnowledgeScreen extends StatefulWidget {
  const KnowledgeScreen({super.key});

  @override
  State<KnowledgeScreen> createState() => _KnowledgeScreenState();
}

class _KnowledgeScreenState extends State<KnowledgeScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<KnowledgeItem> _items = [];
  String _searchQuery = '';

  final List<String> _categories = [
    'General',
    'Books',
    'Work',
    'Personal Growth',
    'Finance',
    'Health',
    'Technology',
    'History',
    'Ideas',
  ];

  @override
  void initState() {
    super.initState();
    _loadKnowledge();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.trim().toLowerCase();
    });
  }

  void _loadKnowledge() {
    setState(() {
      _items = StorageService.getKnowledge();
    });
  }

  List<KnowledgeItem> get _filteredItems {
    if (_searchQuery.isEmpty) {
      return _items;
    }

    return _items.where((item) {
      final text = [
        item.title,
        item.learned,
        item.category,
        item.source,
        item.insight,
        item.action,
      ].join(' ').toLowerCase();

      return text.contains(_searchQuery);
    }).toList();
  }

  Future<void> _deleteKnowledge(KnowledgeItem item) async {
    await StorageService.deleteKnowledge(item.id);
    _loadKnowledge();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Knowledge entry deleted'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _showAddKnowledge() async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _AddKnowledgeSheet(
          categories: _categories,
        );
      },
    );

    if (saved == true) {
      _loadKnowledge();
    }
  }

  void _showKnowledgeDetails(KnowledgeItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _KnowledgeDetailsSheet(
          item: item,
          onDelete: () async {
            Navigator.pop(context);
            await _deleteKnowledge(item);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _filteredItems;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Knowledge Vault',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddKnowledge,
        icon: const Icon(Icons.add),
        label: const Text('Add Knowledge'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            Expanded(
              child: items.isEmpty
                  ? _buildEmptyState()
                  : _buildKnowledgeList(items),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Learn something. Use it.',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Knowledge should lead to action.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .primary
                  .withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              '${_items.length}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search your knowledge...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isEmpty
              ? null
              : IconButton(
                  onPressed: _searchController.clear,
                  icon: const Icon(Icons.close),
                ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(
              color: Colors.grey.shade200,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(
              color: Colors.grey.shade200,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKnowledgeList(List<KnowledgeItem> items) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];

        return Dismissible(
          key: ValueKey(item.id),
          direction: DismissDirection.endToStart,
          confirmDismiss: (_) async {
            return await showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Delete entry?'),
                      content: const Text(
                        'This knowledge entry will be permanently deleted.',
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
                ) ??
                false;
          },
          onDismissed: (_) => _deleteKnowledge(item),
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Icon(
              Icons.delete_outline,
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
          ),
          child: _knowledgeCard(item),
        );
      },
    );
  }

  Widget _knowledgeCard(KnowledgeItem item) {
    final hasAction = item.action.trim().isNotEmpty;

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
        borderRadius: BorderRadius.circular(22),
        onTap: () => _showKnowledgeDetails(item),
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
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
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
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _tag(
                    item.category,
                    Icons.folder_outlined,
                  ),
                  if (item.source.trim().isNotEmpty)
                    _tag(
                      item.source,
                      Icons.link_outlined,
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                item.learned,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Colors.grey.shade700,
                ),
              ),
              if (hasAction) ...[
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.bolt_rounded,
                        size: 19,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.action,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _tag(String text, IconData icon) {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 190,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Colors.grey.shade700,
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(32, 20, 32, 120),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_awesome_outlined,
                size: 34,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Your knowledge vault is empty',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Capture something meaningful and turn it into an insight or action.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: _showAddKnowledge,
              icon: const Icon(Icons.add),
              label: const Text('Add your first knowledge'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddKnowledgeSheet extends StatefulWidget {
  final List<String> categories;

  const _AddKnowledgeSheet({
    required this.categories,
  });

  @override
  State<_AddKnowledgeSheet> createState() => _AddKnowledgeSheetState();
}

class _AddKnowledgeSheetState extends State<_AddKnowledgeSheet> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _learnedController = TextEditingController();
  final _sourceController = TextEditingController();
  final _insightController = TextEditingController();
  final _actionController = TextEditingController();

  String _category = 'General';

  @override
  void dispose() {
    _titleController.dispose();
    _learnedController.dispose();
    _sourceController.dispose();
    _insightController.dispose();
    _actionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final item = KnowledgeItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      learned: _learnedController.text.trim(),
      category: _category,
      source: _sourceController.text.trim(),
      insight: _insightController.text.trim(),
      action: _actionController.text.trim(),
      createdAt: DateTime.now(),
    );

    await StorageService.saveKnowledge(item);

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
                const Text(
                  'Capture Knowledge',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Record what matters, not everything.',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 22),

                _field(
                  controller: _titleController,
                  label: 'Title',
                  hint: 'What did you learn?',
                  icon: Icons.title_outlined,
                  required: true,
                ),

                const SizedBox(height: 14),

                DropdownButtonFormField<String>(
                  initialValue: _category,
                  isExpanded: true,
                  decoration: _inputDecoration(
                    'Category',
                    Icons.folder_outlined,
                  ),
                  items: widget.categories
                      .map(
                        (category) => DropdownMenuItem(
                          value: category,
                          child: Text(
                            category,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _category = value;
                      });
                    }
                  },
                ),

                const SizedBox(height: 14),

                _field(
                  controller: _learnedController,
                  label: 'What did you learn?',
                  hint: 'Write the useful fact or idea...',
                  icon: Icons.lightbulb_outline,
                  maxLines: 4,
                  required: true,
                ),

                const SizedBox(height: 14),

                _field(
                  controller: _sourceController,
                  label: 'Source',
                  hint: 'Book, video, person, experience...',
                  icon: Icons.link_outlined,
                ),

                const SizedBox(height: 14),

                _field(
                  controller: _insightController,
                  label: 'My insight',
                  hint: 'What does this mean for you?',
                  icon: Icons.psychology_outlined,
                  maxLines: 4,
                ),

                const SizedBox(height: 14),

                _field(
                  controller: _actionController,
                  label: 'Action',
                  hint: 'What will you actually do with it?',
                  icon: Icons.bolt_outlined,
                  maxLines: 3,
                ),

                const SizedBox(height: 22),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('Save Knowledge'),
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

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    bool required = false,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      textCapitalization: TextCapitalization.sentences,
      validator: required
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return '$label is required';
              }
              return null;
            }
          : null,
      decoration: _inputDecoration(
        label,
        icon,
        hint: hint,
      ),
    );
  }

  InputDecoration _inputDecoration(
    String label,
    IconData icon, {
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
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
    );
  }
}

class _KnowledgeDetailsSheet extends StatelessWidget {
  final KnowledgeItem item;
  final VoidCallback onDelete;

  const _KnowledgeDetailsSheet({
    required this.item,
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

            Text(
              item.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _detailTag(
                  context,
                  item.category,
                  Icons.folder_outlined,
                ),
                if (item.source.trim().isNotEmpty)
                  _detailTag(
                    context,
                    item.source,
                    Icons.link_outlined,
                  ),
              ],
            ),

            const SizedBox(height: 24),

            _detailSection(
              context,
              'What I learned',
              item.learned,
              Icons.lightbulb_outline,
            ),

            if (item.insight.trim().isNotEmpty) ...[
              const SizedBox(height: 20),
              _detailSection(
                context,
                'My insight',
                item.insight,
                Icons.psychology_outlined,
              ),
            ],

            if (item.action.trim().isNotEmpty) ...[
              const SizedBox(height: 20),
              _detailSection(
                context,
                'Action',
                item.action,
                Icons.bolt_outlined,
              ),
            ],

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailTag(
    BuildContext context,
    String text,
    IconData icon,
  ) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 260),
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: Colors.grey.shade700,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
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
