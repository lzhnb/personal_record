import "package:flutter/material.dart";
import "./widget/heatmap_page.dart";
import "./widget/heatmap_color_tip.dart";
import "./util/date_util.dart";

class HeatMap extends StatefulWidget {
  /// The Date value of start day of heatmap.
  ///
  /// HeatMap shows the start day of [startDate]'s week.
  ///
  /// Default value is 1 year before of the [endDate].
  /// And if [endDate] is null, then set 1 year before of the [DateTime.now].
  final DateTime? startDate;

  /// The Date value of end day of heatmap.
  ///
  /// Default value is [DateTime.now].
  final DateTime? endDate;

  /// The datasets which fill blocks based on its value.
  final Map<DateTime, double>? datasets;

  /// The maximum of value.
  final int? maxValue;

  /// The color value of every block's default color.
  final Color? defaultColor;

  /// The text color value of every blocks.
  final Color? textColor;

  /// The double value of every block's size.
  final double? size;

  /// The double value of every block's fontSize.
  final double? fontSize;

  /// The color value.
  final Color color;

  /// Function that will be called when a block is clicked.
  ///
  /// Parameter gives clicked [DateTime] value.
  final Function(DateTime)? onClick;

  /// The margin value for every block.
  final EdgeInsets? margin;

  /// The double value of every block's borderRadius.
  final double? borderRadius;

  /// Show day text in every blocks if the value is true.
  ///
  /// Default value is false.
  final bool? showText;

  /// Show color tip which represents the color range at the below.
  ///
  /// Default value is true.
  final bool? showColorTip;

  /// Makes heatmap scrollable if the value is true.
  ///
  /// default value is false.
  final bool scrollable;

  /// Widgets which shown at left and right side of colorTip.
  ///
  /// First value is the left side widget and second value is the right side widget.
  /// Be aware that [colorTipHelper.length] have to greater or equal to 2.
  /// Give null value makes default 'less' and 'more' [Text].
  final List<Widget?>? colorTipHelper;

  /// The integer value which represents the number of [HeatMapColorTip]'s tip container.
  final int? colorTipCount;

  /// The double value of [HeatMapColorTip]'s tip container's size.
  final double? colorTipSize;

  const HeatMap({
    Key? key,
    required this.color,
    this.startDate,
    this.endDate,
    this.textColor,
    this.size = 20,
    this.fontSize,
    this.onClick,
    this.margin,
    this.borderRadius,
    this.datasets,
    this.maxValue = 10,
    this.defaultColor,
    this.showText = false,
    this.showColorTip = true,
    this.scrollable = false,
    this.colorTipHelper,
    this.colorTipCount,
    this.colorTipSize,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HeatMap();
}

class _HeatMap extends State<HeatMap> {
  /// Put child into [SingleChildScrollView] so that user can scroll the widet horizontally.
  Widget _scrollableHeatMap(Widget child) {
    return widget.scrollable
        ? SingleChildScrollView(
            reverse: true,
            scrollDirection: Axis.horizontal,
            child: child,
          )
        : child;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 800),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Heatmap Widget.
          _scrollableHeatMap(
            HeatMapPage(
              endDate: widget.endDate ?? DateTime.now(),
              startDate: widget.startDate ??
                  DateUtil.oneYearBefore(widget.endDate ?? DateTime.now()),
              size: widget.size,
              fontSize: widget.fontSize,
              datasets: widget.datasets,
              maxValue: widget.maxValue,
              defaultColor: widget.defaultColor,
              textColor: widget.textColor,
              color: widget.color,
              borderRadius: widget.borderRadius,
              onClick: widget.onClick,
              margin: widget.margin,
            ),
          ),
          // Show HeatMapColorTip if showColorTip is true.
          if (widget.showColorTip == true)
            HeatMapColorTip(
              color: widget.color,
              defaultColor: widget.defaultColor,
              borderRadius: widget.borderRadius,
              leftWidget: widget.colorTipHelper?[0],
              rightWidget: widget.colorTipHelper?[1],
              containerCount: widget.colorTipCount,
              size: widget.colorTipSize,
            ),
        ],
      ),
    );
  }
}
