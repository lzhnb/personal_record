// ignore_for_file: unnecessary_brace_in_string_interps

import "package:flutter/material.dart";
import "package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart";
import 'dart:convert';
import 'dart:io';

class Token {
  String date;
  int running;
  List<String> reading;

  Token(this.date, this.running, this.reading);

  factory Token.fromJson(dynamic json) {
    return Token(json['date'] as String, json['running'] as int,
        (json["reading"] as List<dynamic>).cast<String>());
  }

  @override
  String toString() {
    return '{ ${date}, ${running}, ${reading.toString()}}';
  }

  Map toJson() => {
        "date": date,
        "running": running,
        "reading": reading,
      };
}

class TokenManager {
  Map<DateTime, int> runningMapDatasets = {};
  Map<DateTime, List<String>> readingMapDatasets = {};

  TokenManager(this.runningMapDatasets, this.readingMapDatasets);

  int runningCount() {
    int count = 0;
    runningMapDatasets.forEach((key, value) {
      count += value;
    });
    return count;
  }

  int readingCount() {
    int count = 0;
    readingMapDatasets.forEach((key, value) {
      count += value.length;
    });
    return count;
  }

  Map<DateTime, int> readingCountMapDatasets() {
    Map<DateTime, int> readingCountMapDatasets = {};

    readingMapDatasets.forEach((key, value) {
      int length = value.length;
      if (length > 0) {
        readingCountMapDatasets[key] = length;
      }
    });
    return readingCountMapDatasets;
  }

  void parseTokens(List<Token> tokens) {
    /*
    Example:
    {
      "user": [
        {
          "date": "2023-10-01",
          "running": 10,
          "reading": [
            "paper1",
            "paper2"
          ]
        }
      ]
    }
    */
    for (Token token in tokens) {
      DateTime? dateTime = DateTime.tryParse(token.date);
      if (dateTime != null) {
        if (token.running > 0) {
          // NOTE: it can not in a situation of all 0
          runningMapDatasets[dateTime] = token.running;
        }
        if (token.reading.isNotEmpty) {
          // NOTE: it can not in a situation of all 0
          readingMapDatasets[dateTime] = token.reading;
        }
      }
    }
  }

  List<Token> exportTokens() {
    List<Token> exportTokens = [];
    // get all dates
    List<DateTime> runningDates = runningMapDatasets.keys.toList();
    List<DateTime> readingDates = readingMapDatasets.keys.toList();
    Set<DateTime> allDatesSet = <DateTime>{};
    allDatesSet.addAll(runningDates);
    allDatesSet.addAll(readingDates);
    List<DateTime> allDates = allDatesSet.toList();
    // loop all dates
    for (DateTime date in allDates) {
      String dateString =
          "${date.year}-${date.month.toString().padLeft(2, "0")}-${date.day.toString().padLeft(2, "0")}";
      int runningDistance = runningMapDatasets[date] ?? 0;
      List<String> readingPapers = readingMapDatasets[date] ?? [];
      Token token = Token(dateString, runningDistance, readingPapers);
      exportTokens.add(token);
    }
    return exportTokens;
  }
}

class MyHeatMap extends StatefulWidget {
  const MyHeatMap({super.key});

  @override
  State<MyHeatMap> createState() => _MyHeatMapState();
}

class _MyHeatMapState extends State<MyHeatMap> {
  final TextEditingController dateController = TextEditingController();
  final TextEditingController runnningController = TextEditingController();
  final TextEditingController readingController = TextEditingController();

  String dataBaseFile = "assets/data/db.json";

  TokenManager tokenManager =
      TokenManager(<DateTime, int>{}, <DateTime, List<String>>{});

