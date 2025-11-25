import 'dart:math';
import 'package:flutter/material.dart';
import 'additive_generator.dart';

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

class MultiQQResult {
  final int quantity;
  final List<double> repetitionProfits;

  MultiQResult({required this.quantity, required this.repetitionProfits});

  double get averageProfit => repetitionProfits.isEmpty ? 0.0 : repetitionProfits.reduce((a, b) => a + b) / repetitionProfits.length;
}

class MonteCarloProvider extends ChangeNotifier {
  // Inputs
  int _quantity = 60;
  double _unitCost = 500;
  double _sellingPrice = 1000;
  double _salvagePrice = 100;
  int _daysToSimulate = 30; // Changed from _simulations
  List<ProbabilityEntry> _probabilities = [];

  // Outputs
  List<SimulationResult> _results = [];
  double _averageProfit = 0.0;
  bool _isButtonEnabled = false;
  String? _simulationError;

  // Multi-Q Analysis
  String _multiQInput = "";
  int _multiQDays = 365;
  int _multiQRepetitions = 100;
  List<MultiQResult> _multiQResults = [];
  bool _isMultiQLoading = false;

  // Getters
  int get quantity => _quantity;
  double get unitCost => _unitCost;
  double get sellingPrice => _sellingPrice;
  double get salvagePrice => _salvagePrice;
  int get daysToSimulate => _daysToSimulate;
  List<ProbabilityEntry> get probabilities => _probabilities;
  List<SimulationResult> get results => _results;
  double get averageProfit => _averageProfit;
  bool get isButtonEnabled => _isButtonEnabled;
  String? get simulationError => _simulationError;

  String get multiQInput => _multiQInput;
  int get multiQDays => _multiQDays;
  int get multiQRepetitions => _multiQRepetitions;
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

  void setDaysToSimulate(String value) {
    final number = int.tryParse(value);
    if (number != null && number > 0) {
      _daysToSimulate = number;
      notifyListeners();
    }
  }

  void setMultiQDays(String value) {
    final number = int.tryParse(value);
    if (number != null && number > 0) {
      _multiQDays = number;
      notifyListeners();
    }
  }

  void setMultiQRepetitions(String value) {
    final number = int.tryParse(value);
    if (number != null && number > 0) {
      _multiQRepetitions = number;
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
      randomNumbers = generator.generateSequence(_daysToSimulate);
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
    _averageProfit = _results.fold(0.0, (sum, res) => sum + res.profit) / _results.length;
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
    _multiQResults.clear(); // Bug fix: Ensure list is cleared.
    _simulationError = null;
    notifyListeners(); // Notify listeners that loading has started and results are cleared.

    final qValues = _multiQInput.split(',').map((e) => int.tryParse(e.trim())).where((e) => e != null && e > 0).toList();
    List<MultiQResult> newResults = []; // Use a temporary list

    for (final q in qValues) {
      List<double> repetitionProfits = [];
      bool allRepetitionsSuccessful = true;

      for (int i = 0; i < _multiQRepetitions; i++) {
        final generator = AdditiveGenerator();
        List<double>? randomNumbers;
        bool isValid = false;
        int attempts = 0;

        while (!isValid && attempts < 100) {
          final sequence = generator.generateSequence(_multiQDays);
          if (StatisticalValidator.runAllTests(sequence)) {
            isValid = true;
            randomNumbers = sequence;
          } else {
            generator.regenerateSeeds();
            attempts++;
          }
        }

        if (isValid && randomNumbers != null) {
          final avgProfit = _calculateAverageProfit(randomNumbers, q!);
          repetitionProfits.add(avgProfit);
        } else {
          _simulationError = "La simulación para Q=$q (repetición ${i + 1}) falló.";
          allRepetitionsSuccessful = false;
          break;
        }
      }

      if (allRepetitionsSuccessful) {
        newResults.add(MultiQResult(
          quantity: q!,
          repetitionProfits: repetitionProfits,
        ));
      } else {
        break;
      }
    }

    _multiQResults = newResults; // Atomically update the results
    _isMultiQLoading = false;
    notifyListeners();
  }
}
