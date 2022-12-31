// Copyright 2019 Aleksander Woźniak
// SPDX-License-Identifier: Apache-2.0

// ignore_for_file: unnecessary_brace_in_string_interps

import "package:tuple/tuple.dart";

/* Token */

class Token {
  String date;
  int running;
  List<String> reading;

  Token(this.date, this.running, this.reading);

  factory Token.fromJson(dynamic json) {
    return Token(json["date"] as String, json["running"] as int,
        (json["reading"] as List<dynamic>).cast<String>());
  }

  @override
  String toString() {
    return "{ ${date}, ${running}, ${reading.toString()}}";
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

  void deletePaper(DateTime date, int index) {
    readingMapDatasets[date]?.removeAt(index);
  }

  Tuple2<int, List<String>> dateQeury(DateTime date) {
    int running = runningMapDatasets[date] ?? 0;
    List<String> reading = readingMapDatasets[date] ?? [];
    return Tuple2<int, List<String>>(running, reading);
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
      if (runningDistance > 0 || readingPapers.isNotEmpty) {
        exportTokens.add(Token(dateString, runningDistance, readingPapers));
      }
    }
    return exportTokens;
  }
}

/* Calendar */
final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year - 1, 1, 1);
final kLastDay = DateTime(kToday.year + 1, 12, 31);
