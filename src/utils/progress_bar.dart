import 'dart:io';

class ProgressBar {
  const ProgressBar(this.maxBarLength);

  final int maxBarLength;

  void set(
    final double percent, {
    final String prefix = '',
    final String suffix = '',
  }) {
    final String bPrefix = List<String>.filled(
      ((percent / 100) * maxBarLength).floor(),
      '#',
    ).join();

    final String bSuffix =
        List<String>.filled(maxBarLength - prefix.length, '-').join();

    stdout.write(
      <String>[
        '\r',
        if (prefix.isNotEmpty) prefix,
        '[$bPrefix$bSuffix]',
        if (suffix.isNotEmpty) suffix,
      ].join(' '),
    );
  }

  void end() {
    stdout.writeln();
  }
}
