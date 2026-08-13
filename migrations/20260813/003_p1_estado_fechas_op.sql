-- P1-01 — Coherencia mínima entre estado y fechas reales de una OP.
-- Reproducible: corrige la anomalía histórica de 260802 sólo cuando está presente.

DO $correccion$
BEGIN
  IF EXISTS (
    SELECT 1
      FROM public.ordenes_produccion
     WHERE id = 'c8091333'
       AND codigo_lote = '260802'
       AND estado_produccion = 'BORRADOR'
       AND (fecha_inicio_real IS NOT NULL OR fecha_cierre_real IS NOT NULL)
  ) THEN
    IF EXISTS (
      SELECT 1 FROM public.reportes_produccion WHERE orden_produccion_id = 'c8091333'
      UNION ALL SELECT 1 FROM public.dictamenes_calidad_produccion WHERE orden_produccion_id = 'c8091333'
      UNION ALL SELECT 1 FROM public.entregas_produccion WHERE orden_produccion_id = 'c8091333'
      UNION ALL SELECT 1 FROM public.solicitudes_material WHERE orden_produccion_id = 'c8091333'
      UNION ALL SELECT 1 FROM public.consumos WHERE orden_produccion_id = 'c8091333'
      UNION ALL SELECT 1 FROM public.devoluciones WHERE orden_produccion_id = 'c8091333'
      UNION ALL SELECT 1 FROM public.movimientos_inventario WHERE lote_id = 'LOT-OP-c8091333'
    ) THEN
      RAISE EXCEPTION
        'PRECONDICION_P1_01: la OP 260802 ya tiene actividad operativa asociada';
    END IF;

    UPDATE public.ordenes_produccion
       SET fecha_inicio_real = NULL,
           fecha_cierre_real = NULL
     WHERE id = 'c8091333'
       AND codigo_lote = '260802'
       AND estado_produccion = 'BORRADOR';
  END IF;
END;
$correccion$;

DO $constraint$
BEGIN
  IF NOT EXISTS (
    SELECT 1
      FROM pg_constraint
     WHERE conrelid = 'public.ordenes_produccion'::regclass
       AND conname = 'op_borrador_sin_fechas_reales_ck'
  ) THEN
    ALTER TABLE public.ordenes_produccion
      ADD CONSTRAINT op_borrador_sin_fechas_reales_ck
      CHECK (
        estado_produccion <> 'BORRADOR'
        OR (fecha_inicio_real IS NULL AND fecha_cierre_real IS NULL)
      ) NOT VALID;
  END IF;
END;
$constraint$;

ALTER TABLE public.ordenes_produccion
  VALIDATE CONSTRAINT op_borrador_sin_fechas_reales_ck;

COMMENT ON CONSTRAINT op_borrador_sin_fechas_reales_ck
  ON public.ordenes_produccion IS
  'Una OP BORRADOR aun no ha iniciado y no puede tener fechas reales.';
