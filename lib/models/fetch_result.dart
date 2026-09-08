/// Remote or local list payload with a cache flag for UI.
class FetchResult<T> {
  const FetchResult(this.data, {this.isFromCache = false});

  final T data;
  final bool isFromCache;
}
