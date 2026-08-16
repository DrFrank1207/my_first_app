# Pedidos a domicilio

Los clientes piden comida a domicilio y no tienen claro en qué punto va su
pedido, ni quién lo está llevando. Esta app modela esa realidad: cada pedido
avanza por estados que cargan exactamente los datos que necesitan, y los
pedidos se leen desde un JSON local que la semana 9 se podrá cambiar por una
base de datos sin tocar el modelo.

## El dominio

- `Pedido` — entidad principal. Identidad: `id` (`ped-001`…). Cambia de estado
  con el tiempo y sigue siendo el mismo pedido.
- `Monto` — objeto de valor (`cantidad` + `moneda`), regla: nunca negativo.
- `Direccion` — objeto de valor (`barrio` + `calle`) del domicilio de entrega.
- `EstadoPedido` — sellada (sealed): `Recibido` · `Preparando` ·
  `EnCamino(repartidor)` · `Entregado(entregadoEn, recibio)` ·
  `Cancelado(motivo)`. Tres de sus variantes cargan datos obligatorios: un
  pedido cancelado sin motivo no se puede ni escribir.

Reglas de negocio en la entidad: `sePuedeCancelar`, `sePuedeEditar`,
`estaDemorado(ahora)` (más de 45 minutos desde `creadoEn`). El reloj siempre
entra como parámetro; el dominio jamás llama a `DateTime.now()` y jamás importa
`package:flutter/…`.

### Decisión sobre freezed

Se escribió el modelo a mano y se generó en paralelo la versión con freezed en
una rama de experimento, corriendo las mismas pruebas en las dos. Se entrega la
versión **a mano** porque: no añade dependencias ni un paso de `build_runner` al
CI, conserva los mensajes de `CampoInvalido` que nombran el campo fallido (el
generador los pierde), y con 5 estados y 1 entidad el ahorro de líneas es menor
al costo de un flujo de generación. La igualdad y el `copyWith` escritos a mano
ya están cubiertos por las pruebas de ida y vuelta.

## Cómo correrlo

    flutter pub get
    flutter test
    flutter run

## Estructura

- `lib/core/` — ayudantes sin dueño: lectura defensiva de JSON
  (`CampoInvalido` y amigos) y comparación de listas.
- `lib/features/pedidos/domain/` — el modelo puro, sin Flutter.
- `lib/features/pedidos/data/` — de dónde salen los datos: hoy un JSON local
  en `assets/data/pedidos.json`, detrás de la interfaz `PedidosRepository`.
- `lib/features/pedidos/presentation/` — la pantalla de la semana 3.

El JSON tiene tres casos a propósito: uno completo, uno sin la clave opcional
`extras` y uno cancelado (dato obligatorio). Todas las fechas van en UTC con
`Z` al final.
