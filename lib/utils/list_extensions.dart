extension ListExtension<T> on List<T> {
  T? singleOrNull(bool Function(T) predicate) {
    Iterable<T> results = where((i) => predicate(i));
    if (results.isEmpty || results.length > 1) {
      return null;
    } else {
      return results.first;
    }
  }
}
