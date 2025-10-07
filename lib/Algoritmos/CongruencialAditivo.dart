import 'package:flutter/material.dart';

class CongruencialAditivoWidget extends StatefulWidget {
  @override
  _CongruencialAditivoWidgetState createState() =>
      _CongruencialAditivoWidgetState();
}

class _CongruencialAditivoWidgetState extends State<CongruencialAditivoWidget> {
  final _initialSequenceCtrl = TextEditingController();
  final _mCtrl = TextEditingController();
  final _iterCtrl = TextEditingController();

  List<Map<String, dynamic>> _results = [];

  void _generateNumbers() {
    final initialSequenceStr = _initialSequenceCtrl.text;
    final m = int.tryParse(_mCtrl.text);
    final iterations = int.tryParse(_iterCtrl.text);

    if (initialSequenceStr.isEmpty ||
        m == null ||
        iterations == null ||
        iterations <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingrese valores válidos.')),
      );
      return;
    }

    final initialSequence =
        initialSequenceStr.split(',').map((e) => int.tryParse(e.trim())).toList();

    if (initialSequence.any((e) => e == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'La secuencia inicial contiene valores no numéricos.')),
      );
      return;
    }

    setState(() {
      _results.clear();
      List<int> sequence = List<int>.from(initialSequence.whereType<int>());
      final k = sequence.length;

      for (int i = 0; i < iterations; i++) {
        final nextX = (sequence[i] + sequence[i + k - 1]) % m;
        final r = nextX / (m - 1);

        _results.add({
          'i': i + k + 1,
          'x_i_1': sequence[i + k - 1],
          'x_i_k': sequence[i],
          'sum': sequence[i] + sequence[i + k - 1],
          'nextX': nextX,
          'r': r.toStringAsFixed(4),
        });

        sequence.add(nextX);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _initialSequenceCtrl,
          decoration: const InputDecoration(
            labelText: 'Secuencia Inicial (X₁, X₂, ... , Xₖ)',
            hintText: 'e.g., 65, 89, 98',
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
            labelText: 'Número de Iteraciones (n)',
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
                DataColumn(label: Text('Xᵢ₋₁')),
                DataColumn(label: Text('Xᵢ₋ₖ')),
                DataColumn(label: Text('Suma')),
                DataColumn(label: Text('Xᵢ')),
                DataColumn(label: Text('rᵢ')),
              ],
              rows: _results
                  .map(
                    (row) => DataRow(
                      cells: [
                        DataCell(Text(row['i'].toString())),
                        DataCell(Text(row['x_i_1'].toString())),
                        DataCell(Text(row['x_i_k'].toString())),
                        DataCell(Text(row['sum'].toString())),
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