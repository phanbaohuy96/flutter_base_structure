class MoneySuggestionUtils {
  List<int> paidSuggestions(int total) {
    const denominations = [
      1000,
      2000,
      5000,
      10000,
      20000,
      50000,
      100000,
      200000,
      500000,
    ];

    final minAmount = (total / 1000).ceil() * 1000;

    final comparePoint = minAmount % 10000 == 0 ? 10000 : 1000;

    if (minAmount % 1000 == 0) {
      final evenPart = minAmount ~/ (comparePoint * 10);
      final surplus = minAmount % (comparePoint * 10);
      if (evenPart > 0) {
        final suggestions = [minAmount];
        final fitDenominations = denominations.where(
          (e) {
            if (surplus % (comparePoint * 2) == 0) {
              return e > (comparePoint * 2);
            }
            return e > comparePoint;
          },
        );

        for (final m in fitDenominations) {
          if (m > suggestions.last) {
            suggestions.add(m);
          } else {
            final amount = _suggestAmountWithMoney(m, suggestions.last);
            if (suggestions.contains(amount)) {
              continue;
            }

            if ([
              amount != suggestions.last + m,
              [
                fitDenominations.any((e) => amount / e == 2),
                suggestions.every((e) => amount / e != 2),
              ].every((e) => e),
            ].any((e) => e)) {
              suggestions.add(amount);
            }
          }
        }

        final maxAmount =
            (total ~/ denominations.last + 1) * denominations.last;
        if (total > denominations.last && !suggestions.contains(maxAmount)) {
          suggestions
              .add((total ~/ denominations.last + 1) * denominations.last);
        }
        return suggestions;
      } else {
        return [
          minAmount,
          ...denominations.where((e) => e > minAmount),
        ];
      }
    }
    return [];
  }

  int _suggestAmountWithMoney(int money, int lastSuggestion) {
    final comparePoint = money < 10000 ? 10000 : 100000;

    final evenPart = lastSuggestion ~/ comparePoint;
    var amount = money + evenPart * comparePoint;

    while (amount <= lastSuggestion) {
      amount += money;
    }
    return amount;
  }
}
