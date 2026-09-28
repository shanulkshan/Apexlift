/// Kind of set. Warm-ups are excluded from volume and PRs later on.
enum SetType {
  warmup,
  working,
  drop,
  failure;

  /// Cycles to the next type (tap-to-change in the set row).
  SetType get next => values[(index + 1) % values.length];

  bool get countsTowardVolume => this != warmup;
}
