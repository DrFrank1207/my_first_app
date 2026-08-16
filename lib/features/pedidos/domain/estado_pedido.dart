import 'package:mi_primer_app/core/json.dart';

/// En qué punto de su vida está un pedido.
///
/// `sealed` significa dos cosas: nadie fuera de este archivo puede añadir un
/// estado, y el compilador conoce la lista completa. Eso es lo que hace que
/// los `switch` de abajo puedan ser exhaustivos sin `default`.
sealed class EstadoPedido {
  const EstadoPedido();

  /// El ÚNICO sitio donde un texto del JSON se convierte en un tipo.
  factory EstadoPedido.fromJson(Map<String, dynamic> json) {
    final tipo = leerTexto(json, 'tipo');
    return switch (tipo) {
      'recibido' => const Recibido(),
      'preparando' => const Preparando(),
      'en_camino' => EnCamino(leerTexto(json, 'repartidor')),
      'entregado' => Entregado(
        leerFecha(json, 'entregadoEn'),
        leerTexto(json, 'recibio'),
      ),
      'cancelado' => Cancelado(leerTexto(json, 'motivo')),
      _ => throw CampoInvalido('estado.tipo', 'no es un estado conocido', tipo),
    };
  }

  /// Y el único sitio donde vuelve a ser texto. Simétrico a fromJson: si
  /// añades un estado arriba y olvidas añadirlo aquí, esto no compila.
  Map<String, dynamic> toJson() => switch (this) {
    Recibido() => {'tipo': 'recibido'},
    Preparando() => {'tipo': 'preparando'},
    EnCamino(:final repartidor) => {
      'tipo': 'en_camino',
      'repartidor': repartidor,
    },
    Entregado(:final entregadoEn, :final recibio) => {
      'tipo': 'entregado',
      'entregadoEn': entregadoEn.toIso8601String(),
      'recibio': recibio,
    },
    Cancelado(:final motivo) => {'tipo': 'cancelado', 'motivo': motivo},
  };

  /// Regla de negocio, no de interfaz: un pedido que ya salió o llegó ya no
  /// se puede cancelar.
  bool get sePuedeCancelar => switch (this) {
    Recibido() || Preparando() => true,
    EnCamino() || Entregado() || Cancelado() => false,
  };

  /// Regla de negocio, no de interfaz: solo el recién recibido se puede
  /// corregir (cambiar la dirección, quitar un extra).
  bool get sePuedeEditar => switch (this) {
    Recibido() => true,
    Preparando() || EnCamino() || Entregado() || Cancelado() => false,
  };

  /// Texto para la pantalla. En un proyecto con varios idiomas esto se va a
  /// la capa de presentación; con uno solo, aquí está bien y se prueba fácil.
  String get etiqueta => switch (this) {
    Recibido() => 'Recibido',
    Preparando() => 'Preparando',
    EnCamino(:final repartidor) => 'En camino · $repartidor',
    Entregado(:final recibio) => 'Entregado · recibió $recibio',
    Cancelado(:final motivo) => 'Cancelado: $motivo',
  };
}

final class Recibido extends EstadoPedido {
  const Recibido();

  @override
  bool operator ==(Object other) => other is Recibido;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'Recibido()';
}

final class Preparando extends EstadoPedido {
  const Preparando();

  @override
  bool operator ==(Object other) => other is Preparando;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'Preparando()';
}

final class EnCamino extends EstadoPedido {
  const EnCamino(this.repartidor);

  final String repartidor;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnCamino && other.repartidor == repartidor;

  @override
  int get hashCode => Object.hash(runtimeType, repartidor);

  @override
  String toString() => 'EnCamino($repartidor)';
}

final class Entregado extends EstadoPedido {
  const Entregado(this.entregadoEn, this.recibio);

  final DateTime entregadoEn;
  final String recibio;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Entregado &&
          other.entregadoEn == entregadoEn &&
          other.recibio == recibio;

  @override
  int get hashCode => Object.hash(runtimeType, entregadoEn, recibio);

  @override
  String toString() => 'Entregado($entregadoEn, $recibio)';
}

final class Cancelado extends EstadoPedido {
  // El assert documenta la regla y la caza en depuración. La GARANTÍA es
  // leerTexto, que rechaza la cadena vacía también en producción.
  const Cancelado(this.motivo) : assert(motivo != '', 'cancelar exige motivo');

  final String motivo; // cancelar SIN motivo no se puede ni escribir

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Cancelado && other.motivo == motivo;

  @override
  int get hashCode => Object.hash(runtimeType, motivo);

  @override
  String toString() => 'Cancelado($motivo)';
}
