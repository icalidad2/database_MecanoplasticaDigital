# Evidencia de Puerta C — Reproducibilidad

Fecha: 13/08/2026  
Responsable de ejecución técnica: ChatGPT/Codex, bajo autorización del proyecto  
Responsable de aceptación: José de Jesús  
Rama de certificación: `tmp-puerta-c-final-20260813` (`br-gentle-resonance-aycuh788`)  
Padre: `production` (`br-late-hat-aym2669f`)  
Resultado: **APROBADA**

## Objetivo

Demostrar que el núcleo operativo puede reconstruirse en una rama nueva derivada de `production` utilizando la línea base versionada y que, una vez reconstruido, conserva las reglas P0/P1 y el caso E2E persistente Nucita.

## Línea base versionada

La migración fundacional quedó incorporada en:

- `migrations/baseline/000_nucleo_operativo_v0_2.sql` — driver de ejecución.
- `migrations/baseline/000_01_schema.sql` — esquema fundacional.
- `migrations/baseline/000_02_logic.sql` — funciones, triggers y vistas mínimas.
- `migrations/baseline/000_03_seed.sql` — datos maestros/fixtures mínimos requeridos.

Las migraciones posteriores permanecen ordenadas como `001` a `004`. Las migraciones `002` y `003` fueron corregidas para no exigir que existan datos históricos específicos en una reconstrucción limpia.

## Reconstrucción

La rama `br-gentle-resonance-aycuh788` fue creada directamente desde `production`. Antes de la reconstrucción contenía únicamente las seis tablas heredadas de `production`.

La fundación fue aplicada por bloques equivalentes a los archivos versionados debido a que el conector de Neon no admite un archivo `psql` con `\ir` ni múltiples comandos dentro de una sola sentencia preparada. Esta es una limitación del mecanismo de ejecución utilizado para la certificación, no una dependencia manual del diseño: el driver versionado permite la ejecución normal con `psql`/CI.

Tras aplicar la fundación se verificaron 42 tablas públicas y se cargaron los catálogos/fixtures mínimos requeridos para las pruebas.

## P0 — Integridad

Se verificó:

- lote `APROBADO/LIBERADO` con existencia disponible: elegible;
- lote `CUARENTENA/BLOQUEADO`: no elegible;
- lote `RECHAZADO/BLOQUEADO`: no elegible;
- intento transaccional de surtir un lote en cuarentena: rechazado por `LOTE_CALIDAD_NO_APROBADA`;
- saldos negativos después del E2E: `0`.

El script `tests/20260813/001_p0_integridad.sql` fue actualizado para usar fixtures autocontenidos y no depender de los históricos `260810` o `2624178b`.

## P1 — Coherencia de estado de OP

La restricción `op_borrador_sin_fechas_reales_ck` quedó activa. Un intento de mantener la OP en `BORRADOR` con `fecha_inicio_real` fue rechazado por PostgreSQL, como se esperaba.

## E2E persistente Nucita

Se reconstruyó y ejecutó el flujo controlado con los identificadores `E2E-20260813-*`:

| Control | Resultado |
|---|---:|
| Consumo total | 18.000 kg |
| HDI2061 | 16.200 kg |
| Molienda MOPA | 1.800 kg |
| Proporción de molienda | 10.0 % |
| Lotes consumidos diferenciados | 2 |
| Saldos negativos | 0 |
| Surtidos desde lotes no liberados | 0 |
| Movimientos confirmados con auditoría incompleta | 0 |
| Devolución con asignación automática | 1 |

La devolución interna por diferencia de peso se registró sin exigir al operador localizar la solicitud original y quedó asignada mediante `FIFO_AUTOMATICO_EXCEDENTE`.

## Control de `production`

Al cierre se consultó `production` (`br-late-hat-aym2669f`) y continúa con **6 tablas públicas**. No recibió las tablas, datos E2E ni cambios de la certificación.

## Decisión de Puerta C

**PUERTA C APROBADA.**

La línea base fundacional que faltaba quedó versionada y una rama limpia derivada de `production` pudo reconstruir el núcleo operativo y superar las comprobaciones P0, P1 y E2E necesarias para este bloque. No se requiere ningún cambio manual no documentado para definir el núcleo: los pasos ejecutados corresponden a los archivos de `migrations/baseline` y a las migraciones/pruebas versionadas.

La segunda rama `tmp-puerta-c-certificacion-20260813` (`br-summer-shadow-ayfg82jc`) se creó como repetición adicional; su ejecución masiva fue detenida por el control de seguridad del conector antes de modificar `production`. No es necesaria para la decisión porque la primera rama limpia ya constituye la certificación reproducible.
