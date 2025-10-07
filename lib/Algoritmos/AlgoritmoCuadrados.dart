// algoritmos_widgets.dart
import 'package:flutter/material.dart';

class Algoritmo1Widget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var x0;
    var x1;
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Builder(
            builder: (context) {
              var seed0Ctrl = TextEditingController();
              var seed1Ctrl = TextEditingController();
              var iterCtrl = TextEditingController();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: seed0Ctrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                    decoration: const InputDecoration(
                      labelText: 'Semilla inicial 1',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: seed1Ctrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                    decoration: const InputDecoration(
                      labelText: 'Semilla inicial 2',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: iterCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Iteraciones',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          final s0 = double.tryParse(seed0Ctrl.text);
                          final s1 = double.tryParse(seed1Ctrl.text);
                          final it = int.tryParse(iterCtrl.text);

                          if (s0 == null || s1 == null || it == null || it <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Ingrese valores válidos')),
                            );
                            return;
                          }

                          x0 = s0;
                          x1 = s1;

                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Datos confirmados'),
                              content: Text('x0: $s0\nx1: $s1\nIteraciones: $it'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        },
                        child: const Text('Confirmar'),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          
        ),
         // Aquí se usa el widget importado
      ],
    );
  }
}

class Algoritmo2Widget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text('Vista para Algoritmo 2');
  }
}

class Algoritmo3Widget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text('Vista para Algoritmo 3');
  }
}

class Algoritmo4Widget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text('Vista para Algoritmo 4');
  }
}
