import 'dart:math';

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
    // Normalizar dividiendo por m para obtener un rango [0.0, 1.0)
    return double.parse((nextValue / m).toStringAsFixed(4));
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
