import 'dart:math';
import 'package:programas/Pruebas/chi_cuadrada_table.dart';

class PruebaChiCuadrada {
  static Map<String, dynamic> calcular(List<double> numeros, int n, double confianza) {
    if (n > numeros.length) {
      return {'error': 'La cantidad de números (n) es mayor que la lista de números aleatorios.'};
    }

    List<double> sublist = numeros.sublist(0, n);
    int m = sqrt(n).round();
    double ei = n / m;
    double alpha = 1 - (confianza / 100);

    List<int> oi = List.filled(m, 0);
    for (double num in sublist) {
      int classIndex = (num * m).floor();
      if (classIndex >= m) classIndex = m - 1;
      oi[classIndex]++;
    }

    double chi0 = 0;
    for (int obs in oi) {
      chi0 += pow(ei - obs, 2) / ei;
    }

    double chi_alpha_m_1 = ChiCuadradaTable.lookup(alpha, m - 1);

    if (chi_alpha_m_1 == null) {
      return {'error': 'No se encontró el valor crítico de Chi-Cuadrada para los grados de libertad dados.'};
    }

    List<Map<String, dynamic>> table = [];
    for (int i = 0; i < m; i++) {
      table.add({
        'i': i + 1,
        'intervalo': '[${(i / m).toStringAsFixed(4)}, ${(i / m + 1 / m).toStringAsFixed(4)})',
        'Ei': ei,
        'Oi': oi[i],
        'calc': pow(ei - oi[i], 2) / ei,
      });
    }

    return {
      'H0': 'ri ~ U(0,1)',
      'H1': 'Los números no son uniformes',
      'm': m,
      'Ei': ei,
      'chi0': chi0,
      'chi_alpha_m_1': chi_alpha_m_1,
      'table': table,
      'conclusion': chi0 < chi_alpha_m_1
          ? 'No se rechaza H0, ya que χ₀² < χ²α,m-1'
          : 'Se rechaza H0, ya que χ₀² ≥ χ²α,m-1',
    };
  }
}
