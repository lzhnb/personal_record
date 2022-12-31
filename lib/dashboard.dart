import "utils.dart";
import "dart:convert";
import "dart:io";
import "package:table_calendar/table_calendar.dart";
import "package:flutter/material.dart";

class CalendarDashboard extends StatefulWidget {
  const CalendarDashboard({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CalendarDashboardState createState() => _CalendarDashboardState();
}

class _CalendarDashboardState extends State<CalendarDashboard> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // init controller
  final TextEditingController runningController = TextEditingController();
  final TextEditingController readingController = TextEditingController();
  final TextEditingController tempReadingController = TextEditingController();

  // parse json
  String dataBaseFile = "assets/data/db.json";
  TokenManager tokenManager =
      TokenManager(<DateTime, int>{}, <DateTime, List<String>>{});

  // ignore: non_constant_identifier_names
  Widget RunningInputField() {
    return Padding(
      padding:
          const EdgeInsets.only(left: 16, right: 16, top: 8.0, bottom: 8.0),
      child: Row(
        children: <Widget>[
          Container(
            height: 40,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(width: 1, color: Colors.black12)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // Minus
                IconButton(
                  padding: const EdgeInsets.all(0),
                  icon: const Icon(Icons.remove),
                  onPressed: (() {
                    if (runningController.text == "") {
                      runningController.text = "0";
                    } else if (runningController.text == "0") {
                    } else {
                      runningController.text =
                          (int.parse(runningController.text) - 1).toString();
                    }
                  }),
                ),
                // Textfield
                Container(
                  width: 80,
                  decoration: const BoxDecoration(
                      border: Border(
                          left: BorderSide(width: 1, color: Colors.black12),
                          right: BorderSide(width: 1, color: Colors.black12))),
                  child: TextField(
                    controller: runningController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 20),
                    enableInteractiveSelection: false,
                    decoration: const InputDecoration(
                      contentPadding:
                          EdgeInsets.only(left: 0, top: 2, bottom: 2, right: 0),
                      border: OutlineInputBorder(
                        gapPadding: 0,
                        borderSide: BorderSide(
                          width: 0,
                          style: BorderStyle.none,
                        ),
                      ),
                    ),
                  ),
                ),
                // Plus
                IconButton(
                  padding: const EdgeInsets.all(0),
                  icon: const Icon(Icons.add),
                  onPressed: (() {
                    if (runningController.text == "") {
                      runningController.text = "1";
                    } else {
                      runningController.text =
                          (int.parse(runningController.text) + 1).toString();
                    }
                  }),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 8),
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                    const Color.fromRGBO(255, 144, 0, 1.0)),
              ),
              child: const Text("COMMIT RUNNING"),
              onPressed: () {
                int? runningDistance = int.tryParse(runningController.text);
                if (runningDistance != null) {
                  setState(
                    () {
                      // update running
                      tokenManager.runningMapDatasets[_focusedDay] =
                          runningDistance;
                    },
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text("Invalid input datetime or running distance!"),
                    ),
                  );
                }
                runningController.text = "0";
              },
            ),
          )
        ],
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
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(
                  const Color.fromRGBO(218, 65, 64, 1.0)),
            ),
            child: const Text("COMMIT READING"),
            onPressed: () {
              String paperTitle = readingController.text;
              if (paperTitle != "") {
                // update reading list
                setState(
                  () {
                    if (tokenManager.readingMapDatasets[_focusedDay] == null) {
                      tokenManager.readingMapDatasets[_focusedDay] = [
                        paperTitle
                      ];
                    } else {
                      tokenManager.readingMapDatasets[_focusedDay]
                          ?.add(paperTitle);
                    }
                    readingController.text = "";
                  },
                );
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
  Widget ReadCard(String title, int index) {
    return Card(
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(fontSize: 18),
        ),
        trailing: Wrap(
          // spacing: -16,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                return RenameDialog(context, index);
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.delete,
                color: Colors.redAccent,
              ),
              onPressed: () {
                setState(() {
                  // remove this paper
                  tokenManager.deletePaper(_focusedDay, index);
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Widget ReadingList() {
    List<String> paperList = tokenManager.dateQeury(_focusedDay).item2;
    return (paperList.isEmpty)
        ? Container()
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            shrinkWrap: true,
            itemCount: paperList.length,
            itemBuilder: (BuildContext context, int index) {
              return ReadCard(paperList[index], index);
            },
          );
  }

  // ignore: non_constant_identifier_names
  void RenameDialog(BuildContext context, int index) {
    // Create AlertDialog
    AlertDialog dialog = AlertDialog(
      title: const Text("重命名文章"),
      content: TextField(
        controller: tempReadingController,
        style: const TextStyle(color: Colors.black87),
        decoration: const InputDecoration(
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
            )),
      ),
      actions: [
        ElevatedButton(
            child: const Text("确认"),
            onPressed: () {
              setState(() {
                if (tempReadingController.text == "") {
                  Navigator.of(context).pop(false);
                } else {
                  tokenManager.readingMapDatasets[_focusedDay]![index] =
                      tempReadingController.text;
                  tempReadingController.text = "";
                  Navigator.of(context).pop(true);
                }
              });
            }),
        ElevatedButton(
            child: const Text("退出"),
            onPressed: () {
              Navigator.of(context).pop(false);
            }),
      ],
    );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return dialog;
        });
  }

  Future<void> saveAsJson() async {
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
      print("faile to write into $dataBaseFile!");
    }
    tokenManager.parseTokens(exportTokens);
  }

  @override
  void dispose() {
    super.dispose();
    runningController.dispose();
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
        title: const Text("Calendar Dashboard"),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TableCalendar(
              firstDay: kFirstDay,
              lastDay: kLastDay,
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) {
                // Use `selectedDayPredicate` to determine which day is currently selected.
                // If this returns true, then `day` will be marked as selected.

                // Using `isSameDay` is recommended to disregard
                // the time-part of compared DateTime objects.
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                if (!isSameDay(_selectedDay, selectedDay)) {
                  // Call `setState()` when updating the selected day
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                }
              },
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  // Call `setState()` when updating calendar format
                  setState(() {
                    _calendarFormat = format;
                  });
                }
              },
              onPageChanged: (focusedDay) {
                // No need to call `setState()` here
                _focusedDay = focusedDay;
              },
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: <Widget>[
                  Text(
                    " 📅日期：${_focusedDay.year}-${_focusedDay.month.toString().padLeft(2, "0")}-${_focusedDay.day.toString().padLeft(2, "0")}",
                    textScaleFactor: 2,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8, right: 8),
                    child: ElevatedButton(
                      onPressed: saveAsJson,
                      child: const Text("SAVE"),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: <Widget>[
                  Text(
                    " 🏃‍今日跑步（公里）：${tokenManager.dateQeury(_focusedDay).item1}",
                    textAlign: TextAlign.left,
                    textScaleFactor: 1.5,
                  ),
                  RunningInputField(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    " 📰今日阅读论文：${tokenManager.dateQeury(_focusedDay).item2.length}",
                    textAlign: TextAlign.left,
                    textScaleFactor: 1.5,
                  ),
                  ReadingTextField(),
                  ReadingList(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pushNamed("/HeatMap"),
        child: const Icon(Icons.visibility),
      ),
    );
  }
}
