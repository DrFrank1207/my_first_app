import 'package:mi_primer_app/features/pedidos/domain/estado_pedido.dart';
import 'package:mi_primer_app/features/pedidos/domain/pedido.dart';

/// Lo que la aplicación necesita saber de los pedidos.
///
/// `abstract interface class` = solo contrato: nadie puede heredar de aquí,
/// solo implementarlo. Es la declaración de intenciones más explícita que hay.
abstract interface class PedidosRepository {
  Future<List<Pedido>> obtenerTodos();

  Future<Pedido?> obtenerPorId(String id);

  /// Los que aún están en marcha: recibidos, preparándose o en camino.
  Future<List<Pedido>> obtenerPendientes();
}

/// Un pedido sigue pendiente mientras su estado no sea terminal.
bool estaPendiente(Pedido pedido) =>
    pedido.estado is! Entregado && pedido.estado is! Cancelado;
