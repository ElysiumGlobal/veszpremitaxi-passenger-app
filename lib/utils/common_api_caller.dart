typedef LoadingCallback = void Function(bool loading);
typedef ErrorCallback = void Function(Object? error, StackTrace stack);
typedef ResultCallback<T> = void Function(T data);

mixin LoadingApiMixin {
  Future<void> processApi<T>(
    Future<T> Function() request, {
    LoadingCallback? loading,
    ErrorCallback? error,
    required ResultCallback<T> result,
  }) async {
    try {
      loading?.call(true);
      final data = await request();
      result.call(data);
    } catch (e, st) {
      error?.call(e, st);
    } finally {
      loading?.call(false);
    }
  }
}
