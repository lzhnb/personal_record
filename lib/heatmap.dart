// ignore_for_file: unnecessary_brace_in_string_interps

import "package:flutter/material.dart";
import "package:flutter/rendering.dart";
import "dart:convert";
import "dart:io";
import "src/heatmap/heatmap.dart";

// from https://zhuanlan.zhihu.com/p/350146779
class FixedSizeGridDelegate extends SliverGridDelegate {
  final double width;
  final double height;
  final double mainAxisSpacing;
  final double minCrossAxisSpacing;

  FixedSizeGridDelegate(
    this.width,
    this.height, {
    this.mainAxisSpacing = 0.0,
    this.minCrossAxisSpacing = 0.0,
  });

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    int crossAxisCount = constraints.crossAxisExtent ~/ width;
    double crossAxisSpacing =
        (constraints.crossAxisExtent - width * crossAxisCount) /
            (crossAxisCount - 1);

    while (crossAxisSpacing < minCrossAxisSpacing) {
      crossAxisCount -= 1;
      crossAxisSpacing =
          (constraints.crossAxisExtent - width * crossAxisCount) /
              (crossAxisCount - 1);
    }

    return SliverGridRegularTileLayout(
      crossAxisCount: crossAxisCount,
      mainAxisStride: height + mainAxisSpacing,
      crossAxisStride: width + crossAxisSpacing,
      childMainAxisExtent: height,
      childCrossAxisExtent: width,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
    );
  }

  @override
  bool shouldRelayout(FixedSizeGridDelegate oldDelegate) {
    return oldDelegate.width != width ||
        oldDelegate.height != height ||
        oldDelegate.mainAxisSpacing != mainAxisSpacing;
  }
}

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
    double runningCount = 0, paperCount = 0;
    Map<DateTime, double> runningMapDataset = {};
    Map<DateTime, double> readingMapDataset = {};
    tokenDatabase.forEach((date, value) {
      var running = value["running"];
      if (running is double) {
        running = running;
      } else {
        try {
          running = running.toDouble();
        } catch (e) {
          throw Exception("Error in parsing running!");
        }
      }
      List<String> reading = (value["reading"] as List<dynamic>).cast<String>();
      runningCount += running;
      paperCount += reading.length;
      if (running > 0) {
        runningMapDataset[DateTime.parse(date)] = running;
      }
      if (reading.isNotEmpty) {
        readingMapDataset[DateTime.parse(date)] = reading.length.toDouble();
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
        title: const Text("Summary"),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Text(
                "🏃‍累计跑步: ${runningCount} km",
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.left,
                textScaleFactor: 1.6,
              ),
            ),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              elevation: 10,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                  color: const Color.fromRGBO(255, 144, 0, 1.0),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Text(
                "📰累计阅读论文: ${paperCount.toInt()}",
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.left,
                textScaleFactor: 1.6,
              ),
            ),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              elevation: 10,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                  color: const Color.fromRGBO(218, 65, 64, 1.0),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Text(
                "📘累计阅读书籍: ${bookCount}",
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.left,
                textScaleFactor: 1.6,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(),
            ),
            Container(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView.builder(
                itemCount: bookDatabase.length,
                itemBuilder: (BuildContext context, int index) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16),
                        child: Text(
                          textAlign: TextAlign.left,
                          bookDatabase.keys.toList()[index],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      GridView.builder(
                        shrinkWrap: true,
                        itemCount: bookDatabase.values.toList()[index].length,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        gridDelegate: FixedSizeGridDelegate(120, 200,
                            mainAxisSpacing: 10),
                        itemBuilder: (BuildContext context, int bookIndex) {
                          return Column(
                            children: <Widget>[
                              SizedBox(
                                width: 120,
                                height: 177,
                                child: FadeInImage.assetNetwork(
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
                              SizedBox(
                                width: 120,
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
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Divider(),
                      ),
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
