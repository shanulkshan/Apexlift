import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../core/router/app_router.dart';
import '../../core/widgets/glass/glass_sheet.dart';
import '../../l10n/app_localizations.dart';

/// Starts a workout (empty, or from [routineId]) and opens it. If one is
/// already running, offers to resume it instead of starting another.
Future<void> startWorkout(
  BuildContext context,
  WidgetRef ref, {
  int? routineId,
}) async {
  final l10n = AppLocalizations.of(context);
  final repo = ref.read(workoutRepositoryProvider);

  final active = await repo.active();
  if (!context.mounted) return;
  if (active != null) {
    final resume = await showGlassConfirm(
      context: context,
      title: l10n.alreadyActiveTitle,
      message: l10n.alreadyActiveBody,
      confirmLabel: l10n.workoutsResume,
      cancelLabel: l10n.cancel,
    );
    if (resume && context.mounted) context.push(AppRoutes.workout);
    return;
  }

  HapticFeedback.mediumImpact();
  if (routineId == null) {
    await repo.startEmpty(name: l10n.workoutDefaultName);
  } else {
    await repo.startFromRoutine(routineId);
  }
  if (context.mounted) context.push(AppRoutes.workout);
}
