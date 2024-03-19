import 'dart:async';
import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

typedef ChartValueCallback = Future<Map<String, dynamic>> Function(
    List<String>, int, int);

class GraphStatChart extends StatefulWidget {
  final int numDatapoints;
  final int datapointIntervalInSeconds;
  final int assumeTimeoutAfterNTicks = 3;

  final bool aggregate;
  final String unit;

  final ChartValueCallback callback;

  final List<String> hids;
  final String? caption;

  final double? max;

  const GraphStatChart(
      {super.key,
      required this.hids,
      this.caption,
      required this.callback,
      this.aggregate = true,
      this.unit = "W",
      this.max,
      this.numDatapoints = 61,
      this.datapointIntervalInSeconds = 10});

  @override
  State<GraphStatChart> createState() => GraphStatChartState();
}

class GraphStatChartState extends State<GraphStatChart> {
  UniqueKey key = UniqueKey();

  late double maxY;

  final Map<String, List<dynamic>> datapoints = {};

  Timer? _timer;

  double maxScale = 1.25;

  fetchPowerUsageData() async {
    Map<String, dynamic> response = await widget.callback(
        widget.hids, widget.numDatapoints, widget.datapointIntervalInSeconds);

    for (String hid in widget.hids) {
      List<dynamic> records = response[hid];

      // Prepare the output structure, initially with nulls to distinguish from actual 0 values
      List<double?> hostDatapoints =
          List.filled(widget.numDatapoints, null, growable: false);

      // Calculate the start and end time for the interpolation range
      final endTime = DateTime.now().toUtc();
      final startTime = endTime.subtract(Duration(
          seconds: widget.numDatapoints * widget.datapointIntervalInSeconds));
      final double startTimestamp = startTime.millisecondsSinceEpoch.toDouble();

      if (records.isNotEmpty) {
        // Convert all timestamps to milliseconds since epoch and ensure value is a double
        List<Map<String, dynamic>> convertedRecords = records.map((record) {
          return {
            "time": record["time"] * 1000,
            "value": record["value"].toDouble(),
          };
        }).toList();

        // Initialize variables to keep track of the last known good value
        double? lastKnownGoodValue;

        // Interpolate values for each target timestamp
        for (int i = 0; i < widget.numDatapoints; i++) {
          final targetTimestamp =
              startTimestamp + (i * widget.datapointIntervalInSeconds * 1000);

          Map<String, dynamic>? beforeRecord;
          Map<String, dynamic>? afterRecord;
          for (var record in convertedRecords) {
            if (record["time"] <= targetTimestamp) {
              beforeRecord = record;
              lastKnownGoodValue =
                  record["value"]; // Update last known good value
            }
            if (record["time"] > targetTimestamp) {
              afterRecord = record;
              break;
            }
          }

          if (beforeRecord != null && afterRecord != null) {
            final beforeTime = beforeRecord["time"];
            final afterTime = afterRecord["time"];
            final beforeValue = beforeRecord["value"];
            final afterValue = afterRecord["value"];

            if (afterTime - beforeTime >
                widget.datapointIntervalInSeconds *
                    1000 *
                    widget.assumeTimeoutAfterNTicks) {
              // If the time between datapoints is this large, we can assume the data is actually zero or no data is available
              hostDatapoints[i] = 0;
            } else {
              final interpolatedValue = beforeValue +
                  (afterValue - beforeValue) *
                      ((targetTimestamp - beforeTime) /
                          (afterTime - beforeTime));
              hostDatapoints[i] = interpolatedValue;
            }
          } else {
            // Use last known good value if it's not null, otherwise default to 0.0
            hostDatapoints[i] = lastKnownGoodValue ?? 0.0;
          }
        }

        // Replace any nulls with 0.0, assuming that a lack of data equates to a measurement of 0
        for (int i = 0; i < hostDatapoints.length; i++) {
          hostDatapoints[i] = hostDatapoints[i] ?? 0.0;
        }
      } else {
        // If there are no records, fill with 0.0 (assuming this means no measurements)
        hostDatapoints =
            List.filled(widget.numDatapoints, 0.0, growable: false);
      }

      datapoints[hid] = hostDatapoints.cast<double>();
    }

    double max = 0;

    int length = widget.hids.isEmpty ? 0 : datapoints[widget.hids[0]]!.length;

    if (widget.aggregate) {
      for (int i = 0; i < length; i++) {
        double sum = 0;

        for (String hid in widget.hids) {
          sum += datapoints[hid]![i] != null ? datapoints[hid]![i]! : 0;
        }

        if (sum > max) {
          max = sum;
        }
      }
    } else {
      for (int i = 0; i < length; i++) {
        for (String hid in widget.hids) {
          if (datapoints[hid]![i] > max) {
            max = datapoints[hid]![i];
          }
        }
      }
    }

    maxY = widget.max ?? max;

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    // Ensure no duplicates are present
    assert(widget.hids.toSet().length == widget.hids.length);

    maxY = widget.max ?? 100;

    fetchPowerUsageData();
    _timer = Timer.periodic(
        const Duration(seconds: 10), (Timer t) => fetchPowerUsageData());
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LineChart(
      mainData(),
    );
  }

