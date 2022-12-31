// ignore_for_file: unnecessary_brace_in_string_interps

import "package:flutter/material.dart";
import "package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart";
import "dart:convert";
import "dart:io";
import "utils.dart";

class MyHeatMap extends StatefulWidget {
  const MyHeatMap({super.key});

  @override
  State<MyHeatMap> createState() => _MyHeatMapState();
}

class _MyHeatMapState extends State<MyHeatMap> {
  String dataBaseFile = "assets/data/db.json";

  TokenManager tokenManager =
      TokenManager(<DateTime, int>{}, <DateTime, List<String>>{});

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // read json file
    String jsonString = File(dataBaseFile).readAsStringSync();
    // parse token
    var dataBase = jsonDecode(jsonString)["tokens"] as List;
    List<Token> tokens =
        dataBase.map((tokenJson) => Token.fromJson(tokenJson)).toList();

    tokenManager.parseTokens(tokens);

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Calendar Heatmap"),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              " 🏃‍累计跑步（公里）：${tokenManager.runningCount()}",
              textAlign: TextAlign.left,
              textScaleFactor: 2,
            ),
            Card(
              margin: const EdgeInsets.all(10),
              elevation: 10,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: HeatMap(
                  datasets: tokenManager.runningMapDatasets,
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
              " 📰累计阅读论文：${tokenManager.readingCount()}",
              textAlign: TextAlign.left,
              textScaleFactor: 2,
            ),
            Card(
              margin: const EdgeInsets.all(10),
              elevation: 10,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: HeatMap(
                  datasets: tokenManager.readingCountMapDatasets(),
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
