import 'package:mi_primer_app/core/json.dart';

/// Dónde se entrega el pedido.
///
/// Es un **objeto de valor**: dos direcciones con el mismo barrio y la misma
/// calle son la misma dirección, así que no lleva `id` y se compara por
/// contenido.
class Direccion {
  const Direccion({required this.barrio, required this.calle})
    : assert(calle != '', 'una entrega sin calle no se puede ubicar');

  factory Direccion.fromJson(Map<String, dynamic> json) => Direccion(
    barrio: leerTexto(json, 'barrio'),
    calle: leerTexto(json, 'calle'),
  );

  final String barrio;
  final String calle;

  Map<String, dynamic> toJson() => {'barrio': barrio, 'calle': calle};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Direccion && other.barrio == barrio && other.calle == calle;

  @override
  int get hashCode => Object.hash(barrio, calle);

  @override
  String toString() => 'Direccion($barrio, $calle)';
}
