// ignore_for_file: unnecessary_brace_in_string_interps

import "package:flutter/material.dart";
import "package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart";
import "dart:convert";
import "dart:io";
import "utils.dart";
import "package:tuple/tuple.dart";

class MyHeatMap extends StatefulWidget {
  const MyHeatMap({super.key});

  @override
  State<MyHeatMap> createState() => _MyHeatMapState();
}

class _MyHeatMapState extends State<MyHeatMap> {
  String dataBaseFile = "assets/data/db.json";

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // read json file
    String jsonString = File(dataBaseFile).readAsStringSync();
    // parse tokens
    Map<String, dynamic> dataBase = jsonDecode(jsonString)["tokens"];
    int runningCount = 0, readingCount = 0;
    List<Token> tokens = [];
    dataBase.forEach((date, value) {
      int running = value["running"] ?? 0;
      List<String> reading = (value["reading"] as List<dynamic>).cast<String>();
      runningCount += running;
      readingCount += reading.length;
      tokens.add(Token(date, running, reading));
    });

    // get maps
    Tuple2<Map<DateTime, int>, Map<DateTime, int>> datasets =
        tokensToMaps(tokens);
    Map<DateTime, int> runningMapDataset = datasets.item1;
    Map<DateTime, int> readingMapDataset = datasets.item2;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Calendar Heatmap"),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              " 🏃‍累计跑步（公里）：${runningCount}",
              textAlign: TextAlign.left,
              textScaleFactor: 2,
            ),
            Card(
              margin: const EdgeInsets.all(10),
              elevation: 10,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: HeatMap(
                  datasets: runningMapDataset,
                  size: 18,
                  scrollable: true,
                  startDate: DateTime(2023, 1, 1),
                  endDate: DateTime(2023, 12, 31),
                  textColor: Colors.black,
                  colorMode: ColorMode.opacity,
                  colorsets: const {
                    1: Color.fromRGBO(255, 144, 0, 1.0),
                  },
                ),
              ),
            ),
            Text(
              " 📰累计阅读论文：${readingCount}",
              textAlign: TextAlign.left,
              textScaleFactor: 2,
            ),
            Card(
              margin: const EdgeInsets.all(10),
              elevation: 10,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: HeatMap(
                  datasets: readingMapDataset,
                  size: 18,
                  scrollable: true,
                  startDate: DateTime(2023, 1, 1),
                  endDate: DateTime(2023, 12, 31),
                  textColor: Colors.black,
                  colorMode: ColorMode.opacity,
                  colorsets: const {
                    1: Color.fromRGBO(218, 65, 64, 1.0),
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
