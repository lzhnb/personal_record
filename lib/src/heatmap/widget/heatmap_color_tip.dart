import "package:flutter/material.dart";
import "../data/heatmap_color.dart";

class HeatMapColorTip extends StatelessWidget {
  /// Default length of [containerCount].
  final int _defaultLength = 5;

  /// The color value.
  final Color? color;

  /// The default background color value of every blocks.
  final Color? defaultColor;

  /// The double value of every block's borderRadius.
  final double? borderRadius;

  /// The widget which shows left side of [HeatMapColorTip].
  ///
  /// If the value is null then show default 'less' [Text].
  final Widget? leftWidget;

  /// The widget which shows right side of [HeatMapColorTip].
  ///
  /// If the value is null then show default 'more' [Text].
  final Widget? rightWidget;

  /// The integer value of color tip containers count.
  final int? containerCount;

  /// The double value of tip container's size.
  final double? size;

  const HeatMapColorTip({
    Key? key,
    this.color,
    this.defaultColor,
    this.borderRadius,
    this.leftWidget,
    this.rightWidget,
    this.containerCount,
    this.size,
  }) : super(key: key);

  /// It returns the List of tip container.
  List<Widget> _heatmapList() => _heatmapListOpacity();

  /// Evenly show every colors from transparent to non-transparent.
  List<Widget> _heatmapListOpacity() {
    List<Widget> children = [];

    for (int i = 0; i < (containerCount ?? _defaultLength); i++) {
      children.add(_tipContainer(i == 0
          ? (defaultColor ?? HeatMapColor.defaultColor)
          : color?.withOpacity(i / (containerCount ?? _defaultLength)) ??
              Colors.white));
    }
    return children;
  }

  /// Container which is colored by [color].
  Widget _tipContainer(Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1),
      child: Container(
        width: size ?? 10,
        height: size ?? 10,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.all(
            Radius.circular(borderRadius ?? 5),
          ),
        ),
      ),
    );
  }

  /// Default text widget.
  Widget _defaultText(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: size ?? 10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 8, right: 20),
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          leftWidget ?? _defaultText("Less"),
          ..._heatmapList(),
          rightWidget ?? _defaultText("More"),
        ],
      ),
    );
  }
}
