import "package:flutter/material.dart";
import "heatmap.dart";
import "dashboard.dart";

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
      routes: {
        "/": (context) => const CalendarDashboard(),
        "/HeatMap": (context) => const MyHeatMap(),
      },
    );
  }
}
