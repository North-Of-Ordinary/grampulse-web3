import 'package:flutter/material.dart';

/// Performance-optimized scroll physics for smooth scrolling.
/// Uses ClampingScrollPhysics for better performance on Android
/// and reduced overdraw during overscroll.
class OptimizedScrollPhysics extends ScrollPhysics {
  const OptimizedScrollPhysics({super.parent});

  @override
  OptimizedScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return OptimizedScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  SpringDescription get spring => const SpringDescription(
        mass: 80,
        stiffness: 100,
        damping: 0.8,
      );

  @override
  double get minFlingVelocity => 50.0;

  @override
  double get maxFlingVelocity => 8000.0;

  @override
  Tolerance get tolerance => const Tolerance(
        velocity: 1.0,
        distance: 0.5,
      );
}

/// Fast scroll physics for lists with many items
class FastListScrollPhysics extends ClampingScrollPhysics {
  const FastListScrollPhysics({super.parent});

  @override
  FastListScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return FastListScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  double get minFlingVelocity => 100.0;

  @override
  double get maxFlingVelocity => 10000.0;
}
