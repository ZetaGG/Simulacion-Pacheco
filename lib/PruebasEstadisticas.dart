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
  String? _selectedTest;
  final TextEditingController _nController = TextEditingController();
  final TextEditingController _confidenceController = TextEditingController();
  final TextEditingController _decimalsController = TextEditingController(text: '4');
  Map<String, dynamic>? _results;

  // Generate random numbers for testing
  final Random _random = Random();
  late List<double> _randomNumbers;

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
    Map<String, dynamic>? res;

    // Determine decimals (default 4) and prepare the exact sequence used for the test so we can show it later
    int decimals = 4;
    try {
      decimals = int.parse(_decimalsController.text);
      if (decimals < 0) decimals = 0;
    } catch (_) {
      decimals = 4;
    }

    // Round the sequence to the requested number of decimals
    final sequence = _randomNumbers
        .sublist(0, n)
        .map((d) => double.parse(d.toStringAsFixed(decimals)))
        .toList();

    switch (_selectedTest) {
      case 'Medias':
        res = PruebaMedias.calcular(sequence, n, confidence);
        break;
      case 'Varianzas':
        res = PruebaVarianzas.calcular(sequence, n, confidence);
        break;
      case 'Chi-Cuadrada':
        res = PruebaChiCuadrada.calcular(sequence, n, confidence);
        break;
      case 'Corridas':
        res = PruebaCorridas.calcular(sequence, n, confidence);
        break;
      case 'Poker':
        res = PruebaPoker.calcular(sequence, n, confidence, digits: decimals);
        break;
    }

    if (res == null) return;
    // Attach the sequence used and decimals so ResultDisplay can render formatted values
    res['sequence'] = sequence;
    res['decimals'] = decimals;
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
              onChanged: (String? newValue) {
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
            SizedBox(height: 8),
            TextField(
              controller: _decimalsController,
              decoration: InputDecoration(labelText: 'Decimales en números aleatorios (ej. 4)'),
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
