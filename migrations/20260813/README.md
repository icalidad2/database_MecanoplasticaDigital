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
- [ ] Inventario de definiciones afectadas capturado.
- [ ] Migraciones implementadas.
- [ ] Migraciones probadas en rama limpia.
- [ ] Evidencia enlazada con las pruebas SQL.
