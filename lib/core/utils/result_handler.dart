Future<(T?, Object?)> safeCall<T>(Future<T> Function() call) async {
  try {
    final data = await call();
    return (data, null);
  } catch (e) {
    return (null, e);
  }
}

(T?, Object?) safeCallSync<T>(T Function() call) {
  try {
    return (call(), null);
  } catch (e) {
    return (null, e);
  }
}
