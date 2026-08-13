# Informe formal de pruebas — 13/08/2026

## 1. Identificación

- Proyecto: Mecanoplástica Digital
- Fecha de ejecución: 13/08/2026
- Entorno principal de pruebas: Neon `diseno-nucleo-v0-2` (`br-divine-leaf-ay4mlu5i`)
- Base: `neondb`
- Rama estable excluida de cambios: `production` (`br-late-hat-aym2669f`)
- Responsable técnico de ejecución: ChatGPT/Codex bajo autorización del proyecto
- Responsable de aceptación: José de Jesús
- Resultado global del núcleo: **APROBADO PARA ACEPTACIÓN CONDICIONADA**

## 2. Objetivo del informe

Consolidar la evidencia de las pruebas ejecutadas el 13/08/2026 sobre la línea base del núcleo operativo y determinar si el núcleo puede cerrarse como base técnica para continuar con los MVP de Almacén, Calidad de Materias Primas, Procesos Secundarios e Inyección.

Este informe **no declara terminado el entregable completo de Base de Datos del Alcance v2**. El cierre corresponde a una línea base del núcleo común, conservando entidades específicas para implementación incremental en los módulos posteriores.

## 3. Resumen de resultados

| Bloque / Puerta | Objetivo | Resultado |
|---|---|---|
| Puerta A — P0 | Integridad de elegibilidad y coherencia de reversión | **APROBADA** |
| Bloque 3 — P1 | Coherencia de estados y fechas reales de OP | **APROBADO** |
| Puerta B — E2E | Flujo persistente Nucita y trazabilidad | **APROBADA** |
| Puerta C — Reproducibilidad | Reconstrucción del núcleo desde rama limpia | **APROBADA** |

## 4. Casos y evidencia

### 4.1 P0-01 — Elegibilidad de lote

**Resultado esperado:** solamente un lote con saldo positivo, activo, inventario disponible, Calidad aprobada y liberación autorizada puede ser surtido.

**Resultado obtenido:**
- `CUARENTENA/BLOQUEADO`: rechazado.
- `APROBADO/BLOQUEADO`: rechazado.
- `RECHAZADO/BLOQUEADO`: rechazado.
- `APROBADO/LIBERADO` con saldo disponible: aceptado.
- El lote real `260810` permaneció no apto mientras estuvo `CUARENTENA/BLOQUEADO`.

**Estatus:** APROBADO.

### 4.2 P0-02 — Coherencia de reversión

**Resultado esperado:** una recepción activa no puede conservar metadatos de reversión y una recepción revertida debe conservarlos de forma completa.

**Resultado obtenido:**
- Se corrigió la inconsistencia histórica de la recepción `2624178b` tras comprobar ausencia de reversión asociada.
- La restricción de coherencia quedó validada.
- Una reversión válida fue aceptada.
- Un segundo intento sobre la misma recepción fue rechazado.

**Estatus:** APROBADO.

### 4.3 P1 — OP piloto `260802`

**Resultado esperado:** una OP en `BORRADOR` no puede tener fechas reales y las transiciones válidas deben conservar coherencia semántica.

**Resultado obtenido:**
- Las fechas de `260802` fueron clasificadas como carga provisional y limpiadas.
- `BORRADOR → EN_PROCESO` fue aceptado en prueba.
- `BORRADOR` con `fecha_inicio_real` fue rechazado.
- Revisión global: cero OP semánticamente imposibles.

**Estatus:** APROBADO.

### 4.4 Puerta B — Caso E2E persistente Nucita

**Datos de entrada:**
- HDI2061: recepción controlada de 25.0 kg.
- Molienda PEAD natural: recepción controlada de 5.0 kg.
- Solicitud/consumo: 16.2 kg HDI2061 + 1.8 kg molienda.
- Ajuste interno: 0.2 kg HDI2061 por diferencia de peso.

**Resultado obtenido:**
- Consumo total: **18.000 kg**.
- Molienda: **1.800 kg = 10.0%**.
- Dos lotes de entrada diferenciados en genealogía.
- Cero saldos negativos.
- Ningún lote bloqueado fue surtido.
- 9/9 movimientos de evidencia con auditoría completa.
- Devolución interna resuelta mediante asignación FIFO automática, sin exigir localizar manualmente la solicitud original.

**Estatus:** APROBADO.

### 4.5 Puerta C — Reproducibilidad

**Resultado esperado:** reconstruir el núcleo en una rama nueva derivada de `production` utilizando archivos versionados, sin depender de cambios manuales no documentados.

**Resultado obtenido:**
- Se versionó la migración fundacional `migrations/baseline/000_nucleo_operativo_v0_2.sql` y sus componentes.
- Las migraciones `002` y `003` se hicieron reproducibles sin depender de registros históricos obligatorios.
- Una rama limpia derivada de `production`, inicialmente con 6 tablas heredadas, reconstruyó el núcleo.
- P0, P1 y E2E volvieron a superar sus comprobaciones en el ambiente reconstruido.
- `production` fue verificada al cierre y permaneció con sus 6 tablas públicas originales.

**Estatus:** APROBADO.

## 5. Defectos

### Defectos cerrados

