-- P0-01 — Elegibilidad integral del lote para surtido.
-- Destino autorizado: diseno-nucleo-v0-2.
-- No ejecutar en production durante el cierre de la linea base condicionada.

CREATE OR REPLACE VIEW public.vw_app_inventario AS
SELECT concat_ws(
         '|'::text,
         ia.lote_id,
         COALESCE(ia.unidad_logistica_id, ''::text),
         ia.ubicacion_id,
         ia.estado_inventario,
         ia.unidad_id
       ) AS id,
       ia.lote_id,
       l.codigo_lote,
       l.articulo_id,
       ar.codigo AS articulo_codigo,
       ar.nombre_producto AS articulo,
       ia.unidad_logistica_id,
       ia.ubicacion_id,
       ub.codigo AS ubicacion_codigo,
       ub.nombre AS ubicacion,
       ub.tipo_ubicacion,
       ub.area_id,
       ae.codigo AS area_codigo,
       ae.nombre AS area,
       ia.estado_inventario,
       ia.unidad_id,
       um.codigo AS unidad,
       ia.existencia,
       l.estado_calidad,
       l.estado_liberacion,
       (
         ia.existencia > 0::numeric
         AND l.activo
         AND ia.estado_inventario = 'DISPONIBLE'::text
         AND l.estado_calidad = 'APROBADO'::text
         AND l.estado_liberacion = 'LIBERADO'::text
       ) AS apto_para_surtido
  FROM public.vw_inventario_actual ia
  JOIN public.lotes l ON l.id = ia.lote_id
  JOIN public.articulos ar ON ar.id = l.articulo_id
  JOIN public.ubicaciones ub ON ub.id = ia.ubicacion_id
  LEFT JOIN public.areas ae ON ae.id = ub.area_id
  LEFT JOIN public.unidades_medida um ON um.id = ia.unidad_id
 WHERE ia.existencia <> 0::numeric
   AND l.activo;

CREATE OR REPLACE FUNCTION public.validar_lote_apto_para_surtido()
RETURNS trigger
LANGUAGE plpgsql
AS $function$
DECLARE
  v_activo boolean;
  v_estado_calidad text;
  v_estado_liberacion text;
  v_disponible numeric(18,3);
BEGIN
  SELECT activo, estado_calidad, estado_liberacion
    INTO v_activo, v_estado_calidad, v_estado_liberacion
    FROM public.lotes
   WHERE id = NEW.lote_id
   FOR KEY SHARE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'LOTE_INEXISTENTE: %', NEW.lote_id;
  END IF;
  IF NOT v_activo THEN
    RAISE EXCEPTION 'LOTE_INACTIVO: %', NEW.lote_id;
  END IF;
  IF v_estado_calidad <> 'APROBADO' THEN
    RAISE EXCEPTION USING ERRCODE = 'P0001',
      MESSAGE = format(
        'LOTE_CALIDAD_NO_APROBADA: lote %s; estado %s',
        NEW.lote_id, v_estado_calidad
      );
  END IF;
  IF v_estado_liberacion <> 'LIBERADO' THEN
    RAISE EXCEPTION USING ERRCODE = 'P0001',
      MESSAGE = format(
        'LOTE_NO_LIBERADO: lote %s; estado %s',
        NEW.lote_id, v_estado_liberacion
      );
  END IF;

  SELECT COALESCE(sum(existencia), 0)
    INTO v_disponible
    FROM public.vw_inventario_actual
   WHERE lote_id = NEW.lote_id
     AND unidad_logistica_id IS NOT DISTINCT FROM NEW.unidad_logistica_id
     AND ubicacion_id = NEW.ubicacion_origen_id
     AND estado_inventario = 'DISPONIBLE'
     AND unidad_id = NEW.unidad_id;

  IF v_disponible <= 0 THEN
    RAISE EXCEPTION USING ERRCODE = 'P0001',
      MESSAGE = format(
        'LOTE_SIN_EXISTENCIA_DISPONIBLE: lote %s; ubicacion %s; unidad %s',
        NEW.lote_id, NEW.ubicacion_origen_id, NEW.unidad_id
      );
  END IF;

  RETURN NEW;
END;
$function$;

