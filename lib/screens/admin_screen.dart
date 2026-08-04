import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../models/course_model.dart';
import '../models/question_model.dart';
import '../models/story_model.dart';
import '../models/unit_model.dart';
import '../providers/content_provider.dart';
import '../services/api_service.dart';
import '../widgets/question_edit_dialog.dart';
import '../widgets/story_question_edit_dialog.dart';

const List<String> _difficulties = [
  'Beginner',
  'Elementary',
  'Intermediate',
  'Upper Intermediate',
  'Advanced',
  'Expert',
];

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  List<Map<String, dynamic>> _users = [];
  bool _loadingUsers = true;
  String? _usersError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadUsers();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final content = context.read<ContentProvider>();
      if (!content.loaded) content.loadAll();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _loadingUsers = true;
      _usersError = null;
    });
    try {
      final users = await context.read<ApiService>().fetchAdminUsers();
      if (!mounted) return;
      setState(() {
        _users = users;
        _loadingUsers = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _usersError = e.message;
        _loadingUsers = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _usersError = '$e';
        _loadingUsers = false;
      });
    }
  }

  Future<void> _deleteUser(int id, String username) async {
    final api = context.read<ApiService>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete user?'),
        content: Text(
          'Delete "$username" and all of their progress?\nThis cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: AppTheme.wrongRed)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await api.adminDeleteUser(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deleted $username'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      await _loadUsers();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), behavior: SnackBarBehavior.floating),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Users'),
            Tab(text: 'Units'),
            Tab(text: 'Stories'),
            Tab(text: 'Courses'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _OverviewTab(
            users: _users,
            onOpenTab: _tabController.animateTo,
          ),
          _UsersTab(
            users: _users,
            loading: _loadingUsers,
            error: _usersError,
            onRefresh: _loadUsers,
            onDelete: _deleteUser,
          ),
          const _UnitsTab(),
          const _StoriesTab(),
          const _CoursesTab(),
        ],
      ),
    );
  }
}

// ---------------- Overview ----------------

class _OverviewTab extends StatelessWidget {
  final List<Map<String, dynamic>> users;
  final void Function(int index) onOpenTab;

  const _OverviewTab({required this.users, required this.onOpenTab});

