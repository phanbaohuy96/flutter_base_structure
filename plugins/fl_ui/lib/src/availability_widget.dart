import 'package:flutter/material.dart';

/// A widget that controls the availability state of its child.
/// When disabled, applies a greyscale effect with configurable opacity and
/// optional animation.
class AvailabilityWidget extends StatefulWidget {
  /// Controls whether the widget is enabled or disabled.
  /// When [enable] is true, the child widget is displayed normally.
  /// When [enable] is false, the child widget is greyed out and optionally
  /// made non-interactive.
  final bool enable;

  /// The child widget to control availability for.
  final Widget child;

  /// Whether to absorb pointer events when the widget is disabled.
  /// Defaults to true, making the widget non-interactive when disabled.
  final bool absorbingWhenDisabled;

  /// Controls the opacity of the greyscale effect when disabled.
  /// - 0.0 = completely grey (no original colors)
  /// - 1.0 = original colors (no greying effect)
  /// - Values between 0.0-1.0 blend original and greyscale colors
  /// Defaults to 0.85 for a subtle greying effect.
  final double greyOpacity;

  /// Duration of the animation when transitioning between enabled/disabled states.
  /// If null, no animation is applied and changes are immediate.
  final Duration? animationDuration;

  /// Animation curve for the transition. Defaults to [Curves.easeInOut].
  final Curve animationCurve;

  const AvailabilityWidget({
    Key? key,
    required this.child,
    this.enable = true,
    this.absorbingWhenDisabled = true,
    this.greyOpacity = 0.85,
    this.animationDuration,
    this.animationCurve = Curves.easeInOut,
  }) : super(key: key);

  /// Factory constructor for animated availability widget.
  /// Provides smooth transitions between enabled/disabled states.
  const AvailabilityWidget.animated({
    Key? key,
    required Widget child,
    bool enable = true,
    bool absorbingWhenDisabled = true,
    double greyOpacity = 0.85,
    Duration animationDuration = const Duration(milliseconds: 300),
    Curve animationCurve = Curves.easeInOut,
  }) : this(
          key: key,
          child: child,
          enable: enable,
          absorbingWhenDisabled: absorbingWhenDisabled,
          greyOpacity: greyOpacity,
          animationDuration: animationDuration,
          animationCurve: animationCurve,
        );

  @override
  State<AvailabilityWidget> createState() => _AvailabilityWidgetState();
}

class _AvailabilityWidgetState extends State<AvailabilityWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration ?? Duration.zero,
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: widget.animationCurve,
    );

    // Set initial state
    if (widget.enable) {
      _animationController.value = 1.0;
    } else {
      _animationController.value = 0.0;
    }
  }

  @override
  void didUpdateWidget(AvailabilityWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update animation duration if changed
    if (widget.animationDuration != oldWidget.animationDuration) {
      _animationController.duration = widget.animationDuration ?? Duration.zero;
    }

    // Animate to new state if enable changed
    if (widget.enable != oldWidget.enable) {
      if (widget.enable) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        // Interpolate between disabled and enabled states
        // When animation.value = 0.0 (disabled): use greyOpacity
        // When animation.value = 1.0 (enabled): use 1.0 (full color)
        final animatedOpacity =
            widget.greyOpacity - widget.greyOpacity * _animation.value;

        final animatedColorFilter = ColorFilter.matrix([
          // Red output = weighted luminance + opacity-adjusted red
          0.2126 + (1 - animatedOpacity) * 0.7874, 0.7152 * animatedOpacity,
          0.0722 * animatedOpacity, 0, 0,
          // Green output = weighted luminance + opacity-adjusted green
          0.2126 * animatedOpacity, 0.7152 + (1 - animatedOpacity) * 0.2848,
          0.0722 * animatedOpacity, 0, 0,
          // Blue output = weighted luminance + opacity-adjusted blue
          0.2126 * animatedOpacity, 0.7152 * animatedOpacity,
          0.0722 + (1 - animatedOpacity) * 0.9278, 0, 0,
          // Alpha channel: preserves transparency
          0, 0, 0, 1, 0,
        ]);

        return AbsorbPointer(
          absorbing: !widget.enable && widget.absorbingWhenDisabled,
          child: ColorFiltered(
            colorFilter: animatedColorFilter,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
