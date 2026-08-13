-- Pruebas P1-01 — estado y fechas reales de ordenes de produccion.
-- Las transiciones de prueba se revierten mediante subtransacciones.

DO $tests$
DECLARE
  v_transicion_valida boolean := false;
  v_invalida_rechazada boolean := false;
  v_error text;
BEGIN
  IF EXISTS (
    SELECT 1
      FROM public.ordenes_produccion
     WHERE estado_produccion = 'BORRADOR'
       AND (fecha_inicio_real IS NOT NULL OR fecha_cierre_real IS NOT NULL)
  ) THEN
    RAISE EXCEPTION 'P1_01_FALLO: existe una OP BORRADOR con fechas reales';
  END IF;

  -- Transicion valida prevista para la accion AppSheet "Iniciar produccion".
  BEGIN
    UPDATE public.ordenes_produccion
       SET estado_produccion = 'EN_PROCESO',
           fecha_inicio_real = clock_timestamp(),
           fecha_cierre_real = NULL
     WHERE id = 'c8091333'
       AND estado_produccion = 'BORRADOR';

    IF NOT EXISTS (
      SELECT 1 FROM public.ordenes_produccion
       WHERE id = 'c8091333'
         AND estado_produccion = 'EN_PROCESO'
         AND fecha_inicio_real IS NOT NULL
         AND fecha_cierre_real IS NULL
    ) THEN
      RAISE EXCEPTION 'P1_01_FALLO: transicion BORRADOR a EN_PROCESO no aplicada';
    END IF;

    v_transicion_valida := true;
    RAISE EXCEPTION USING ERRCODE = 'P0002', MESSAGE = 'ROLLBACK_TRANSICION_VALIDA';
  EXCEPTION WHEN SQLSTATE 'P0002' THEN
    IF SQLERRM <> 'ROLLBACK_TRANSICION_VALIDA' THEN RAISE; END IF;
  END;

  -- Intento invalido: conservar BORRADOR y asignar una fecha real.
  BEGIN
    UPDATE public.ordenes_produccion
       SET fecha_inicio_real = clock_timestamp()
     WHERE id = 'c8091333'
       AND estado_produccion = 'BORRADOR';
    RAISE EXCEPTION 'P1_01_FALLO: se acepto BORRADOR con fecha real';
  EXCEPTION WHEN check_violation THEN
    GET STACKED DIAGNOSTICS v_error = MESSAGE_TEXT;
    IF v_error NOT LIKE '%op_borrador_sin_fechas_reales_ck%' THEN
      RAISE;
    END IF;
    v_invalida_rechazada := true;
  END;

  IF NOT v_transicion_valida OR NOT v_invalida_rechazada THEN
    RAISE EXCEPTION 'P1_01_FALLO: cobertura de transiciones incompleta';
  END IF;

  IF EXISTS (
    SELECT 1 FROM public.ordenes_produccion
     WHERE id = 'c8091333'
       AND NOT (
         estado_produccion = 'BORRADOR'
         AND fecha_inicio_real IS NULL
         AND fecha_cierre_real IS NULL
       )
  ) THEN
    RAISE EXCEPTION 'P1_01_FALLO: la prueba dejo alterada la OP 260802';
  END IF;
END;
$tests$;