  @override
  Widget build(BuildContext context) {
    final content = context.watch<ContentProvider>();
    final items = [
      ('Users', users.length, Icons.people_outline),
      ('Units', content.units.length, Icons.menu_book_outlined),
      ('Stories', content.stories.length, Icons.auto_stories_outlined),
      ('Courses', content.courses.length, Icons.school_outlined),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Overview', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.6,
          children: [
            for (final item in items) _StatCard(label: item.$1, value: item.$2, icon: item.$3),
          ],
        ),
        const SizedBox(height: 24),
        Text('Quick actions', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        _ActionTile(
          icon: Icons.people_outline,
          label: 'Manage users & scores',
          onTap: () => onOpenTab(1),
        ),
        _ActionTile(
          icon: Icons.menu_book_outlined,
          label: 'Manage units & questions',
          onTap: () => onOpenTab(2),
        ),
        _ActionTile(
          icon: Icons.auto_stories_outlined,
          label: 'Manage stories',
          onTap: () => onOpenTab(3),
        ),
        _ActionTile(
          icon: Icons.school_outlined,
          label: 'Manage courses',
          onTap: () => onOpenTab(4),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;

  const _StatCard({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppTheme.primaryColor),
            const SizedBox(height: 8),
            Text(
              '$value',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryColor),
        title: Text(label),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

// ---------------- Users ----------------

class _UsersTab extends StatelessWidget {
  final List<Map<String, dynamic>> users;
  final bool loading;
  final String? error;
  final Future<void> Function() onRefresh;
  final Future<void> Function(int id, String username) onDelete;

  const _UsersTab({
    required this.users,
    required this.loading,
    required this.error,
    required this.onRefresh,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (loading && users.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                error!,
                style: const TextStyle(color: AppTheme.wrongRed),
              ),
            ),
          Text('Users (${users.length})', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          if (users.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text('No users yet', style: TextStyle(color: Colors.grey)),
            )
          else
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              child: Column(
                children: [
                  for (final user in users) _UserRow(user: user, onDelete: onDelete),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _UserRow extends StatelessWidget {
  final Map<String, dynamic> user;
  final Future<void> Function(int id, String username) onDelete;

  const _UserRow({required this.user, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final username = user['username'] as String? ?? '?';
    final isAdmin = user['isAdmin'] == true;
    final score = (user['score'] as num?)?.toInt() ?? 0;
    final createdAt = (user['createdAt'] as String? ?? '').split('T').first;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isAdmin
            ? AppTheme.accentColor.withValues(alpha: 0.2)
            : AppTheme.primaryColor.withValues(alpha: 0.15),
        child: Text(
          username.isEmpty ? '?' : username[0].toUpperCase(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isAdmin ? AppTheme.accentColor : AppTheme.primaryColor,
          ),
        ),
      ),
      title: Row(
        children: [
          Flexible(
            child: Text(username, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          if (isAdmin) ...[
            const SizedBox(width: 6),
            const Icon(Icons.verified, color: AppTheme.accentColor, size: 16),
            const Text(' Admin',
                style: TextStyle(color: AppTheme.accentColor, fontSize: 12)),
          ],
        ],
      ),
      subtitle: Text('$score pts · joined $createdAt'),
      trailing: isAdmin
          ? const Icon(Icons.lock_outline, size: 18, color: Colors.grey)
          : IconButton(
              icon: const Icon(Icons.delete_outline, color: AppTheme.wrongRed),
              tooltip: 'Delete user',
              onPressed: () => onDelete(user['id'] as int, username),
            ),
    );
  }
}

// ---------------- Units ----------------

class _UnitsTab extends StatefulWidget {
  const _UnitsTab();

  @override
  State<_UnitsTab> createState() => _UnitsTabState();
}

class _UnitsTabState extends State<_UnitsTab> {
  Future<void> _openEditor([Unit? unit]) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => _UnitEditorScreen(unit: unit)),
    );
    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unit saved'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  Future<void> _delete(Unit unit) async {
    final content = context.read<ContentProvider>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Unit ${unit.unitNumber}?'),
        content: const Text('All questions will be removed. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: AppTheme.wrongRed)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await content.adminDeleteUnit(unit.unitNumber);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unit ${unit.unitNumber} deleted'), behavior: SnackBarBehavior.floating),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not delete: $e'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = context.watch<ContentProvider>();
    if (content.loading && content.units.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    final units = List<Unit>.from(content.units)
      ..sort((a, b) => a.unitNumber.compareTo(b.unitNumber));
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(),
        icon: const Icon(Icons.add),
        label: const Text('Add Unit'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        itemCount: units.length,
        itemBuilder: (context, index) {
          final unit = units[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppTheme.primaryColor,
                child: Text(
                  '${unit.unitNumber}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text('Unit ${unit.unitNumber} · ${unit.difficulty}'),
              subtitle: Text('${unit.questions.length} questions'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: AppTheme.primaryColor),
                    tooltip: 'Edit',
                    onPressed: () => _openEditor(unit),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppTheme.wrongRed),
                    tooltip: 'Delete',
                    onPressed: () => _delete(unit),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _UnitEditorScreen extends StatefulWidget {
  final Unit? unit;

  const _UnitEditorScreen({this.unit});

  @override
  State<_UnitEditorScreen> createState() => _UnitEditorScreenState();
}

class _UnitEditorScreenState extends State<_UnitEditorScreen> {
  final TextEditingController _numberController = TextEditingController();
  late String _difficulty;
  late final List<Question> _questions;
  bool _saving = false;

  bool get _isNew => widget.unit == null;

  @override
  void initState() {
    super.initState();
    final unit = widget.unit;
    _numberController.text = unit?.unitNumber.toString() ?? '';
    _difficulty = unit?.difficulty ?? 'Beginner';
    _questions = List.from(unit?.questions ?? []);
  }

  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
  }

  Future<void> _editQuestion(int index) async {
    final result = await showDialog<Question>(
      context: context,
      builder: (_) => QuestionEditDialog(initial: _questions[index]),
    );
    if (result != null && mounted) {
      setState(() => _questions[index] = result);
    }
  }

  Future<void> _addQuestion() async {
    final result = await showDialog<Question>(
      context: context,
      builder: (_) => const QuestionEditDialog(),
    );
    if (result != null && mounted) {
      setState(() => _questions.add(result));
    }
  }

  Future<void> _save() async {
    final number = int.tryParse(_numberController.text.trim()) ?? 0;
    if (number <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unit number is required'), behavior: SnackBarBehavior.floating),
      );
      return;
    }
    if (_questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one question'), behavior: SnackBarBehavior.floating),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final content = context.read<ContentProvider>();
      if (_isNew) {
        await content.adminCreateUnit(number, _difficulty, _questions);
      } else {
        await content.adminUpdateUnitMeta(
          widget.unit!.unitNumber,
          difficulty: _difficulty,
          questions: _questions,
        );
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save: $e'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isNew ? 'Add Unit' : 'Edit Unit ${widget.unit!.unitNumber}'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _numberController,
            enabled: _isNew,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Unit number',
              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _difficulty,
            decoration: const InputDecoration(
              labelText: 'Difficulty',
              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
            ),
            items: [
              for (final d in _difficulties)
                DropdownMenuItem(value: d, child: Text(d)),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _difficulty = value);
            },
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Text('Questions (${_questions.length})',
                    style: Theme.of(context).textTheme.titleLarge),
              ),
              TextButton.icon(
                onPressed: _addQuestion,
                icon: const Icon(Icons.add),
                label: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_questions.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text('No questions yet', style: TextStyle(color: Colors.grey)),
            )
          else
            for (int i = 0; i < _questions.length; i++)
              Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 16,
                    backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.12),
                    child: Text('${i + 1}', style: const TextStyle(fontSize: 13)),
                  ),
                  title: Text(_questions[i].word, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Answer: ${_questions[i].answer}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        onPressed: () => _editQuestion(i),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20, color: AppTheme.wrongRed),
                        onPressed: () => setState(() => _questions.removeAt(i)),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

// ---------------- Stories ----------------

class _StoriesTab extends StatefulWidget {
  const _StoriesTab();

  @override
  State<_StoriesTab> createState() => _StoriesTabState();
}

class _StoriesTabState extends State<_StoriesTab> {
  Future<void> _openEditor([Story? story]) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => _StoryEditorScreen(story: story)),
    );
    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Story saved'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  Future<void> _delete(Story story) async {
    final content = context.read<ContentProvider>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete "${story.title}"?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: AppTheme.wrongRed)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final id = story.id;
    try {
      if (id != null) {
        await content.adminDeleteStory(id);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Story deleted'), behavior: SnackBarBehavior.floating),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not delete: $e'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = context.watch<ContentProvider>();
    if (content.loading && content.stories.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    final stories = content.stories;
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(),
        icon: const Icon(Icons.add),
        label: const Text('Add Story'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        itemCount: stories.length,
        itemBuilder: (context, index) {
          final story = stories[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: const Icon(Icons.auto_stories, color: AppTheme.primaryColor),
              title: Text(story.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${story.questions.length} questions'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: AppTheme.primaryColor),
                    tooltip: 'Edit',
                    onPressed: () => _openEditor(story),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppTheme.wrongRed),
                    tooltip: 'Delete',
                    onPressed: () => _delete(story),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StoryEditorScreen extends StatefulWidget {
  final Story? story;

  const _StoryEditorScreen({this.story});

  @override
  State<_StoryEditorScreen> createState() => _StoryEditorScreenState();
}

class _StoryEditorScreenState extends State<_StoryEditorScreen> {
  late final TextEditingController _title;
  late final TextEditingController _content;
  late final List<StoryQuestion> _questions;
  bool _saving = false;

  bool get _isNew => widget.story == null;

  @override
  void initState() {
    super.initState();
    final story = widget.story;
    _title = TextEditingController(text: story?.title ?? '');
    _content = TextEditingController(text: story?.content ?? '');
    _questions = List.from(story?.questions ?? []);
  }

  @override
  void dispose() {
    _title.dispose();
    _content.dispose();
    super.dispose();
  }

  Future<void> _editQuestion(int index) async {
    final result = await showDialog<StoryQuestion>(
      context: context,
      builder: (_) => StoryQuestionEditDialog(initial: _questions[index]),
    );
    if (result != null && mounted) {
      setState(() => _questions[index] = result);
    }
  }

  Future<void> _addQuestion() async {
    final result = await showDialog<StoryQuestion>(
      context: context,
      builder: (_) => const StoryQuestionEditDialog(),
    );
    if (result != null && mounted) {
      setState(() => _questions.add(result));
    }
  }

  Future<void> _save() async {
    if (_title.text.trim().isEmpty || _content.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and content are required'), behavior: SnackBarBehavior.floating),
      );
      return;
    }
    if (_questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one question'), behavior: SnackBarBehavior.floating),
      );
      return;
    }
    setState(() => _saving = true);
    final story = Story(
      id: widget.story?.id,
      title: _title.text.trim(),
      content: _content.text.trim(),
      questions: _questions,
    );
    try {
      final content = context.read<ContentProvider>();
      if (_isNew) {
        await content.adminCreateStory(story);
      } else {
        await content.adminUpdateStory(widget.story!.id!, story);
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save: $e'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isNew ? 'Add Story' : 'Edit Story'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _title,
            decoration: const InputDecoration(
              labelText: 'Title',
              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _content,
            maxLines: 8,
            decoration: const InputDecoration(
              labelText: 'Content (French)',
              alignLabelWithHint: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Text('Questions (${_questions.length})',
                    style: Theme.of(context).textTheme.titleLarge),
              ),
              TextButton.icon(
                onPressed: _addQuestion,
                icon: const Icon(Icons.add),
                label: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_questions.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text('No questions yet', style: TextStyle(color: Colors.grey)),
            )
          else
            for (int i = 0; i < _questions.length; i++)
              Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 16,
                    backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.12),
                    child: Text('${i + 1}', style: const TextStyle(fontSize: 13)),
                  ),
                  title: Text(_questions[i].question,
                      maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Answer: ${_questions[i].correctAnswer}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        onPressed: () => _editQuestion(i),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20, color: AppTheme.wrongRed),
                        onPressed: () => setState(() => _questions.removeAt(i)),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

// ---------------- Courses ----------------

class _CoursesTab extends StatefulWidget {
  const _CoursesTab();

  @override
  State<_CoursesTab> createState() => _CoursesTabState();
}

class _CoursesTabState extends State<_CoursesTab> {
  Future<void> _openEditor([Course? course]) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => _CourseEditorScreen(course: course)),
    );
    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Course saved'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  Future<void> _delete(Course course) async {
    final content = context.read<ContentProvider>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete "${course.title}"?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: AppTheme.wrongRed)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final id = course.id;
    try {
      if (id != null) {
        await content.adminDeleteCourse(id);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Course deleted'), behavior: SnackBarBehavior.floating),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not delete: $e'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = context.watch<ContentProvider>();
    if (content.loading && content.courses.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    final courses = content.courses;
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(),
        icon: const Icon(Icons.add),
        label: const Text('Add Course'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        itemCount: courses.length,
        itemBuilder: (context, index) {
          final course = courses[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: const Icon(Icons.school_outlined, color: AppTheme.primaryColor),
              title: Text(course.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${course.lessons.length} lessons · ${course.questions.length} questions'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: AppTheme.primaryColor),
                    tooltip: 'Edit',
                    onPressed: () => _openEditor(course),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppTheme.wrongRed),
                    tooltip: 'Delete',
                    onPressed: () => _delete(course),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CourseEditorScreen extends StatefulWidget {
  final Course? course;

  const _CourseEditorScreen({this.course});

  @override
  State<_CourseEditorScreen> createState() => _CourseEditorScreenState();
}

class _CourseEditorScreenState extends State<_CourseEditorScreen> {
  late final TextEditingController _title;
  late final TextEditingController _description;
  late String _iconKey;
  late final List<CourseLesson> _lessons;
  late final List<Question> _questions;
  bool _saving = false;

  bool get _isNew => widget.course == null;

  @override
  void initState() {
    super.initState();
    final course = widget.course;
    _title = TextEditingController(text: course?.title ?? '');
    _description = TextEditingController(text: course?.description ?? '');
    _iconKey = course?.iconKey ?? 'school';
    _lessons = List.from(course?.lessons ?? []);
    _questions = List.from(course?.questions ?? []);
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _editLesson(int index) async {
    final result = await _showLessonDialog(_lessons[index]);
    if (result != null && mounted) {
      setState(() => _lessons[index] = result);
    }
  }

  Future<void> _addLesson() async {
    final result = await _showLessonDialog();
    if (result != null && mounted) {
      setState(() => _lessons.add(result));
    }
  }

  Future<CourseLesson?> _showLessonDialog([CourseLesson? lesson]) {
    return showDialog<CourseLesson>(
      context: context,
      builder: (_) => _CourseLessonEditDialog(initial: lesson),
    );
  }

  Future<void> _editQuestion(int index) async {
    final result = await showDialog<Question>(
      context: context,
      builder: (_) => QuestionEditDialog(initial: _questions[index]),
    );
    if (result != null && mounted) {
      setState(() => _questions[index] = result);
    }
  }

  Future<void> _addQuestion() async {
    final result = await showDialog<Question>(
      context: context,
      builder: (_) => const QuestionEditDialog(),
    );
    if (result != null && mounted) {
      setState(() => _questions.add(result));
    }
  }

  Future<void> _save() async {
    if (_title.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title is required'), behavior: SnackBarBehavior.floating),
      );
      return;
    }
    if (_lessons.isEmpty || _questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one lesson and one question'), behavior: SnackBarBehavior.floating),
      );
      return;
    }
    setState(() => _saving = true);
    final course = Course(
      id: widget.course?.id,
      title: _title.text.trim(),
      description: _description.text.trim(),
      iconKey: _iconKey,
      lessons: _lessons,
      questions: _questions,
    );
    try {
      final content = context.read<ContentProvider>();
      if (_isNew) {
        await content.adminCreateCourse(course);
      } else {
        await content.adminUpdateCourse(widget.course!.id!, course);
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save: $e'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isNew ? 'Add Course' : 'Edit Course'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _title,
            decoration: const InputDecoration(
              labelText: 'Title',
              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _description,
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _iconKey,
            decoration: const InputDecoration(
              labelText: 'Icon',
              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
            ),
            items: const [
              DropdownMenuItem(value: 'school', child: Text('School')),
              DropdownMenuItem(value: 'question', child: Text('Question')),
              DropdownMenuItem(value: 'quiz', child: Text('Quiz')),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _iconKey = value);
            },
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Text('Lessons (${_lessons.length})',
                    style: Theme.of(context).textTheme.titleLarge),
              ),
              TextButton.icon(
                onPressed: _addLesson,
                icon: const Icon(Icons.add),
                label: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_lessons.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text('No lessons yet', style: TextStyle(color: Colors.grey)),
            )
          else
            for (int i = 0; i < _lessons.length; i++)
              Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 16,
                    backgroundColor: AppTheme.accentColor.withValues(alpha: 0.15),
                    child: Text('${i + 1}', style: const TextStyle(fontSize: 13)),
                  ),
                  title: Text(_lessons[i].title,
                      maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        onPressed: () => _editLesson(i),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20, color: AppTheme.wrongRed),
                        onPressed: () => setState(() => _lessons.removeAt(i)),
                      ),
                    ],
                  ),
                ),
              ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Text('Questions (${_questions.length})',
                    style: Theme.of(context).textTheme.titleLarge),
              ),
              TextButton.icon(
                onPressed: _addQuestion,
                icon: const Icon(Icons.add),
                label: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_questions.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text('No questions yet', style: TextStyle(color: Colors.grey)),
            )
          else
            for (int i = 0; i < _questions.length; i++)
              Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 16,
                    backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.12),
                    child: Text('${i + 1}', style: const TextStyle(fontSize: 13)),
                  ),
                  title: Text(_questions[i].word, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Answer: ${_questions[i].answer}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        onPressed: () => _editQuestion(i),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20, color: AppTheme.wrongRed),
                        onPressed: () => setState(() => _questions.removeAt(i)),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class _CourseLessonEditDialog extends StatefulWidget {
  final CourseLesson? initial;

  const _CourseLessonEditDialog({this.initial});

  @override
  State<_CourseLessonEditDialog> createState() => _CourseLessonEditDialogState();
}

class _CourseLessonEditDialogState extends State<_CourseLessonEditDialog> {
  late final TextEditingController _title;
  late final TextEditingController _content;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.initial?.title ?? '');
    _content = TextEditingController(text: widget.initial?.content ?? '');
  }

  @override
  void dispose() {
    _title.dispose();
    _content.dispose();
    super.dispose();
  }

  void _save() {
    if (_title.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lesson title is required'), behavior: SnackBarBehavior.floating),
      );
      return;
    }
    Navigator.pop(
      context,
      CourseLesson(title: _title.text.trim(), content: _content.text.trim()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(widget.initial == null ? 'Add Lesson' : 'Edit Lesson'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _title,
            decoration: const InputDecoration(labelText: 'Lesson title'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _content,
            maxLines: 6,
            decoration: const InputDecoration(labelText: 'Content'),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}
