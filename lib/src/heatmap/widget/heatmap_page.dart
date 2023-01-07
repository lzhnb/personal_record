import "dart:math";

import "package:flutter/material.dart";
import "./heatmap_month_text.dart";
import "./heatmap_column.dart";
import "../util/date_util.dart";
import "./heatmap_week_text.dart";

class HeatMapPage extends StatelessWidget {
  /// List value of every sunday's month information.
  ///
  /// From 1: January to 12: December.
  final List<int> _firstDayInfos = [];

  /// The number of days between [startDate] and [endDate].
  final int _dateDifferent;

  /// The Date value of start day of heatmap.
  ///
  /// HeatMap shows the start day of [startDate]'s week.
  ///
  /// Default value is 1 year before the [endDate].
  /// And if [endDate] is null, then set 1 year before the [DateTime.now]
  final DateTime startDate;

  /// The Date value of end day of heatmap.
  ///
  /// Default value is [DateTime.now]
  final DateTime endDate;

  /// The double value of every block's width and height.
  final double? size;

  /// The double value of every block's fontSize.
  final double? fontSize;

  /// The datasets which fill blocks based on its value.
  final Map<DateTime, int>? datasets;

  /// The integer value of the maximum value for the [datasets].
  final int? maxValue;

  /// The margin value for every block.
  final EdgeInsets? margin;

  /// The default background color value of every blocks.
  final Color? defaultColor;

  /// The text color value of every blocks.
  final Color? textColor;

  final Color? color;

  /// The double value of every block's borderRadius.
  final double? borderRadius;

  /// Function that will be called when a block is clicked.
  ///
  /// Paratmeter gives clicked [DateTime] value.
  final Function(DateTime)? onClick;

  HeatMapPage({
    Key? key,
    required this.startDate,
    required this.endDate,
    this.size,
    this.fontSize,
    this.datasets,
    this.maxValue = 10,
    this.defaultColor,
    this.textColor,
    this.color,
    this.borderRadius,
    this.onClick,
    this.margin,
  })  : _dateDifferent = endDate.difference(startDate).inDays,
        super(key: key);

  /// Get [HeatMapColumn] from [startDate] to [endDate].
  List<Widget> _heatmapColumnList() {
    // Create empty list.
    List<Widget> columns = [];

    // Set cursor(position) to first day of weeks
    // until cursor reaches the final week.
    for (int datePos = 0 - (startDate.weekday % 7);
        datePos <= _dateDifferent;
        datePos += 7) {
      // Get first day of week by adding cursor's value to startDate.
      // ignore: no_leading_underscores_for_local_identifiers
      DateTime _firstDay = DateUtil.changeDay(startDate, datePos);

      columns.add(
        HeatMapColumn(
          // If last day is not saturday, week also includes future Date.
          // So we have to make future day on last column blanck.
          //
          // To make empty space to future day, we have to pass this HeatMapPage's
          // endDate to HeatMapColumn's endDate.
          startDate: _firstDay,
          endDate: datePos <= _dateDifferent - 7
              ? DateUtil.changeDay(startDate, datePos + 6)
              : endDate,
          numDays: min(endDate.difference(_firstDay).inDays + 1, 7),
          size: size,
          fontSize: fontSize,
          defaultColor: defaultColor,
          color: color,
          textColor: textColor,
          borderRadius: borderRadius,
          margin: margin,
          maxValue: maxValue,
          onClick: onClick,
          datasets: datasets,
        ),
      );

      // also add first day's month information to _firstDayInfos list.
      _firstDayInfos.add(_firstDay.month);
    }

    return columns;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Show week labels to left side of heatmap.
            HeatMapWeekText(
              margin: margin,
              fontSize: fontSize,
              size: size,
              fontColor: textColor,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Show month labels to top of heatmap.
                HeatMapMonthText(
                  firstDayInfos: _firstDayInfos,
                  margin: margin,
                  fontSize: fontSize,
                  fontColor: textColor,
                  size: size,
                ),

                // Heatmap itself.
                Row(
                  children: <Widget>[..._heatmapColumnList()],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
