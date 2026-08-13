-- Bloque 4 — Caso E2E persistente Nucita.
-- Destino autorizado: diseno-nucleo-v0-2.
-- Los identificadores E2E-20260813-* se conservan como evidencia consultable.

BEGIN;

DO $precondiciones$
BEGIN
  IF EXISTS (
    SELECT 1 FROM public.recepciones_materiales WHERE id LIKE 'E2E-20260813-%'
    UNION ALL SELECT 1 FROM public.solicitudes_material WHERE id LIKE 'E2E-20260813-%'
    UNION ALL SELECT 1 FROM public.surtidos WHERE id LIKE 'E2E-20260813-%'
    UNION ALL SELECT 1 FROM public.consumos WHERE id LIKE 'E2E-20260813-%'
    UNION ALL SELECT 1 FROM public.devoluciones WHERE id LIKE 'E2E-20260813-%'
    UNION ALL SELECT 1 FROM public.movimientos_inventario WHERE id LIKE 'E2E-20260813-%'
  ) THEN
    RAISE EXCEPTION 'PRECONDICION_E2E: ya existen identificadores E2E-20260813';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM public.ordenes_produccion
     WHERE id = 'c8091333' AND codigo_lote = '260802'
       AND estado_produccion = 'BORRADOR'
       AND fecha_inicio_real IS NULL AND fecha_cierre_real IS NULL
  ) THEN
    RAISE EXCEPTION 'PRECONDICION_E2E: la OP 260802 no esta lista para iniciar';
  END IF;
END;
$precondiciones$;

INSERT INTO public.ubicaciones (
  id, codigo, nombre, area_id, tipo_ubicacion, permite_existencia, activo
) VALUES (
  'UB-PI-SM-MP', 'PI-SM-MP', 'Supermercado de materiales - Inyeccion',
  '7c5d277e', 'SUPERMERCADO', true, true
)
ON CONFLICT (id) DO NOTHING;

UPDATE public.ordenes_produccion
   SET estado_produccion = 'EN_PROCESO',
       fecha_inicio_real = clock_timestamp(),
       fecha_cierre_real = NULL
 WHERE id = 'c8091333' AND estado_produccion = 'BORRADOR';

-- 1. Recepciones en cuarentena.
INSERT INTO public.recepciones_materiales (
  id, articulo_id, tipo_analisis, numero_analisis, folio_ft_al_01,
  codigo_lote, lote_proveedor, proveedor_id, area_origen_id,
  cantidad_capturada, unidad_capturada_id, ubicacion_cuarentena_id,
  fecha_recepcion, recibido_por, observaciones
) VALUES (
  'E2E-20260813-REC-HDI', 'HDI2061', 'MP_EXTERNA',
  'AC-E2E-20260813-HDI', 'FT-AL-01-E2E-20260813-HDI',
  'E2E-260813-HDI', 'PC-E2E-260813-HDI', 'PROV-PLAST-COMP', NULL,
  25.000, 'UNIDAD-KG', 'UB-AL-CUAR-MP', clock_timestamp(), '717ae505',
  'Caso E2E persistente Nucita: resina HDI2061'
), (
  'E2E-20260813-REC-MOPA', 'MOPA', 'MOLIENDA',
  'AC-E2E-20260813-MOPA', NULL,
  'E2E-260813-MOPA', NULL, NULL, '7c5d277e',
  5.000, 'UNIDAD-KG', 'UB-AL-CUAR-MO', clock_timestamp(), '717ae505',
  'Caso E2E persistente Nucita: molienda PEAD natural'
);

-- 2. Dictamen y liberacion por Calidad.
SELECT public.registrar_dictamen_calidad_material(
  'ANL-REC-E2E-20260813-REC-HDI', 'APROBADO', current_date,
  'TEST-INSPECTOR-CALIDAD', 'TEST-JEFE-CALIDAD',
  'Aprobado para caso E2E persistente Nucita'
);

SELECT public.registrar_dictamen_calidad_material(
  'ANL-REC-E2E-20260813-REC-MOPA', 'APROBADO', current_date,
  'TEST-INSPECTOR-CALIDAD', 'TEST-JEFE-CALIDAD',
  'Aprobado para caso E2E persistente Nucita'
);

