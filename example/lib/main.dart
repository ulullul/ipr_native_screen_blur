import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ipr_screen_blur/ipr_screen_blur.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _secureScreen = SecureScreen();
  final _log = <String>[];
  StreamSubscription<SecureScreenEvent>? _subscription;
  bool _secureMode = false;
  bool _captured = false;

  @override
  void initState() {
    super.initState();
    _subscription = _secureScreen.events.listen(_onEvent);
    _refreshCaptured();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _onEvent(SecureScreenEvent event) {
    setState(() {
      _log.insert(0, '${_timestamp()}  $event');
      if (event case CaptureStateChanged(:final captured)) {
        _captured = captured;
      }
    });
  }

  Future<void> _refreshCaptured() async {
    final captured = await _secureScreen.isScreenCaptured();
    if (!mounted) return;
    setState(() => _captured = captured);
  }

  Future<void> _setSecureMode(bool enabled) async {
    try {
      await _secureScreen.setSecureMode(enabled);
      if (!mounted) return;
      setState(() {
        _secureMode = enabled;
        _log.insert(0, '${_timestamp()}  setSecureMode($enabled)');
      });
    } on PlatformException catch (e) {
      if (!mounted) return;
      setState(() => _log.insert(0, '${_timestamp()}  error: ${e.message}'));
    }
  }

  static String _timestamp() {
    final now = DateTime.now();
    String two(int value) => value.toString().padLeft(2, '0');
    return '${two(now.hour)}:${two(now.minute)}:${two(now.second)}';
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('ipr_screen_blur example')),
        body: Column(
          children: [
            SwitchListTile(
              title: const Text('Secure mode'),
              subtitle: const Text('Block screenshots, hide app switcher'),
              value: _secureMode,
              onChanged: _setSecureMode,
            ),
            ListTile(
              leading: Icon(
                _captured ? Icons.fiber_manual_record : Icons.circle_outlined,
                color: _captured ? Colors.red : null,
              ),
              title: Text(
                _captured ? 'Screen is being captured' : 'Not captured',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh',
                onPressed: _refreshCaptured,
              ),
            ),
            const Divider(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Event log'),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _log.length,
                itemBuilder: (context, index) => ListTile(
                  dense: true,
                  title: Text(
                    _log[index],
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
