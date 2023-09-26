import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';

class KPieChartData {
  final Map<String, int> count;
  // 单位
  final String v;

  KPieChartData(this.count, this.v);
}

class KPieChart extends StatelessWidget {
  final KPieChartData data;
  const KPieChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Chart<MapEntry<String, int>>(
      data: data.count.entries.toList(),
      variables: {
    'data': Variable(accessor: (m) => m.value),
    'key': Variable(accessor: (m) => m.key),
      },
      transforms: [Proportion(variable: 'data', as: 'percent')],
      marks: [
    IntervalMark(
        position: Varset('percent') / Varset('key'),
        label: LabelEncode(
            encoder: (tuple) => Label('')),
            color: ColorEncode(variable: 'key', values: Defaults.colors10),
            modifiers: [StackModifier()])
      ],
      coord: PolarCoord(transposed: true, dimCount: 1),
    );
  }
}
