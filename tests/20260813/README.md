# Paquete de pruebas — 13/08/2026

## Cobertura obligatoria

1. P0-01: elegibilidad positiva y negativa de lotes.
2. P0-02: consistencia de recepciones activas y revertidas.
3. P1-01: coherencia entre estado y fechas de OP.
4. E2E Nucita: 16.2 kg de HDI2061 + 1.8 kg de molienda.
5. Inventario no negativo y auditoría de movimientos.
6. Genealogía completa mediante `vw_app_trazabilidad_op`.
7. Reconstrucción del núcleo en una rama limpia.

## Evidencia mínima por caso

- Identificador y objetivo.
- Precondiciones y datos controlados.
- Pasos o script ejecutado.
- Resultado esperado.
- Resultado obtenido.
- Consulta de evidencia.
- Fecha y responsable.
- Estado: aprobado, rechazado o bloqueado.

## Estado

- [x] Paquete abierto.
- [x] Script de Puerta A P0 agregado: `001_p0_integridad.sql`.
- [x] Script P1-01 agregado: `002_p1_estado_fechas_op.sql`.
- [x] Resultados P0 registrados en `RESULTADOS_PUERTA_A.md`.
- [x] Resultados del Bloque 3 registrados en `RESULTADOS_BLOQUE_3.md`.
- [ ] Evidencia persistente E2E conservada.
