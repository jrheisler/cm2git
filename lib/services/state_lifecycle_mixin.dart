import 'package:cm_2_git/services/state_abstract.dart';
import 'package:flutter/material.dart';
import '../main.dart';

mixin StateManagerLifecycle<T extends StatefulWidget> on State<T> {
  late final BaseStateManager _stateManager;
  late final String _stateManagerName;
  bool keepAlive = false;

  @override
  void initState() {
    super.initState();
    _stateManager = createStateManager();
    _stateManagerName = createStateManagerName();
    _stateManager.onStateChanged = () {
      if (mounted)
      setState(() {});
    };
    smReg.register(_stateManagerName, _stateManager);
  }

  @override
  void dispose() {
    if (!keepAlive) {
      smReg.unregister(_stateManagerName);
      _stateManager.dispose();
    }
    super.dispose();
  }

  BaseStateManager createStateManager();

  String createStateManagerName();
}