SELECT public.registrar_evento_calidad_lote(
  'E2E-20260813-EVT-LIB-HDI', 'LOT-REC-E2E-20260813-REC-HDI',
  'APROBADO', 'LIBERADO', 'LIBERACION',
  'Liberacion para caso E2E persistente Nucita', 'TEST-JEFE-CALIDAD', NULL
);

SELECT public.registrar_evento_calidad_lote(
  'E2E-20260813-EVT-LIB-MOPA', 'LOT-REC-E2E-20260813-REC-MOPA',
  'APROBADO', 'LIBERADO', 'LIBERACION',
  'Liberacion para caso E2E persistente Nucita', 'TEST-JEFE-CALIDAD', NULL
);

INSERT INTO public.movimientos_inventario (
  id, tipo_movimiento, lote_id, cantidad, unidad_id,
  ubicacion_origen_id, estado_origen, ubicacion_destino_id, estado_destino,
  estado_movimiento, fecha_efectiva, confirmado_por, motivo_ajuste, creado_por
) VALUES (
  'E2E-20260813-MOV-LIB-HDI', 'LIBERACION_CALIDAD',
  'LOT-REC-E2E-20260813-REC-HDI', 25.000, 'UNIDAD-KG',
  'UB-AL-CUAR-MP', 'CUARENTENA', 'UB-AL-LIB-RES', 'DISPONIBLE',
  'CONFIRMADO', clock_timestamp(), 'TEST-JEFE-CALIDAD',
  'Liberacion de HDI2061 para E2E Nucita', 'TEST-JEFE-CALIDAD'
), (
  'E2E-20260813-MOV-LIB-MOPA', 'LIBERACION_CALIDAD',
  'LOT-REC-E2E-20260813-REC-MOPA', 5.000, 'UNIDAD-KG',
  'UB-AL-CUAR-MO', 'CUARENTENA', 'UB-AL-LIB-RES', 'DISPONIBLE',
  'CONFIRMADO', clock_timestamp(), 'TEST-JEFE-CALIDAD',
  'Liberacion de molienda para E2E Nucita', 'TEST-JEFE-CALIDAD'
);

-- 3. Solicitud para Vaso Nucita.
INSERT INTO public.solicitudes_material (
  id, folio_solicitud, orden_produccion_id, area_solicitante_id,
  estado_solicitud, solicitado_por, solicitado_en, fecha_requerida,
  observaciones
) VALUES (
  'E2E-20260813-SOL-01', 'SOL-E2E-20260813-01', 'c8091333', '7c5d277e',
  'BORRADOR', '66afb827', clock_timestamp(), clock_timestamp(),
  'Solicitud persistente E2E Vaso Nucita'
);

INSERT INTO public.solicitud_detalles (
  id, solicitud_material_id, articulo_id, cantidad_solicitada,
  cantidad_cancelada, unidad_id
) VALUES
  ('E2E-20260813-SOLD-HDI', 'E2E-20260813-SOL-01', 'HDI2061', 16.200, 0, 'UNIDAD-KG'),
  ('E2E-20260813-SOLD-MOPA', 'E2E-20260813-SOL-01', 'MOPA', 1.800, 0, 'UNIDAD-KG');

UPDATE public.solicitudes_material
   SET estado_solicitud = 'SOLICITADA'
 WHERE id = 'E2E-20260813-SOL-01';

-- 4 y 5. Surtido por lote y recepcion en custodia de la OP.
INSERT INTO public.surtidos (
  id, folio_surtido, solicitud_material_id, estado_surtido,
  preparado_por, entregado_por, recibido_por,
  preparado_en, entregado_en, recibido_en, observaciones
) VALUES (
  'E2E-20260813-SUR-01', 'SUR-E2E-20260813-01', 'E2E-20260813-SOL-01',
  'RECIBIDO', '717ae505', '717ae505', '66afb827',
  clock_timestamp(), clock_timestamp(), clock_timestamp(),
  'Surtido persistente E2E a custodia de OP 260802'
);

