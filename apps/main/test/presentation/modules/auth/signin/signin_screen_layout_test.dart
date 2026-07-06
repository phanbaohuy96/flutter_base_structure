import 'dart:convert';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:my_flutter_base/domain/usecases/auth/auth_usecase.dart';
import 'package:my_flutter_base/generated/assets.dart';
import 'package:my_flutter_base/l10n/generated/app_localizations.dart';
import 'package:my_flutter_base/presentation/modules/auth/signin/bloc/signin_bloc.dart';
import 'package:my_flutter_base/presentation/modules/auth/signin/views/signin_screen.dart';
import 'package:my_flutter_base/presentation/theme/theme.dart';

class _FakeAuthUsecase implements AuthUsecase {
  @override
  Future<bool> loginWithPhoneNumberPassword({
    required String phoneNumber,
    required String password,
  }) async {
    return true;
  }
}

class _TransparentAssetBundle extends CachingAssetBundle {
  static final Uint8List _transparentPng = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAFgwJ/lQnn6QAAAABJRU5ErkJggg==',
  );

  @override
  Future<ByteData> load(String key) async {
    if (key != Assets.images.png.logo) {
      return rootBundle.load(key);
    }
    return ByteData.sublistView(_transparentPng);
  }
}

void main() {
  setUp(() {
    if (!GetIt.instance.isRegistered<LogUtils>()) {
      GetIt.instance.registerSingleton<LogUtils>(LogUtils());
    }
  });

  tearDown(() => GetIt.instance.reset());

  Widget buildSubject({double keyboardInset = 0}) {
    final bloc = SigninBloc(_FakeAuthUsecase());
    final theme = MainAppTheme.normal();

    return DefaultAssetBundle(
      bundle: _TransparentAssetBundle(),
      child: MaterialApp(
        theme: theme.light.theme,
        darkTheme: theme.dark.theme,
        localizationsDelegates: const [
          FlMediaLocalizations.delegate,
          CoreLocalizations.delegate,
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocale.supportedLocales,
        home: MediaQuery(
          data: MediaQueryData(
            size: const Size(390, 844),
            viewInsets: EdgeInsets.only(bottom: keyboardInset),
          ),
          child: BlocProvider<SigninBloc>(
            create: (_) => bloc,
            child: const SignInScreen(),
          ),
        ),
      ),
    );
  }

  testWidgets('keeps footer fixed and pads scroll body for keyboard', (
    tester,
  ) async {
    const keyboardInset = 320.0;

    await tester.pumpWidget(buildSubject(keyboardInset: keyboardInset));

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.resizeToAvoidBottomInset, isFalse);

    final keyboardPadding = tester.widget<AnimatedPadding>(
      find.ancestor(
        of: find.byType(SingleChildScrollView),
        matching: find.byType(AnimatedPadding),
      ),
    );
    expect(
      keyboardPadding.padding.resolve(TextDirection.ltr).bottom,
      keyboardInset,
    );
  });
}
