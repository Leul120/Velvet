import 'package:flutter/material.dart';
import 'package:velvet_mobile/core/security/app_lock_service.dart';

class AppLockScreen extends StatefulWidget {
  const AppLockScreen({super.key, required this.child});

  final Widget child;

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen> {
  String _enteredPin = '';
  bool _showError = false;

  @override
  void initState() {
    super.initState();
    AppLockService.instance.addListener(_onLockStateChanged);
  }

  @override
  void dispose() {
    AppLockService.instance.removeListener(_onLockStateChanged);
    super.dispose();
  }

  void _onLockStateChanged() {
    if (mounted) setState(() {});
  }

  void _onKeyPress(String digit) {
    if (_enteredPin.length < 4) {
      setState(() {
        _showError = false;
        _enteredPin += digit;
      });

      if (_enteredPin.length == 4) {
        final success = AppLockService.instance.verifyPin(_enteredPin);
        if (!success) {
          setState(() {
            _showError = true;
            _enteredPin = '';
          });
        }
      }
    }
  }

  void _onDelete() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLocked = AppLockService.instance.isLocked;

    return Stack(
      children: [
        widget.child,
        if (isLocked)
          Scaffold(
            backgroundColor: const Color(0xFF0A0A0C),
            body: SafeArea(
              child: Column(
                children: [
                  const Spacer(),
                  const Icon(
                    Icons.lock_outline_rounded,
                    size: 48,
                    color: Color(0xFFEA580C),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'VELVET Discreet Lock',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _showError
                        ? 'Incorrect PIN. Try again.'
                        : 'Enter your 4-digit PIN to continue',
                    style: TextStyle(
                      fontSize: 13,
                      color: _showError ? Colors.redAccent : Colors.white54,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // PIN Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (index) {
                      final filled = index < _enteredPin.length;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: filled ? const Color(0xFFEA580C) : Colors.transparent,
                          border: Border.all(
                            color: filled ? const Color(0xFFEA580C) : Colors.white38,
                            width: 2,
                          ),
                        ),
                      );
                    }),
                  ),

                  const Spacer(),

                  // Keypad Grid
                  Container(
                    maxWidth: 280,
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      children: [
                        for (var row in [
                          ['1', '2', '3'],
                          ['4', '5', '6'],
                          ['7', '8', '9'],
                          ['', '0', 'del']
                        ])
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: row.map((key) {
                                if (key.isEmpty) {
                                  return const SizedBox(width: 64, height: 64);
                                }
                                if (key == 'del') {
                                  return IconButton(
                                    onPressed: _onDelete,
                                    icon: const Icon(Icons.backspace_outlined, color: Colors.white70),
                                    iconSize: 24,
                                  );
                                }
                                return InkWell(
                                  onTap: () => _onKeyPress(key),
                                  borderRadius: BorderRadius.circular(32),
                                  child: Container(
                                    width: 64,
                                    height: 64,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withOpacity(0.06),
                                      border: Border.all(color: Colors.white10),
                                    ),
                                    child: Text(
                                      key,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
