import 'model.dart';
import 'styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

class Native {
  static const MethodChannel customChannel = OptionalMethodChannel('custom');
  static Future<String> getClipboard() {
    return customChannel.invokeMethod('getClipboard');
  }
}

class CellTapHandler extends StatefulWidget {
  const CellTapHandler({@required this.builder, @required this.model, Key key}) : super(key: key);

  final SpreadSheetModel model;
  final Widget Function(SpreadSheetCellManager) builder;

  @override
  SpreadSheetCellManager createState() => SpreadSheetCellManager();
}

class SpreadSheetCellManager extends State<CellTapHandler> {
  final controller = TextEditingController();
  FocusNode focusNode = FocusNode();
  final visibleCells = <int, EditableNode>{};

  EditableNode activeCell;

  @override
  void initState() {
    super.initState();
  }

  void onSubmitted() {
    moveActiveCell(0, 1);
  }

  void moveActiveCell(int dx, int dy) {
    if (activeCell == null) {
      return;
    }
    final nextIndex = widget.model.getCell(activeCell.index, dx, dy);
    if (nextIndex == null) {
      return;
    }
    setActiveCell(visibleCells[nextIndex]);
  }

  @override
  void reassemble() {
    super.reassemble();
    focusNode.unfocus();
  }

  void setActiveCell(EditableNode node) {
    if (node == activeCell) {
      return;
    }

    focusNode.unfocus();
    focusNode = FocusNode();
    focusNode.addListener(() {
      if (focusNode.hasFocus && controller.text.isNotEmpty) {
        final c = controller;
        c.selection = TextSelection(baseOffset: 0, extentOffset: c.text.length);
      }
    });

    if (activeCell?.mounted == true) {
      activeCell?.setEditing(null);
    }

    activeCell = node;
    activeCell?.setEditing(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(focusNode);
    });
  }

  Future<void> onPaste() async {
    final x = await Native.getClipboard();
    controller.text = x;
  }

  void onCopy() {}

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: focusNode,
      onKey: (x) {
        if (x is RawKeyDownEvent) {
          final key = x.physicalKey;

          if (key == PhysicalKeyboardKey.arrowUp) {
            moveActiveCell(0, -1);
          } else if (key == PhysicalKeyboardKey.arrowDown) {
            moveActiveCell(0, 1);
          } else if (key == PhysicalKeyboardKey.arrowLeft) {
            moveActiveCell(-1, 0);
          } else if (key == PhysicalKeyboardKey.arrowRight) {
            moveActiveCell(1, 0);
          } else if (key == PhysicalKeyboardKey.escape) {
            setActiveCell(null);
          } else if (key == PhysicalKeyboardKey.keyV && x.data.isMetaPressed) {
            onPaste();
          } else if (key == PhysicalKeyboardKey.keyC && x.data.isMetaPressed) {
            onCopy();
          }
        }
      },
      child: GestureDetector(
        onTapDown: (details) {
          final RenderBox obj = context.findRenderObject();
          final result = BoxHitTestResult();
          final position = obj.globalToLocal(details.globalPosition);
          if (!obj.hitTest(result, position: position)) {
            return;
          }

          final got = result.path.first;
          final dynamic foundObject = got.target;

          if (foundObject is RenderMetaData) {
            final EditableNode cell = foundObject.metaData;
            setActiveCell(cell);
          }
        },
        child: widget.builder(this),
      ),
    );
  }
}

abstract class EditableNode {
  void setEditing(SpreadSheetCellManager manager);
  int get index;
  bool get mounted;
}

class SpreadSheetCell extends StatefulWidget {
  final SpreadSheetModel model;
  final SpreadSheetCellManager manager;
  final int i;

  const SpreadSheetCell({
    @required this.model,
    @required this.i,
    @required this.manager,
    Key key,
  }) : super(key: key);

  @override
  _SpreadSheetCellState createState() => _SpreadSheetCellState();
}

class _SpreadSheetCellState extends State<SpreadSheetCell> implements EditableNode {
  SpreadSheetCellManager _editingMode;

  @override
  int get index => widget.i;

  @override
  void initState() {
    super.initState();
    widget.manager.visibleCells[widget.i] = this;
  }

  @override
  void dispose() {
    super.dispose();
    widget.manager.visibleCells[widget.i] = null;
  }

  String get content => widget.model[widget.i];
  set content(String value) {
    widget.model[widget.i] = value;
  }

  Widget buildContent() {
    if (_editingMode != null) {
      return TextField(
        style: Styles.of(context).cellTextStyle,
        focusNode: _editingMode.focusNode,
        controller: _editingMode.controller,
        decoration: InputDecoration.collapsed(hintText: ''),
        onSubmitted: (_) {
          widget.manager.onSubmitted();
        },
      );
    } else if (content.isNotEmpty ?? false) {
      return Text(content ?? '');
    } else {
      return SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    final i = widget.i;
    final height = widget.model.height;
    final width = widget.model.width;
    final length = width * height;

    final isRightEdge = (i % width) == (width - 1);
    final isBottomEdge = i >= (length - width);

    final side = BorderSide(color: Colors.grey);

    final decoration = BoxDecoration(
      color: Colors.white,
      border: Border(
          top: side,
          left: side,
          bottom: isBottomEdge ? side : BorderSide.none,
          right: isRightEdge ? side : BorderSide.none),
    );

    return MetaData(
      behavior: HitTestBehavior.opaque,
      metaData: this,
      child: IgnorePointer(
        child: Container(
          padding: EdgeInsets.only(left: 4),
          alignment: Alignment.centerLeft,
          decoration: decoration,
          child: buildContent(),
        ),
      ),
    );
  }

  @override
  void setEditing(SpreadSheetCellManager manager) {
    setState(() {
      if (manager != null) {
        final c = manager.controller;
        c.text = content ?? '';
      } else {
        content = _editingMode.controller.text;
      }
      _editingMode = manager;
    });
  }
}
