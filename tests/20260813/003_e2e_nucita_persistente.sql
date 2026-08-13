-- Consultas de evidencia reproducible para la Puerta B.

-- Resumen de consumo y proporcion de molienda.
SELECT orden_produccion_id,
       sum(cantidad) FILTER (WHERE tipo_evento = 'CONSUMO') AS consumo_total_kg,
       sum(cantidad) FILTER (
         WHERE tipo_evento = 'CONSUMO' AND articulo_relacionado_id = 'MOPA'
       ) AS molienda_kg,
       round(
         sum(cantidad) FILTER (
           WHERE tipo_evento = 'CONSUMO' AND articulo_relacionado_id = 'MOPA'
         )
         / NULLIF(sum(cantidad) FILTER (WHERE tipo_evento = 'CONSUMO'), 0),
         3
       ) AS proporcion_molienda
  FROM public.vw_app_trazabilidad_op
 WHERE orden_produccion_id = 'c8091333'
 GROUP BY orden_produccion_id;

-- Genealogia persistente completa de la OP.
SELECT *
  FROM public.vw_app_trazabilidad_op
 WHERE orden_produccion_id = 'c8091333'
 ORDER BY fecha_evento, tipo_evento, lote_relacionado_id;

-- Balance por lote, ubicacion y estado.
SELECT ia.*
  FROM public.vw_inventario_actual ia
 WHERE ia.lote_id IN (
   'LOT-REC-E2E-20260813-REC-HDI',
   'LOT-REC-E2E-20260813-REC-MOPA'
 )
 ORDER BY ia.lote_id, ia.ubicacion_id, ia.estado_inventario;

-- Auditoria de movimientos confirmados.
SELECT id, tipo_movimiento, lote_id, cantidad, unidad_id,
       ubicacion_origen_id, estado_origen,
       ubicacion_destino_id, estado_destino,
       estado_movimiento, fecha_efectiva, creado_por, confirmado_por
  FROM public.movimientos_inventario
 WHERE id LIKE 'E2E-20260813-%'
 ORDER BY fecha_efectiva, id;

-- La asignacion de la devolucion se resolvio automaticamente.
SELECT da.*, dd.lote_id, d.orden_produccion_id
  FROM public.devolucion_asignaciones da
  JOIN public.devolucion_detalles dd ON dd.id = da.devolucion_detalle_id
  JOIN public.devoluciones d ON d.id = dd.devolucion_id
 WHERE da.devolucion_detalle_id = 'E2E-20260813-DEVD-01';

-- Prueba negativa sin residuos: el lote 260810 sigue bloqueado y el trigger
-- debe impedir que se agregue al surtido E2E.
DO $test$
DECLARE
  v_rechazado boolean := false;
  v_error text;
BEGIN
  BEGIN
    INSERT INTO public.surtido_detalles (
      id, surtido_id, solicitud_detalle_id, lote_id, cantidad_entregada,
      cantidad_recibida, unidad_id, ubicacion_origen_id, ubicacion_destino_id
    ) VALUES (
      'E2E-20260813-NEG-BLOQUEADO', 'E2E-20260813-SUR-01',
      'E2E-20260813-SOLD-HDI', 'LOT-OP-ab7300d6', 1.000, NULL,
      'UNIDAD-PZA', 'UB-AL-RECEP-PP', 'UB-PI-CUST-OP'
    );
    RAISE EXCEPTION 'PUERTA_B_FALLO: se acepto lote 260810 bloqueado';
  EXCEPTION WHEN SQLSTATE 'P0001' THEN
    GET STACKED DIAGNOSTICS v_error = MESSAGE_TEXT;
    IF v_error NOT LIKE 'LOTE_CALIDAD_NO_APROBADA:%'
       AND v_error NOT LIKE 'LOTE_NO_LIBERADO:%' THEN
      RAISE;
    END IF;
    v_rechazado := true;
  END;

  IF NOT v_rechazado THEN
    RAISE EXCEPTION 'PUERTA_B_FALLO: prueba negativa incompleta';
  END IF;
END;
$test$;

-- Cero saldos negativos globales.
SELECT count(*) AS saldos_negativos
  FROM public.vw_inventario_actual
 WHERE existencia < 0;
