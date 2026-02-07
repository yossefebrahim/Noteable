class Result<T> {
  final T? data;
  final String? error;

  const Result._({this.data, this.error});

  const Result.success(T data) : this._(data: data);

  const Result.failure(String error) : this._(error: error);

  bool get isSuccess => error == null;

  bool get isFailure => !isSuccess;
}
