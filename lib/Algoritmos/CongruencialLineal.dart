import 'package:flutter/material.dart';

class CongruencialLinealWidget extends StatefulWidget {
  @override
  _CongruencialLinealWidgetState createState() =>
      _CongruencialLinealWidgetState();
}

class _CongruencialLinealWidgetState extends State<CongruencialLinealWidget> {
  final _seedCtrl = TextEditingController();
  final _aCtrl = TextEditingController();
  final _cCtrl = TextEditingController();
  final _mCtrl = TextEditingController();
  final _iterCtrl = TextEditingController();

  List<Map<String, dynamic>> _results = [];

  void _generateNumbers() {
    final seed = int.tryParse(_seedCtrl.text);
    final a = int.tryParse(_aCtrl.text);
    final c = int.tryParse(_cCtrl.text);
    final m = int.tryParse(_mCtrl.text);
    final iterations = int.tryParse(_iterCtrl.text);

    if (seed == null ||
        a == null ||
        c == null ||
        m == null ||
        iterations == null ||
        iterations <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingrese valores válidos.')),
      );
      return;
    }

    setState(() {
      _results.clear();
      int x = seed;

      for (int i = 0; i < iterations; i++) {
        final nextX = (a * x + c) % m;
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
            labelText: 'Constante Multiplicativa (a)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _cCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Constante Aditiva (c)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _mCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Módulo (m)',
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