# Máquina mínima de estados de orden de producción

Fecha de decisión: 13/08/2026  
Alcance: núcleo operativo v0.2

## Estados y fechas

| Estado | Significado | `fecha_inicio_real` | `fecha_cierre_real` |
|---|---|---:|---:|
| `BORRADOR` | OP creada, editable y aún no iniciada | Nula | Nula |
| `EN_PROCESO` | Producción iniciada | Informada | Nula |
| `CERRADA` | Producción terminada | Informada | Informada y no anterior al inicio |
| `CANCELADA` | OP detenida sin cierre productivo normal | Según si llegó a iniciar | Según la política de cancelación pendiente |

## Transiciones mínimas

1. `BORRADOR` → `EN_PROCESO`: acción **Iniciar producción**; informa
   `fecha_inicio_real` y conserva `fecha_cierre_real` nula.
2. `EN_PROCESO` → `CERRADA`: acción **Cerrar producción**; conserva el inicio e
   informa `fecha_cierre_real`.
3. `BORRADOR` → `CANCELADA` y `EN_PROCESO` → `CANCELADA`: requieren una acción
   explícita y trazable. La política detallada de cancelación queda fuera de
   P1-01 y deberá definirse antes de habilitar esas acciones en AppSheet.

No se permite regresar de `EN_PROCESO` o `CERRADA` a `BORRADOR`. La validación
incorporada en P1-01 protege desde ahora la regla crítica: una OP `BORRADOR` no
puede contener fechas reales. El control completo de todas las transiciones se
incorporará junto con las acciones definitivas de inicio, cierre y cancelación.

## Decisión sobre la OP piloto 260802

Las fechas reales eran valores provisionales, no evidencia de una transición:

- ambas coincidían exactamente con la fecha de creación/programación;
- la OP no tenía reportes, dictámenes, entregas, solicitudes, consumos,
  devoluciones ni movimientos de inventario;
- el registro de trabajo del 08/08 declaró la OP en `BORRADOR` y dejó pendiente
  la acción AppSheet **Iniciar producción**.

Por tanto, se conservaron el estado y la identidad de la OP, y se limpiaron
`fecha_inicio_real` y `fecha_cierre_real`.

