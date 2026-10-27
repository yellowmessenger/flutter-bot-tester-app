import 'dart:async';

import 'package:flutter/material.dart';

import 'chatbot.dart';
import 'push.dart';
import 'screens/info_screen.dart';
import 'screens/profile_list_screen.dart';
import 'screens/quick_start_screen.dart';
import 'widgets.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const YellowBotApp());
  initPush();
}

class YellowBotApp extends StatelessWidget {
  const YellowBotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yellow Bot Flutter',
      theme: ThemeData(
        // fidelity keeps the brand orange instead of muting it to brown.
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF97316),
          dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
        ),
      ),
      home: const HomeTabs(),
    );
  }
}

/// Quick Start, Profiles and Info tabs, like the iOS tester app.
class HomeTabs extends StatefulWidget {
  const HomeTabs({super.key});

  @override
  State<HomeTabs> createState() => _HomeTabsState();
}

class _HomeTabsState extends State<HomeTabs> {
  int _tab = 0;
  final _subscriptions = <StreamSubscription<dynamic>>[];

  @override
  void initState() {
    super.initState();
    _subscriptions.addAll([
      Chatbot.events.listen((event) {
        final e = event as Map;
        debugPrint('[YMChat] event ${e['code']} ${e['data']}');
      }),
      Chatbot.closeEvents.listen((_) => debugPrint('[YMChat] bot closed')),
      Chatbot.loadFailedEvents.listen((_) {
        if (mounted) {
          showErrorAlert(
              context, 'Bot failed to load. Check the bot id and network.');
        }
      }),
    ]);
  }

  @override
  void dispose() {
    for (final s in _subscriptions) {
      s.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _tab,
        children: const [
          QuickStartScreen(),
          ProfileListScreen(),
          InfoScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.bolt), label: 'Quick Start'),
          NavigationDestination(
              icon: Icon(Icons.view_agenda_outlined), label: 'Profiles'),
          NavigationDestination(icon: Icon(Icons.info_outline), label: 'Info'),
        ],
      ),
    );
  }
}
