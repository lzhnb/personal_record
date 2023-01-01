// ignore_for_file: unnecessary_brace_in_string_interps

import "package:flutter/material.dart";
import "package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart";
import "dart:convert";
import "dart:io";

class MyHeatMap extends StatefulWidget {
  const MyHeatMap({super.key});

  @override
  State<MyHeatMap> createState() => _MyHeatMapState();
}

class _MyHeatMapState extends State<MyHeatMap> {
  String databaseFile = "assets/data/db.json";

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // read json file
    String jsonString = File(databaseFile).readAsStringSync();
    // parse tokens
    Map<String, dynamic> tokenDatabase = jsonDecode(jsonString)["tokens"];
    Map<String, dynamic> bookDatabase = jsonDecode(jsonString)["books"];
    int runningCount = 0, paperCount = 0;
    Map<DateTime, int> runningMapDataset = {};
    Map<DateTime, int> readingMapDataset = {};
    tokenDatabase.forEach((date, value) {
      int running = value["running"] ?? 0;
      List<String> reading = (value["reading"] as List<dynamic>).cast<String>();
      runningCount += running;
      paperCount += reading.length;
      if (running > 0) {
        runningMapDataset[DateTime.parse(date)] = running;
      }
      if (reading.isNotEmpty) {
        readingMapDataset[DateTime.parse(date)] = reading.length;
      }
    });

    // parse books
    int bookCount = 0;

    for (String category in bookDatabase.keys) {
      List<String> bookList =
          (bookDatabase[category] as List<dynamic>).cast<String>();
      bookCount += bookList.length;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(94, 161, 254, 1.0),
        title: const Text("Calendar Heatmap && Book Gallary"),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                " 🏃‍累计跑步（公里）：${runningCount}",
                textAlign: TextAlign.left,
                textScaleFactor: 1.6,
              ),
            ),
            Card(
              margin: const EdgeInsets.all(10),
              elevation: 10,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: HeatMap(
                  borderRadius: 2,
                  margin: const EdgeInsets.all(1.2),
                  size: 12,
                  fontSize: 10,
                  datasets: runningMapDataset,
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
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                " 📰累计阅读论文：${paperCount}",
                textAlign: TextAlign.left,
                textScaleFactor: 1.6,
              ),
            ),
            Card(
              margin: const EdgeInsets.all(10),
              elevation: 10,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: HeatMap(
                  borderRadius: 2,
                  margin: const EdgeInsets.all(1.2),
                  size: 12,
                  fontSize: 10,
                  datasets: readingMapDataset,
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
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                " 📘累计阅读书籍：${bookCount}",
                textAlign: TextAlign.left,
                textScaleFactor: 1.6,
              ),
            ),
            SizedBox(
              height: 300,
              child: ListView.builder(
                itemCount: bookDatabase.length,
                itemBuilder: (BuildContext context, int index) {
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(bookDatabase.keys.toList()[index]),
                      ),
                      GridView.builder(
                        shrinkWrap: true,
                        itemCount: bookDatabase.values.toList()[index].length,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 6,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 0.7,
                        ),
                        itemBuilder: (BuildContext context, int bookIndex) {
                          return Column(
                            children: <Widget>[
                              SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: FadeInImage.assetNetwork(
                                  height: 130,
                                  fit: BoxFit.fill,
                                  placeholder:
                                      "assets/images/bookPlaceholder.png",
                                  image: bookDatabase.values.toList()[index]
                                      [bookIndex]["file"],
                                  imageErrorBuilder:
                                      ((context, error, stackTrace) {
                                    return Image.asset(
                                        height: 130,
                                        fit: BoxFit.fill,
                                        "assets/images/bookPlaceholder.png");
                                  }),
                                ),
                              ),
                              // Card(
                              //   child: FadeInImage.assetNetwork(
                              //     fit: BoxFit.cover,
                              //     placeholder:
                              //         "assets/images/bookPlaceholder.png",
                              //     image: bookDatabase.values.toList()[index]
                              //         [bookIndex]["file"],
                              //     imageErrorBuilder:
                              //         ((context, error, stackTrace) {
                              //       return Image.asset(
                              //           fit: BoxFit.fill,
                              //           "assets/images/bookPlaceholder.png");
                              //     }),
                              //   ),
                              // ),
                              SizedBox(
                                width: 80,
                                child: Text(
                                  bookDatabase.values.toList()[index][bookIndex]
                                      ["title"],
                                  softWrap: true,
                                  textAlign: TextAlign.left,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                              )
                            ],
                          );
                        },
                      )
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
