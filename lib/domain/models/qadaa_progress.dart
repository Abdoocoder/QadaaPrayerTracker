class QadaaProgress {
  final int totalMissed;
  final int completed;

  const QadaaProgress({
    required this.totalMissed,
    required this.completed,
  });

  int get remaining => totalMissed - completed;
  double get percentage => totalMissed > 0 ? (completed / totalMissed) * 100 : 0;
  bool get isComplete => remaining <= 0;
}
