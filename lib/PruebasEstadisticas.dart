import 'package:flutter/material.dart';
import 'package:programas/Pruebas/PruebaMedias.dart';
import 'package:programas/Pruebas/PruebaVarianzas.dart';
import 'package:programas/Pruebas/PruebaChiCuadrada.dart';
import 'package:programas/Pruebas/PruebaCorridas.dart';
import 'package:programas/Pruebas/PruebaPoker.dart';
import 'dart:math';
import 'package:programas/ResultDisplay.dart';

class PruebasEstadisticas extends StatefulWidget {
  @override
  _PruebasEstadisticasState createState() => _PruebasEstadisticasState();
}

class _PruebasEstadisticasState extends State<PruebasEstadisticas> {
  String _selectedTest;
  final TextEditingController _nController = TextEditingController();
  final TextEditingController _confidenceController = TextEditingController();
  Map<String, dynamic> _results;

  // Generate random numbers for testing
  final Random _random = Random();
  List<double> _randomNumbers;

  @override
  void initState() {
    super.initState();
    _randomNumbers = List.generate(1000, (_) => _random.nextDouble());
  }

  void _calculate() {
    if (_selectedTest == null || _nController.text.isEmpty || _confidenceController.text.isEmpty) {
      return;
    }
    int n = int.parse(_nController.text);
    double confidence = double.parse(_confidenceController.text);
    Map<String, dynamic> res;

    switch (_selectedTest) {
      case 'Medias':
        res = PruebaMedias.calcular(_randomNumbers, n, confidence);
        break;
      case 'Varianzas':
        res = PruebaVarianzas.calcular(_randomNumbers, n, confidence);
        break;
      case 'Chi-Cuadrada':
        res = PruebaChiCuadrada.calcular(_randomNumbers, n, confidence);
        break;
      case 'Corridas':
        res = PruebaCorridas.calcular(_randomNumbers, n, confidence);
        break;
      case 'Poker':
        res = PruebaPoker.calcular(_randomNumbers, n, confidence);
        break;
    }

    setState(() {
      _results = res;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pruebas Estadísticas'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              hint: Text('Seleccione una prueba'),
              value: _selectedTest,
              onChanged: (String newValue) {
                setState(() {
                  _selectedTest = newValue;
                });
              },
              items: <String>['Medias', 'Varianzas', 'Chi-Cuadrada', 'Corridas', 'Poker']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            TextField(
              controller: _nController,
              decoration: InputDecoration(labelText: 'Cantidad de números (n)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _confidenceController,
              decoration: InputDecoration(labelText: 'Nivel de Confianza (ej. 95)'),
              keyboardType: TextInputType.number,
            ),
            ElevatedButton(
              onPressed: _calculate,
              child: Text('Calcular'),
            ),
            if (_results != null)
              Expanded(
                child: SingleChildScrollView(
                  child: ResultDisplay(results: _results),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
