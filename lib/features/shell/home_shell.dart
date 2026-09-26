import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/glass/glass_nav_bar.dart';
import '../../l10n/app_localizations.dart';
import '../library/library_providers.dart';

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  @override
  void initState() {
    super.initState();
    // Fetch the exercise catalog in the background on first launch (and
    // resume it if a previous download was interrupted).
    Future.microtask(() => ref.read(catalogSyncProvider.notifier).sync());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final shell = widget.navigationShell;
    return Scaffold(
      extendBody: true, // content scrolls behind the floating glass bar
      body: shell,
      bottomNavigationBar: GlassNavBar(
        selectedIndex: shell.currentIndex,
        onSelected: (i) =>
            shell.goBranch(i, initialLocation: i == shell.currentIndex),
        items: [
          GlassNavItem(
            icon: Icons.bolt_outlined,
            selectedIcon: Icons.bolt_rounded,
            label: l10n.navToday,
          ),
          GlassNavItem(
            icon: Icons.menu_book_outlined,
            selectedIcon: Icons.menu_book_rounded,
            label: l10n.navLibrary,
          ),
          GlassNavItem(
            icon: Icons.fitness_center_outlined,
            selectedIcon: Icons.fitness_center_rounded,
            label: l10n.navWorkouts,
          ),
          GlassNavItem(
            icon: Icons.insights_outlined,
            selectedIcon: Icons.insights_rounded,
            label: l10n.navProgress,
          ),
          GlassNavItem(
            icon: Icons.person_outline_rounded,
            selectedIcon: Icons.person_rounded,
            label: l10n.navProfile,
          ),
        ],
      ),
    );
  }
}
