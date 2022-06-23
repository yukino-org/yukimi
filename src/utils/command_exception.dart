class CRTException implements Exception {
  CRTException(this.error);

  factory CRTException.fromJson(final Map<dynamic, dynamic> json) =>
      CRTException(json['error'] as String);

  factory CRTException.missingOption(final String option) =>
      CRTException('Missing option: $option');

  factory CRTException.invalidOption(final String option) =>
      CRTException('Invalid option: $option');

  factory CRTException.unknownArgumentVariable(final String option) =>
      CRTException('Unknown argument variable: $option');

  final String error;

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        'error': error,
      };

  @override
  String toString() => 'Command Error: $error';
}
