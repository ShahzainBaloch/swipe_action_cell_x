import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'swipe_action.dart';
import 'swipe_action_controller.dart';

/// An iOS Mail-grade fluid swipe action cell widget with spring physics,
/// rubber-band elasticity, full-swipe actions, and haptic feedback.
class SwipeActionCell extends StatefulWidget {
  /// The main content widget shown inside the cell.
  final Widget child;

  /// The list of actions revealed when swiping from left to right.
  final List<SwipeAction> leftActions;

  /// The list of actions revealed when swiping from right to left.
  final List<SwipeAction> rightActions;

  /// Optional programmatic controller.
  final SwipeActionController? controller;

  /// Threshold percentage (between 0.0 and 1.0) of total cell width
  /// required to trigger a full-swipe action. Defaults to `0.65` (65%).
  final double fullSwipeThreshold;

  /// Whether haptic feedback should trigger when crossing the full-swipe threshold.
  final bool enableHaptics;

  /// If true, automatically animates collapsing the cell height to 0
  /// when a full swipe completes.
  final bool dismissOnFullSwipe;

  /// The animation curve used when snapping or resetting the cell.
  final Curve animationCurve;

  /// The animation duration for snap transitions.
  final Duration animationDuration;

  /// Optional callback invoked whenever the open/closed state changes.
  final ValueChanged<SwipeActionState>? onStateChanged;

  const SwipeActionCell({
    super.key,
    required this.child,
    this.leftActions = const [],
    this.rightActions = const [],
    this.controller,
    this.fullSwipeThreshold = 0.65,
    this.enableHaptics = true,
    this.dismissOnFullSwipe = false,
    this.animationCurve = Curves.easeOutCubic,
    this.animationDuration = const Duration(milliseconds: 280),
    this.onStateChanged,
  });

  @override
  State<SwipeActionCell> createState() => _SwipeActionCellState();
}