  // ignore: non_constant_identifier_names
  Widget DateTextField() {
    DateTime now = DateTime.now();
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16.0),
      child: TextField(
        controller: dateController,
        autofocus: true,
        decoration: InputDecoration(
          enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xffe7e7e7), width: 1.0)),
          focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF20bca4), width: 1.0)),
          labelText: "YYYY-MM-DD",
          hintText:
              "${now.year}-${now.month.toString().padLeft(2, "0")}-${now.day.toString().padLeft(2, "0")}",
          hintStyle: const TextStyle(color: Colors.grey),
          isDense: true,
          suffix: ElevatedButton(
            child: const Text("CLEAR"),
            onPressed: () {
              DateTime? dateTime = DateTime.tryParse(dateController.text);
              if (dateTime != null) {
                // NOTE: it can not in a situation of all 0
                tokenManager.runningMapDatasets.remove(dateTime);
                tokenManager.readingMapDatasets[dateTime] = [];
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Invalid input datetime!"),
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Widget RunningTextField() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8.0),
      child: TextField(
        controller: runnningController,
        decoration: InputDecoration(
          enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xffe7e7e7), width: 1.0)),
          focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF20bca4), width: 1.0)),
          hintText: "Running Distance: 5",
          hintStyle: const TextStyle(color: Colors.grey),
          isDense: true,
          suffix: ElevatedButton(
            child: const Text("COMMIT RUNNING"),
            onPressed: () {
              DateTime? dateTime = DateTime.tryParse(dateController.text);
              int? runningDistance = int.tryParse(runnningController.text);
              if (dateTime != null && runningDistance != null) {
                tokenManager.runningMapDatasets[dateTime] = runningDistance;
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text("Invalid input datetime or running distance!"),
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Widget ReadingTextField() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8.0),
      child: TextField(
        controller: readingController,
        decoration: InputDecoration(
          enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xffe7e7e7), width: 1.0)),
          focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF20bca4), width: 1.0)),
          hintText: "Paper Title",
          hintStyle: const TextStyle(color: Colors.grey),
          isDense: true,
          suffix: ElevatedButton(
            child: const Text("COMMIT READING"),
            onPressed: () {
              DateTime? dateTime = DateTime.tryParse(dateController.text);
              String paperTitle = readingController.text;
              if (dateTime != null && paperTitle != "") {
                if (tokenManager.readingMapDatasets[dateTime] == null) {
                  tokenManager.readingMapDatasets[dateTime] = [paperTitle];
                } else {
                  tokenManager.readingMapDatasets[dateTime]?.add(paperTitle);
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Invalid input datetime!"),
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Future<void> _saveAsJson() async {
    // convert `runningMapDatasets` into tokens
    List<Token> exportTokens = tokenManager.exportTokens();
    // write into json file
    Map<String, dynamic> exportJson = {"tokens": exportTokens};
    try {
      File jsonFile = File(dataBaseFile);
      String jsonString = jsonEncode(exportJson);
      jsonFile.writeAsString(jsonString);
    } catch (e) {
      // ignore: avoid_print
      print("faile to write into ${dataBaseFile}!");
    }
  }

  @override
  void dispose() {
    super.dispose();
    dateController.dispose();
    runnningController.dispose();
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
        title: const Text("My Heatmap"),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DateTextField(),
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
                    1: Colors.orange,
                  },
                  onClick: (value) {
                    setState(() {
                      dateController.text =
                          "${value.year}-${value.month.toString().padLeft(2, "0")}-${value.day.toString().padLeft(2, "0")}";
                      int heat = tokenManager.runningMapDatasets[
                              DateTime.parse(dateController.text)] ??
                          1;
                      runnningController.text = heat.toString();
                    });
                  },
                ),
              ),
            ),
            RunningTextField(),
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
                    1: Colors.red,
                  },
                  onClick: (value) {
                    setState(() {
                      dateController.text =
                          "${value.year}-${value.month.toString().padLeft(2, "0")}-${value.day.toString().padLeft(2, "0")}";
                    });
                  },
                ),
              ),
            ),
            ReadingTextField(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveAsJson,
        child: const Icon(Icons.save),
      ),
    );
  }
}
