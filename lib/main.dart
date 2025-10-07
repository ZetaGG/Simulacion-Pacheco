import 'package:flutter/material.dart';
import 'package:programas/Pantalla%20de%20inicio.dart';
import 'package:programas/Tema1.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => PantallaInicio(),
        '/Tema1':(context) => Tema1(),
      },
    );
  }
}