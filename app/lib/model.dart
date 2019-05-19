import 'package:flutter/foundation.dart';

class SpreadSheetModel {
  final int width;
  final int height;
  final List<List<String>> cells;

  VoidCallback onChanged;

  SpreadSheetModel(this.width, this.height)
      : cells = List.generate(height, (_) => List.filled(width, ''));

  SpreadSheetModel.fromList(this.cells)
      : width = cells[0].length,
        height = cells.length;

  String operator [](int index) => cells[getRow(index)][getColumn(index)];
  operator []=(int index, String value) {
    if (this[index] == value) {
      return;
    }

    cells[getRow(index)][getColumn(index)] = value;
    onChanged?.call();
  }

  int get totalCells => width * height;

  int getColumn(int i) => i % width;
  int getRow(int i) => i ~/ width;
  int getIndex(int x, int y) => y * width + x;

  int getCell(int i, int dx, int dy) {
    final y = getRow(i) + dy;
    final x = getColumn(i) + dx;

    if (y < 0 || x < 0 || y >= height || x >= width) {
      return null;
    }

    return getIndex(x, y);
  }

  static const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  String getTopLabel(int i) => letters[i];
  String getLeftLabel(int i) => '$i';

  void clearAll() {
    for (var row in cells) {
      for (var i = 0; i < row.length; i++) {
        row[i] = '';
      }
    }
    onChanged();
  }
}