| ID | Defecto | Resolución | Estado |
|---|---|---|---|
| P0-01 | Lotes no liberados podían resultar elegibles para surtido | Vista y validación transaccional alineadas con Calidad/liberación | Cerrado |
| P0-02 | Recepción activa con metadato `revertida_en` inconsistente | Corrección controlada + restricción de consistencia | Cerrado |
| P1-01 | OP `BORRADOR` con fechas reales | Dato piloto corregido + restricción de estados/fechas | Cerrado |
| REP-01 | El repositorio no reconstruía el núcleo desde `production` | Migración fundacional `000` versionada | Cerrado |
| REP-02 | Migraciones `002`/`003` dependían de datos históricos concretos | Precondiciones reproducibles | Cerrado |

### Defectos abiertos del núcleo

No quedan defectos P0/P1 conocidos que impidan utilizar esta línea base para continuar desarrollo incremental.

Los pendientes que siguen no se clasifican como defectos del núcleo cerrado, sino como **alcance diferido o validaciones posteriores del entregable completo**.

## 6. Cambio de alcance operativo del cierre

El Alcance v2 requiere que la base de datos final cubra las entidades necesarias para Admin, Almacén, Producción, Inyección, Procesos Secundarios y Calidad. Para cumplir el calendario sin degradar integridad, se adopta el siguiente criterio de cierre:

### Línea base del núcleo incluida en este cierre

Se considera cerrada la infraestructura común necesaria para:
- identidades maestras;
- órdenes de producción y lotes;
- ubicaciones y custodia;
- solicitudes y surtidos;
- movimientos e inventario derivado;
- consumos y devoluciones;
- recepción de materiales;
- estados y eventos de Calidad/liberación necesarios para elegibilidad;
- auditoría crítica;
- trazabilidad OP ↔ lotes de entrada;
- reproducibilidad mediante migraciones versionadas.

### Entidades diferidas a los MVP correspondientes

Se difieren explícitamente, sin eliminarlas del Alcance v2:

- **Máquinas** — MVP Inyección.
- **Moldes** — MVP Inyección.
- **Parámetros de proceso** — MVP Inyección.
- **Scrap detallado** — MVP Procesos Secundarios / Inyección según origen.
- **Paros** — MVP Procesos Secundarios e Inyección.
- **Inspecciones operativas completas** — MVP Calidad de Materias Primas e integraciones de Calidad de Inyección/Procesos Secundarios.
- **Certificados de calidad y referencias de archivo** — MVP Calidad de Materias Primas.
- **Turnos parametrizables** — módulos de Producción.
- **Tipos de movimiento parametrizables** — evolución del MVP Almacén; el núcleo conserva por ahora los tipos controlados requeridos por las transacciones implementadas.

La decisión no elimina requisitos. Únicamente cambia el momento de implementación: cada entidad se incorporará en el módulo que realmente la consume, reutilizando las claves e identidades del núcleo.

## 7. Riesgo residual

| Riesgo residual | Impacto | Tratamiento |
|---|---|---|
| AppSheet aún no ha ejecutado el E2E completo contra esta línea base | Medio | Validar durante MVP Almacén y posteriores integraciones |
| Concurrencia/rendimiento con al menos 10 usuarios no certificada aún | Medio | Prueba no funcional antes de aceptación formal del entregable DB/MVP |
| Security Filters, permisos y experiencia offline dependen de configuración AppSheet | Medio | Validar por módulo |
| Entidades diferidas aún no implementadas | Bajo para el núcleo / Alto para alcance final | Implementación incremental según cronograma |
| Aceptación de responsables de área todavía no emitida | Medio | Revisión y firma en entregas de cada módulo |
| La ejecución mediante conector Neon tiene limitaciones para scripts `psql` con includes | Bajo | Driver versionado utilizable por `psql`/CI; mantener evidencia del procedimiento |

## 8. Recomendación de aceptación condicionada — 14/08/2026

Se recomienda **ACEPTAR CONDICIONADAMENTE la línea base del núcleo operativo v0.2** para iniciar el desarrollo del MVP de Almacén el 17/08/2026.

La aceptación significa:
1. Congelar las reglas comunes de identidad, inventario, Calidad, auditoría y trazabilidad probadas.
2. Permitir que los módulos posteriores extiendan el esquema mediante relaciones con el núcleo.
3. Prohibir duplicar o sustituir sin ADR las entidades comunes ya congeladas.
4. Mantener `production` sin migración hasta que exista autorización específica de despliegue.
5. No confundir esta aceptación con la aceptación final del entregable completo de Base de Datos del Alcance v2.

### Condiciones posteriores

Antes de declarar terminado el entregable completo de Base de Datos deberán completarse las entidades diferidas que correspondan al alcance final, pruebas de integración AppSheet, rendimiento/concurrencia, seguridad por rol/área, operación offline seleccionada, respaldo/restauración formal y aceptación del responsable técnico.

## 9. Dictamen

**LÍNEA BASE DEL NÚCLEO OPERATIVO: APROBADA PARA ACEPTACIÓN CONDICIONADA.**

Las Puertas A, B y C y la validación P1 fueron superadas. No quedan defectos críticos conocidos de integridad en el núcleo que bloqueen el inicio del siguiente módulo. El alcance funcional diferido permanece vigente y deberá implementarse en las fases correspondientes.
