import 'package:flutter/material.dart';

class ProductosMediosWidget extends StatefulWidget {
  @override
  _ProductosMediosWidgetState createState() => _ProductosMediosWidgetState();
}

class _ProductosMediosWidgetState extends State<ProductosMediosWidget> {
  final _seed0Ctrl = TextEditingController();
  final _seed1Ctrl = TextEditingController();
  final _iterCtrl = TextEditingController();

  List<Map<String, dynamic>> _results = [];

  void _generateNumbers() {
    final seed0 = int.tryParse(_seed0Ctrl.text);
    final seed1 = int.tryParse(_seed1Ctrl.text);
    final iterations = int.tryParse(_iterCtrl.text);

    if (seed0 == null ||
        seed1 == null ||
        iterations == null ||
        iterations <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingrese valores válidos.')),
      );
      return;
    }

    if (_seed0Ctrl.text.length != _seed1Ctrl.text.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Las semillas deben tener la misma longitud.')),
      );
      return;
    }

    setState(() {
      _results.clear();
      int x0 = seed0;
      int x1 = seed1;
      final d = _seed0Ctrl.text.length;

      for (int i = 0; i < iterations; i++) {
        final y = x0 * x1;
        final yStr = y.toString().padLeft(d * 2, '0');
        final startIndex = (yStr.length - d) ~/ 2;
        final nextXStr = yStr.substring(startIndex, startIndex + d);
        final nextX = int.parse(nextXStr);
        final r = double.parse('0.$nextXStr');

        _results.add({
          'i': i + 1,
          'x0': x0,
          'x1': x1,
          'y': y,
          'nextX': nextXStr,
          'r': r.toStringAsFixed(d),
        });

        x0 = x1;
        x1 = nextX;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _seed0Ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Semilla 1 (X₀)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _seed1Ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Semilla 2 (X₁)',
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
                DataColumn(label: Text('X₀')),
                DataColumn(label: Text('X₁')),
                DataColumn(label: Text('Yᵢ = X₀×X₁')),
                DataColumn(label: Text('Xᵢ₊₁')),
                DataColumn(label: Text('rᵢ')),
              ],
              rows: _results
                  .map(
                    (row) => DataRow(
                      cells: [
                        DataCell(Text(row['i'].toString())),
                        DataCell(Text(row['x0'].toString())),
                        DataCell(Text(row['x1'].toString())),
                        DataCell(Text(row['y'].toString())),
                        DataCell(Text(row['nextX'])),
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