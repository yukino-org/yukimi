class CRTException implements Exception {
  CRTException(this.error);

  factory CRTException.fromJson(final Map<dynamic, dynamic> json) =>
      CRTException(json['error'] as String);

  final String error;

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        'error': error,
      };

  @override
  String toString() => 'Command Error: $error';
}
