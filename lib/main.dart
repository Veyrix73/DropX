import 'package:flutter/material.dart';

import 'screens/activity_screen.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'settings/app_settings.dart';
import 'theme/dropx_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settings = await AppSettings.load();
  runApp(DropXApp(settings: settings));
}

class DropXApp extends StatelessWidget {
  const DropXApp({super.key, required this.settings});
  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: settings,
      builder: (context, _) => MaterialApp(
        title: 'DropX',
        debugShowCheckedModeBanner: false,
        theme: DropXTheme.build(Brightness.light, settings.accentColor),
        darkTheme: DropXTheme.build(Brightness.dark, settings.accentColor),
        themeMode: settings.themeMode,
        home: AppShell(settings: settings),
      ),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.settings});
  final AppSettings settings;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  static const _items = [
    (label: 'Home', icon: Icons.grid_view_rounded),
    (label: 'Activity', icon: Icons.swap_horiz_rounded),
    (label: 'Settings', icon: Icons.tune_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 900;
        final pages = [
          HomeScreen(settings: widget.settings),
          const ActivityScreen(),
          SettingsScreen(settings: widget.settings),
        ];

        return Scaffold(
          body: SafeArea(
            child: Row(
              children: [
                if (wide) _sideNavigation(context),
                Expanded(
                  child: IndexedStack(index: _index, children: pages),
                ),
              ],
            ),
          ),
          bottomNavigationBar: wide
              ? null
              : NavigationBar(
                  selectedIndex: _index,
                  onDestinationSelected: (value) =>
                      setState(() => _index = value),
                  destinations: _items
                      .map((item) => NavigationDestination(
                            icon: Icon(item.icon),
                            label: item.label,
                          ))
                      .toList(),
                ),
        );
      },
    );
  }

  Widget _sideNavigation(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 238,
      padding: const EdgeInsets.fromLTRB(21, 28, 13, 20),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.sync_alt_rounded,
                  color: theme.colorScheme.onPrimary,
                  size: 25,
                ),
              ),
              const SizedBox(width: 11),
              const Text(
                'DropX',
                style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 48),
          Padding(
            padding: const EdgeInsets.only(left: 12, bottom: 12),
            child: Text(
              'WORKSPACE',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                letterSpacing: 1.4,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          for (var i = 0; i < _items.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Material(
                color: _index == i
                    ? theme.colorScheme.primary.withOpacity(0.13)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(15),
                child: InkWell(
                  onTap: () => setState(() => _index = i),
                  borderRadius: BorderRadius.circular(15),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 13, vertical: 14),
                    child: Row(
                      children: [
                        Icon(
                          _items[i].icon,
                          size: 21,
                          color: _index == i
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 13),
                        Text(
                          _items[i].label,
                          style: TextStyle(
                            fontWeight: _index == i
                                ? FontWeight.w900
                                : FontWeight.w600,
                            color: _index == i
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest
                  .withOpacity(0.55),
              borderRadius: BorderRadius.circular(19),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.shield_outlined,
                    color: theme.colorScheme.primary),
                const SizedBox(height: 10),
                const Text('Your files stay yours.',
                    style: TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 5),
                Text(
                  'Transfer security is being built.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
