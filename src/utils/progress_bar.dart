import 'dart:io';

class ProgressBar {
  const ProgressBar();

  void set(
    final double percent, {
    final int? current,
    final int? total,
    final String prefix = '',
  }) {
    final String state =
        '${percent.floor()}% (${current ?? '?'}/${total ?? '?'})';

    final int maxBarLength =
        terminalWidth - prefix.length - adjust - state.length;

    final String bPrefix = List<String>.filled(
      ((percent / 100) * maxBarLength).floor(),
      '█',
    ).join();

    final String bSuffix = List<String>.filled(
      maxBarLength - bPrefix.length,
      ' ',
    ).join();

    stdout.write('\r$prefix$state [$bPrefix$bSuffix]');
  }

  void end() {
    stdout.write('\r${List<String>.filled(terminalWidth, ' ').join()}');
  }

  int get terminalWidth => stdout.terminalColumns;

  static const int adjust = 3;
}
