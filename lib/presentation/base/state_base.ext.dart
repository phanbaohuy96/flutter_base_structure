part of 'base.dart';

extension StateBaseExtention on StateBase {
  void hideKeyBoard() => CommonFunction.hideKeyBoard(context);

  TranslateCallback get tr => S.of(context).translate;

  ThemeData get theme => Theme.of(context);

  Size get device => MediaQuery.of(context).size;

  double get paddingTop => MediaQuery.of(context).padding.top;

  double get paddingBottom => MediaQuery.of(context).padding.bottom;

  void backToAuth() {
    // Navigator.of(context).pushNamedAndRemoveUntil(
    //   RouteList.authRoute,
    //   (route) => false,
    // );
  }

  void backToHome() {
    Navigator.of(context).popUntil(
      ModalRoute.withName(RouteList.dashBoardRoute),
    );
  }

  String parseServerGender(String gender) {
    if (gender == tr('gender.male')) {
      return ServerGender.male;
    } else {
      return ServerGender.female;
    }
  }
}