INSERT INTO public.movimientos_inventario (
  id, tipo_movimiento, lote_id, cantidad, unidad_id,
  ubicacion_origen_id, estado_origen, ubicacion_destino_id, estado_destino,
  estado_movimiento, fecha_efectiva, confirmado_por, motivo_ajuste, creado_por
) VALUES (
  'E2E-20260813-MOV-SUR-HDI', 'SURTIDO_MATERIAL',
  'LOT-REC-E2E-20260813-REC-HDI', 16.200, 'UNIDAD-KG',
  'UB-AL-LIB-RES', 'DISPONIBLE', 'UB-PI-CUST-OP', 'DISPONIBLE',
  'CONFIRMADO', clock_timestamp(), '717ae505',
  'Surtido HDI2061 a OP 260802', '717ae505'
), (
  'E2E-20260813-MOV-SUR-MOPA', 'SURTIDO_MATERIAL',
  'LOT-REC-E2E-20260813-REC-MOPA', 1.800, 'UNIDAD-KG',
  'UB-AL-LIB-RES', 'DISPONIBLE', 'UB-PI-CUST-OP', 'DISPONIBLE',
  'CONFIRMADO', clock_timestamp(), '717ae505',
  'Surtido molienda PEAD a OP 260802', '717ae505'
);

INSERT INTO public.surtido_detalles (
  id, surtido_id, solicitud_detalle_id, lote_id, cantidad_entregada,
  cantidad_recibida, unidad_id, ubicacion_origen_id,
  ubicacion_destino_id, movimiento_inventario_id
) VALUES (
  'E2E-20260813-SURD-HDI', 'E2E-20260813-SUR-01',
  'E2E-20260813-SOLD-HDI', 'LOT-REC-E2E-20260813-REC-HDI',
  16.200, 16.200, 'UNIDAD-KG', 'UB-AL-LIB-RES', 'UB-PI-CUST-OP',
  'E2E-20260813-MOV-SUR-HDI'
), (
  'E2E-20260813-SURD-MOPA', 'E2E-20260813-SUR-01',
  'E2E-20260813-SOLD-MOPA', 'LOT-REC-E2E-20260813-REC-MOPA',
  1.800, 1.800, 'UNIDAD-KG', 'UB-AL-LIB-RES', 'UB-PI-CUST-OP',
  'E2E-20260813-MOV-SUR-MOPA'
);

-- 6. Consumo real total de 18.0 kg.
INSERT INTO public.consumos (
  id, folio_consumo, orden_produccion_id, estado_consumo,
  registrado_por, registrado_en, confirmado_por, confirmado_en, observaciones
) VALUES (
  'E2E-20260813-CON-01', 'CON-E2E-20260813-01', 'c8091333', 'CONFIRMADO',
  '66afb827', clock_timestamp(), '66afb827', clock_timestamp(),
  'Consumo real persistente E2E Nucita: 18.0 kg'
);

INSERT INTO public.movimientos_inventario (
  id, tipo_movimiento, lote_id, cantidad, unidad_id,
  ubicacion_origen_id, estado_origen, estado_movimiento,
  fecha_efectiva, confirmado_por, motivo_ajuste, creado_por
) VALUES (
  'E2E-20260813-MOV-CON-HDI', 'CONSUMO_MATERIAL',
  'LOT-REC-E2E-20260813-REC-HDI', 16.200, 'UNIDAD-KG',
  'UB-PI-CUST-OP', 'DISPONIBLE', 'CONFIRMADO', clock_timestamp(),
  '66afb827', 'Consumo HDI2061 en OP 260802', '66afb827'
), (
  'E2E-20260813-MOV-CON-MOPA', 'CONSUMO_MATERIAL',
  'LOT-REC-E2E-20260813-REC-MOPA', 1.800, 'UNIDAD-KG',
  'UB-PI-CUST-OP', 'DISPONIBLE', 'CONFIRMADO', clock_timestamp(),
  '66afb827', 'Consumo molienda PEAD en OP 260802', '66afb827'
);

