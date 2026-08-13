# Diccionario mínimo de objetos modificados — 13/08/2026

## Objetos estructurales

| Objeto | Tipo | Cambio | Dependencias principales | Validación |
|---|---|---|---|---|
| `vw_app_inventario` | Vista | `apto_para_surtido` exige saldo positivo, lote activo, inventario `DISPONIBLE`, Calidad `APROBADO` y liberación `LIBERADO` | `vw_inventario_actual`, `lotes`, `articulos`, `ubicaciones` | P0-01 |
| `validar_lote_apto_para_surtido()` | Función trigger | Aplica transaccionalmente los mismos criterios de la vista | `lotes`, `vw_inventario_actual`, `surtido_detalles` | P0-01 |
| `recepciones_materiales_reversion_consistencia_ck` | Restricción | Vincula `ACTIVA`/`REVERTIDA` con los dos campos de reversión | `recepciones_materiales` | P0-02 |
| `op_borrador_sin_fechas_reales_ck` | Restricción | Impide fechas reales en una OP `BORRADOR` | `ordenes_produccion` | P1-01 |
| `UB-PI-SM-MP` | Dato maestro | Ubicación `SUPERMERCADO` de materiales de Inyección | `ubicaciones`, área Inyección | E2E |

## Correcciones de datos

| Registro | Antes | Después | Justificación |
|---|---|---|---|
| Recepción `2624178b` | `ACTIVA` con `revertida_en` informada | `ACTIVA`; `reversion_recepcion_id` y `revertida_en` nulos | No existía reversión asociada |
| OP `c8091333` / lote `260802` | `BORRADOR` con fechas reales provisionales | Fechas limpiadas; posteriormente `EN_PROCESO` por el E2E persistente | No había actividad previa; el E2E ejecutó una transición real |

## Evidencia persistente E2E

Los registros con prefijo `E2E-20260813-*` cubren recepciones, análisis,
eventos de Calidad, movimientos, solicitud, surtido, consumo y devolución. La
genealogía se consulta por la OP `c8091333` mediante
`vw_app_trazabilidad_op`.

## Objetos consultados, no redefinidos

- `vw_inventario_actual`
- `vw_app_trazabilidad_op`
- `registrar_dictamen_calidad_material(...)`
- `registrar_evento_calidad_lote(...)`
- `registrar_devolucion_interna_diferencia_peso(...)`
- triggers de inmutabilidad y saldo de `movimientos_inventario`

