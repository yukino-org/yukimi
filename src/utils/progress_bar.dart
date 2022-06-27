import 'dart:io';

import 'console.dart';

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
    final String bPrefix = '=' * ((percent / 100) * maxBarLength).floor();
    final String bSuffix = '-' * (maxBarLength - bPrefix.length);

    stdout.write(
      '\r$prefix$state [${Dye.dye(bPrefix, 'lightGreen')}${Dye.dye(bSuffix, 'dark')}]',
    );
  }

  void end() {
    stdout.write('\r${' ' * terminalWidth}');
  }

  int get terminalWidth => stdout.terminalColumns;

  static const int adjust = 3;
}
