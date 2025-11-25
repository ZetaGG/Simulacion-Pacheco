import 'dart:math';
import 'package:flutter/material.dart';

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
    final random = Random();
    double totalProfit = 0.0;

    for (int i = 0; i < _simulations; i++) {
      final double randomValue = random.nextDouble();
      int simulatedDemand = 0;

      for (var entry in _probabilities) {
        if (randomValue >= entry.lowerBound && randomValue < entry.upperBound) {
          simulatedDemand = entry.demand;
          break;
        }
      }

      final double salesRevenue = min(_quantity, simulatedDemand) * _sellingPrice;
      final double salvageRevenue = max(0, _quantity - simulatedDemand) * _salvagePrice;
      final double totalCost = _quantity * _unitCost;
      final double profit = (salesRevenue + salvageRevenue) - totalCost;
      totalProfit += profit;

      _results.add(SimulationResult(
        day: i + 1,
        random: randomValue,
        simulatedDemand: simulatedDemand,
        quantity: _quantity,
        salesRevenue: salesRevenue,
        salvageRevenue: salvageRevenue,
        totalCost: totalCost,
        profit: profit,
      ));
    }

    _averageProfit = totalProfit / _simulations;
    notifyListeners();
  }
}
