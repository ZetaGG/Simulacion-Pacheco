import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';
import 'monte_carlo_logic.dart';

class MonteCarloScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MonteCarloProvider(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Tema 4: Simulación de Montecarlo'),
        ),
        body: MonteCarloView(),
      ),
    );
  }
}

class MonteCarloView extends StatefulWidget {
  @override
  _MonteCarloViewState createState() => _MonteCarloViewState();
}

class _MonteCarloViewState extends State<MonteCarloView> {
  final TextEditingController _demandController = TextEditingController();
  final TextEditingController _probController = TextEditingController();

  late final TextEditingController _quantityController;
  late final TextEditingController _unitCostController;
  late final TextEditingController _sellingPriceController;
  late final TextEditingController _salvagePriceController;
  late final TextEditingController _simulationsController;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<MonteCarloProvider>(context, listen: false);
    _quantityController = TextEditingController(text: provider.quantity.toString());
    _unitCostController = TextEditingController(text: provider.unitCost.toString());
    _sellingPriceController = TextEditingController(text: provider.sellingPrice.toString());
    _salvagePriceController = TextEditingController(text: provider.salvagePrice.toString());
    _simulationsController = TextEditingController(text: provider.simulations.toString());
  }

  @override
  void dispose() {
    _demandController.dispose();
    _probController.dispose();
    _quantityController.dispose();
    _unitCostController.dispose();
    _sellingPriceController.dispose();
    _salvagePriceController.dispose();
    _simulationsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MonteCarloProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildInputSection(provider),
          SizedBox(height: 20),
          _buildProbabilitySection(provider),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: provider.isButtonEnabled ? () => provider.runSimulation() : null,
            child: Text('Simular'),
          ),
          if (!provider.isButtonEnabled)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'La suma de las probabilidades debe ser 1.0',
                style: TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
          SizedBox(height: 20),
          if (provider.results.isNotEmpty) ...[
            _buildSummaryCard(provider.averageProfit),
            SizedBox(height: 20),
            _buildResultsTable(provider.results),
            SizedBox(height: 20),
            _buildChart(provider.results, provider.averageProfit),
          ]
        ],
      ),
    );
  }

  Widget _buildInputSection(MonteCarloProvider provider) {
    return Wrap(
      spacing: 16.0,
      runSpacing: 16.0,
      children: [
        _buildTextField("Q (Cantidad)", _quantityController, provider.setQuantity),
        _buildTextField("Costo Unitario", _unitCostController, provider.setUnitCost),
        _buildTextField("Precio Venta", _sellingPriceController, provider.setSellingPrice),
        _buildTextField("Precio Reventa", _salvagePriceController, provider.setSalvagePrice),
        _buildTextField("N (Simulaciones)", _simulationsController, provider.setSimulations),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, Function(String) onChanged) {
    return SizedBox(
      width: 200,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
        keyboardType: TextInputType.number,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildProbabilitySection(MonteCarloProvider provider) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: TextField(controller: _demandController, decoration: InputDecoration(labelText: 'Demanda'), keyboardType: TextInputType.number)),
            SizedBox(width: 10),
            Expanded(child: TextField(controller: _probController, decoration: InputDecoration(labelText: 'Probabilidad'), keyboardType: TextInputType.number)),
            SizedBox(width: 10),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                provider.addProbability(_demandController.text, _probController.text);
                _demandController.clear();
                _probController.clear();
              },
            ),
          ],
        ),
        SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          itemCount: provider.probabilities.length,
          itemBuilder: (context, index) {
            final entry = provider.probabilities[index];
            return ListTile(
              title: Text('Demanda: ${entry.demand}, Prob: ${entry.probability}'),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => provider.removeProbability(index),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSummaryCard(double averageProfit) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Utilidad Promedio', style: Theme.of(context).textTheme.headline6),
            SizedBox(height: 10),
            Text('\$${averageProfit.toStringAsFixed(2)}', style: Theme.of(context).textTheme.headline4),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsTable(List<SimulationResult> results) {
    final List<PlutoColumn> columns = [
      PlutoColumn(title: 'Día', field: 'day', type: PlutoColumnType.number()),
      PlutoColumn(title: 'Aleatorio', field: 'random', type: PlutoColumnType.number()),
      PlutoColumn(title: 'Demanda', field: 'demand', type: PlutoColumnType.number()),
      PlutoColumn(title: 'Q Comprada', field: 'quantity', type: PlutoColumnType.number()),
      PlutoColumn(title: 'Ing. Venta', field: 'sales', type: PlutoColumnType.number()),
      PlutoColumn(title: 'Ing. Reventa', field: 'salvage', type: PlutoColumnType.number()),
      PlutoColumn(title: 'Utilidad', field: 'profit', type: PlutoColumnType.number()),
    ];

    final List<PlutoRow> rows = results.map((res) {
      return PlutoRow(cells: {
        'day': PlutoCell(value: res.day),
        'random': PlutoCell(value: res.random),
        'demand': PlutoCell(value: res.simulatedDemand),
        'quantity': PlutoCell(value: res.quantity),
        'sales': PlutoCell(value: res.salesRevenue),
        'salvage': PlutoCell(value: res.salvageRevenue),
        'profit': PlutoCell(value: res.profit),
      });
    }).toList();

    return SizedBox(
      height: 400,
      child: PlutoGrid(
        columns: columns,
        rows: rows,
        configuration: PlutoGridConfiguration(
          style: PlutoGridStyleConfig(
            gridBorderColor: Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildChart(List<SimulationResult> results, double averageProfit) {
    final spots = results.map((res) => FlSpot(res.day.toDouble(), res.profit)).toList();

    return SizedBox(
      height: 300,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(show: true),
          borderData: FlBorderData(show: true),
          extraLinesData: ExtraLinesData(horizontalLines: [
            HorizontalLine(
              y: averageProfit,
              color: Colors.red.withOpacity(0.8),
              strokeWidth: 2,
              label: HorizontalLineLabel(
                show: true,
                labelResolver: (_) => 'Promedio: ${averageProfit.toStringAsFixed(2)}',
              ),
            ),
          ]),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: false,
              barWidth: 2,
              belowBarData: BarAreaData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}
