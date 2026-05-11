import 'package:flutter/material.dart';
import '../services/lock_service.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key, required this.onUnlocked});

  final VoidCallback onUnlocked;

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  bool _attempting = false;
  bool _retryAvailable = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _tryUnlock());
  }

  Future<void> _tryUnlock() async {
    if (_attempting) return;
    setState(() {
      _attempting = true;
      _retryAvailable = false;
    });
    final ok = await tryAuthenticate();
    if (!mounted) return;
    if (ok) {
      widget.onUnlocked();
    } else {
      setState(() {
        _attempting = false;
        _retryAvailable = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('images/Logo_icon.png', width: 160),
              const SizedBox(height: 32),
              const Text(
                'EmberSpark',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('Locked', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 48),
              if (_attempting)
                const CircularProgressIndicator()
              else
                ElevatedButton.icon(
                  icon: const Icon(Icons.lock_open),
                  label: Text(_retryAvailable ? 'Try again' : 'Unlock'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                  ),
                  onPressed: _tryUnlock,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
