/// Resolves a concrete state instance from a feature's `_factories` registry.
///
/// Feature states keep a file-private `_factories` map pairing each concrete
/// state subtype with a constructor that takes the shared `_StateData`. This
/// helper owns the whole dispatch policy so it lives in one place instead of
/// being copy-pasted into every state file: pick [TResult] when the caller
/// requested a specific subtype, otherwise fall back to [fallbackType] (the
/// caller's runtime type), look it up, and return it already narrowed to
/// [TResult] — no `as` cast at the call site.
///
/// Throws a descriptive [StateError] naming the unresolved type when it was
/// never registered, replacing the opaque "Null check operator used on a null
/// value" the bare `_factories[type]!` lookup would otherwise raise far from
/// the cause. The message points at the fix: register the state in the same
/// edit that introduces it.
TResult resolveState<TResult extends TState, TState, TData>(
  Map<Type, TState Function(TData)> factories, {
  required Type fallbackType,
  required TData data,
}) {
  final requested = TResult == TState ? fallbackType : TResult;
  final make = factories[requested];
  if (make == null) {
    throw StateError(
      'State $requested is not registered in _factories. '
      'Add it in the same edit as the state subclass.',
    );
  }
  return make(data) as TResult;
}
