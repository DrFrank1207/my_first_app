import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:mi_primer_app/core/json.dart';
import 'package:mi_primer_app/features/pedidos/domain/pedido.dart';
import 'package:mi_primer_app/features/pedidos/domain/pedidos_repository.dart';

/// Cómo se lee un archivo de texto. Se inyecta para poder probar sin assets.
typedef LectorDeAssets = Future<String> Function(String ruta);

class PedidosLocales implements PedidosRepository {
  /// El lector entra por el constructor. En producción es `rootBundle`; en las
  /// pruebas, una función que devuelve una cadena. Esa costura de dos líneas
  /// es lo que hace que las pruebas no necesiten ni Flutter ni el bundle.
  PedidosLocales({
    LectorDeAssets? lector,
    this.ruta = 'assets/data/pedidos.json',
  }) : _lector = lector ?? rootBundle.loadString;

  final LectorDeAssets _lector;
  final String ruta;

  /// El archivo no cambia mientras la app corre: leerlo y parsearlo en cada
  /// pantalla sería tirar trabajo a la basura.
  List<Pedido>? _cache;

  @override
  Future<List<Pedido>> obtenerTodos() async {
    final guardado = _cache;
    if (guardado != null) return guardado;

    final crudo = await _lector(ruta);
    final decodificado = jsonDecode(crudo);

    if (decodificado is! List) {
      throw const CampoInvalido(
        '(raíz)',
        'el archivo debe contener una lista',
        null,
      );
    }

    return _cache = decodificado
        .map((e) => Pedido.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<Pedido?> obtenerPorId(String id) async {
    // firstWhere sin orElse lanza `Bad state: No element` cuando no encuentra.
    // Un bucle explícito devuelve null y se lee mejor que el orElse con truco.
    for (final pedido in await obtenerTodos()) {
      if (pedido.id == id) return pedido;
    }
    return null;
  }

  @override
  Future<List<Pedido>> obtenerPendientes() async =>
      (await obtenerTodos()).where(estaPendiente).toList(growable: false);
}
