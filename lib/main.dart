import "package:flutter/material.dart";
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import "heatmap.dart";
import "pages/heatmap_calendar_example.dart";
import "pages/heatmap_example.dart";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Personal Record",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text("My Heatmap"),
        ),
        body: MyHeatMap(),
      ),
    );
  }
}
