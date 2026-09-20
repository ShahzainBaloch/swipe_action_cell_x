import 'package:flutter/foundation.dart';

/// Represents the current open state of a [SwipeActionCell].
enum SwipeActionState {
  /// The cell is completely closed.
  closed,

  /// The left actions are revealed.
  openLeft,

  /// The right actions are revealed.
  openRight,
}

/// Controller used to programmatically trigger open or close states on a [SwipeActionCell],
/// and to coordinate mutual exclusion so only one cell remains open at a time in a list.
class SwipeActionController extends ChangeNotifier {
  VoidCallback? _onClose;
  VoidCallback? _onOpenLeft;
  VoidCallback? _onOpenRight;

  SwipeActionState _state = SwipeActionState.closed;

  /// The current state of the cell attached to this controller.
  SwipeActionState get state => _state;

  /// Whether the cell is currently open in either direction.
  bool get isOpen => _state != SwipeActionState.closed;

  /// Internal attachment method called by the cell state.
  void attach({
    required VoidCallback onClose,
    required VoidCallback onOpenLeft,
    required VoidCallback onOpenRight,
  }) {
    _onClose = onClose;
    _onOpenLeft = onOpenLeft;
    _onOpenRight = onOpenRight;
  }

  /// Internal detachment method called when the cell unmounts.
  void detach() {
    _onClose = null;
    _onOpenLeft = null;
    _onOpenRight = null;
  }

  /// Updates internal state and notifies listeners.
  void updateState(SwipeActionState newState) {
    if (_state != newState) {
      _state = newState;
      notifyListeners();
    }
  }

  /// Programmatically close the action cell.
  void close() {
    _onClose?.call();
  }

  /// Programmatically open the left actions.
  void openLeft() {
    _onOpenLeft?.call();
  }

  /// Programmatically open the right actions.
  void openRight() {
    _onOpenRight?.call();
  }

  @override
  void dispose() {
    detach();
    super.dispose();
  }
}
