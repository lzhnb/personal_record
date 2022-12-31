import "package:tuple/tuple.dart";
import "package:intl/intl.dart";

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

Tuple2<Map<DateTime, int>, Map<DateTime, int>> tokensToMaps(
    List<Token> tokens) {
  Map<DateTime, int> runningMapDatasets = {};
  Map<DateTime, int> readingMapDatasets = {};

  for (Token token in tokens) {
    DateTime? dateTime = DateTime.tryParse(token.date);
    if (dateTime != null) {
      if (token.running > 0) {
        // NOTE: it can not in a situation of all 0
        runningMapDatasets[dateTime] = token.running;
      }
      if (token.reading.isNotEmpty) {
        // NOTE: it can not in a situation of all 0
        readingMapDatasets[dateTime] = token.reading.length;
      }
    }
  }

  return Tuple2<Map<DateTime, int>, Map<DateTime, int>>(
      runningMapDatasets, readingMapDatasets);
}

class TokenManager {
  final DateFormat formatter = DateFormat("yyyy-MM-dd");

  Map<String, int> runningMapDatasets = {};
  Map<String, List<String>> readingMapDatasets = {};

  TokenManager(this.runningMapDatasets, this.readingMapDatasets);

  Future<void> deletePaper(DateTime date, int index) async {
    final String dateString = formatter.format(date);
    print("dateString: $dateString");
    print("before readingMapDatasets:\n$readingMapDatasets");
    readingMapDatasets[dateString]?.removeAt(index);
    print("after readingMapDatasets:\n$readingMapDatasets");
  }

  Tuple2<int, List<String>> dateQeury(DateTime date) {
    final String dateString = formatter.format(date);
    int running = runningMapDatasets[dateString] ?? 0;
    List<String> reading = readingMapDatasets[dateString] ?? [];
    return Tuple2<int, List<String>>(running, reading);
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
    // for (Token token in tokens) {
    //   DateTime? dateTime = DateTime.tryParse(token.date);
    //   if (dateTime != null) {
    //     if (token.running > 0) {
    //       // NOTE: it can not in a situation of all 0
    //       runningMapDatasets[dateTime] = token.running;
    //     }
    //     if (token.reading.isNotEmpty) {
    //       // NOTE: it can not in a situation of all 0
    //       readingMapDatasets[dateTime] = token.reading;
    //     }
    //   }
    // }
    for (Token token in tokens) {
      if (token.running > 0) {
        // NOTE: it can not in a situation of all 0
        runningMapDatasets[token.date] = token.running;
      }
      if (token.reading.isNotEmpty) {
        // NOTE: it can not in a situation of all 0
        readingMapDatasets[token.date] = token.reading;
      }
    }
  }

  Map<String, dynamic> exportTokens() {
    List<String> runningDates = runningMapDatasets.keys.toList();
    List<String> readingDates = readingMapDatasets.keys.toList();
    Set<String> allDatesSet = <String>{};
    allDatesSet.addAll(runningDates);
    allDatesSet.addAll(readingDates);
    List<String> allDates = allDatesSet.toList();
    Map<String, dynamic> exportTokens = {};

    for (String dateString in allDates) {
      int runningDistance = runningMapDatasets[dateString] ?? 0;
      List<String> readingPapers = readingMapDatasets[dateString] ?? [];
      if (runningDistance > 0 || readingPapers.isNotEmpty) {
        exportTokens[dateString] = {
          "running": runningDistance,
          "reading": readingPapers,
        };
      }
    }
    return exportTokens;
  }
}

/* Calendar */
final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year - 1, 1, 1);
final kLastDay = DateTime(kToday.year + 1, 12, 31);
