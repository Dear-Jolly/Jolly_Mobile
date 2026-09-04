sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Failure<T> extends Result<T> {
  final String message;
  final int? statusCode;
  final String? code;
  final String? requestId;

  const Failure(this.message, {this.statusCode, this.code, this.requestId});

  bool get isRateLimited => statusCode == 429 || code == 'COMMON_004';
}
