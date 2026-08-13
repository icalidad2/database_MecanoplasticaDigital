# Evidencia del Bloque 3 — OP piloto 260802

Fecha: 13/08/2026  
Entorno: Neon `diseno-nucleo-v0-2` (`br-divine-leaf-ay4mlu5i`)  
Resultado: **APROBADO**

## Dictamen previo

Las fechas reales de `260802` se clasificaron como carga provisional. La OP
seguía en `BORRADOR`, ambas fechas eran iguales a su creación y no existía
actividad operativa asociada.

## Casos previstos

| Caso | Resultado esperado | Resultado obtenido |
|---|---|---|
| Corrección de `260802` | `BORRADOR`, inicio y cierre nulos | Aprobado |
| Transición `BORRADOR` → `EN_PROCESO` | Aceptada con fecha de inicio | Aprobado; cambio revertido al terminar |
| `BORRADOR` con `fecha_inicio_real` | Rechazado por restricción | Aprobado; intento rechazado |
| Revisión global | Cero OP semánticamente imposibles | Aprobado; resultado 0 |

## Evidencia final

- `260802`: estado `BORRADOR`, `fecha_inicio_real = NULL` y
  `fecha_cierre_real = NULL`.
- `op_borrador_sin_fechas_reales_ck`: creada y validada.
- OP `BORRADOR` imposibles: 0.
- OP `EN_PROCESO` imposibles: 0.
- OP `CERRADA` imposibles: 0.

## Decisión

Bloque 3 aprobado. La OP piloto queda disponible para ejecutar posteriormente
la acción real **Iniciar producción**; la prueba no simuló permanentemente una
actividad que no ocurrió.
