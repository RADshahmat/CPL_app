import 'package:flutter/material.dart';
import 'package:cpl/dashboard.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primarySwatch: Colors.indigo,
          primaryColor: Colors.indigo,
          appBarTheme: const AppBarTheme(
            
            backgroundColor: Color.fromARGB(1, 44, 62, 80),
            
          )),
      routes: {
        "/": (context) =>  PCDashBoardScreen(),
        "/home": (context) =>  PCDashBoardScreen(),
      },
    );
  }
}
