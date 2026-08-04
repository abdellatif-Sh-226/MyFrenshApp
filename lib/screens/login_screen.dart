import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/content_provider.dart';
import '../providers/friends_provider.dart';
import '../providers/progress_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    if (username.isEmpty || password.isEmpty) {
      setState(() => _error = 'Please enter a username and password.');
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    final auth = context.read<AuthProvider>();
    final String? error =
        _isLogin ? await auth.login(username, password) : await auth.register(username, password);

    if (!mounted) return;

    if (error != null) {
      setState(() {
        _submitting = false;
        _error = error;
      });
      return;
    }

    final progress = context.read<ProgressProvider>();
    final content = context.read<ContentProvider>();
    final friends = context.read<FriendsProvider>();
    await Future.wait([
      progress.loadProgress(),
      content.loadAll(),
      friends.loadAll(),
    ]);
    if (!mounted) return;
    setState(() => _submitting = false);
  }

  Future<void> _continueOffline() async {
    final auth = context.read<AuthProvider>();
    final progress = context.read<ProgressProvider>();
    final content = context.read<ContentProvider>();
    await auth.skipLogin();
    await Future.wait([progress.loadProgress(), content.loadAll()]);
  }

  void _toggleMode() {
    setState(() {
      _isLogin = !_isLogin;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.menu_book,
                    size: 72,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppConstants.appName,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isLogin ? 'Sign in to sync your progress' : 'Create a free account',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDark ? Colors.white60 : Colors.grey.shade600,
                        ),
                  ),
                  const SizedBox(height: 32),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextField(
                            controller: _usernameController,
                            enabled: !_submitting,
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
                          const SizedBox(height: 16),
                          TextField(
                            controller: _passwordController,
                            enabled: !_submitting,
                            obscureText: true,
                            onSubmitted: (_) => _submit(),
                            decoration: const InputDecoration(
                              labelText: 'Password',
                              prefixIcon: Icon(Icons.lock_outline),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(16)),
                              ),
                            ),
                          ),
                          if (_error != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.wrongRed.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline,
                                      color: AppTheme.wrongRed, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _error!,
                                      style: const TextStyle(
                                        color: AppTheme.wrongRed,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _submitting ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: _submitting
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(_isLogin ? 'Sign In' : 'Sign Up'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _submitting ? null : _toggleMode,
                    child: Text(
                      _isLogin
                          ? "Don't have an account? Sign up"
                          : 'Already have an account? Sign in',
                    ),
                  ),
                  const SizedBox(height: 4),
                  TextButton.icon(
                    onPressed: _submitting ? null : _continueOffline,
                    icon: const Icon(Icons.offline_bolt_outlined, size: 18),
                    label: const Text('Continue without account'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
