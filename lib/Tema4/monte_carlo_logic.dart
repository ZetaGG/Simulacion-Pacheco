import 'dart:math';
import 'package:flutter/material.dart';

//region Nuevo Motor de Números Aleatorios y Pruebas Estadísticas

class AdditiveGenerator {
  final int k = 6;
  final int m = 10000;
  late List<int> _seeds;

  AdditiveGenerator() {
    _generateInitialSeeds();
  }

  void _generateInitialSeeds() {
    final random = Random();
    _seeds = List<int>.generate(k, (_) => random.nextInt(m));
  }

  void regenerateSeeds() {
    _generateInitialSeeds();
  }

  double _next() {
    final int nextValue = (_seeds.first + _seeds.last) % m;
    _seeds.removeAt(0);
    _seeds.add(nextValue);
    // Normalizar y redondear a 4 decimales
    return double.parse((nextValue / (m - 1)).toStringAsFixed(4));
  }

  List<double> generateSequence(int count) {
    return List<double>.generate(count, (_) => _next());
  }
}

class StatisticalValidator {
  static const double _zValue95 = 1.96; // Z_{alpha/2} para 95% de confianza

  static bool runAllTests(List<double> numbers) {
    return _meanTest(numbers) && _varianceTest(numbers) && _runsTest(numbers);
  }

  // 1. Prueba de Medias
  static bool _meanTest(List<double> numbers) {
    final int n = numbers.length;
    if (n == 0) return false;

    final double mean = numbers.reduce((a, b) => a + b) / n;
    final double z = (mean - 0.5) / (1 / sqrt(12 * n));

    return z.abs() < _zValue95;
  }

  // 2. Prueba de Varianza
  static bool _varianceTest(List<double> numbers) {
    final int n = numbers.length;
    if (n <= 1) return false;

    final double mean = numbers.reduce((a, b) => a + b) / n;
    final double variance = numbers.map((x) => pow(x - mean, 2)).reduce((a, b) => a + b) / (n - 1);

    // Aproximación Normal a Chi-cuadrado para n > 30
    final double df = (n - 1).toDouble();
    final double chiSquareStat = df * variance / (1 / 12);

    final double lowerBound = 0.5 * pow(-_zValue95 + sqrt(2 * df - 1), 2);
    final double upperBound = 0.5 * pow(_zValue95 + sqrt(2 * df - 1), 2);

    return chiSquareStat >= lowerBound && chiSquareStat <= upperBound;
  }

  // 3. Prueba de Corridas Arriba y Abajo
  static bool _runsTest(List<double> numbers) {
    final int n = numbers.length;
    if (n < 2) return true; // Cannot determine runs with less than 2 numbers.

    int runs = 1;
    // Start at 2 to avoid accessing index -1 on the first iteration.
    for (int i = 2; i < n; i++) {
      bool currentDirection = numbers[i] > numbers[i-1];
      bool previousDirection = numbers[i-1] > numbers[i-2];
      if (currentDirection != previousDirection) {
        runs++;
      }
    }

    final double expectedRuns = (2 * n - 1) / 3.0;
    final double varianceRuns = (16 * n - 29) / 90.0;
    final double z = (runs - expectedRuns) / sqrt(varianceRuns);

    return z.abs() < _zValue95;
  }
}

//endregion

class ProbabilityEntry {
  final int demand;
  final double probability;
  double cumulative = 0.0;
  double lowerBound = 0.0;
  double upperBound = 0.0;

  ProbabilityEntry({required this.demand, required this.probability});
}

class SimulationResult {
  final int day;
  final double random;
  final int simulatedDemand;
  final int quantity;
  final double salesRevenue;
  final double salvageRevenue;
  final double totalCost;
  final double profit;

  SimulationResult({
    required this.day,
    required this.random,
    required this.simulatedDemand,
    required this.quantity,
    required this.salesRevenue,
    required this.salvageRevenue,
    required this.totalCost,
    required this.profit,
  });
}

class MultiQResult {
  final int quantity;
  final double averageProfit;

  MultiQResult({required this.quantity, required this.averageProfit});
}

class MonteCarloProvider extends ChangeNotifier {
  // Inputs
  int _quantity = 60;
  double _unitCost = 500;
  double _sellingPrice = 1000;
  double _salvagePrice = 100;
  int _simulations = 100;
  List<ProbabilityEntry> _probabilities = [];

  // Outputs
  List<SimulationResult> _results = [];
  double _averageProfit = 0.0;
  bool _isButtonEnabled = false;
  String? _simulationError;

  // Multi-Q Analysis
  String _multiQInput = "";
  List<MultiQResult> _multiQResults = [];
  bool _isMultiQLoading = false;

  // Getters
  int get quantity => _quantity;
  double get unitCost => _unitCost;
  double get sellingPrice => _sellingPrice;
  double get salvagePrice => _salvagePrice;
  int get simulations => _simulations;
  List<ProbabilityEntry> get probabilities => _probabilities;
  List<SimulationResult> get results => _results;
  double get averageProfit => _averageProfit;
  bool get isButtonEnabled => _isButtonEnabled;
  String? get simulationError => _simulationError;

  String get multiQInput => _multiQInput;
  List<MultiQResult> get multiQResults => _multiQResults;
  bool get isMultiQLoading => _isMultiQLoading;

  void setMultiQInput(String value) {
    _multiQInput = value;
    notifyListeners();
  }

