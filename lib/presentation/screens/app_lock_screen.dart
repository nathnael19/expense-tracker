import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../data/services/security_service.dart';

class AppLockScreen extends StatefulWidget {
  final VoidCallback onAuthenticated;

  const AppLockScreen({super.key, required this.onAuthenticated});

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen> {
  bool _isAuthenticating = false;
  String _message = 'Locked';

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    final available = await SecurityService.isBiometricAvailable();
    if (available && mounted) {
      // Small delay to ensure the activity is fully ready to show the prompt
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) _authenticate();
    } else {
      setState(() {
        _message = 'Biometrics not available or not set up.';
      });
    }
  }

  Future<void> _authenticate() async {
    setState(() {
      _isAuthenticating = true;
      _message = 'Authenticating...';
    });

    final authenticated = await SecurityService.authenticate();

    if (authenticated) {
      widget.onAuthenticated();
    } else {
      setState(() {
        _isAuthenticating = false;
        _message = 'Authentication failed. Tap to retry.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 80, color: Colors.grey),
            const Gap(24),
            Text(
              'Expense Tracker Locked',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const Gap(16),
            Text(_message, style: const TextStyle(color: Colors.grey)),
            const Gap(32),
            if (!_isAuthenticating)
              ElevatedButton.icon(
                onPressed: _authenticate,
                icon: const Icon(Icons.fingerprint),
                label: const Text('Unlock'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
