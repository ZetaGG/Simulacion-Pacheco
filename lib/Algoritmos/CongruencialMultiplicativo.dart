import 'package:flutter/material.dart';

enum AFormula { threePlus8k, fivePlus8k }

class CongruencialMultiplicativoWidget extends StatefulWidget {
  @override
  _CongruencialMultiplicativoWidgetState createState() =>
      _CongruencialMultiplicativoWidgetState();
}

class _CongruencialMultiplicativoWidgetState
    extends State<CongruencialMultiplicativoWidget> {
  final _seedCtrl = TextEditingController();
  final _gCtrl = TextEditingController();
  final _kCtrl = TextEditingController();
  final _iterCtrl = TextEditingController();

  AFormula _formula = AFormula.threePlus8k;

  List<Map<String, dynamic>> _results = [];

  void _generateNumbers() {
    final seed = int.tryParse(_seedCtrl.text);
    final g = int.tryParse(_gCtrl.text);
    final k = int.tryParse(_kCtrl.text);
    final m = g != null ? (1 << g) : null; // m = 2^g
    final iterations = int.tryParse(_iterCtrl.text);

    if (seed == null ||
        g == null ||
        m == null ||
        k == null ||
        k < 0 ||
        iterations == null ||
        iterations <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingrese valores válidos.')),
      );
      return;
    }

    final base = _formula == AFormula.threePlus8k ? 3 : 5;
    final a = base + 8 * k;

    setState(() {
      _results.clear();
      int x = seed;

      for (int i = 0; i < iterations; i++) {
        final nextX = (a * x) % m;
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

        // Selección de fórmula para 'a'
        const Text('Constante multiplicativa (a) = base + 8k'),
        RadioListTile<AFormula>(
          title: const Text('a = 3 + 8k'),
          value: AFormula.threePlus8k,
          groupValue: _formula,
          onChanged: (val) => setState(() => _formula = val!),
          contentPadding: EdgeInsets.zero,
        ),
        RadioListTile<AFormula>(
          title: const Text('a = 5 + 8k'),
          value: AFormula.fivePlus8k,
          groupValue: _formula,
          onChanged: (val) => setState(() => _formula = val!),
          contentPadding: EdgeInsets.zero,
        ),
        TextField(
          controller: _kCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'k',
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