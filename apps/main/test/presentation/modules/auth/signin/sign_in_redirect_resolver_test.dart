import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_flutter_base/presentation/modules/auth/signin/sign_in_redirect_resolver.dart';
import 'package:my_flutter_base/presentation/modules/auth/signin/signin_route_args.dart';

/// These cases pin the redirect security boundary: the resolver must only ever
/// hand back a same-origin in-app path, falling back to [home] for anything
/// that could escape the app (off-site URLs) or loop the user back to sign-in.
/// A regression here re-opens an open-redirect hole on web, so the intent —
/// "why each input is rejected" — is encoded alongside the expectation.
void main() {
  late DefaultSignInRedirectResolver resolver;

  setUp(() {
    resolver = DefaultSignInRedirectResolver();
  });

  group('DefaultSignInRedirectResolver.resolve', () {
    test('falls back to the home route when no redirect is requested', () {
      expect(resolver.resolve(), resolver.home);
      expect(resolver.resolve(requestedRedirect: null), resolver.home);
    });

    test('the template home route is the dev-mode dashboard demo', () {
      expect(resolver.home, DevModeDashboardScreen.routeName);
    });

    test('returns a valid same-origin path unchanged, preserving query', () {
      expect(resolver.resolve(requestedRedirect: '/orders/123'), '/orders/123');
      expect(
        resolver.resolve(requestedRedirect: '/orders?status=open'),
        '/orders?status=open',
      );
    });

    test('rejects loop-backs to the sign-in route', () {
      expect(
        resolver.resolve(requestedRedirect: signInRouteName),
        resolver.home,
      );
    });

    test('rejects off-site targets with a scheme or authority', () {
      for (final hostile in <String>[
        'https://evil.com',
        'javascript:alert(1)',
        'data:text/html,x',
        '//evil.com', // protocol-relative
        r'/\evil.com', // backslash that Dart normalizes to an authority
        r'\\evil.com',
      ]) {
        expect(
          resolver.resolve(requestedRedirect: hostile),
          resolver.home,
          reason: '"$hostile" must not be returned as a destination',
        );
      }
    });

    test('rejects relative or non-rooted paths', () {
      for (final notRooted in <String>[
        'evil.com',
        'orders/123',
        ' //evil.com', // leading space stops it parsing as an authority
        '%2F%2Fevil.com', // encoded slashes are not a literal leading slash
      ]) {
        expect(resolver.resolve(requestedRedirect: notRooted), resolver.home);
      }
    });
  });
}
