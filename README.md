# Mecanoplástica Digital — Base de datos

Repositorio de migraciones, pruebas y documentación reproducible del núcleo
operativo implementado en Neon Postgres.

## Entornos

- Producción: `production` (`br-late-hat-aym2669f`). No se modifica durante el
  cierre de la línea base.
- Desarrollo: `diseno-nucleo-v0-2` (`br-divine-leaf-ay4mlu5i`). Toda ejecución
  y validación del 13 de agosto de 2026 se realiza aquí.
- Base de datos: `neondb`.
- Proyecto Neon: `database_MecanoplasticaDigital`
  (`noisy-frog-47969124`).

## Estructura del repositorio

- `migrations/`: cambios reproducibles y ordenados del esquema.
- `tests/`: pruebas SQL y evidencias de aceptación.
- `docs/`: decisiones, contratos y documentación de la línea base.
- `neon_workflow.yml`: flujo inicial de ramas temporales de Neon.

## Regla de arquitectura

El núcleo define las identidades, relaciones y controles transversales que
comparten todos los módulos. Almacén, Inyección, Procesos Secundarios y Calidad
podrán añadir tablas y vistas específicas durante su etapa programada, pero no
deberán duplicar ni eludir los contratos del núcleo.

La línea base vigente está definida en
[`docs/LINEA_BASE_NUCLEO_v0.2.md`](docs/LINEA_BASE_NUCLEO_v0.2.md).
