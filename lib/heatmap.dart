import "package:flutter/material.dart";
import "package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart";

class MyHeatMap extends StatefulWidget {
  const MyHeatMap({super.key});

  @override
  State<MyHeatMap> createState() => _MyHeatMapState();
}

class _MyHeatMapState extends State<MyHeatMap> {
  final TextEditingController dateController = TextEditingController();
  final TextEditingController heatLevelController = TextEditingController();

  Map<DateTime, int> heatMapDatasets = {
    DateTime(2023, 8, 6): 3,
    DateTime(2023, 8, 7): 7,
    DateTime(2023, 8, 8): 10,
    DateTime(2023, 8, 9): 13,
    DateTime(2023, 8, 13): 6,
  };

  Widget _textField(final String hint, final TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 20, top: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xffe7e7e7), width: 1.0)),
          focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF20bca4), width: 1.0)),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
          isDense: true,
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    dateController.dispose();
    heatLevelController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(10),
            elevation: 10,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: HeatMap(
                datasets: heatMapDatasets,
                size: 20,
                scrollable: true,
                startDate: DateTime(2023, 1, 1),
                endDate: DateTime(2023, 12, 31),
                textColor: Colors.black,
                colorMode: ColorMode.opacity,
                showText: false,
                colorsets: {
                  1: Colors.green,
                },
                onClick: (value) {
                  setState(() {
                    dateController.text = value.year.toString() +
                        "-" +
                        value.month.toString().padLeft(2, "0") +
                        "-" +
                        value.day.toString().padLeft(2, "0");
                    int heat =
                        heatMapDatasets[DateTime.parse(dateController.text)] ??
                            1;
                    heatLevelController.text = heat.toString();
                  });
                },
              ),
            ),
          ),
          _textField("YYYY-MM-DD", dateController),
          _textField("Heat Level", heatLevelController),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 100,
                  height: 30,
                  margin: const EdgeInsets.all(5),
                  child: SizedBox(
                    child: ElevatedButton(
                      child: const Text("COMMIT"),
                      onPressed: () {
                        setState(() {
                          DateTime? dateTime =
                              DateTime.tryParse(dateController.text);
                          int? heatLevel =
                              int.tryParse(heatLevelController.text);
                          if (dateTime != null && heatLevel != null) {
                            heatMapDatasets[
                                    DateTime.parse(dateController.text)] =
                                int.parse(heatLevelController.text);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    "Invalid input datetime or heatlevel!"),
                              ),
                            );
                          }
                        });
                      },
                    ),
                  ),
                ),
                Container(
                  width: 100,
                  height: 30,
                  margin: const EdgeInsets.all(5),
                  child: SizedBox(
                    child: ElevatedButton(
                      child: const Text("CLEAR"),
                      onPressed: () {
                        setState(() {
                          DateTime? dateTime =
                              DateTime.tryParse(dateController.text);
                          if (dateTime != null) {
                            heatMapDatasets[dateTime] = 0;
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Invalid input datetime!"),
                              ),
                            );
                          }
                        });
                      },
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
