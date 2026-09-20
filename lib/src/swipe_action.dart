import 'package:flutter/material.dart';

/// Configuration for an action button revealed by swiping.
class SwipeAction {
  /// The optional text title displayed beneath or next to the icon.
  final String? title;

  /// The icon widget displayed for this action.
  final Widget? icon;

  /// The background fill color of the action slot.
  final Color backgroundColor;

  /// The color applied to [title] and icon by default.
  final Color foregroundColor;

  /// Callback fired when the action button is tapped or triggered by a full swipe.
  final VoidCallback onTap;

  /// Whether this action should be expanded to fill the entire cell during a full swipe.
  final bool performsFirstActionWithFullSwipe;

  /// The fixed base width of this action button. Defaults to `76.0`.
  final double width;

  /// Custom text style for [title].
  final TextStyle? textStyle;

  /// Custom padding around icon and text.
  final EdgeInsetsGeometry padding;

  /// Optional custom widget replacement for full content customization.
  final Widget? customContent;

  const SwipeAction({
    this.title,
    this.icon,
    this.backgroundColor = Colors.blue,
    this.foregroundColor = Colors.white,
    required this.onTap,
    this.performsFirstActionWithFullSwipe = false,
    this.width = 76.0,
    this.textStyle,
    this.padding = const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
    this.customContent,
  });
}
