import 'home_page.dart';
import 'package:flutter/foundation.dart' show debugDefaultTargetPlatformOverride;
import 'package:flutter/material.dart';

void main() {
  // Desktop platforms are not recognized as valid targets by
  // Flutter; force a specific target to prevent exceptions.
  debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
  runApp(new MyApp());
}

/// Top level widget for the example application.
class MyApp extends StatefulWidget {
  /// Constructs a new app with the given [key].
  const MyApp({Key key}) : super(key: key);

  @override
  _AppState createState() => new _AppState();
}

class _AppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