  String formatDateTimeToHHMM(DateTime dateTime) {
    final DateFormat formatter = DateFormat('HH:mm');
    return formatter.format(dateTime);
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    int totalTimeframeInSeconds =
        (widget.numDatapoints - 1) * widget.datapointIntervalInSeconds;

    // Convert datapoint index to time offset
    value *= widget.datapointIntervalInSeconds;

    TextStyle style = Theme.of(context).textTheme.bodyMedium!;

    Widget text;

    if (value == 0 ||
        value == totalTimeframeInSeconds / 2 ||
        value == totalTimeframeInSeconds) {
      DateTime subtractedTime = DateTime.now()
          .subtract(Duration(seconds: totalTimeframeInSeconds - value.toInt()));
      text = Text(formatDateTimeToHHMM(subtractedTime), style: style);
    } else {
      text = Text('', style: style);
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    TextStyle style = Theme.of(context).textTheme.bodyMedium!;

    String text = '';

    if (value.toInt() == 0) {
      text = value.toInt().toString();
    }

    if (value == (widget.max ?? math.max(maxY * maxScale, 10))) {
      text = value.toInt().toString();
    }

    if (value.toInt() == (widget.max ?? math.max(maxY * maxScale, 10)) ~/ 2) {
      text = value.toInt().toString();
    }

    if (value.toInt() == (widget.max ?? 0).toInt()) {
      text = value.toInt().toString();
    }

    return Text(text, style: style, textAlign: TextAlign.left);
  }

  List<FlSpot> buildDatapoints(String hid) {
    List<FlSpot> spots = [];

    for (int i = 0; i < widget.numDatapoints; i++) {
      if (datapoints[hid] == null ||
          i < widget.numDatapoints - datapoints[hid]!.length) {
        spots.add(FlSpot(i.toDouble(), 0));
      } else {
        if (widget.aggregate) {
          double sum = 0;

          for (String hid0 in widget.hids) {
            int index = i - (widget.numDatapoints - datapoints[hid0]!.length);
            sum += datapoints[hid0]![index] != null
                ? datapoints[hid0]![index]!
                : 0;
            if (hid0 == hid) {
              break;
            }
          }

          spots.add(FlSpot(i.toDouble(), sum));
        } else {
          spots.add(FlSpot(i.toDouble(), datapoints[hid]![i]));
        }
      }
    }

    return spots;
  }

  LineChartData mainData() {
    List<Color> gradientColors = [
      Theme.of(context).colorScheme.primary,
      Theme.of(context).colorScheme.secondary,
    ];

    return LineChartData(
      lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
              fitInsideVertically: true,
              fitInsideHorizontally: true,
              maxContentWidth: double.infinity,
              tooltipBgColor: Theme.of(context).colorScheme.surface,
              tooltipRoundedRadius: 10,
              getTooltipItems: (touchedSpots) {
                List<LineTooltipItem> items = [];

                DateTime subtractedTime = DateTime.now().subtract(Duration(
                    seconds: ((widget.numDatapoints - 1) -
                            touchedSpots.first.x.toInt()) *
                        widget.datapointIntervalInSeconds));

                for (int i = 0; i < widget.hids.length; i++) {
                  double value = touchedSpots[i].y;

                  if (widget.aggregate) {
                    value = widget.hids.length > 1
                        ? touchedSpots[i + 1].y
                        : touchedSpots[i].y;

                    if (i + 2 < touchedSpots.length) {
                      value -= touchedSpots[i + 2].y;
                    }
                  }

                  items.add(LineTooltipItem(
                      "${widget.hids.length <= 1 ? "${formatDateTimeToHHMM(subtractedTime)} " : ""}${widget.hids.length > 1 ? "${widget.hids.reversed.toList()[i]} " : ""}- ${value.toStringAsFixed(1).toString()} ${widget.unit}",
                      TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      )));
                }

                if (widget.hids.length > 1 && widget.aggregate) {
                  items.insert(
                      0,
                      LineTooltipItem(
                          "${formatDateTimeToHHMM(subtractedTime)} - Total: ${touchedSpots.first.y.toStringAsFixed(1).toString()} ${widget.unit}",
                          TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          )));
                }

                return items;
              })),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: math.max(maxY, 10) / 5,
        verticalInterval: widget.numDatapoints / 20,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Theme.of(context).colorScheme.primary,
            strokeWidth: 0.5,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: Theme.of(context).colorScheme.primary,
            strokeWidth: 0.5,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 30,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: widget.numDatapoints - 1,
      minY: 0,
      maxY: math.max(maxY * maxScale, 10),
      lineBarsData: [
        for (String hid in widget.hids)
          LineChartBarData(
            spots: buildDatapoints(hid),
            isCurved: true,
            preventCurveOverShooting: true,
            gradient: LinearGradient(
              colors: gradientColors,
            ),
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: const FlDotData(
              show: false,
            ),
            belowBarData: BarAreaData(
              show: true,
              color: interpolateColor(
                  Colors.purple,
                  Theme.of(context).colorScheme.primary,
                  widget.hids.length,
                  widget.hids.indexOf(hid)),
            ),
          ),
        if (widget.hids.length > 1 && widget.aggregate)
          LineChartBarData(
            spots: buildDatapoints(widget.hids.last),
            isCurved: true,
            preventCurveOverShooting: true,
            gradient: LinearGradient(
              colors: gradientColors,
            ),
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: const FlDotData(
              show: false,
            ),
          ),
      ],
    );
  }
}

Color interpolateColor(
    Color colorA, Color colorB, int totalLines, int currentIndex) {
  // Calculate the base color value for n = 0 and n = N
  double baseRed = colorA.red.toDouble();
  double baseGreen = colorA.green.toDouble();
  double baseBlue = colorA.blue.toDouble();
  double topRed = colorB.red.toDouble();
  double topGreen = colorB.green.toDouble();
  double topBlue = colorB.blue.toDouble();

  // Calculate the difference between the base and top colors
  double diffRed = (topRed - baseRed) / totalLines;
  double diffGreen = (topGreen - baseGreen) / totalLines;
  double diffBlue = (topBlue - baseBlue) / totalLines;

  // Calculate the color for the current index
  double red = topRed - diffRed * (totalLines - 1 - currentIndex);
  double green = topGreen - diffGreen * (totalLines - 1 - currentIndex);
  double blue = topBlue - diffBlue * (totalLines - 1 - currentIndex);

  return Color.fromRGBO(red.round(), green.round(), blue.round(), 0.3);
}
