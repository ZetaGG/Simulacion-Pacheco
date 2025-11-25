import 'dart:math';
import 'package:programas/Pruebas/chi_cuadrada_table.dart';

class PruebaPoker {
  static Map<String, dynamic> calcular(List<double> numeros, int n, double confianza, {int digits = 5}) {
    if (n > numeros.length) {
      return {'error': 'La cantidad de números (n) es mayor que la lista de números aleatorios.'};
    }

    List<double> sublist = numeros.sublist(0, n);

    final int base = 10;
    final int k = digits;
    final int scale = pow(base, k).toInt();

    Map<String, int> observed = {};
    for (double num in sublist) {
      String s = (num * scale).floor().toString().padLeft(k, '0');
      Map<String, int> counts = {};
      for (int i = 0; i < s.length; i++) {
        counts[s[i]] = (counts[s[i]] ?? 0) + 1;
      }
      List<int> mults = counts.values.toList()..sort((a, b) => b.compareTo(a));
      final key = mults.join('-');
      observed[key] = (observed[key] ?? 0) + 1;
    }

    List<List<int>> partitions = _partitions(k);
    Map<String, double> probabilities = {};
    for (var part in partitions) {
      final sig = part.join('-');
      probabilities[sig] = _patternProbability(part, base);
    }

    double chi0 = 0;
    List<Map<String, dynamic>> table = [];
    probabilities.forEach((sig, prob) {
      double expected = prob * n;
      final obs = (observed[sig] ?? 0).toDouble();
      // avoid division by zero
      final calc = expected > 0 ? pow(obs - expected, 2) / expected : 0.0;
      chi0 += calc;
      table.add({
        'Tipo': sig,
        'Probabilidad': prob,
        'Oi': obs,
        'Ei': expected,
        'calc': calc,
      });
    });

    // degrees of freedom = number of categories - 1
    int df = probabilities.length - 1;

    double alpha = 1 - (confianza / 100);
    double? chi_alpha_m_1 = ChiCuadradaTable.lookup(alpha, df);

    if (chi_alpha_m_1 == null) {
      return {'error': 'No se encontró el valor crítico de Chi-Cuadrada para los grados de libertad dados.'};
    }

    return {
      'H0': 'Los números ri son independientes',
      'H1': 'Los números ri no son independientes',
      'chi0': chi0,
      'chi_alpha_m_1': chi_alpha_m_1,
      'table': table,
      'conclusion': chi0 < chi_alpha_m_1
          ? 'No se rechaza H0, ya que χ₀² < χ²α,m-1'
          : 'Se rechaza H0, ya que χ₀² ≥ χ²α,m-1',
    };
  }

  // Generate integer partitions of n (as lists of parts in non-increasing order)
  static List<List<int>> _partitions(int n) {
    List<List<int>> result = [];
    void helper(int remaining, int maxPart, List<int> current) {
      if (remaining == 0) {
        result.add(List.from(current));
        return;
      }
      for (int part = min(maxPart, remaining); part >= 1; part--) {
        current.add(part);
        helper(remaining - part, part, current);
        current.removeLast();
      }
    }
    helper(n, n, []);
    return result;
  }

  // Compute theoretical probability for a given partition (list of multiplicities) in base 'base'
  static double _patternProbability(List<int> part, int base) {
    final int k = part.fold(0, (a, b) => a + b);
    final int r = part.length;

    // falling factorial P(base, r) = base * (base-1) * ... * (base-r+1)
    int falling = 1;
    for (int i = 0; i < r; i++) {
      falling *= (base - i);
    }

    // divide by factorials of repeated part sizes
    Map<int, int> freq = {};
    for (var v in part) {
      freq[v] = (freq[v] ?? 0) + 1;
    }
    int denomRepeats = 1;
    freq.forEach((_, count) {
      denomRepeats *= _factorial(count);
    });

    int numerator = (falling ~/ denomRepeats);

    // positional arrangements: k! / (m1! m2! ...)
    int pos = _factorial(k);
    for (var m in part) {
      pos ~/= _factorial(m);
    }

    double count = (numerator * pos).toDouble();
    double total = pow(base, k).toDouble();
    return count / total;
  }

  static int _factorial(int n) {
    int f = 1;
    for (int i = 2; i <= n; i++) f *= i;
    return f;
  }
}
