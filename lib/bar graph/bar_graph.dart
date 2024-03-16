import 'package:expense_tracker/bar%20graph/individula_bar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MyBarGraph extends StatefulWidget {
  final List<double> monthlySummary; //[ 300,400,600]
  final int startMonth; //1: Jan, 2: Feb ...

  const MyBarGraph({
    super.key,
    required this.monthlySummary,
    required this.startMonth,
  });

  @override
  State<MyBarGraph> createState() => _MyBarGraphState();
}

class _MyBarGraphState extends State<MyBarGraph> {
  List<IndividualBar> barData = [];

  // initilize bar data - use our monthly summary to create a list of bars
  void initilizeBarData() {
    barData = List.generate(
      widget.monthlySummary.length,
      (index) => IndividualBar(
        x: index,
        y: widget.monthlySummary[index],
      ),
    );
  }

// clclulate max amount for graph

  double calculateMax() {
    double max = 500;

    widget.monthlySummary.sort();

    max = widget.monthlySummary.last * 1.05;

    if (max < 500) {
      return 500;
    }
    return max;
  }

  @override
  Widget build(BuildContext context) {
    initilizeBarData();

    double barWidth = 20;
    double spaceBetweenBars = 15;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: SizedBox(
          width: barWidth * barData.length +
              spaceBetweenBars * (barData.length - 1),
          child: BarChart(
            BarChartData(
              minY: 0,
              maxY: calculateMax(),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: const FlTitlesData(
                show: true,
                topTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: getBottomTitles,
                      reservedSize: 24),
                ),
              ),
              barGroups: barData
                  .map(
                    (data) => BarChartGroupData(
                      x: data.x,
                      barRods: [
                        BarChartRodData(
                            toY: data.y,
                            width: 20,
                            borderRadius: BorderRadius.circular(4),
                            color: Colors.grey.shade800,
                            backDrawRodData: BackgroundBarChartRodData(
                              color: Colors.white,
                              show: true,
                              toY: calculateMax(),
                            )),
                      ],
                    ),
                  )
                  .toList(),
              alignment: BarChartAlignment.end,
              groupsSpace: spaceBetweenBars,
            ),
          ),
        ),
      ),
    );
  }
}

Widget getBottomTitles(double value, TitleMeta meta) {
  const textStyle = TextStyle(
    color: Colors.grey,
    fontWeight: FontWeight.bold,
    fontSize: 14,
  );

  String text;
  switch (value.toInt() % 12) {
    case 0:
      text = 'Ja';
      break;
    case 1:
      text = 'Fe';
      break;
    case 2:
      text = 'Ma';
      break;
    case 3:
      text = 'Ap';
      break;
    case 4:
      text = 'Ma';
      break;
    case 5:
      text = 'Ju';
      break;
    case 6:
      text = 'Ju';
      break;
    case 7:
      text = 'Au';
      break;
    case 8:
      text = 'Se';
      break;
    case 9:
      text = 'Oc';
      break;
    case 10:
      text = 'No';
      break;
    case 11:
      text = 'De';
      break;

    default:
      text = '';
      break;
  }

  return SideTitleWidget(
    child: Text(
      text,
      style: textStyle,
    ),
    axisSide: meta.axisSide,
  );
}
