import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

Stream<E> debounceEventTranformer<E>({
  required Stream<E> events,
  required EventMapper<E> mapper,
  Duration duration = const Duration(milliseconds: 200),
}) {
  return events.debounceTime(duration).asyncExpand(mapper);
}
