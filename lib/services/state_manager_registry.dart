


import 'package:cm_2_git/services/state_abstract.dart';

class SMReg {
  // A map to hold instances of state managers with their names as keys
  final Map<String, dynamic> _stateManagers = {};

  // Method to add a state manager with a unique name
  void register(String name, dynamic manager) {
    if (!_stateManagers.containsKey(name)) {
      _stateManagers[name] = manager;
    } else {
      //maybe it's been marked as keepAlive, and now is being reopened
      //so it gets deleted and a new one is registered
      unregister(name);
      _stateManagers[name] = manager;
    }
  }

  // Method to retrieve a state manager by name
  T getStateManager<T>(String name) {
    final manager = _stateManagers[name];
    if (manager == null) {
      throw Exception('State manager with the name $name not found.');
    }
    return manager as T;
  }

  // Method to remove a state manager by name
  void unregister(String name) {
    if (_stateManagers.containsKey(name)) {
      final manager = _stateManagers.remove(name);
      if (manager is BaseStateManager) {
        manager.dispose();
      }
    } else {
      //oh well...
      //throw Exception('State manager with the name $name not found.');
    }
  }

  // Optional: Method to dispose all state managers
  void disposeAll() {
    _stateManagers.forEach((_, manager) {
      if (manager is BaseStateManager) {
        manager.dispose();
      }
    });
    _stateManagers.clear();
  }
}


/*
// Usage example
void main() {
  // Create the registry
  final StateManagerRegistry registry = StateManagerRegistry();

  // Register state managers
  registry.register('counter', CounterStateManager());
  registry.register('theme', ThemeStateManager());

  // Retrieve and use a state manager
  final counterManager = registry.getStateManager<CounterStateManager>('counter');
  counterManager.incrementCounter();

  // When a state manager is no longer needed
  registry.unregister('counter');

  // Dispose all state managers when the app is closing
  registry.disposeAll();
}
 */