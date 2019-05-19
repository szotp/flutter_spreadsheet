import 'package:flutter/rendering.dart';
import 'package:meta/meta.dart';

class WeightedColumnsGridDelegate extends SliverGridDelegate {
  final List<int> columnWeights;
  final int numberOfRows;
  final double cellHeight;

  WeightedColumnsGridDelegate({
    @required this.columnWeights,
    @required this.numberOfRows,
    @required this.cellHeight,
  });

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    return WeightedColumnsGridLayout(constraints, this);
  }

  @override
  bool shouldRelayout(SliverGridDelegate oldDelegate) {
    return true;
  }
}

class WeightedColumnsGridLayout extends SliverGridLayout {
  final SliverConstraints constraints;
  final List<int> widths;
  final int height;

  final List<double> calculatedWidths;
  final List<double> calculatedOffsets;

  int get width => widths.length;

  final double cellHeight;

  factory WeightedColumnsGridLayout(
      SliverConstraints constaints, WeightedColumnsGridDelegate parent) {
    var sum = 0;
    for (var item in parent.columnWeights) {
      sum += item;
    }
    final part = constaints.crossAxisExtent / sum;

    final calculatedOffsets = <double>[];
    final calculatedWidths = <double>[];

    var heightSum = 0.0;
    for (var item in parent.columnWeights) {
      sum += item;
      final width = item * part;
      calculatedWidths.add(width);
      calculatedOffsets.add(heightSum);
      heightSum += width;
    }

    return WeightedColumnsGridLayout.custom(
      constaints,
      parent.columnWeights,
      parent.numberOfRows,
      calculatedOffsets,
      calculatedWidths,
      parent.cellHeight,
    );
  }

  const WeightedColumnsGridLayout.custom(
    this.constraints,
    this.widths,
    this.height,
    this.calculatedOffsets,
    this.calculatedWidths,
    this.cellHeight,
  );

  @override
  double computeMaxScrollOffset(int childCount) {
    return cellHeight / width * childCount;
  }

  @override
  SliverGridGeometry getGeometryForChildIndex(int index) {
    final y = index ~/ width;
    final x = index % width;

    return SliverGridGeometry(
      mainAxisExtent: cellHeight,
      crossAxisExtent: calculatedWidths[x],
      scrollOffset: cellHeight * y,
      crossAxisOffset: calculatedOffsets[x],
    );
  }

  @override
  int getMaxChildIndexForScrollOffset(double scrollOffset) {
    return scrollOffset ~/ cellHeight * width;
  }

  @override
  int getMinChildIndexForScrollOffset(double scrollOffset) {
    return scrollOffset ~/ cellHeight * width;
  }
}
