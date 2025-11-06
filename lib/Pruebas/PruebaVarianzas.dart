import 'dart:math';
import 'package:programas/Pruebas/chi_cuadrada_table.dart';

class PruebaVarianzas {
  static Map<String, dynamic> calcular(List<double> numeros, int n, double confianza) {
    if (n > numeros.length) {
      return {'error': 'La cantidad de números (n) es mayor que la lista de números aleatorios.'};
    }

    List<double> sublist = numeros.sublist(0, n);
    double sum = sublist.reduce((a, b) => a + b);
    double mean = sum / n;
    double varianceSum = sublist.map((x) => pow(x - mean, 2)).reduce((a, b) => a + b);
    double s2 = varianceSum / (n - 1);
    double alpha = 1 - (confianza / 100);

    double chi_alpha_2 = ChiCuadradaTable.lookup(alpha / 2, n - 1);
    double chi_1_alpha_2 = ChiCuadradaTable.lookup(1 - alpha / 2, n - 1);

    if (chi_alpha_2 == null || chi_1_alpha_2 == null) {
      return {'error': 'No se encontraron los valores críticos de Chi-Cuadrada para los grados de libertad dados.'};
    }

    double li = chi_1_alpha_2 / (12 * (n - 1));
    double ls = chi_alpha_2 / (12 * (n - 1));

    return {
      'H0': 'σ^2 = 1/12',
      'H1': 'σ^2 ≠ 1/12',
      'mean': mean,
      'varianceSum': varianceSum,
      's2': s2,
      'chi_alpha_2': chi_alpha_2,
      'chi_1_alpha_2': chi_1_alpha_2,
      'Li': li,
      'Ls': ls,
      'conclusion': s2 >= li && s2 <= ls
          ? 'No se rechaza H0, ya que S^2 está dentro del intervalo [$li, $ls]'
          : 'Se rechaza H0, ya que S^2 no está dentro del intervalo [$li, $ls]',
    };
  }
}
