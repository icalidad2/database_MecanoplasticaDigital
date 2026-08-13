# Evidencia de Puerta B — E2E persistente Nucita

Fecha: 13/08/2026  
Entorno: Neon `diseno-nucleo-v0-2` (`br-divine-leaf-ay4mlu5i`)  
OP: `260802` / `c8091333`  
Resultado: **APROBADA**

## Datos controlados

- Prefijo persistente: `E2E-20260813-*`.
- Recepción HDI2061: 25.0 kg.
- Recepción molienda PEAD natural: 5.0 kg.
- Solicitud, surtido y consumo: 16.2 kg HDI2061 + 1.8 kg molienda.
- Ajuste interno representativo: 0.2 kg HDI2061 por diferencia de peso.

## Criterios

| Criterio | Resultado |
|---|---|
| Genealogía consultable en `vw_app_trazabilidad_op` | Aprobado: 3 eventos |
| Dos lotes consumidos distinguibles | Aprobado: HDI2061 y MOPA |
| Consumo total 18.0 kg | Aprobado: 18.000 kg |
| Proporción de molienda 10% | Aprobado: 1.800 / 18.000 = 0.100 |
| Ningún lote bloqueado surtido | Aprobado: intento con `260810` rechazado |
| Cero saldos negativos | Aprobado: resultado global 0 |
| Movimientos con auditoría completa | Aprobado: 9 de 9 movimientos |
| Devolución sin localizar manualmente la solicitud | Aprobado: asignación FIFO automática |

## Genealogía obtenida

| Evento | Lote | Artículo | Cantidad |
|---|---|---|---:|
| `CONSUMO` | `E2E-260813-HDI` | HDI2061 | 16.200 kg |
| `CONSUMO` | `E2E-260813-MOPA` | Molienda PEAD natural | 1.800 kg |
| `DEVOLUCION_INTERNA` | `E2E-260813-HDI` | HDI2061 | 0.200 kg |

## Balance final

| Lote | Ubicación | Estado | Existencia |
|---|---|---|---:|
| HDI2061 | Almacén liberado | `DISPONIBLE` | 8.800 kg |
| HDI2061 | Custodia OP | `DISPONIBLE` | 0.000 kg |
| HDI2061 | Supermercado Inyección | `DISPONIBLE` | 0.200 kg |
| Molienda | Almacén liberado | `DISPONIBLE` | 3.200 kg |
| Molienda | Custodia OP | `DISPONIBLE` | 0.000 kg |

Los saldos de cuarentena quedaron en cero después de la liberación. No existe
ningún saldo negativo en `vw_inventario_actual`.

## Decisión

Puerta B aprobada. El caso permanece consultable mediante los identificadores
`E2E-20260813-*` y la OP `c8091333`. No debe eliminarse antes de completar el
informe formal y la prueba de reconstrucción.
