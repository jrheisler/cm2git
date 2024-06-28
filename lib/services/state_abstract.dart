// Base class for state managers
import 'dart:ui';

abstract class BaseStateManager {
  VoidCallback? onStateChanged;


  // Common dispose method
  void dispose() {
    onStateChanged = null;
  }
}