// ignore_for_file: lines_longer_than_80_chars
/// Represents a condition and its associated value.

class Conditional<T> {
  /// The function that determines if the condition is met.
  final bool Function() condition;

  /// The function that provides the value if the condition is met.
  final T Function() value;

  /// Creates a new [Conditional].
  Conditional({required this.condition, required this.value});
}

/// A builder for chaining multiple synchronous conditions and returning
/// the value associated with the first satisfied condition.
///
/// If no condition matches, the optional fallback value set by [orElse] is returned.
class ConditionBuilder<T> {
  final List<Conditional<T>> _conditions = [];

  /// Creates a [ConditionBuilder] with a single initial condition.
  ///
  /// This named constructor allows quick inline usage without needing to
  /// instantiate the builder and then call `.on(...)` separately.
  ///
  /// Example:
  /// ```dart
  /// final color = ConditionBuilder.on(() => isDarkMode, () => Colors.black)
  ///   .on(() => isHighContrast, () => Colors.amber)
  ///   .build(orElse: () => Colors.white);
  /// ```
  ConditionBuilder.on({
    required bool Function() condition,
    required T Function() value,
  }) {
    _conditions.add(Conditional(condition: condition, value: value));
  }

  /// Adds a synchronous condition and its corresponding value to the builder.
  ConditionBuilder<T> on(bool Function() condition, T Function() value) {
    _conditions.add(Conditional(condition: condition, value: value));
    // ignore: avoid_returning_this
    return this;
  }

  ConditionBuilder.from(List<Conditional<T>> conditions) {
    _conditions.addAll(conditions);
  }

  /// Evaluates the conditions in order and returns the value of the first
  /// condition that evaluates to `true`.
  ///
  /// If no condition matches, the [orElse] parameter is used if provided.
  ///
  /// Throws an [AssertionError] if no conditions are added.
  /// Throws a [StateError] if no condition is met and no fallback is available.
  T? build({T? Function()? orElse}) {
    assert(
      _conditions.isNotEmpty,
      'ConditionBuilder: you must provide at least one condition.',
    );

    for (final condition in _conditions) {
      if (condition.condition()) {
        return condition.value();
      }
    }

    if (orElse != null) {
      return orElse();
    }

    throw StateError(
      'ConditionBuilder: No condition was met and no orElse value was provided.',
    );
  }
}
