import 'package:flutter/material.dart';

import '../services/api.dart';
import '../theme/app_theme.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _repeatPasswordController = TextEditingController();

  bool _busy = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureRepeat = true;
  String? _err;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _repeatPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (_busy) return;

    FocusScope.of(context).unfocus();

    final currentPassword = _currentPasswordController.text;
    final newPassword = _newPasswordController.text;
    final repeatPassword = _repeatPasswordController.text;

    if (currentPassword.isEmpty || newPassword.isEmpty || repeatPassword.isEmpty) {
      setState(() {
        _err = 'Заполни все поля';
      });
      return;
    }

    if (newPassword.length < 6) {
      setState(() {
        _err = 'Новый пароль должен быть не короче 6 символов';
      });
      return;
    }

    if (newPassword != repeatPassword) {
      setState(() {
        _err = 'Новые пароли не совпадают';
      });
      return;
    }

    if (currentPassword == newPassword) {
      setState(() {
        _err = 'Новый пароль должен отличаться от текущего';
      });
      return;
    }

    setState(() {
      _busy = true;
      _err = null;
    });

    try {
      await Api.instance.post('/auth/change-password', {
        'current_password': currentPassword,
        'new_password': newPassword,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пароль изменён')),
      );

      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _err = e.toString().replaceFirst('Exception: ', '');
        _busy = false;
      });
    }
  }

  InputDecoration _passwordDecoration({
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: const Icon(Icons.key_rounded),
      suffixIcon: IconButton(
        onPressed: _busy ? null : onToggle,
        icon: Icon(
          obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Смена пароля'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(
                        Icons.lock_reset_rounded,
                        size: 54,
                        color: AppTheme.primary,
                      ),

                      const SizedBox(height: 14),

                      const Text(
                        'Смена пароля',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'Укажи текущий пароль и задай новый.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 22),

                      if (_err != null)
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEECEC),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            _err!,
                            style: const TextStyle(
                              color: AppTheme.danger,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                      TextField(
                        controller: _currentPasswordController,
                        enabled: !_busy,
                        obscureText: _obscureCurrent,
                        textInputAction: TextInputAction.next,
                        decoration: _passwordDecoration(
                          label: 'Текущий пароль',
                          obscure: _obscureCurrent,
                          onToggle: () {
                            setState(() {
                              _obscureCurrent = !_obscureCurrent;
                            });
                          },
                        ),
                      ),

                      const SizedBox(height: 14),

                      TextField(
                        controller: _newPasswordController,
                        enabled: !_busy,
                        obscureText: _obscureNew,
                        textInputAction: TextInputAction.next,
                        decoration: _passwordDecoration(
                          label: 'Новый пароль',
                          obscure: _obscureNew,
                          onToggle: () {
                            setState(() {
                              _obscureNew = !_obscureNew;
                            });
                          },
                        ),
                      ),

                      const SizedBox(height: 14),

                      TextField(
                        controller: _repeatPasswordController,
                        enabled: !_busy,
                        obscureText: _obscureRepeat,
                        onSubmitted: (_) => _changePassword(),
                        decoration: _passwordDecoration(
                          label: 'Повтори новый пароль',
                          obscure: _obscureRepeat,
                          onToggle: () {
                            setState(() {
                              _obscureRepeat = !_obscureRepeat;
                            });
                          },
                        ),
                      ),

                      const SizedBox(height: 22),

                      FilledButton(
                        onPressed: _busy ? null : _changePassword,
                        child: Text(_busy ? 'Сохранение...' : 'Изменить пароль'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}