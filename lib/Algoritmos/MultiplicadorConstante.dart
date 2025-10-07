import 'package:flutter/material.dart';

class MultiplicadorConstanteWidget extends StatefulWidget {
  @override
  _MultiplicadorConstanteWidgetState createState() =>
      _MultiplicadorConstanteWidgetState();
}

class _MultiplicadorConstanteWidgetState
    extends State<MultiplicadorConstanteWidget> {
  final _seedCtrl = TextEditingController();
  final _constantCtrl = TextEditingController();
  final _iterCtrl = TextEditingController();

  List<Map<String, dynamic>> _results = [];

  void _generateNumbers() {
    final seed = int.tryParse(_seedCtrl.text);
    final constant = int.tryParse(_constantCtrl.text);
    final iterations = int.tryParse(_iterCtrl.text);

    if (seed == null ||
        constant == null ||
        iterations == null ||
        iterations <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingrese valores válidos.')),
      );
      return;
    }

    if (_seedCtrl.text.length != _constantCtrl.text.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('La semilla y la constante deben tener la misma longitud.')),
      );
      return;
    }

    setState(() {
      _results.clear();
      int x = seed;
      final d = _seedCtrl.text.length;

      for (int i = 0; i < iterations; i++) {
        final y = constant * x;
        final yStr = y.toString().padLeft(d * 2, '0');
        final startIndex = (yStr.length - d) ~/ 2;
        final nextXStr = yStr.substring(startIndex, startIndex + d);
        final nextX = int.parse(nextXStr);
        final r = double.parse('0.$nextXStr');

        _results.add({
          'i': i + 1,
          'x': x,
          'y': y,
          'nextX': nextXStr,
          'r': r.toStringAsFixed(d),
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
          controller: _constantCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Constante (a)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
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
                DataColumn(label: Text('Yᵢ = a×Xᵢ')),
                DataColumn(label: Text('Xᵢ₊₁')),
                DataColumn(label: Text('rᵢ')),
              ],
              rows: _results
                  .map(
                    (row) => DataRow(
                      cells: [
                        DataCell(Text(row['i'].toString())),
                        DataCell(Text(row['x'].toString())),
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