import '../../common/constants.dart';

/// Drives offset/page pagination for a single listing.
///
/// The use case owns only the cursor (how many items have been loaded and which
/// page is next); it does **not** retain the loaded items — the consuming bloc
/// already accumulates them in its state, so keeping a second copy here only
/// invited the two to drift. [getData] starts a fresh listing, [loadMoreData]
/// advances it, and [canNext] reports whether the last page came back full
/// (the signal that another page may exist).
///
/// The cursor only advances on a successful fetch, so a thrown request leaves
/// the listing replayable from where it was.
class ListingUseCase<T, P> {
  ListingUseCase(
    this._fetchPage, [
    this._fetchLimit = PaginationConstant.lowLimit,
  ]);

  /// Fetches one page. Receives the running `offset`, the page `limit`, the
  /// 1-based `page`, and the optional caller `param`.
  final Future<List<T>> Function(int offset, int limit, int page, [P? param])
  _fetchPage;

  final int _fetchLimit;

  int _loadedCount = 0;
  int _page = 0;
  bool _canNext = false;

  int get fetchLimit => _fetchLimit;

  /// Whether the most recent fetch returned a full page, i.e. another page may
  /// be available. `false` before the first fetch and after a short page.
  bool get canNext => _canNext;

  /// Resets the cursor and loads the first page.
  Future<List<T>> getData([P? param]) {
    _loadedCount = 0;
    _page = 0;
    _canNext = false;
    return loadMoreData(param);
  }

  /// Loads the page after the current cursor without resetting it.
  Future<List<T>> loadMoreData([P? param]) async {
    final page = _page + 1;
    final items = await _fetchPage(_loadedCount, _fetchLimit, page, param);
    _loadedCount += items.length;
    _page = page;
    _canNext = items.length >= _fetchLimit;
    return items;
  }
}
