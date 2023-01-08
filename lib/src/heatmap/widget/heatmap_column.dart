import "dart:math";

import "package:flutter/material.dart";
import "./heatmap_container.dart";
import "../util/date_util.dart";

class HeatMapColumn extends StatelessWidget {
  /// The List widgets of [HeatMapContainer].
  ///
  /// It includes every days of the week and
  /// if one week doesn't have 7 days, it will be filled with empty [Container].
  final List<Widget> dayContainers;

  /// The List widgets of empty [Container].
  ///
  /// It only processes when given week's length is not 7.
  final List<Widget> emptySpace;

  /// The date value of first day of given week.
  final DateTime startDate;

  /// The date value of last day of given week.
  final DateTime endDate;

  /// The double value of every [HeatMapContainer]'s width and height.
  final double? size;

  /// The double value of every [HeatMapContainer]'s fontSize.
  final double? fontSize;

  /// The default background color value of [HeatMapContainer].
  final Color? defaultColor;

  /// The datasets which fill blocks based on its value.
  ///
  /// datasets keys have to greater or equal to [startDate] and
  /// smaller or equal to [endDate].
  final Map<DateTime, double>? datasets;

  /// The text color value of [HeatMapContainer].
  final Color? textColor;

  /// The color value.
  final Color? color;

  /// The double value of [HeatMapContainer]'s borderRadius.
  final double? borderRadius;

  /// The margin value for every block.
  final EdgeInsets? margin;

  /// Function that will be called when a block is clicked.
  ///
  /// Paratmeter gives clicked [DateTime] value.
  final Function(DateTime)? onClick;

  /// The integer value of the maximum value for the highest value of the month.
  final int? maxValue;

  // The number of day blocks to draw. This should be seven for all but the
  // current week.
  final int numDays;

  HeatMapColumn({
    Key? key,
    required this.startDate,
    required this.endDate,
    required this.numDays,
    this.size,
    this.fontSize,
    this.defaultColor,
    this.datasets,
    this.textColor,
    this.borderRadius,
    this.margin,
    this.color,
    this.onClick,
    this.maxValue,
  })  :
        // Init list.
        dayContainers = List.generate(
          numDays,
          (i) => HeatMapContainer(
              date: DateUtil.changeDay(startDate, i),
              backgroundColor: defaultColor,
              size: size,
              fontSize: fontSize,
              textColor: textColor,
              borderRadius: borderRadius,
              margin: margin,
              onClick: onClick,
              // If datasets has DateTime key which is equal to this HeatMapContainer's date,
              // we have to color the matched HeatMapContainer.
              //
              // If datasets is null or doesn't contains the equal DateTime value, send null.
              selectedColor: datasets?.keys.contains(
                        DateTime(startDate.year, startDate.month,
                            startDate.day - startDate.weekday % 7 + i),
                      ) ??
                      false
                  // Color and set opacity value to current day's datasets key
                  // devided by maxValue which is the maximum value of the month.
                  ? color?.withOpacity(
                      min(
                          (datasets?[DateTime(
                                      startDate.year,
                                      startDate.month,
                                      startDate.day +
                                          i -
                                          (startDate.weekday % 7))] ??
                                  1) /
                              (maxValue ?? 1),
                          1.0),
                    )
                  : null),
        ),
        // Fill emptySpace list only if given wek doesn't have 7 days.
        emptySpace = (numDays != 7)
            ? List.generate(
                7 - numDays,
                (i) => Container(
                    margin: margin ?? const EdgeInsets.all(2),
                    width: size ?? 42,
                    height: size ?? 42),
              )
            : [],
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[...dayContainers, ...emptySpace],
    );
  }
}