class _SwipeActionCellState extends State<SwipeActionCell>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  Animation<double>? _offsetAnimation;
  double _currentOffset = 0.0;
  bool _thresholdCrossed = false;
  bool _isDismissed = false;

  double get _totalLeftWidth =>
      widget.leftActions.fold(0.0, (sum, a) => sum + a.width);

  double get _totalRightWidth =>
      widget.rightActions.fold(0.0, (sum, a) => sum + a.width);

  SwipeAction? get _fullSwipeLeftAction {
    for (final action in widget.leftActions) {
      if (action.performsFirstActionWithFullSwipe) return action;
    }
    return widget.leftActions.isNotEmpty ? widget.leftActions.first : null;
  }

  SwipeAction? get _fullSwipeRightAction {
    for (final action in widget.rightActions.reversed) {
      if (action.performsFirstActionWithFullSwipe) return action;
    }
    return widget.rightActions.isNotEmpty ? widget.rightActions.last : null;
  }

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _animController.addListener(() {
      if (_offsetAnimation != null) {
        setState(() {
          _currentOffset = _offsetAnimation!.value;
        });
      }
    });
    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _updateStateFromOffset();
      }
    });

    widget.controller?.attach(
      onClose: close,
      onOpenLeft: openLeft,
      onOpenRight: openRight,
    );
  }

  @override
  void didUpdateWidget(covariant SwipeActionCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.detach();
      widget.controller?.attach(
        onClose: close,
        onOpenLeft: openLeft,
        onOpenRight: openRight,
      );
    }
  }

  @override
  void dispose() {
    widget.controller?.detach();
    _animController.dispose();
    super.dispose();
  }

  void _updateStateFromOffset() {
    final SwipeActionState state;
    if (_currentOffset > 0.1) {
      state = SwipeActionState.openLeft;
    } else if (_currentOffset < -0.1) {
      state = SwipeActionState.openRight;
    } else {
      state = SwipeActionState.closed;
    }
    widget.controller?.updateState(state);
    widget.onStateChanged?.call(state);
  }

  void close() {
    _animateTo(0.0);
  }

  void openLeft() {
    if (_totalLeftWidth > 0) {
      _animateTo(_totalLeftWidth);
    }
  }

  void openRight() {
    if (_totalRightWidth > 0) {
      _animateTo(-_totalRightWidth);
    }
  }

  void _animateTo(double target) {
    _offsetAnimation = Tween<double>(
      begin: _currentOffset,
      end: target,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: widget.animationCurve,
    ));
    _animController.forward(from: 0.0);
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details, double cellWidth) {
    if (_isDismissed) return;
    final delta = details.primaryDelta ?? 0.0;
    double newOffset = _currentOffset + delta;

    // Boundary constraints with rubber band resistance
    if (newOffset > 0) {
      if (widget.leftActions.isEmpty) {
        newOffset = 0.0;
      } else if (newOffset > _totalLeftWidth && _fullSwipeLeftAction == null) {
        final overflow = newOffset - _totalLeftWidth;
        newOffset = _totalLeftWidth + overflow * 0.3;
      }
    } else if (newOffset < 0) {
      if (widget.rightActions.isEmpty) {
        newOffset = 0.0;
      } else if (newOffset.abs() > _totalRightWidth &&
          _fullSwipeRightAction == null) {
        final overflow = newOffset.abs() - _totalRightWidth;
        newOffset = -(_totalRightWidth + overflow * 0.3);
      }
    }

    final fullThreshold = cellWidth * widget.fullSwipeThreshold;
    final isOverThreshold = newOffset.abs() >= fullThreshold;

    if (isOverThreshold && !_thresholdCrossed) {
      _thresholdCrossed = true;
      if (widget.enableHaptics) {
        HapticFeedback.mediumImpact();
      }
    } else if (!isOverThreshold && _thresholdCrossed) {
      _thresholdCrossed = false;
    }

    setState(() {
      _currentOffset = newOffset;
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details, double cellWidth) {
    if (_isDismissed) return;
    final velocity = details.primaryVelocity ?? 0.0;
    final fullThreshold = cellWidth * widget.fullSwipeThreshold;

    // 1. Check Full Swipe Action
    if (_currentOffset >= fullThreshold && _fullSwipeLeftAction != null) {
      if (widget.enableHaptics) {
        HapticFeedback.heavyImpact();
      }
      _fullSwipeLeftAction!.onTap();
      _handleAfterFullSwipe();
      return;
    } else if (_currentOffset <= -fullThreshold &&
        _fullSwipeRightAction != null) {
      if (widget.enableHaptics) {
        HapticFeedback.heavyImpact();
      }
      _fullSwipeRightAction!.onTap();
      _handleAfterFullSwipe();
      return;
    }

    // 2. Check Standard Snap Open / Close
    if (_currentOffset > 0) {
      if (velocity > 300 || _currentOffset > _totalLeftWidth * 0.5) {
        _animateTo(_totalLeftWidth);
      } else {
        _animateTo(0.0);
      }
    } else if (_currentOffset < 0) {
      if (velocity < -300 || _currentOffset.abs() > _totalRightWidth * 0.5) {
        _animateTo(-_totalRightWidth);
      } else {
        _animateTo(0.0);
      }
    }
    _thresholdCrossed = false;
  }

  void _handleAfterFullSwipe() {
    if (widget.dismissOnFullSwipe) {
      setState(() {
        _isDismissed = true;
      });
    } else {
      _animateTo(0.0);
    }
    _thresholdCrossed = false;
  }

  Widget _buildActionButton(SwipeAction action, bool isExpanded, double width) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        action.onTap();
        close();
      },
      child: Container(
        width: width,
        color: action.backgroundColor,
        padding: action.padding,
        alignment: Alignment.center,
        child: action.customContent ??
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (action.icon != null)
                  IconTheme(
                    data: IconThemeData(color: action.foregroundColor, size: 24),
                    child: action.icon!,
                  ),
                if (action.title != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    action.title!,
                    style: action.textStyle ??
                        TextStyle(
                          color: action.foregroundColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
      ),
    );
  }

  Widget _buildLeftActionStrip(double cellWidth) {
    if (_currentOffset <= 0 || widget.leftActions.isEmpty) {
      return const SizedBox.shrink();
    }

    final isFullSwiped = _currentOffset >= cellWidth * widget.fullSwipeThreshold;
    final primaryAction = _fullSwipeLeftAction;

    return Positioned(
      left: 0,
      top: 0,
      bottom: 0,
      width: _currentOffset,
      child: ClipRect(
        child: Row(
          children: widget.leftActions.map((action) {
            final isPrimary = action == primaryAction;
            final itemWidth = isFullSwiped && isPrimary
                ? _currentOffset -
                    widget.leftActions
                        .where((a) => a != primaryAction)
                        .fold(0.0, (s, a) => s + a.width)
                : action.width;

            return _buildActionButton(action, isFullSwiped && isPrimary,
                itemWidth.clamp(0.0, _currentOffset));
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildRightActionStrip(double cellWidth) {
    if (_currentOffset >= 0 || widget.rightActions.isEmpty) {
      return const SizedBox.shrink();
    }

    final absOffset = _currentOffset.abs();
    final isFullSwiped = absOffset >= cellWidth * widget.fullSwipeThreshold;
    final primaryAction = _fullSwipeRightAction;

    return Positioned(
      right: 0,
      top: 0,
      bottom: 0,
      width: absOffset,
      child: ClipRect(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: widget.rightActions.map((action) {
            final isPrimary = action == primaryAction;
            final itemWidth = isFullSwiped && isPrimary
                ? absOffset -
                    widget.rightActions
                        .where((a) => a != primaryAction)
                        .fold(0.0, (s, a) => s + a.width)
                : action.width;

            return _buildActionButton(action, isFullSwiped && isPrimary,
                itemWidth.clamp(0.0, absOffset));
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isDismissed) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final cellWidth = constraints.maxWidth;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Left Action strip
            _buildLeftActionStrip(cellWidth),

            // Right Action strip
            _buildRightActionStrip(cellWidth),

            // Main Cell Content
            Transform.translate(
              offset: Offset(_currentOffset, 0),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragUpdate: (details) =>
                    _onHorizontalDragUpdate(details, cellWidth),
                onHorizontalDragEnd: (details) =>
                    _onHorizontalDragEnd(details, cellWidth),
                onTap: _currentOffset.abs() > 0.1 ? close : null,
                child: widget.child,
              ),
            ),
          ],
        );
      },
    );
  }
}
