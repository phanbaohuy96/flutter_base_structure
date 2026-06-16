import 'package:core/domain/use_case/listing_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ListingUseCase', () {
    const limit = 3;

    /// Builds a use case backed by [pages], handing back one list per fetch and
    /// recording the (offset, limit, page) it was called with.
    ({
      ListingUseCase<int, String> useCase,
      List<({int offset, int limit, int page, String? param})> calls,
    })
    buildWith(List<List<int>> pages) {
      final calls = <({int offset, int limit, int page, String? param})>[];
      var index = 0;
      final useCase = ListingUseCase<int, String>((
        offset,
        pageLimit,
        page, [
        param,
      ]) async {
        calls.add((offset: offset, limit: pageLimit, page: page, param: param));
        return index < pages.length ? pages[index++] : <int>[];
      }, limit);
      return (useCase: useCase, calls: calls);
    }

    test('getData fetches the first page from offset 0, page 1', () async {
      final h = buildWith([
        [1, 2, 3],
      ]);

      final items = await h.useCase.getData('q');

      expect(items, [1, 2, 3]);
      expect(h.calls.single, (offset: 0, limit: limit, page: 1, param: 'q'));
    });

    test('a full page means canNext is true', () async {
      final h = buildWith([
        [1, 2, 3],
      ]);

      await h.useCase.getData();

      expect(h.useCase.canNext, isTrue);
    });

    test('a short page means canNext is false', () async {
      final h = buildWith([
        [1, 2],
      ]);

      await h.useCase.getData();

      expect(h.useCase.canNext, isFalse);
    });

    test('loadMoreData advances offset and page using loaded count', () async {
      final h = buildWith([
        [1, 2, 3],
        [4, 5, 6],
        [7],
      ]);

      await h.useCase.getData();
      await h.useCase.loadMoreData();
      final last = await h.useCase.loadMoreData();

      expect(last, [7]);
      expect(h.calls, [
        (offset: 0, limit: limit, page: 1, param: null),
        (offset: 3, limit: limit, page: 2, param: null),
        (offset: 6, limit: limit, page: 3, param: null),
      ]);
      expect(h.useCase.canNext, isFalse);
    });

    test('getData resets the cursor after a previous listing', () async {
      final h = buildWith([
        [1, 2, 3],
        [4, 5, 6],
        [9, 8, 7],
      ]);

      await h.useCase.getData();
      await h.useCase.loadMoreData();
      final reset = await h.useCase.getData();

      expect(reset, [9, 8, 7]);
      expect(h.calls.last, (offset: 0, limit: limit, page: 1, param: null));
    });

    test('a thrown fetch leaves the cursor replayable', () async {
      var attempts = 0;
      final useCase = ListingUseCase<int, void>((offset, l, page, [_]) async {
        attempts++;
        if (attempts == 1) {
          throw StateError('boom');
        }
        return [1, 2, 3];
      }, limit);

      await expectLater(useCase.getData(), throwsStateError);
      expect(useCase.canNext, isFalse);

      final retry = await useCase.getData();
      expect(retry, [1, 2, 3]);
      expect(useCase.canNext, isTrue);
    });
  });
}
