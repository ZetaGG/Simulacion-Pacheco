import 'dart:math';

class PruebaMedias {
  static Map<String, dynamic> calcular(List<double> numeros, int n, double confianza) {
    if (n > numeros.length) {
      return {'error': 'La cantidad de números (n) es mayor que la lista de números aleatorios.'};
    }

    List<double> sublist = numeros.sublist(0, n);
    double sum = sublist.reduce((a, b) => a + b);
    double u = sum / n;
    double alpha = 1 - (confianza / 100);
    double z = _getZ(alpha);
    double li = 0.5 - z * (1 / sqrt(12 * n));
    double ls = 0.5 + z * (1 / sqrt(12 * n));

    List<Map<String, dynamic>> table = [];
    for (int i = 0; i < n; i++) {
      table.add({
        'i': i + 1,
        'r_i': sublist[i],
      });
    }

    return {
      'H0': 'μ = 0.5',
      'H1': 'μ ≠ 0.5',
      'U': u,
      'Z': z,
      'Li': li,
      'Ls': ls,
      'sum': sum,
      'table': table,
      'conclusion': u >= li && u <= ls
          ? 'No se rechaza H0, ya que U está dentro del intervalo [$li, $ls]'
          : 'Se rechaza H0, ya que U no está dentro del intervalo [$li, $ls]',
    };
  }

  static double _getZ(double alpha) {
    if (alpha <= 0.01) return 2.58;
    if (alpha <= 0.02) return 2.33;
    if (alpha <= 0.05) return 1.96;
    if (alpha <= 0.1) return 1.645;
    return 1.96; // Default for 95%
  }
}