  void setQuantity(String value) {
    final number = int.tryParse(value);
    if (number != null && number > 0) {
      _quantity = number;
      notifyListeners();
    }
  }

  void setUnitCost(String value) {
    final number = double.tryParse(value);
    if (number != null && number > 0) {
      _unitCost = number;
      notifyListeners();
    }
  }

  void setSellingPrice(String value) {
    final number = double.tryParse(value);
    if (number != null && number > 0) {
      _sellingPrice = number;
      notifyListeners();
    }
  }

  void setSalvagePrice(String value) {
    final number = double.tryParse(value);
    if (number != null && number > 0) {
      _salvagePrice = number;
      notifyListeners();
    }
  }

  void setSimulations(String value) {
    final number = int.tryParse(value);
    if (number != null && number > 0) {
      _simulations = number;
      notifyListeners();
    }
  }

  void addProbability(String demand, String probability) {
    final int? dem = int.tryParse(demand);
    final double? prob = double.tryParse(probability);

    if (dem != null && prob != null) {
      _probabilities.add(ProbabilityEntry(demand: dem, probability: prob));
      _calculateCumulative();
      _validateProbabilities();
      notifyListeners();
    }
  }

  void removeProbability(int index) {
    _probabilities.removeAt(index);
    _calculateCumulative();
    _validateProbabilities();
    notifyListeners();
  }

  void _calculateCumulative() {
    double cumulative = 0.0;
    for (var entry in _probabilities) {
      entry.lowerBound = cumulative;
      cumulative += entry.probability;
      entry.upperBound = cumulative;
      entry.cumulative = cumulative;
    }
  }

  void _validateProbabilities() {
    double total = _probabilities.fold(0.0, (sum, item) => sum + item.probability);
    _isButtonEnabled = (total - 1.0).abs() < 0.001; // Use a small tolerance for floating point
    notifyListeners();
  }

  void runSimulation() {
    _results.clear();
    _simulationError = null;
    final generator = AdditiveGenerator();
    List<double> randomNumbers;
    bool isValid = false;
    int attempts = 0;

    while (!isValid && attempts < 100) {
      randomNumbers = generator.generateSequence(_simulations);
      if (StatisticalValidator.runAllTests(randomNumbers)) {
        isValid = true;
        _runSimulationWithNumbers(randomNumbers, _quantity);
      } else {
        generator.regenerateSeeds();
        attempts++;
      }
    }

    if (!isValid) {
      _simulationError = "Error: No se pudo generar una secuencia estadísticamente válida. Intente nuevamente.";
    }

    notifyListeners();
  }

  void _runSimulationWithNumbers(List<double> randomNumbers, int quantity) {
    _results.clear();
    for (int i = 0; i < randomNumbers.length; i++) {
      final randomValue = randomNumbers[i];
      int simulatedDemand = 0;
      for (var entry in _probabilities) {
        if (randomValue >= entry.lowerBound && randomValue < entry.upperBound) {
          simulatedDemand = entry.demand;
          break;
        }
      }
      final salesRevenue = min(quantity, simulatedDemand) * _sellingPrice;
      final salvageRevenue = max(0, quantity - simulatedDemand) * _salvagePrice;
      final totalCost = quantity * _unitCost;
      final profit = (salesRevenue + salvageRevenue) - totalCost;

      _results.add(SimulationResult(
          day: i + 1,
          random: randomValue,
          simulatedDemand: simulatedDemand,
          quantity: quantity,
          salesRevenue: salesRevenue,
          salvageRevenue: salvageRevenue,
          totalCost: totalCost,
          profit: profit));
    }
    _averageProfit = _calculateAverageProfit(randomNumbers, quantity);
  }

  double _calculateAverageProfit(List<double> randomNumbers, int quantity) {
    double totalProfit = 0;
    for (final randomValue in randomNumbers) {
      int simulatedDemand = 0;
      for (var entry in _probabilities) {
        if (randomValue >= entry.lowerBound && randomValue < entry.upperBound) {
          simulatedDemand = entry.demand;
          break;
        }
      }
      final sales = min(quantity, simulatedDemand) * _sellingPrice;
      final salvage = max(0, quantity - simulatedDemand) * _salvagePrice;
      final cost = quantity * _unitCost;
      totalProfit += (sales + salvage) - cost;
    }
    return totalProfit / randomNumbers.length;
  }

  Future<void> runMultiQSimulation() async {
    _isMultiQLoading = true;
    _multiQResults.clear();
    _simulationError = null;
    notifyListeners();

    final qValues = _multiQInput.split(',')
        .map((e) => int.tryParse(e.trim()))
        .where((e) => e != null && e > 0)
        .toList();

    for (final q in qValues) {
      final generator = AdditiveGenerator();
      List<double>? randomNumbers;
      bool isValid = false;
      int attempts = 0;

      while (!isValid && attempts < 100) {
        final sequence = generator.generateSequence(_simulations);
        if (StatisticalValidator.runAllTests(sequence)) {
          isValid = true;
          randomNumbers = sequence;
        } else {
          generator.regenerateSeeds();
          attempts++;
        }
      }

      if (isValid && randomNumbers != null) {
        final averageProfit = _calculateAverageProfit(randomNumbers, q!);
        _multiQResults.add(MultiQResult(
          quantity: q,
          averageProfit: averageProfit,
        ));
      } else {
        _simulationError = "La simulación para Q=$q falló. No se pudo generar una secuencia válida.";
        break;
      }
    }

    _isMultiQLoading = false;
    notifyListeners();
  }
}
