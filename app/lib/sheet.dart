import 'cell.dart';
import 'model.dart';
import 'styles.dart';
import 'weighted_grid_delegate.dart';
import 'package:flutter/material.dart';

class SpreadSheet extends StatefulWidget {
  final SpreadSheetModel model;
  final List<int> columnWidths;

  const SpreadSheet({Key key, this.model, this.columnWidths}) : super(key: key);

  @override
  _SpreadSheetState createState() => _SpreadSheetState();
}

class _SpreadSheetState extends State<SpreadSheet> {
  final leftHeaderController = TrackingScrollController();
  final contentController = ScrollController();

  @override
  void initState() {
    super.initState();

    contentController.addListener(() {
      leftHeaderController.position.jumpTo(contentController.offset);
    });
  }

  Widget buildRightSide() {
    final sum = widget.columnWidths.reduce((a, b) => a + b);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: sum.toDouble(),
        child: Column(
          children: <Widget>[
            GridView.builder(
              shrinkWrap: true,
              itemCount: widget.columnWidths.length,
              gridDelegate: WeightedColumnsGridDelegate(
                columnWeights: widget.columnWidths,
                numberOfRows: 1,
                cellHeight: Styles.of(context).topBarHeight,
              ),
              itemBuilder: (context, i) {
                return Container(
                  alignment: Alignment.center,
                  child: Text(widget.model.getTopLabel(i), style: TextStyle(color: Colors.white)),
                );
              },
            ),
            Expanded(
              child: buildDataGrid(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDataGrid() {
    return CellTapHandler(
      model: widget.model,
      builder: (handler) {
        return DefaultTextStyle(
          style: Styles.of(context).cellTextStyle,
          child: GridView.builder(
            controller: contentController,
            itemCount: widget.model.totalCells,
            itemBuilder: (context, i) {
              return SpreadSheetCell(
                model: widget.model,
                i: i,
                manager: handler,
              );
            },
            gridDelegate: WeightedColumnsGridDelegate(
              columnWeights: widget.columnWidths,
              numberOfRows: widget.model.height,
              cellHeight: Styles.of(context).cellHeight,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = Styles.of(context);

    return Container(
      color: s.topBarColor,
      child: Stack(
        children: <Widget>[
          Positioned(
            left: s.leftWidth,
            right: 0,
            top: 0,
            height: s.topBarHeight,
            child: Container(
              color: s.topBarColor,
            ),
          ),
          Positioned(
            top: s.topBarHeight,
            bottom: 0,
            width: s.leftWidth,
            child: buildLeftBar(),
          ),
          Positioned.fill(
            left: s.leftWidth,
            child: buildRightSide(),
          ),
        ],
      ),
    );
  }

  Widget buildLeftBar() {
    return GridView.builder(
      physics: NeverScrollableScrollPhysics(),
      controller: leftHeaderController,
      gridDelegate: WeightedColumnsGridDelegate(
        columnWeights: [1],
        numberOfRows: widget.model.height,
        cellHeight: Styles.of(context).cellHeight,
      ),
      itemBuilder: (context, i) {
        return Container(
          padding: EdgeInsets.all(2),
          child: Text(
            widget.model.getLeftLabel(i),
            style: TextStyle(color: Colors.white),
          ),
          alignment: Alignment.centerLeft,
        );
      },
    );
  }
}
