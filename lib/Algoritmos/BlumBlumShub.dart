import 'package:flutter/material.dart';

class BlumBlumShubWidget extends StatefulWidget {
  @override
  State<BlumBlumShubWidget> createState() => _BlumBlumShubWidgetState();
}

class _BlumBlumShubWidgetState extends State<BlumBlumShubWidget> {
  final _x0Ctrl = TextEditingController();
  final _mCtrl = TextEditingController();
  final _nCtrl = TextEditingController();

  // Cada fila: { i, xi, xi2, ri }
  List<Map<String, Object>> _rows = [];

  void _run() {
    final X0 = BigInt.tryParse(_x0Ctrl.text.trim());
    final m = BigInt.tryParse(_mCtrl.text.trim());
    final n = int.tryParse(_nCtrl.text.trim());

    if (X0 == null || m == null || n == null || n <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingrese X0, m y n válidos (n > 0).')),
      );
      return;
    }
    if (m <= BigInt.one) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('m debe ser > 1 para que (m - 1) sea válido.')),
      );
      return;
    }

    setState(() {
      _rows.clear();
      BigInt xi = X0;
      final mMinusOne = m - BigInt.one;

      for (int i = 1; i <= n; i++) {
        final xi2 = xi * xi;         // Xi^2
        final xi1 = xi2 % m;         // (Xi^2) mod m
        // ri = xi1 / (m - 1)  -> double
        final double ri = xi1.toDouble() / mMinusOne.toDouble();

        _rows.add({
          'i': i,
          'xi': xi.toString(),
          'xi2': xi2.toString(),
          'ri': ri,
        });

        xi = xi1; // avanzar a siguiente Xi
      }
    });
  }

  @override
  void dispose() {
    _x0Ctrl.dispose();
    _mCtrl.dispose();
    _nCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _x0Ctrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Semilla inicial (X0)',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _mCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'm',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 140,
              child: TextField(
                controller: _nCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'n',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed: _run,
            child: const Text('Ejecutar'),
          ),
        ),
        const SizedBox(height: 16),
        if (_rows.isNotEmpty)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('i')),
                DataColumn(label: Text('Xi')),
                DataColumn(label: Text('Xi^2')),
                DataColumn(label: Text('ri')),
              ],
              rows: _rows
                  .map(
                    (r) => DataRow(
                      cells: [
                        DataCell(Text(r['i'].toString())),
                        DataCell(SelectableText(r['xi'] as String)),
                        DataCell(SelectableText(r['xi2'] as String)),
                        DataCell(Text((r['ri'] as double).toStringAsFixed(4))),
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