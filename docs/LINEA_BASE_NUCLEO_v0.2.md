# Línea base condicionada del núcleo operativo v0.2

**Fecha de congelación:** 13 de agosto de 2026  
**Estado inicial:** condicionada; pendiente de cerrar P0, E2E y
reproducibilidad.  
**Rama Neon autorizada:** `diseno-nucleo-v0-2`
(`br-divine-leaf-ay4mlu5i`).  
**Rama Neon excluida de cambios:** `production`
(`br-late-hat-aym2669f`).

## 1. Objetivo de cierre

Establecer una base técnica estable, auditable y extensible que permita
desarrollar los módulos posteriores sin rediseñar las identidades, relaciones,
movimientos, estados de Calidad ni trazabilidad del sistema.

Esta línea base no declara terminado el Alcance Detallado v2. Declara estable
el contrato común sobre el cual cada módulo podrá incorporar sus tablas,
funciones y vistas específicas en su espacio programado de ejecución.

## 2. Alcance no reducible

Los siguientes controles forman parte del núcleo y no pueden trasladarse a los
módulos posteriores:

1. Integridad de claves primarias, foráneas, unicidad y cantidades.
2. Identidad inmutable de usuarios, áreas, artículos, órdenes y lotes.
3. Inventario derivado de movimientos confirmados.
4. Protección contra inventario negativo y surtido no autorizado.
5. Estados independientes de Calidad, liberación e inventario.
6. Inmutabilidad y reversión auditable de movimientos confirmados.
7. Consumo explícito, devoluciones y asignación interna sin exigir al operador
   localizar la solicitud original.
8. Genealogía entre lotes consumidos, orden de producción y lote resultante.
9. Conversión de unidades conservando cantidad y unidad capturadas.
10. Identidad y auditoría del usuario que ejecuta y confirma cada operación.

## 2.1 Inventario congelado al inicio del bloque

Consulta de solo lectura ejecutada el 13 de agosto de 2026 en
`diseno-nucleo-v0-2`:

| Tipo de objeto | Cantidad |
|---|---:|
| Tablas | 39 |
| Vistas | 14 |
| Funciones | 30 |
| Restricciones reportadas por `information_schema` | 578 |
| Restricciones sin validar | 0 |

Inventario inicial del repositorio GitHub:

| Elemento | Estado |
|---|---|
| Rama remota | `main` |
| Archivo versionado | `neon_workflow.yml` |
| Migraciones SQL | Ninguna |
| Pruebas SQL | Ninguna |
| Documentación de reconstrucción | Ninguna |

Este inventario es la referencia de entrada del paquete del 13/08; no implica
que todos los objetos existentes estén aceptados funcionalmente.

## 3. Contratos que podrán consumir los módulos

### 3.1 Identidades compartidas

Los módulos deberán referenciar las entidades del núcleo mediante sus claves
técnicas `TEXT`; no crearán catálogos paralelos para usuarios, roles, áreas,
subáreas, unidades, artículos, ubicaciones, órdenes o lotes.

### 3.2 Inventario

Toda entrada, salida, transferencia, consumo, devolución, merma o ajuste que
afecte existencias deberá generar un movimiento confirmado mediante una
operación controlada. Ningún módulo editará saldos directamente.

### 3.3 Calidad

Los módulos podrán añadir datos de inspección propios, pero el resultado que
habilita o bloquea inventario deberá integrarse con los estados y eventos de
Calidad del núcleo. Una vista de módulo no podrá declarar elegible un lote que
el núcleo mantenga bloqueado, rechazado o en cuarentena.

### 3.4 Trazabilidad

Cada tabla transaccional específica deberá conservar referencias suficientes
para recuperar, como mínimo:

- usuario y fecha;
- área y operación;
- artículo, lote y ubicación;
- orden de producción cuando corresponda;
- movimiento de inventario generado;
- estado y reversión o cancelación asociada.

### 3.5 Vistas para AppSheet

Las vistas comunes del núcleo son contratos de consulta. Las vistas específicas
se nombrarán `vw_app_<modulo>_<proposito>` y podrán enriquecer información, pero
no contradecir los saldos, estados ni reglas del núcleo.

## 4. Extensiones permitidas por módulo

Durante la ejecución de cada MVP se podrán incorporar, entre otras, las
siguientes entidades especializadas:

- Almacén: documentos, certificados y controles logísticos específicos.
- Inyección: máquinas, moldes, parámetros y eventos de proceso.
- Procesos Secundarios: operaciones, estaciones, paros, scrap y controles WIP.
- Calidad: planes e inspecciones especializadas y resultados por proceso.

Toda extensión deberá:

1. declararse en una migración versionada;
2. reutilizar las claves del núcleo;
3. incluir restricciones e índices necesarios;
4. incluir pruebas positivas, negativas y de trazabilidad;
5. exponer a AppSheet solo tablas de captura controlada o vistas de lectura;
6. registrar cualquier cambio requerido en el contrato común antes de
   modificarlo.

## 5. Fuera del cierre del 13 de agosto

No forman parte de la aceptación de esta línea base las implementaciones
completas de máquinas, moldes, parámetros, scrap, paros, inspecciones,
certificados, turnos ni tipos de movimiento parametrizables. Se difieren a los
MVP correspondientes, sin eliminar la obligación de integrarse con el núcleo.

## 6. Definición de terminado

La línea base podrá recomendarse para aceptación condicionada únicamente cuando
se cumplan simultáneamente estos criterios:

- [ ] P0-01 cerrado: ningún lote bloqueado, rechazado o en cuarentena aparece ni
  puede validarse como apto para surtido.
- [ ] P0-02 cerrado: estado y campos de reversión de cada recepción son
  coherentes y están protegidos por una restricción.
- [ ] La OP piloto `260802` no conserva una combinación imposible de estado y
  fechas, o la excepción queda formalmente resuelta.
- [ ] Existe un caso E2E persistente: recepción, dictamen, solicitud, surtido,
  consumo, devolución o ajuste y genealogía.
- [ ] El caso Nucita demuestra 16.2 kg de HDI2061 y 1.8 kg de molienda, con 10 %
  de molienda y sin inventario negativo.
- [ ] Migraciones y pruebas SQL están versionadas.
- [ ] El núcleo se reconstruye satisfactoriamente en una rama limpia.
- [ ] Existe un informe formal con precondición, esperado, obtenido, evidencia,
  fecha y responsable por prueba.
- [ ] `production` permanece sin cambios durante la validación.

## 7. Regla de cambio posterior

Una necesidad de módulo que requiera cambiar este contrato se tratará como una
decisión de arquitectura: deberá justificar impacto, compatibilidad, migración
y pruebas de regresión. Agregar una tabla o vista específica no exige reabrir la
línea base mientras respete los contratos anteriores.
