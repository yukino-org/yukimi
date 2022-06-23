import 'dart:io';

class UnsupportedPlatformException implements Exception {
  const UnsupportedPlatformException();

  @override
  String toString() =>
      'Exception: Unsupported platform (${Platform.operatingSystem}';
}

class CommandException implements Exception {
  const CommandException(this.exception);

  factory CommandException.fromJson(final Map<dynamic, dynamic> json) =>
      CommandException(json['error'] as String);

  factory CommandException.missingOption(final String option) =>
      CommandException('Missing option: $option');

  factory CommandException.invalidOption(final String option) =>
      CommandException('Invalid option: $option');

  factory CommandException.unknownArgumentVariable(final String option) =>
      CommandException('Unknown argument variable: $option');

  factory CommandException.unknownPlatform() =>
      const CommandException('Unknown system platform');

  final String exception;

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        'exception': exception,
      };

  @override
  String toString() => 'Command Exception: $exception';
}
