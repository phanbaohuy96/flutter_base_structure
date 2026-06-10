import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

class _Data {
  const _Data(this.value);

  final int value;
}

abstract class _State {
  const _State(this.data);

  final _Data data;
}

class _Initial extends _State {
  const _Initial(super.data);
}

class _Loaded extends _State {
  const _Loaded(super.data);
}

/// A subtype deliberately left out of [factories] to exercise the failure path.
class _Errored extends _State {
  const _Errored(super.data);
}

void main() {
  final factories = <Type, _State Function(_Data)>{
    _Initial: _Initial.new,
    _Loaded: _Loaded.new,
  };

  group('resolveState', () {
    test('builds the state for the requested subtype, ignoring fallback', () {
      final state = resolveState<_Loaded, _State, _Data>(
        factories,
        fallbackType: _Initial,
        data: const _Data(7),
      );

      expect(state, isA<_Loaded>());
      expect(state.data.value, 7);
    });

    test('falls back to fallbackType when the request is the base type', () {
      final state = resolveState<_State, _State, _Data>(
        factories,
        fallbackType: _Loaded,
        data: const _Data(5),
      );

      expect(state, isA<_Loaded>());
      expect(state.data.value, 5);
    });

    test('throws a descriptive StateError when the type is unregistered', () {
      expect(
        () => resolveState<_Errored, _State, _Data>(
          factories,
          fallbackType: _Initial,
          data: const _Data(0),
        ),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            allOf(contains('_Errored'), contains('_factories')),
          ),
        ),
      );
    });
  });
}
