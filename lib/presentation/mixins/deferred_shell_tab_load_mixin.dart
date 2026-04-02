import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/home_shell_tab_controller.dart';

/// Carica dati pesanti solo quando la tab della shell è visibile (IndexedStack).
///
/// Se [HomeShellTabController] non è nel tree (es. test isolati), [onDeferredShellTabVisible]
/// viene invocato al primo frame come prima.
mixin DeferredShellTabLoadMixin<T extends StatefulWidget> on State<T> {
  int get deferredShellTabIndex;

  void onDeferredShellTabVisible();

  HomeShellTabController? _shellTabs;
  bool _deferredLoadDone = false;
  bool _listenerAttached = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _deferredAttachAndMaybeLoad();
    });
  }

  void _deferredOnShellTabChanged() => _deferredTryLoad();

  void _deferredAttachAndMaybeLoad() {
    if (!mounted) return;
    try {
      _shellTabs = context.read<HomeShellTabController>();
    } on ProviderNotFoundException {
      _shellTabs = null;
    }

    if (_shellTabs != null && !_listenerAttached) {
      _shellTabs!.addListener(_deferredOnShellTabChanged);
      _listenerAttached = true;
    }

    _deferredTryLoad();
  }

  void _deferredTryLoad() {
    if (!mounted || _deferredLoadDone) return;

    if (_shellTabs == null) {
      _deferredLoadDone = true;
      onDeferredShellTabVisible();
      return;
    }

    if (_shellTabs!.index != deferredShellTabIndex) return;

    _deferredLoadDone = true;
    onDeferredShellTabVisible();
  }

  @override
  void dispose() {
    if (_listenerAttached) {
      _shellTabs?.removeListener(_deferredOnShellTabChanged);
    }
    super.dispose();
  }
}
