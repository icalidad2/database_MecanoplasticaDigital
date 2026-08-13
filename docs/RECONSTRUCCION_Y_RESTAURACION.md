# Reconstrucción y restauración del núcleo

## Alcance actual del repositorio

El paquete `migrations/20260813` reproduce los cambios incrementales del cierre
del 13/08/2026. Todavía no existe una migración fundacional que construya desde
cero todos los objetos anteriores al 13/08 ni sus datos maestros.

Por ello deben distinguirse dos escenarios:

1. **Reproducción incremental:** partir de una línea base del núcleo anterior al
   13/08 y ejecutar `001` a `004` en orden.
2. **Reconstrucción integral:** partir de `production` o de una base vacía y
   construir todo el núcleo únicamente desde GitHub. Este escenario permanece
   bloqueado hasta versionar la migración fundacional y sus datos maestros.

## Orden de ejecución

1. `001_p0_elegibilidad_lote.sql`
2. `002_p0_consistencia_reversion_recepcion.sql`
3. `003_p1_estado_fechas_op.sql`
4. `004_e2e_nucita_persistente.sql`
5. `tests/20260813/001_p0_integridad.sql`
6. `tests/20260813/002_p1_estado_fechas_op.sql`
7. `tests/20260813/003_e2e_nucita_persistente.sql`

Los scripts `002`, `003` y `004` contienen precondiciones explícitas y fallan de
forma segura si el dato objetivo no coincide o si los identificadores E2E ya
existen. `004` ejecuta el E2E en una sola transacción.

## Procedimiento de prueba en Neon

1. Crear una rama temporal desde la línea base que se desea reconstruir.
2. Confirmar por identificador que la rama no es `production`.
3. Inventariar tablas, vistas, funciones, triggers, restricciones e índices.
4. Ejecutar las migraciones en el orden anterior.
5. Ejecutar las pruebas SQL.
6. Comparar el esquema y las consultas de evidencia con la rama de diseño.
7. Conservar el resultado mientras se revisa; eliminar la rama temporal solo
   después de registrar la decisión de cierre.

## Restauración

- Ante un fallo dentro de `004`, la transacción revierte el E2E completo.
- Las correcciones de `002` y `003` no deben revertirse manualmente sin revisar
  primero la evidencia que justificó el cambio.
- Para descartar una reconstrucción fallida, eliminar la rama temporal; no
  aplicar operaciones de limpieza sobre `production`.
- Para restaurar un entorno aprobado, crear una rama desde el punto de tiempo o
  rama aprobada y verificar nuevamente las puertas A, B y C.

## Requisito para desbloquear la reconstrucción integral

Crear y validar en una rama nueva:

- `migrations/baseline/000_nucleo_operativo_v0_2.sql` con el esquema completo;
- datos maestros mínimos versionados: roles, áreas, unidades, ubicaciones,
  artículos y usuarios técnicos de prueba;
- manifest de versión y checksums;
- prueba automática que compare el inventario esperado: 39 tablas, 14 vistas,
  30 funciones, 24 triggers, 580 restricciones y 114 índices en el estado del
  13/08/2026.

