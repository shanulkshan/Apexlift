import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';

/// ExerciseDB animations are drawn on white, so they always sit on a white
/// tile (also in dark mode). Cached to disk so they work offline once seen.
class ExerciseGif extends ConsumerWidget {
  const ExerciseGif({
    super.key,
    required this.url,
    required this.size,
    this.radius = 12,
  });

  final String url;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Custom exercises have no animation: show a branded tile instead.
    if (url.isEmpty) {
      final theme = Theme.of(context);
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary.withValues(alpha: 0.35),
                theme.colorScheme.primary.withValues(alpha: 0.12),
              ],
            ),
          ),
          child: Icon(Icons.fitness_center_rounded,
              size: size * 0.4, color: theme.colorScheme.onSurface),
        ),
      );
    }
    final dpr = MediaQuery.devicePixelRatioOf(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: ColoredBox(
        color: Colors.white,
        child: SizedBox.square(
          dimension: size,
          child: CachedNetworkImage(
            imageUrl: url,
            cacheManager: ref.watch(gifCacheManagerProvider),
            fit: BoxFit.contain,
            memCacheWidth: (size * dpr).round(),
            placeholder: (_, _) => const Center(
              child: SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            errorWidget: (_, _, _) =>
                const Icon(Icons.fitness_center, color: Colors.black26),
          ),
        ),
      ),
    );
  }
}
