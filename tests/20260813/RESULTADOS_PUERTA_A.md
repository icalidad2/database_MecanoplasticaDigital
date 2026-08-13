# Evidencia de Puerta A — Integridad P0

Fecha: 13/08/2026  
Entorno: Neon `diseno-nucleo-v0-2` (`br-divine-leaf-ay4mlu5i`)  
Base: `neondb`  
Resultado: **APROBADA**

## P0-01 — Elegibilidad de lote

| Caso | Vista | Validación transaccional | Resultado |
|---|---:|---:|---|
| Lote real `260810`, `CUARENTENA/BLOQUEADO` | No apto | Rechazado | Aprobado |
| Lote controlado `CUARENTENA/BLOQUEADO` | No apto | Rechazado | Aprobado |
| Lote controlado `RECHAZADO/BLOQUEADO` | No apto | Rechazado | Aprobado |
| Lote controlado `APROBADO/LIBERADO` con saldo disponible | Apto | Aceptado | Aprobado |

La vista y `validar_lote_apto_para_surtido()` aplican la misma conjunción:
saldo positivo, lote activo, inventario `DISPONIBLE`, Calidad `APROBADO` y
liberación `LIBERADO`.

## P0-02 — Coherencia de reversión

- Se confirmó que `2624178b` no tenía fila asociada en
  `reversiones_recepciones_materiales` antes de limpiar `revertida_en`.
- La recepción quedó `ACTIVA`, con `reversion_recepcion_id` y `revertida_en`
  nulos.
- La restricción `recepciones_materiales_reversion_consistencia_ck` fue creada
  y validada.
- Una reversión normal se aplicó correctamente dentro de la prueba.
- Un segundo intento de reversión sobre la misma recepción fue rechazado.
- La reversión de prueba se deshizo automáticamente al finalizar el caso.

## Control de residuos

La consulta final devolvió cero lotes, movimientos y reversiones con
identificadores `TEST-P0-*`. No quedaron datos de prueba persistentes.

## Decisión

Puerta A aprobada. El E2E puede iniciar cuando corresponda al siguiente bloque;
esta evidencia no autoriza ningún cambio en `production`.

