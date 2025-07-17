import 'package:flutter/material.dart';

import 'package:islamic_toolkit_app/main.dart';

class AppRebuilder extends StatefulWidget {
  const AppRebuilder({super.key});

  @override
  State<AppRebuilder> createState() => _AppRebuilderState();

  static _AppRebuilderState? of(BuildContext context) =>
      context.findAncestorStateOfType<_AppRebuilderState>();
}

class _AppRebuilderState extends State<AppRebuilder> {
  Key appKey = UniqueKey();

  void rebuildApp() {
    setState(() {
      appKey = UniqueKey(); // change key to force full rebuild
    });
  }

  @override
  Widget build(BuildContext context) {
    return MyApp(key: appKey);
  }
}
