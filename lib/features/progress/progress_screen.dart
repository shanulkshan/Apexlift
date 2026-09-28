import 'package:flutter/material.dart';

import '../../core/widgets/coming_soon_view.dart';
import '../../l10n/app_localizations.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ComingSoonView(
      title: l10n.navProgress,
      icon: Icons.insights,
      message: l10n.progressComingSoon,
    );
  }
}
