import 'package:flutter/material.dart';

class ResultDisplay extends StatelessWidget {
  final Map<String, dynamic> results;

  ResultDisplay({@required this.results});

  @override
  Widget build(BuildContext context) {
    if (results == null) {
      return Container();
    }
    if (results.containsKey('error')) {
      return Text(results['error'], style: TextStyle(color: Colors.red));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Hipótesis:', style: Theme.of(context).textTheme.headline6),
        Text('H0: ${results["H0"]}'),
        Text('H1: ${results["H1"]}'),
        SizedBox(height: 16),
        if (results.containsKey('table'))
          _buildTable(context, results['table']),
        SizedBox(height: 16),
        Text('Resultados y Estadísticos:', style: Theme.of(context).textTheme.headline6),
        ..._buildStats(context, results),
        SizedBox(height: 16),
        Text('Conclusión:', style: Theme.of(context).textTheme.headline6),
        Text(results['conclusion']),
      ],
    );
  }

  Widget _buildTable(BuildContext context, List<Map<String, dynamic>> tableData) {
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

  List<Widget> _buildStats(BuildContext context, Map<String, dynamic> stats) {
    List<Widget> statWidgets = [];
    stats.forEach((key, value) {
      if (key != 'H0' && key != 'H1' && key != 'table' && key != 'conclusion' && key != 'sequence') {
        statWidgets.add(Text('$key: $value'));
      }
    });
    return statWidgets;
  }
}
