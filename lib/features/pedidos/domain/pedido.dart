import 'package:mi_primer_app/core/comparaciones.dart';
import 'package:mi_primer_app/core/json.dart';
import 'package:mi_primer_app/features/pedidos/domain/direccion.dart';
import 'package:mi_primer_app/features/pedidos/domain/estado_pedido.dart';
import 'package:mi_primer_app/features/pedidos/domain/monto.dart';

/// Una orden de comida a domicilio.
///
/// Es una **entidad**: tiene identidad propia. Dos pedidos con el mismo
/// contenido son dos pedidos distintos si tienen `id` distinto.
class Pedido {
  const Pedido({
    required this.id,
    required this.cliente,
    required this.direccion,
    required this.monto,
    required this.creadoEn,
    required this.estado,
    this.extras = const <String>[],
  });

  factory Pedido.fromJson(Map<String, dynamic> json) => Pedido(
    id: leerTexto(json, 'id'),
    cliente: leerTexto(json, 'cliente'),
    direccion: Direccion.fromJson(leerMapa(json, 'direccion')),
    monto: Monto.fromJson(leerMapa(json, 'monto')),
    creadoEn: leerFecha(json, 'creadoEn'),
    estado: EstadoPedido.fromJson(leerMapa(json, 'estado')),
    extras: leerTextos(json, 'extras'),
  );

  final String id;
  final String cliente;
  final Direccion direccion;
  final Monto monto;
  final DateTime creadoEn;
  final EstadoPedido estado;
  final List<String> extras;

  Map<String, dynamic> toJson() => {
    'id': id,
    'cliente': cliente,
    'direccion': direccion.toJson(),
    'monto': monto.toJson(),
    'creadoEn': creadoEn.toUtc().toIso8601String(),
    'estado': estado.toJson(),
    'extras': extras,
  };

  // ── Reglas de negocio ───────────────────────────────────────────────────
  // Viven aquí, no en el widget. Un widget no se puede probar en 3 ms.

  bool get tieneExtras => extras.isNotEmpty;

  bool get sePuedeCancelar => estado.sePuedeCancelar;

  bool get sePuedeEditar => estado.sePuedeEditar;

  /// El reloj entra como parámetro, no se lee dentro.
  ///
  /// Con `DateTime.now()` dentro, esta regla no se puede probar: el resultado
  /// depende del día en que se corra la prueba.
  Duration antiguedad(DateTime ahora) => ahora.difference(creadoEn);

  /// Más de 45 minutos desde que se recibió el pedido.
  bool estaDemorado(DateTime ahora) =>
      antiguedad(ahora) > const Duration(minutes: 45);

  // ── Copia ───────────────────────────────────────────────────────────────

  Pedido copyWith({
    String? cliente,
    Direccion? direccion,
    Monto? monto,
    EstadoPedido? estado,
    List<String>? extras,
  }) => Pedido(
    id: id, // la identidad NO se copia con cambios
    cliente: cliente ?? this.cliente,
    direccion: direccion ?? this.direccion,
    monto: monto ?? this.monto,
    creadoEn: creadoEn, // ni la fecha de creación
    estado: estado ?? this.estado,
    extras: extras ?? this.extras,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Pedido &&
          other.id == id &&
          other.cliente == cliente &&
          other.direccion == direccion &&
          other.monto == monto &&
          other.creadoEn == creadoEn &&
          other.estado == estado &&
          listasIguales(other.extras, extras);

  @override
  int get hashCode => Object.hash(
    id,
    cliente,
    direccion,
    monto,
    creadoEn,
    estado,
    Object.hashAll(extras), // NO Object.hash(extras): eso hashea
  ); // la referencia, no el contenido

  @override
  String toString() => 'Pedido($id, $cliente, ${estado.etiqueta})';
}
