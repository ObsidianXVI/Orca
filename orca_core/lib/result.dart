part of orca_core;

class OrcaResult<T> {
  final int statusCode;
  final OrcaException? exception;
  final T? payload;

  const OrcaResult({
    required this.statusCode,
    this.payload,
    this.exception,
  });

  static OrcaResult fromJson(JSON json) => OrcaResult(
        statusCode: json['statusCode'] as int,
        payload: json.containsKey('payload') ? json['payload'] : null,
        exception: json.containsKey('exception')
            ? OrcaException.fromJson(json['exception'] as JSON)
            : null,
      );

  OrcaResult.insufficientPathLengthOfRequest(String givenEnd)
      : statusCode = 400,
        exception = OrcaException(
          exceptionLevel: ExceptionLevel.error,
          message:
              'The request path ends with "$givenEnd", which is not an endpoint.',
        ),
        payload = null;
}

extension ResponseUtils on HttpResponse {
  void fromOrcaResult(OrcaResult orcaResult) {
    statusCode = orcaResult.statusCode;
    headers.set('Access-Control-Allow-Origin', '*');
    write(
      jsonEncode({
        'statusCode': statusCode,
        if (orcaResult.payload != null) 'payload': orcaResult.payload,
        if (orcaResult.exception != null)
          'exception': orcaResult.exception!.toJson(),
      }),
    );
  }
}
