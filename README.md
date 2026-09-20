# swipe_action_cell_x

An iOS Mail-grade fluid swipe action cell widget for Flutter with spring physics, rubber-band elasticity, progressive full-swipe actions, and haptic feedback.

[![pub package](https://img.shields.io/pub/v/swipe_action_cell_x.svg)](https://pub.dev/packages/swipe_action_cell_x)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

---

## ✨ Features

- 🍏 **iOS Mail Native Feel**: Drag gestures feature authentic rubber-band resistance and fluid spring rebound animations.
- ⚡ **Full-Swipe Trigger**: Swipe past threshold (e.g. 65% of screen width) to automatically trigger primary actions (like Trash or Archive) with crisp haptics.
- 🎨 **Bi-Directional Action Strips**: Configure independent actions for both left-to-right (Leading) and right-to-left (Trailing) gestures.
- 📳 **Haptic Feedback Integration**: Haptics fire when crossing the full-swipe boundary and upon action execution.
- 🎛️ **Programmatic Controller**: Open or close cells from code (`SwipeActionController`).
- 🧹 **Zero External Dependencies**: Pure Flutter SDK widget tree implementation.

---

## 🚀 Getting Started

Add `swipe_action_cell_x` to your `pubspec.yaml`:

```yaml
dependencies:
  swipe_action_cell_x: ^1.0.0
```

Import the package:

```dart
import 'package:swipe_action_cell_x/swipe_action_cell_x.dart';
```

---

## 💡 Quick Example

```dart
SwipeActionCell(
  key: ValueKey(item.id),
  // Left actions (Leading swipe)
  leftActions: [
    SwipeAction(
      title: 'Read',
      icon: const Icon(Icons.mark_email_read_outlined),
      backgroundColor: Colors.blue,
      onTap: () => markAsRead(item),
    ),
  ],
  // Right actions (Trailing swipe)
  rightActions: [
    SwipeAction(
      title: 'Flag',
      icon: const Icon(Icons.flag_outlined),
      backgroundColor: Colors.amber,
      onTap: () => flagItem(item),
    ),
    SwipeAction(
      title: 'Trash',
      icon: const Icon(Icons.delete_outline),
      backgroundColor: Colors.red,
      performsFirstActionWithFullSwipe: true, // Triggered automatically on full swipe!
      onTap: () => deleteItem(item),
    ),
  ],
  child: ListTile(
    title: Text(item.title),
    subtitle: Text(item.snippet),
  ),
)
```

---

## 🛠️ Configuration Options

### `SwipeActionCell`

| Property | Type | Default | Description |
|---|---|---|---|
| `leftActions` | `List<SwipeAction>` | `[]` | Actions revealed when swiping left-to-right. |
| `rightActions` | `List<SwipeAction>` | `[]` | Actions revealed when swiping right-to-left. |
| `controller` | `SwipeActionController?` | `null` | Controller for programmatic open/close. |
| `fullSwipeThreshold` | `double` | `0.65` | Fraction of total width required for full-swipe trigger. |
| `enableHaptics` | `bool` | `true` | Whether haptics vibrate on threshold cross. |
| `dismissOnFullSwipe` | `bool` | `false` | Collapse cell height to 0 after full swipe. |
| `animationDuration` | `Duration` | `280ms` | Duration for spring snap animations. |

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
Copyright © 2026 [Shahzain Baloch](https://github.com/ShahzainBaloch).
