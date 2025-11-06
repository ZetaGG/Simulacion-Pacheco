import 'dart:math';
import 'package:programas/Pruebas/chi_cuadrada_table.dart';

class PruebaPoker {
  static Map<String, dynamic> calcular(List<double> numeros, int n, double confianza) {
    if (n > numeros.length) {
      return {'error': 'La cantidad de números (n) es mayor que la lista de números aleatorios.'};
    }

    List<double> sublist = numeros.sublist(0, n);
    Map<String, int> observed = {
      'TD': 0, '1P': 0, 'T': 0, '2P': 0, 'P': 0, 'F': 0, 'Q': 0
    };

    for (double num in sublist) {
      String s = (num * 100000).floor().toString().padLeft(5, '0');
      Map<String, int> counts = {};
      for (int i = 0; i < s.length; i++) {
        counts[s[i]] = (counts[s[i]] ?? 0) + 1;
      }

      if (counts.length == 5) {
        observed['TD']++;
      } else if (counts.length == 4) {
        observed['1P']++;
      } else if (counts.length == 3) {
        if (counts.values.any((c) => c == 3)) {
          observed['T']++;
        } else {
          observed['2P']++;
        }
      } else if (counts.length == 2) {
        if (counts.values.any((c) => c == 4)) {
          observed['F']++;
        } else {
          observed['P']++;
        }
      } else {
        observed['Q']++;
      }
    }

    Map<String, double> probabilities = {
      'TD': 0.3024, '1P': 0.504, 'T': 0.072, '2P': 0.108,
      'P': 0.0045, 'F': 0.009, 'Q': 0.0001
    };

    double chi0 = 0;
    List<Map<String, dynamic>> table = [];
    probabilities.forEach((key, prob) {
      double expected = prob * n;
      chi0 += pow(observed[key] - expected, 2) / expected;
      table.add({
        'Tipo': key,
        'Probabilidad': prob,
        'Oi': observed[key],
        'Ei': expected,
        'calc': pow(observed[key] - expected, 2) / expected,
      });
    });

    double alpha = 1 - (confianza / 100);
    double chi_alpha_m_1 = ChiCuadradaTable.lookup(alpha, 6);

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
}
