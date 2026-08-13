# Paquete de migraciones — 13/08/2026

## Objetivo

Versionar los cambios necesarios para cerrar la línea base condicionada del
núcleo operativo en la rama Neon `diseno-nucleo-v0-2`.

## Secuencia prevista

1. `001_p0_elegibilidad_lote.sql`
2. `002_p0_consistencia_reversion_recepcion.sql`
3. `003_p1_estado_fechas_op.sql`, sujeto a confirmación de la máquina de estados.

## Reglas del paquete

- No ejecutar en `production` durante esta fase.
- Cada archivo debe declarar precondiciones, impacto y validación posterior.
- Los cambios deben ser repetibles o fallar de forma explícita y segura si la
  precondición no se cumple.
- Las correcciones de datos deben separarse de las restricciones estructurales
  cuando faciliten auditoría y reversión.
- No incluir tablas especializadas de los MVP posteriores.

## Estado

- [x] Paquete abierto.
- [x] Inventario de definiciones afectadas capturado.
- [x] Migraciones P0 implementadas.
- [x] Migraciones P0 probadas en `diseno-nucleo-v0-2`.
- [x] Evidencia P0 enlazada con `tests/20260813/001_p0_integridad.sql`.
