import 'package:core/core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

class _TestBloc extends CoreBlocBase<int, int> {
  _TestBloc() : super(0);
}

class _ProbeScreen extends StatefulWidget {
  const _ProbeScreen({required this.bloc, required this.onErrorRecorded});

  final _TestBloc bloc;
  final void Function(ErrorData) onErrorRecorded;

  @override
  State<_ProbeScreen> createState() => _ProbeScreenState();
}

class _ProbeScreenState extends CoreStateBase<_ProbeScreen> {
  @override
  CoreDelegate? get delegate => widget.bloc;

  // Bypass the context-heavy default so the test exercises only the
  // register/teardown lifecycle, not error presentation.
  @override
  void onError(ErrorData error) => widget.onErrorRecorded(error);

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

void main() {
  // CoreStateBase logs lifecycle events through logUtils, which resolves
  // LogUtils from GetIt; register it so initState/dispose don't throw.
  setUp(() {
    if (!GetIt.instance.isRegistered<LogUtils>()) {
      GetIt.instance.registerSingleton<LogUtils>(LogUtils());
    }
  });

  tearDown(() => GetIt.instance.reset());

  testWidgets(
    'delegate stops notifying a screen once it is disposed',
    (tester) async {
      final bloc = _TestBloc();
      addTearDown(bloc.close);
      final received = <ErrorData>[];

      await tester.pumpWidget(
        _ProbeScreen(bloc: bloc, onErrorRecorded: received.add),
      );

      // While mounted, the screen receives delegate notifications.
      bloc.notifyError(ErrorData(type: ErrorType.unknown, message: 'first'));
      expect(received, hasLength(1));

      // Dispose the screen by replacing it.
      await tester.pumpWidget(const SizedBox.shrink());

      // After dispose the handler is gone, so further notifications are dropped
      // rather than landing on a defunct screen.
      bloc.notifyError(ErrorData(type: ErrorType.unknown, message: 'second'));
      expect(received, hasLength(1));
    },
  );
}
