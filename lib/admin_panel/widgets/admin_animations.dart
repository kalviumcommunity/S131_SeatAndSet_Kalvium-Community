import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Interactive wrapper that provides springy tactile feedback (scales down to [scaleDown])
/// on press down with a gentle spring return, haptic feedback, and tap callback.
class BouncingScaleTap extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleDown;
  final Duration duration;
  final bool enableHaptics;
  final BorderRadius? borderRadius;

  const BouncingScaleTap({
    super.key,
    required this.child,
    this.onTap,
    this.scaleDown = 0.96,
    this.duration = const Duration(milliseconds: 110),
    this.enableHaptics = true,
    this.borderRadius,
  });

  @override
  State<BouncingScaleTap> createState() => _BouncingScaleTapState();
}

class _BouncingScaleTapState extends State<BouncingScaleTap>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleDown,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onTap == null) return;
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onTap == null) return;
    _controller.reverse();
  }

  void _onTapCancel() {
    if (widget.onTap == null) return;
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: () {
        if (widget.onTap != null) {
          if (widget.enableHaptics) {
            HapticFeedback.lightImpact();
          }
          widget.onTap!();
        }
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}

/// A breathing pulse indicator ring for live statuses (e.g. "No delays today", "Active").
class PulsingGlowBadge extends StatefulWidget {
  final Color color;
  final double size;

  const PulsingGlowBadge({
    super.key,
    required this.color,
    this.size = 10,
  });

  @override
  State<PulsingGlowBadge> createState() => _PulsingGlowBadgeState();
}

class _PulsingGlowBadgeState extends State<PulsingGlowBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static bool get _isRunningInTest {
    try {
      return Platform.environment.containsKey('FLUTTER_TEST');
    } catch (_) {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    if (!_isRunningInTest) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.size * 2.2,
      width: widget.size * 2.2,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final t = _controller.value;
          final haloScale = 1.0 + (t * 0.9);
          final haloOpacity = (1.0 - t).clamp(0.0, 0.7);

          return Stack(
            alignment: Alignment.center,
            children: [
              // Outer expanding ring
              Transform.scale(
                scale: haloScale,
                child: Container(
                  height: widget.size * 1.5,
                  width: widget.size * 1.5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.color.withValues(alpha: haloOpacity),
                  ),
                ),
              ),
              // Inner solid dot
              Container(
                height: widget.size,
                width: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color,
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.5),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Animated counter that smoothly interpolates numbers from 0 to [value].
class AnimatedCounter extends StatelessWidget {
  final num value;
  final TextStyle? style;
  final String prefix;
  final String suffix;
  final Duration duration;
  final bool isCurrency;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.style,
    this.prefix = '',
    this.suffix = '',
    this.duration = const Duration(milliseconds: 800),
    this.isCurrency = false,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: value.toDouble()),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, val, child) {
        String formatted;
        if (isCurrency) {
          formatted = val.toStringAsFixed(0).replaceAllMapped(
                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                (Match m) => '${m[1]},',
              );
        } else {
          formatted = val.round().toString();
        }
        return Text(
          '$prefix$formatted$suffix',
          style: style,
        );
      },
    );
  }
}

/// Smooth cascading entry animation for items in a list or dashboard grid.
class StaggeredSlideFade extends StatelessWidget {
  final Widget child;
  final int index;
  final Duration delayStep;
  final Duration duration;
  final Offset slideOffset;

  const StaggeredSlideFade({
    super.key,
    required this.child,
    required this.index,
    this.delayStep = const Duration(milliseconds: 40),
    this.duration = const Duration(milliseconds: 400),
    this.slideOffset = const Offset(0, 0.1),
  });

  @override
  Widget build(BuildContext context) {
    final startDelay = delayStep * index;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: duration + startDelay,
      curve: Curves.easeOutCubic,
      builder: (context, progress, child) {
        final delayedProgress = ((progress - (startDelay.inMilliseconds / (duration.inMilliseconds + startDelay.inMilliseconds))) /
                (1.0 - (startDelay.inMilliseconds / (duration.inMilliseconds + startDelay.inMilliseconds))))
            .clamp(0.0, 1.0);

        return Opacity(
          opacity: delayedProgress,
          child: Transform.translate(
            offset: Offset(
              slideOffset.dx * 100 * (1.0 - delayedProgress),
              slideOffset.dy * 100 * (1.0 - delayedProgress),
            ),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

/// An animated bar column that smoothly grows to [targetHeight] or [targetRatio].
class AnimatedGrowthBar extends StatelessWidget {
  final double targetRatio;
  final double maxHeight;
  final Color color;
  final Color? activeColor;
  final bool isSelected;
  final BorderRadius? borderRadius;
  final Duration duration;

  const AnimatedGrowthBar({
    super.key,
    required this.targetRatio,
    required this.maxHeight,
    required this.color,
    this.activeColor,
    this.isSelected = false,
    this.borderRadius,
    this.duration = const Duration(milliseconds: 700),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: targetRatio.clamp(0.0, 1.0)),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, ratio, child) {
        final currentHeight = maxHeight * ratio;
        return Container(
          height: currentHeight < 4 ? 4 : currentHeight,
          decoration: BoxDecoration(
            color: isSelected ? (activeColor ?? color) : color,
            borderRadius: borderRadius ?? BorderRadius.circular(6),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: (activeColor ?? color).withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
        );
      },
    );
  }
}
