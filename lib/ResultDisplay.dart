import 'package:flutter/material.dart';

class ResultDisplay extends StatelessWidget {
  final Map<String, dynamic>? results;

  ResultDisplay({required this.results});

  @override
  Widget build(BuildContext context) {
    if (results == null) {
      return Container();
    }
    final r = results!;
    if (r.containsKey('error')) {
      return Text(r['error'], style: TextStyle(color: Colors.red));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (r.containsKey('sequence'))
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text('Secuencia de números usados:', style: Theme.of(context).textTheme.titleLarge),
          ),
  if (r.containsKey('sequence')) _buildSequenceTable(context, r['sequence'], r['decimals'] ?? 4),
  Text('Hipótesis:', style: Theme.of(context).textTheme.titleLarge),
  Text('H0: ${r["H0"]}'),
  Text('H1: ${r["H1"]}'),
        SizedBox(height: 16),
        if (r.containsKey('table'))
          _buildTable(context, r['table']),
        SizedBox(height: 16),
  Text('Resultados y Estadísticos:', style: Theme.of(context).textTheme.titleLarge),
  ..._buildStats(context, r),
        SizedBox(height: 16),
  Text('Conclusión:', style: Theme.of(context).textTheme.titleLarge),
        Text(r['conclusion']),
      ],
    );
  }

  Widget _buildTable(BuildContext context, List<Map<String, dynamic>>? tableData) {
    if (tableData == null || tableData.isEmpty) {
      return Container();
    }
    List<String> headers = tableData.first.keys.toList();
    return DataTable(
      columns: headers.map((h) => DataColumn(label: Text(h))).toList(),
      rows: tableData.map((row) {
        return DataRow(
          cells: headers.map((h) => DataCell(Text(row[h].toString()))).toList(),
        );
      }).toList(),
    );
  }

  Widget _buildSequenceTable(BuildContext context, List<dynamic>? sequence, int decimals) {
    if (sequence == null || sequence.isEmpty) return Container();
    // show index and value columns
    return SizedBox(
      height: 200,
      child: SingleChildScrollView(
        child: DataTable(
          columns: [
            DataColumn(label: Text('i')),
            DataColumn(label: Text('r_i')),
          ],
          rows: sequence.asMap().entries.map((e) {
            final idx = e.key + 1;
            final val = e.value as num;
            return DataRow(cells: [
              DataCell(Text('$idx')),
              DataCell(Text(val.toDouble().toStringAsFixed(decimals))),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  List<Widget> _buildStats(BuildContext context, Map<String, dynamic>? stats) {
    List<Widget> statWidgets = [];
    if (stats == null) return statWidgets;
    stats.forEach((key, value) {
      if (key != 'H0' && key != 'H1' && key != 'table' && key != 'conclusion' && key != 'sequence') {
        statWidgets.add(Text('$key: $value'));
      }
    });
    return statWidgets;
  }
}
