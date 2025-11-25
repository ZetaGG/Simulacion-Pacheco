import 'dart:math';

class PruebaCorridas {
  static Map<String, dynamic> calcular(List<double> numeros, int n, double confianza) {
    if (n > numeros.length) {
      return {'error': 'La cantidad de números (n) es mayor que la lista de números aleatorios.'};
    }

    List<double> sublist = numeros.sublist(0, n);
    List<int> sequence = [];
    List<Map<String, dynamic>> table = [];

    table.add({'i': 1, 'r_i': sublist[0], 'secuencia': '-'});
    for (int i = 0; i < n - 1; i++) {
      int seq_val = sublist[i+1] > sublist[i] ? 1 : 0;
      sequence.add(seq_val);
      table.add({'i': i + 2, 'r_i': sublist[i+1], 'secuencia': seq_val});
    }

    // Assign a sequence value for the first element so the table shows 0/1 for all rows
    if (table.isNotEmpty) {
      table[0]['secuencia'] = sequence.isNotEmpty ? sequence[0] : 0;
    }

    int co = 1;
    for (int i = 0; i < sequence.length - 1; i++) {
      if (sequence[i+1] != sequence[i]) {
        co++;
      }
    }

    double mu_co = (2 * n - 1) / 3;
    double sigma2_co = (16 * n - 29) / 90;
    double sigma_co = sqrt(sigma2_co);
    double z0 = (co - mu_co).abs() / sigma_co;

    double alpha = 1 - (confianza / 100);
    double z_alpha_2 = _getZ(alpha);

    return {
      'H0': 'Los números ri son independientes',
      'H1': 'Los números ri no son independientes',
      'Co': co,
      'mu_co': mu_co,
      'sigma2_co': sigma2_co,
      'sigma_co': sigma_co,
      'z0': z0,
      'z_alpha_2': z_alpha_2,
      'table': table,
      'conclusion': z0 < z_alpha_2
          ? 'No se rechaza H0, ya que Z₀ < Zα/2'
          : 'Se rechaza H0, ya que Z₀ ≥ Zα/2',
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
