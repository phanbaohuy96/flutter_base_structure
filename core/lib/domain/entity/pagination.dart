import '../../common/constants.dart';

class Pagination {
  int limit;
  int offset;
  int total;

  Pagination({
    this.limit = PaginationConstant.lowLimit,
    this.offset = 0,
    this.total = 0,
  });

  int get nextOffset {
    if (total == 0) {
      // Incase haven't loaded yet
      return offset;
    }
    return offset + limit;
  }

  bool get canNext {
    return nextOffset == total && total != 0;
  }

  int get currentPage => total ~/ limit;

  int get nextPage => currentPage + 1;

  int get size => limit;

  void setTotal(List<dynamic>? list) {
    total = list?.length ?? 0;
  }

  @override
  String toString() {
    return '{"limit": $limit, "offset": $offset, "total": $total}';
  }
}