INSERT INTO public.consumo_detalles (
  id, consumo_id, lote_id, cantidad_consumida, unidad_id,
  ubicacion_origen_id, movimiento_inventario_id
) VALUES (
  'E2E-20260813-COND-HDI', 'E2E-20260813-CON-01',
  'LOT-REC-E2E-20260813-REC-HDI', 16.200, 'UNIDAD-KG',
  'UB-PI-CUST-OP', 'E2E-20260813-MOV-CON-HDI'
), (
  'E2E-20260813-COND-MOPA', 'E2E-20260813-CON-01',
  'LOT-REC-E2E-20260813-REC-MOPA', 1.800, 'UNIDAD-KG',
  'UB-PI-CUST-OP', 'E2E-20260813-MOV-CON-MOPA'
);

-- 7. Ajuste interno representativo por diferencia de peso. La funcion recibe
-- OP, lote y unidad; resuelve el detalle de surtido sin pedir la solicitud.
SELECT * FROM public.registrar_devolucion_interna_diferencia_peso(
  'E2E-20260813-DEV-01', 'DEV-E2E-20260813-01',
  'E2E-20260813-DEVD-01', 'E2E-20260813-MOV-DEV-01',
  'c8091333', 'LOT-REC-E2E-20260813-REC-HDI', 0.200, 'UNIDAD-KG',
  'UB-PI-CUST-OP', 'UB-PI-SM-MP', 'PESO',
  '66afb827', '66afb827',
  'Excedente fisico representativo detectado por diferencia de peso'
);

-- 8 y 9. Puerta B: genealogia, proporcion, balance y auditoria.
DO $puerta_b$
DECLARE
  v_consumo_total numeric;
  v_molienda numeric;
BEGIN
  SELECT sum(cantidad),
         sum(cantidad) FILTER (WHERE articulo_relacionado_id = 'MOPA')
    INTO v_consumo_total, v_molienda
    FROM public.vw_app_trazabilidad_op
   WHERE orden_produccion_id = 'c8091333' AND tipo_evento = 'CONSUMO';

  IF v_consumo_total IS DISTINCT FROM 18.000
     OR round(v_molienda / v_consumo_total, 3) IS DISTINCT FROM 0.100 THEN
    RAISE EXCEPTION 'PUERTA_B: consumo o proporcion de molienda incorrectos';
  END IF;

  IF (SELECT count(DISTINCT lote_relacionado_id)
        FROM public.vw_app_trazabilidad_op
       WHERE orden_produccion_id = 'c8091333' AND tipo_evento = 'CONSUMO') <> 2 THEN
    RAISE EXCEPTION 'PUERTA_B: la genealogia no distingue dos lotes consumidos';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM public.vw_app_trazabilidad_op
     WHERE orden_produccion_id = 'c8091333'
       AND tipo_evento = 'DEVOLUCION_INTERNA'
  ) THEN
    RAISE EXCEPTION 'PUERTA_B: la devolucion interna no aparece en trazabilidad';
  END IF;

  IF EXISTS (SELECT 1 FROM public.vw_inventario_actual WHERE existencia < 0) THEN
    RAISE EXCEPTION 'PUERTA_B: existe inventario negativo';
  END IF;

  IF EXISTS (
    SELECT 1 FROM public.movimientos_inventario
     WHERE id LIKE 'E2E-20260813-%'
       AND (estado_movimiento <> 'CONFIRMADO' OR fecha_efectiva IS NULL
            OR tipo_movimiento IS NULL OR creado_por IS NULL
            OR confirmado_por IS NULL)
  ) THEN
    RAISE EXCEPTION 'PUERTA_B: auditoria incompleta en movimientos E2E';
  END IF;

  IF EXISTS (
    SELECT 1 FROM public.surtido_detalles sd
    JOIN public.lotes l ON l.id = sd.lote_id
    WHERE sd.id LIKE 'E2E-20260813-%'
      AND (l.estado_calidad <> 'APROBADO' OR l.estado_liberacion <> 'LIBERADO')
  ) THEN
    RAISE EXCEPTION 'PUERTA_B: se surtio un lote no liberado';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM public.devolucion_asignaciones
     WHERE devolucion_detalle_id = 'E2E-20260813-DEVD-01'
       AND metodo_asignacion = 'FIFO_AUTOMATICO_EXCEDENTE'
  ) THEN
    RAISE EXCEPTION 'PUERTA_B: no se genero asignacion automatica de devolucion';
  END IF;
END;
$puerta_b$;

COMMIT;

