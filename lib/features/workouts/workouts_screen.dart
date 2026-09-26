import 'package:flutter/material.dart';

import '../../core/widgets/coming_soon_view.dart';
import '../../l10n/app_localizations.dart';

class WorkoutsScreen extends StatelessWidget {
  const WorkoutsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ComingSoonView(
      title: l10n.navWorkouts,
      icon: Icons.fitness_center,
      message: l10n.workoutsComingSoon,
    );
  }
}
