import 'package:mi_primer_app/core/json.dart';

/// Cuánto vale un pedido.
///
/// Es un **objeto de valor**: dos montos con la misma cantidad y la misma
/// moneda son el mismo monto, así que no lleva `id` y se compara por contenido.
class Monto {
  const Monto({required this.cantidad, required this.moneda})
    : assert(cantidad >= 0, 'un pedido no puede costar menos que cero');

  factory Monto.fromJson(Map<String, dynamic> json) => Monto(
    cantidad: leerDecimal(json, 'cantidad'),
    moneda: leerTexto(json, 'moneda'),
  );

  final double cantidad;
  final String moneda;

  Map<String, dynamic> toJson() => {'cantidad': cantidad, 'moneda': moneda};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Monto && other.cantidad == cantidad && other.moneda == moneda;

  @override
  int get hashCode => Object.hash(cantidad, moneda);

  @override
  String toString() => 'Monto($cantidad $moneda)';
}
