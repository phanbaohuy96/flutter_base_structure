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

void main() {
  final factories = <Type, _State Function(_Data)>{
    _Initial: _Initial.new,
    _Loaded: _Loaded.new,
  };

  group('resolveState', () {
    test('builds the registered state for the requested type', () {
      final state = resolveState<_State, _Data>(
        factories,
        requested: _Loaded,
        data: const _Data(7),
      );

      expect(state, isA<_Loaded>());
      expect(state.data.value, 7);
    });

    test('throws a descriptive StateError when the type is unregistered', () {
      expect(
        () => resolveState<_State, _Data>(
          factories,
          requested: _State,
          data: const _Data(0),
        ),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            allOf(contains('_State'), contains('_factories')),
          ),
        ),
      );
    });
  });
}
