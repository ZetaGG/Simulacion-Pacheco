import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';
import 'monte_carlo_service.dart';

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

  // Controllers for Multi-Q section
  late final TextEditingController _multiQController;
  late final TextEditingController _multiQDaysController;
  late final TextEditingController _multiQRepetitionsController;

  // Controllers for general inputs
  late final TextEditingController _quantityController;
  late final TextEditingController _unitCostController;
  late final TextEditingController _sellingPriceController;
  late final TextEditingController _salvagePriceController;
  late final TextEditingController _daysToSimulateController;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<MonteCarloProvider>(context, listen: false);

    // Initialize general input controllers
    _quantityController = TextEditingController(text: provider.quantity.toString());
    _unitCostController = TextEditingController(text: provider.unitCost.toString());
    _sellingPriceController = TextEditingController(text: provider.sellingPrice.toString());
    _salvagePriceController = TextEditingController(text: provider.salvagePrice.toString());
    _daysToSimulateController = TextEditingController(text: provider.daysToSimulate.toString());

    // Initialize Multi-Q controllers
    _multiQController = TextEditingController();
    _multiQDaysController = TextEditingController(text: provider.multiQDays.toString());
    _multiQRepetitionsController = TextEditingController(text: provider.multiQRepetitions.toString());


    // Listener for showing SnackBar on error
    provider.addListener(() {
      if (provider.simulationError != null && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.simulationError!),
              backgroundColor: Colors.red,
            ),
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _demandController.dispose();
    _probController.dispose();
    _multiQController.dispose();
    _multiQDaysController.dispose();
    _multiQRepetitionsController.dispose();
    _quantityController.dispose();
    _unitCostController.dispose();
    _sellingPriceController.dispose();
    _salvagePriceController.dispose();
    _daysToSimulateController.dispose();
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
            child: Text('Simular Días'),
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
          ],

          Divider(height: 40, thickness: 2),
          _buildMultiQSection(provider),
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
        _buildTextField("Número de Días a Simular", _daysToSimulateController, provider.setDaysToSimulate),
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
          physics: NeverScrollableScrollPhysics(),
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
            Text('Utilidad Promedio', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 10),
            Text('\$${averageProfit.toStringAsFixed(2)}', style: Theme.of(context).textTheme.headlineMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsTable(List<SimulationResult> results) {
    final List<PlutoColumn> columns = [
      PlutoColumn(title: 'Día', field: 'day', type: PlutoColumnType.number()),
      PlutoColumn(title: 'Aleatorio', field: 'random', type: PlutoColumnType.number(format: '#.####')),
      PlutoColumn(title: 'Demanda', field: 'demand', type: PlutoColumnType.number()),
      PlutoColumn(title: 'Q Comprada', field: 'quantity', type: PlutoColumnType.number()),
      PlutoColumn(title: 'Ing. Venta', field: 'sales', type: PlutoColumnType.number(format: '#,###.##')),
      PlutoColumn(title: 'Ing. Reventa', field: 'salvage', type: PlutoColumnType.number(format: '#,###.##')),
      PlutoColumn(title: 'Utilidad', field: 'profit', type: PlutoColumnType.number(format: '#,###.##')),
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

  Widget _buildMultiQSection(MonteCarloProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Análisis de Multisimulación',
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16),
        _buildTextField('Valores de Q (ej: 50, 55, 60)', _multiQController, provider.setMultiQInput),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildTextField('Días por Simulación', _multiQDaysController, provider.setMultiQDays)),
            SizedBox(width: 10),
            Expanded(child: _buildTextField('No. de Repeticiones', _multiQRepetitionsController, provider.setMultiQRepetitions)),
          ],
        ),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: provider.isButtonEnabled && !provider.isMultiQLoading
              ? () => provider.runMultiQSimulation()
              : null,
          child: provider.isMultiQLoading
              ? CircularProgressIndicator(color: Colors.white)
              : Text('Comparar Escenarios'),
        ),
        SizedBox(height: 16),
        if (provider.multiQResults.isNotEmpty)
          _buildMultiQResultsTable(provider.multiQResults, provider.multiQRepetitions),
      ],
    );
  }

  Widget _buildMultiQResultsTable(List<MultiQResult> results, int repetitions) {

    final List<PlutoColumn> columns = [];

    // 1. Add Q column (frozen)
    columns.add(PlutoColumn(
      title: 'Q',
      field: 'q',
      type: PlutoColumnType.number(),
      frozen: PlutoColumnFrozen.start,
    ));

    // 2. Add dynamic repetition columns
    for (int i = 0; i < repetitions; i++) {
      columns.add(PlutoColumn(
        title: 'Simulación ${i + 1}',
        field: 'sim_${i+1}',
        type: PlutoColumnType.number(format: '#,###.##'),
      ));
    }

    // 3. Add Average Profit column at the end
    columns.add(PlutoColumn(
      title: 'PROMEDIO TOTAL',
      field: 'average',
      type: PlutoColumnType.number(format: '#,###.##'),
    ));

    final List<PlutoRow> rows = results.map((res) {
      final Map<String, PlutoCell> cells = {};
      cells['q'] = PlutoCell(value: res.quantity);

      for (int i = 0; i < res.repetitionProfits.length; i++) {
        cells['sim_${i+1}'] = PlutoCell(value: res.repetitionProfits[i]);
      }

      cells['average'] = PlutoCell(value: res.averageProfit);

      return PlutoRow(cells: cells);
    }).toList();

    return SizedBox(
      height: 400, // Increased height to better fit data
      child: PlutoGrid(
        columns: columns,
        rows: rows,
      ),
    );
  }
}
