part of orca_core;

enum ExceptionLevel {
  log('LOG'),
  warn('WAR'),
  error('ERR');

  final String label;
  const ExceptionLevel(this.label);

  static ExceptionLevel fromString(String label) {
    switch (label) {
      case 'LOG':
        return ExceptionLevel.log;
      case 'WAR':
        return ExceptionLevel.warn;
      case 'ERR':
        return ExceptionLevel.error;
      default:
        return ExceptionLevel.log;
    }
  }
}

class OrcaException implements Exception {
  final String message;
  final dynamic payload;
  final ExceptionLevel exceptionLevel;

  const OrcaException({
    required this.message,
    required this.exceptionLevel,
    this.payload,
  });

  static OrcaException fromJson(JSON json) => OrcaException(
        message: json['message'] as String,
        exceptionLevel: ExceptionLevel.fromString(
          json['exceptionLevel'] as String,
        ),
        payload: json['payload'],
      );

  JSON toJson() => {
        'message': message,
        'payload': payload,
        'exceptionLevel': exceptionLevel.label,
      };
}
