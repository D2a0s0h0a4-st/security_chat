import 'package:flutter/material.dart';

import '../services/api.dart';
import '../services/session.dart';
import '../theme/app_theme.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  bool _loading = true;
  String? _err;
  List<Map<String, dynamic>> _users = [];

  final Map<String, String> _roles = const {
    'admin': 'Администратор',
    'manager': 'Руководитель',
    'employee': 'Сотрудник',
  };

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _err = null;
    });

    try {
      final res = await Api.instance.getList('/admin/users');

      if (!mounted) return;

      setState(() {
        _users = res.cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _err = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  Future<void> _changeRole(Map<String, dynamic> user, String newRole) async {
    final id = user['id'];

    if (id is! int) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось определить пользователя')),
      );
      return;
    }

    final oldRole = (user['role'] ?? 'employee').toString();

    if (oldRole == newRole) return;

    if (id == Session.instance.userId && newRole != 'admin') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Нельзя снять роль администратора с самого себя'),
        ),
      );
      return;
    }

    try {
      await Api.instance.put(
        '/admin/users/$id/role',
        {'role': newRole},
      );

      await _loadUsers();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Роль пользователя обновлена')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ошибка изменения роли: ${e.toString().replaceFirst('Exception: ', '')}',
          ),
        ),
      );
    }
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final username = (user['username'] ?? '').toString();
    final role = (user['role'] ?? 'employee').toString();
    final isMe = user['id'] == Session.instance.userId;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            CircleAvatar(
              child: Icon(
                role == 'admin'
                    ? Icons.admin_panel_settings_outlined
                    : role == 'manager'
                        ? Icons.manage_accounts_outlined
                        : Icons.person_outline_rounded,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          username,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 8),
                        const Chip(
                          label: Text('Вы'),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _roles[role] ?? role,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            DropdownButton<String>(
              value: _roles.containsKey(role) ? role : 'employee',
              underline: const SizedBox.shrink(),
              items: _roles.entries
                  .map(
                    (entry) => DropdownMenuItem<String>(
                      value: entry.key,
                      child: Text(entry.value),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                _changeRole(user, value);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Права доступа'),
        actions: [
          IconButton(
            tooltip: 'Обновить',
            onPressed: _loadUsers,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _err != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        _err!,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadUsers,
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        const Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              'Здесь администратор может назначать роли пользователям. '
                              'Руководитель может создавать групповые чаты, сотрудник — только личные.',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        if (_users.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(24),
                            child: Center(
                              child: Text('Пользователи не найдены'),
                            ),
                          )
                        else
                          ..._users.map(_buildUserCard),
                      ],
                    ),
                  ),
      ),
    );
  }
}