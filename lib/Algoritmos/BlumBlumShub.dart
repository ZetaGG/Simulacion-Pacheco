import 'package:flutter/material.dart';
import 'dart:math';

class BlumBlumShubWidget extends StatefulWidget {
  @override
  _BlumBlumShubWidgetState createState() => _BlumBlumShubWidgetState();
}

class _BlumBlumShubWidgetState extends State<BlumBlumShubWidget> {
  final _pCtrl = TextEditingController();
  final _qCtrl = TextEditingController();
  final _seedCtrl = TextEditingController();
  final _iterCtrl = TextEditingController();

  List<Map<String, dynamic>> _results = [];
  String _bitSequence = '';

  void _generateNumbers() {
    final p = int.tryParse(_pCtrl.text);
    final q = int.tryParse(_qCtrl.text);
    final seed = int.tryParse(_seedCtrl.text);
    final iterations = int.tryParse(_iterCtrl.text);

    if (p == null ||
        q == null ||
        seed == null ||
        iterations == null ||
        iterations <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingrese valores válidos.')),
      );
      return;
    }

    final m = p * q;
    setState(() {
      _results.clear();
      _bitSequence = '';
      BigInt x = BigInt.from(seed);
      final M = BigInt.from(m);

      for (int i = 0; i < iterations; i++) {
        final nextX = (x * x) % M;
        final bit = nextX % BigInt.two;

        _results.add({
          'i': i + 1,
          'x': x.toString(),
          'nextX': nextX.toString(),
          'bit': bit.toString(),
        });

        _bitSequence += bit.toString();
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
          controller: _pCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Primo (p)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _qCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Primo (q)',
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
            labelText: 'Número de Bits a Generar',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: _generateNumbers,
          child: const Text('Generar'),
        ),
        const SizedBox(height: 20),
        if (_results.isNotEmpty) ...[
          Text(
            'Secuencia de Bits: $_bitSequence',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('i')),
                DataColumn(label: Text('Xᵢ')),
                DataColumn(label: Text('Xᵢ₊₁')),
                DataColumn(label: Text('Bit')),
              ],
              rows: _results
                  .map(
                    (row) => DataRow(
                      cells: [
                        DataCell(Text(row['i'].toString())),
                        DataCell(Text(row['x'])),
                        DataCell(Text(row['nextX'])),
                        DataCell(Text(row['bit'])),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ),
        ]
      ],
    );
  }
}