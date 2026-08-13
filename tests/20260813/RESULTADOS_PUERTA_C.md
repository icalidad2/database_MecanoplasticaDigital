# Evidencia de Puerta C — Reproducibilidad

Fecha: 13/08/2026  
Responsable de ejecución técnica: Codex, bajo autorización del proyecto  
Responsable de aceptación: José de Jesús  
Rama fuente: `diseno-nucleo-v0-2` (`br-divine-leaf-ay4mlu5i`)  
Rama temporal: `tmp-reconstruccion-nucleo-20260813` (`br-shy-butterfly-ay9qu3ga`)  
Padre de la rama temporal: `production` (`br-late-hat-aym2669f`)  
Resultado: **BLOQUEADA**

## Resultado esperado

Ejecutar desde GitHub las migraciones ordenadas y las pruebas P0, P1 y E2E en
una rama limpia, sin depender de cambios manuales no documentados.

## Resultado obtenido

La rama temporal heredó de `production` únicamente seis tablas maestras y una
función. La rama de diseño contiene 39 tablas, 14 vistas, 30 funciones, 24
triggers, 580 restricciones y 114 índices.

El primer objeto de la migración `001` no pudo crearse porque su dependencia
fundacional no existe:

```text
NeonDbError: relation "public.vw_inventario_actual" does not exist
```

No se aplicaron cambios parciales: la sentencia falló antes de crear la vista.
Las migraciones posteriores no se ejecutaron porque dependen de tablas y
funciones igualmente ausentes.

## Controles completados

| Control | Esperado | Obtenido | Estado |
|---|---|---|---|
| Migraciones del día ordenadas | `001` a `004` | Orden y precondiciones documentados | Aprobado |
| Pruebas SQL versionadas | P0, P1 y E2E | Tres scripts; 382 líneas | Aprobado |
| Integridad de archivos | Checksums reproducibles | `MANIFEST.sha256` creado | Aprobado |
| Diccionario de objetos | Objetos y dependencias mínimas | Creado | Aprobado |
| Procedimiento de reconstrucción/restauración | Documentado | Creado | Aprobado |
| Reconstrucción integral desde rama limpia | Sin pasos manuales | Falla por ausencia de línea base fundacional | **Bloqueado** |

## Decisión de Puerta C

Puerta C bloqueada. El ambiente de diseño funciona y las puertas A y B están
aprobadas, pero todavía no puede afirmarse que GitHub reconstruya el núcleo
completo desde `production` o desde una base vacía.

La rama temporal se conserva como evidencia del fallo hasta decidir su
eliminación. No se modificó `production`.

