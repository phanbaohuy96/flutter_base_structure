part of 'splash_screen.dart';

extension SplashAction on _SplashScreenState {
  Future<void> getClientInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    final result = await Future.wait([
      if (Platform.isAndroid) deviceInfo.androidInfo,
      if (Platform.isIOS) deviceInfo.iosInfo,
      PackageInfo.fromPlatform()
    ]).catchError((error, stackTrace) {});

    if (result.isNotEmpty) {
      if (Platform.isAndroid) {
        final androidInfo = result[0] as AndroidDeviceInfo;
        ClientInfo.model = '${androidInfo.manufacturer} ${androidInfo.model}';
        ClientInfo.osversion = androidInfo.version.release;
        ClientInfo.identifier = androidInfo.androidId;
      } else {
        final iosInfo = result[0] as IosDeviceInfo;
        ClientInfo.model = iosInfo.utsname.machine;
        ClientInfo.osversion = iosInfo.systemVersion;
        ClientInfo.identifier = iosInfo.identifierForVendor;
      }
      final info = result[1] as PackageInfo;
      ClientInfo.appVersionName = info.version;
      ClientInfo.appVersionCode = info.buildNumber;
    }

    bloc.add(SplashInitialEvent());
  }
}
