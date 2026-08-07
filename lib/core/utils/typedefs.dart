import '../errors/failure.dart';
import '../result/result.dart';

typedef AsyncResult<T> = Future<Result<T>>;

typedef ResultCallback<T> = Result<T> Function();

typedef AsyncCallback<T> = Future<T>;

typedef FailureCallback = void Function(Failure failure);

typedef SuccessCallback<T> = void Function(T value);