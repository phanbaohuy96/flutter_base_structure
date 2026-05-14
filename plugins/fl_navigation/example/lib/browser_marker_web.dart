import 'dart:js_interop';
import 'dart:js_interop_unsafe';

void setBrowserMarker({
  required String route,
  required String message,
  required bool canPop,
}) {
  final document = globalContext.getProperty<JSObject>('document'.toJS);
  final body = document.getProperty<JSObject?>('body'.toJS);
  if (body == null) {
    return;
  }

  body.getProperty<JSObject>('dataset'.toJS)
    ..setProperty('flNavigationRoute'.toJS, route.toJS)
    ..setProperty('flNavigationMessage'.toJS, message.toJS)
    ..setProperty('flNavigationCanPop'.toJS, canPop.toString().toJS);
}
