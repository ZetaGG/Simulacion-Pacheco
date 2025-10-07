import 'package:flutter/material.dart';
import 'package:programas/Algoritmos/BlumBlumShub.dart';
import 'package:programas/Algoritmos/CongruencialAditivo.dart';
import 'package:programas/Algoritmos/CongruencialCuadratico.dart';
import 'package:programas/Algoritmos/CongruencialLineal.dart';
import 'package:programas/Algoritmos/CongruencialMultiplicativo.dart';
import 'package:programas/Algoritmos/MultiplicadorConstante.dart';
import 'package:programas/Algoritmos/ProductosMedios.dart';

class Tema1 extends StatefulWidget {
  @override
  _Tema1State createState() => _Tema1State();
}

class _Tema1State extends State<Tema1> {
  String selectedAlgorithm = 'Productos Medios';

  Widget _getSelectedWidget() {
    switch (selectedAlgorithm) {
      case 'Productos Medios':
        return ProductosMediosWidget();
      case 'Multiplicador Constante':
        return MultiplicadorConstanteWidget();
      case 'Congruencial Lineal':
        return CongruencialLinealWidget();
      case 'Congruencial Multiplicativo':
        return CongruencialMultiplicativoWidget();
      case 'Congruencial Aditivo':
        return CongruencialAditivoWidget();
      case 'Congruencial Cuadrático':
        return CongruencialCuadraticoWidget();
      case 'Blum Blum Shub':
        return BlumBlumShubWidget();
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tema 1'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Selecciona un algoritmo:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              DropdownButton<String>(
                isExpanded: true,
                value: selectedAlgorithm,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      selectedAlgorithm = newValue;
                    });
                  }
                },
                items: <String>[
                  'Productos Medios',
                  'Multiplicador Constante',
                  'Congruencial Lineal',
                  'Congruencial Multiplicativo',
                  'Congruencial Aditivo',
                  'Congruencial Cuadrático',
                  'Blum Blum Shub',
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              const SizedBox(height: 30),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _getSelectedWidget(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
