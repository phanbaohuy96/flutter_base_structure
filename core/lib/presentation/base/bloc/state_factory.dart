/// Resolves a concrete state instance from a feature's `_factories` registry.
///
/// Feature states keep a file-private `_factories` map pairing each concrete
/// state subtype with a constructor that takes the shared `_StateData`. This
/// helper centralises the lookup so the dispatch policy — and, crucially, its
/// failure mode — lives in one place instead of being copy-pasted into every
/// state file.
///
/// Throws a descriptive [StateError] naming [requested] when the subtype was
/// never registered, replacing the opaque "Null check operator used on a null
/// value" the bare `_factories[type]!` lookup would otherwise raise far from
/// the cause. The message points at the fix: register the state in the same
/// edit that introduces it.
TState resolveState<TState, TData>(
  Map<Type, TState Function(TData)> factories, {
  required Type requested,
  required TData data,
}) {
  final make = factories[requested];
  if (make == null) {
    throw StateError(
      'State $requested is not registered in _factories. '
      'Add it in the same edit as the state subclass.',
    );
  }
  return make(data);
}
