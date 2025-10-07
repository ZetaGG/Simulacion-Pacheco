import 'package:flutter/material.dart';
import 'package:programas/Algoritmos/AlgoritmoCuadrados.dart';

class Tema1 extends StatefulWidget {
  @override
  _Tema1State createState() => _Tema1State();
}

class _Tema1State extends State<Tema1> {
  String selectedAlgorithm = 'Algoritmo 1';

  Widget _getSelectedWidget() {
    switch (selectedAlgorithm) {
      case 'Algoritmo 1':
        return Algoritmo1Widget();
      case 'Algoritmo 2':
        return Algoritmo2Widget();
      case 'Algoritmo 3':
        return Algoritmo3Widget();
      case 'Algoritmo 4':
        return Algoritmo4Widget();
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Selecciona un algoritmo:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
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
                    'Algoritmo 1',
                    'Algoritmo 2',
                    'Algoritmo 3',
                    'Algoritmo 4',
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
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _getSelectedWidget(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
