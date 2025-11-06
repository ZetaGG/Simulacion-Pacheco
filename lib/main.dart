import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:programas/Pantalla%20de%20inicio.dart';
import 'package:programas/PruebasEstadisticas.dart';
import 'package:programas/Tema1.dart';
import 'package:programas/cyber_theme.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: CyberTheme.lightTheme,
      darkTheme: CyberTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: '/',
      routes: {
        '/': (context) => PantallaInicio(),
        '/Tema1': (context) => Tema1(),
        '/PruebasEstadisticas': (context) => PruebasEstadisticas(),
      },
    );
  }
}