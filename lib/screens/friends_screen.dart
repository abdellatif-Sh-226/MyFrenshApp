import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/friends_provider.dart';
import '../widgets/user_avatar.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final friends = context.read<FriendsProvider>();
      if (!friends.loading) friends.loadAll();
    });
  }

  Future<void> _showAddFriendDialog() async {
    final controller = TextEditingController();
    final friends = context.read<FriendsProvider>();
    final String? result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Add a friend'),
        content: TextField(
          controller: controller,
          autocorrect: false,
          textCapitalization: TextCapitalization.none,
          decoration: const InputDecoration(
            labelText: 'Username',
            prefixIcon: Icon(Icons.person_outline),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Send'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (result == null || result.isEmpty) return;

    final error = await friends.sendRequest(result);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error ?? 'Friend request sent to $result'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final friends = context.watch<FriendsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt),
            tooltip: 'Add a friend',
            onPressed: auth.isOnline ? _showAddFriendDialog : null,
          ),
        ],
      ),
      floatingActionButton: auth.isOnline
          ? FloatingActionButton.extended(
              onPressed: _showAddFriendDialog,
              icon: const Icon(Icons.person_add_alt),
              label: const Text('Add friend'),
            )
          : null,
      body: !auth.isOnline
          ? _buildOffline(context)
          : friends.loading && friends.friends.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : _buildContent(context, friends),
    );
  }

  Widget _buildOffline(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.group_outlined, size: 64, color: AppTheme.primaryColor),
            const SizedBox(height: 16),
            Text(
              'Sign in to use friends',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Add friends and compare your scores on the leaderboard.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, FriendsProvider friends) {
    final error = friends.error;
    return RefreshIndicator(
      onRefresh: friends.loadAll,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                error,
                style: const TextStyle(color: AppTheme.wrongRed),
              ),
            ),
          _buildSectionHeader(context, 'Leaderboard'),
          const SizedBox(height: 8),
          ..._buildLeaderboard(context, friends),
          const SizedBox(height: 24),
          _buildSectionHeader(context, 'Friend requests'),
          const SizedBox(height: 8),
          if (friends.incoming.isEmpty)
            _emptyRow(context, 'No pending requests')
          else
            ...friends.incoming.map((r) => _buildRequestCard(context, friends, r)),
          const SizedBox(height: 24),
          _buildSectionHeader(context, 'My friends'),
          const SizedBox(height: 8),
          if (friends.friends.isEmpty)
            _emptyRow(context, 'No friends yet - add one above')
          else
            ...friends.friends.map((f) => _buildFriendCard(context, f)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _emptyRow(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
      ),
    );
  }

  List<Widget> _buildLeaderboard(BuildContext context, FriendsProvider friends) {
    if (friends.leaderboard.isEmpty) {
      return [_emptyRow(context, 'No players yet')];
    }
    return [
      Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Column(
          children: [
            for (int i = 0; i < friends.leaderboard.length; i++)
              _leaderboardRow(context, i + 1, friends.leaderboard[i]),
          ],
        ),
      ),
    ];
  }

  Widget _leaderboardRow(BuildContext context, int rank, Map<String, dynamic> row) {
    final score = (row['score'] as num?)?.toInt() ?? 0;
    return ListTile(
      leading: UserAvatar(
        base64Photo: row['profilePhoto'] as String?,
        username: row['username'] as String? ?? '?',
        isOnline: row['online'] == true,
        size: 40,
        showOnlineIndicator: true,
      ),
      title: Text(
        row['username'] as String? ?? '?',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      trailing: Text(
        '$score pts',
        style: const TextStyle(
          color: AppTheme.primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildRequestCard(
    BuildContext context,
    FriendsProvider friends,
    Map<String, dynamic> request,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            UserAvatar(
              base64Photo: request['fromProfilePhoto'] as String?,
              username: request['from'] as String? ?? '?',
              isOnline: request['fromOnline'] == true,
              size: 40,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    request['from'] as String? ?? '?',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (request['fromOnline'] == true)
                    Text(
                      'Online',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.correctGreen,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.check_circle, color: AppTheme.correctGreen),
              tooltip: 'Accept',
              onPressed: () => friends.acceptRequest((request['id'] as num).toInt()),
            ),
            IconButton(
              icon: const Icon(Icons.cancel, color: AppTheme.wrongRed),
              tooltip: 'Decline',
              onPressed: () => friends.declineRequest((request['id'] as num).toInt()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFriendCard(BuildContext context, Map<String, dynamic> friend) {
    final score = (friend['score'] as num?)?.toInt() ?? 0;
    final isOnline = friend['online'] == true;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: UserAvatar(
          base64Photo: friend['profilePhoto'] as String?,
          username: friend['username'] as String? ?? '?',
          isOnline: isOnline,
          size: 44,
        ),
        title: Text(
          friend['username'] as String? ?? '?',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: isOnline
            ? const Text(
                'Online',
                style: TextStyle(
                  color: AppTheme.correctGreen,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              )
            : null,
        trailing: Text(
          '$score pts',
          style: const TextStyle(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
