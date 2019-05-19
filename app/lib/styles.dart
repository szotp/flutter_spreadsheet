import 'package:flutter/material.dart';

class Styles {
  final gridColor = Colors.grey;
  final topBarHeight = 20.0;
  final cellHeight = 20.0;
  final cellTextStyle = TextStyle(
      fontSize: 16,
      color: Colors.black,
      inherit: false,
      fontFamily: 'Roboto',
      textBaseline: TextBaseline.ideographic);

  static final _shared = Styles();

  final leftWidth = 50.0;
  final topBarColor = Colors.grey[800];

  static Styles of(BuildContext context) => _shared;
}
