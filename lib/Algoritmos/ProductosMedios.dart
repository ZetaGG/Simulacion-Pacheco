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

  bool _isDigitsOnly(String s) => RegExp(r'^\d+$').hasMatch(s);

  void _generateNumbers() {
    final seed0Text = _seed0Ctrl.text.trim();
    final seed1Text = _seed1Ctrl.text.trim();
    final iterText = _iterCtrl.text.trim();

    final iterations = int.tryParse(iterText);

    if (seed0Text.isEmpty ||
        seed1Text.isEmpty ||
        !_isDigitsOnly(seed0Text) ||
        !_isDigitsOnly(seed1Text) ||
        iterations == null ||
        iterations <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingrese valores válidos (solo dígitos y iteraciones > 0).')),
      );
      return;
    }

    if (seed0Text.length != seed1Text.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Las semillas deben tener la misma longitud.')),
      );
      return;
    }

    setState(() {
      _results.clear();
      int x0 = int.parse(seed0Text);
      int x1 = int.parse(seed1Text);
      final d = seed0Text.length;

      for (int i = 0; i < iterations; i++) {
        // Producto de las dos semillas actuales (método de productos medios)
        final y = x0 * x1;

        // Representación con exactamente 2d dígitos (rellena con ceros a la izquierda si hace falta)
        final yStr = y.toString().padLeft(d * 2, '0');

        // Punto de inicio para extraer los d dígitos centrales
        final startIndex = (yStr.length - d) ~/ 2;

        // Extrae los d dígitos centrales -> siguiente semilla
        final nextXStr = yStr.substring(startIndex, startIndex + d);
        final nextX = int.parse(nextXStr);

        // Número pseudoaleatorio rᵢ en [0, 1) usando los d dígitos extraídos
        final rStr = '0.$nextXStr';

        _results.add({
          'i': i + 1,
          'x0Str': x0.toString().padLeft(d, '0'),
          'x1Str': x1.toString().padLeft(d, '0'),
          'yStr': yStr,
          'nextX': nextXStr,
          'r': double.parse(rStr).toStringAsFixed(d),
        });

        x0 = x1;
        x1 = nextX;
      }
    });
  }

  @override
  void dispose() {
    _seed0Ctrl.dispose();
    _seed1Ctrl.dispose();
    _iterCtrl.dispose();
    super.dispose();
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
                        DataCell(Text(row['x0Str'])),
                        DataCell(Text(row['x1Str'])),
                        DataCell(Text(row['yStr'])),
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