part of '../group_sliver.dart';

class SliverGroupBuilder extends StatelessWidget {
  const SliverGroupBuilder({
    this.margin = EdgeInsets.zero,
    this.padding = EdgeInsets.zero,
    this.decoration,
    this.child,
  });

  /// Empty space to surround the [decoration] and [child].
  final EdgeInsetsGeometry margin;

  /// Empty space to inscribe inside the [decoration]. The [child], if any, is
  /// placed inside this padding.
  ///
  /// This padding is in addition to any padding inherent in the [decoration];
  /// see [Decoration.padding].
  final EdgeInsetsGeometry padding;

  /// The decoration to paint behind the [child].
  ///
  /// A shorthand for specifying just a solid color is available in the
  /// constructor: set the `color` argument instead of the `decoration`
  /// argument.
  final Decoration? decoration;

  /// The  sliver widget.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    // get borderRadius
    BorderRadiusGeometry? borderRadius;
    if (decoration != null && decoration is BoxDecoration) {
      borderRadius = (decoration as BoxDecoration).borderRadius;
    }

    final child = _SliverGroup(
      margin: padding as EdgeInsets?,
      borderRadius: borderRadius as BorderRadius?,
      sliver: this.child,
      decorationWidget: Container(decoration: decoration),
    );

    EdgeInsetsGeometry sliverPadding = EdgeInsets.zero;

    sliverPadding = sliverPadding.add(padding);
    sliverPadding = sliverPadding.add(margin);

    if (sliverPadding != EdgeInsets.zero) {
      return SliverPadding(padding: sliverPadding, sliver: child);
    } else {
      return child;
    }
  }
}
