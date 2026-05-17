import 'package:flutter/material.dart';

import 'screens/chats.dart';
import 'screens/login.dart';
import 'services/session.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Session.instance.init();
  } catch (e) {
    debugPrint('Session init failed: $e');
  }

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final isAuthed = Session.instance.isAuthed;

    return MaterialApp(
      title: 'Защищённый чат',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: isAuthed ? const ChatsScreen() : const LoginScreen(),
    );
  }
}