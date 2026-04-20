import '../../../data/models/token.dart';

/// Abstract contract for refreshing the access token.
///
/// Implementations must guarantee that **only one** refresh HTTP request is
/// ever in-flight at a time. Any call to [refresh] while a refresh is already
/// running must await the result of the ongoing request instead of firing a
/// new one.
abstract class RefreshTokenService {
  /// Whether a refresh request is currently in-flight.
  bool get isRefreshing;

  /// Refresh the access token.
  ///
  /// Returns the new [UserToken] on success, or `null` if the refresh failed.
  /// Multiple concurrent callers will all await the **same** underlying request
  Future<UserToken?> refresh();
}
