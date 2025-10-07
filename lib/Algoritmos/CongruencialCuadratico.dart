import 'package:flutter/material.dart';

class CongruencialCuadraticoWidget extends StatefulWidget {
  @override
  _CongruencialCuadraticoWidgetState createState() =>
      _CongruencialCuadraticoWidgetState();
}

class _CongruencialCuadraticoWidgetState
    extends State<CongruencialCuadraticoWidget> {
  final _seedCtrl = TextEditingController();
  final _aCtrl = TextEditingController();
  final _bCtrl = TextEditingController();
  final _cCtrl = TextEditingController();
  final _gCtrl = TextEditingController();
  final _iterCtrl = TextEditingController();

  List<Map<String, dynamic>> _results = [];

  void _generateNumbers() {
    final seed = int.tryParse(_seedCtrl.text);
    final a = int.tryParse(_aCtrl.text);
    final b = int.tryParse(_bCtrl.text);
    final c = int.tryParse(_cCtrl.text);
    final g = int.tryParse(_gCtrl.text);
    final iterations = int.tryParse(_iterCtrl.text);
    final m = g != null ? (1 << g) : null; // m = 2^g

    if (seed == null ||
        a == null ||
        b == null ||
        c == null ||
        m == null ||
        iterations == null ||
        iterations <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingrese valores válidos.')),
      );
      return;
    }

    // Validación: (b - 1) mod 4 debe ser 1
    if (((b - 1) % 4) != 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El valor de b no cumple: (b - 1) mod 4 debe ser igual a 1.'),
        ),
      );
      return;
    }

    setState(() {
      _results.clear();
      int x = seed;

      for (int i = 0; i < iterations; i++) {
        final nextX = (a * x * x + b * x + c) % m;
        final r = nextX / (m - 1);

        _results.add({
          'i': i + 1,
          'x': x,
          'nextX': nextX,
          'r': r.toStringAsFixed(4),
        });

        x = nextX;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _seedCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Semilla (X₀)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _aCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Constante (a)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _bCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Constante (b)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _cCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Constante (c)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _gCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Exponente (g) para m = 2^g',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _iterCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Número de Iteraciones',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: _generateNumbers,
          child: const Text('Generar'),
        ),
        const SizedBox(height: 20),
        if (_results.isNotEmpty)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('i')),
                DataColumn(label: Text('Xᵢ')),
                DataColumn(label: Text('Xᵢ₊₁')),
                DataColumn(label: Text('rᵢ')),
              ],
              rows: _results
                  .map(
                    (row) => DataRow(
                      cells: [
                        DataCell(Text(row['i'].toString())),
                        DataCell(Text(row['x'].toString())),
                        DataCell(Text(row['nextX'].toString())),
                        DataCell(Text(row['r'])),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ),
      ],
    );
  }
}