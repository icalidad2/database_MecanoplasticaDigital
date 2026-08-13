-- Pruebas de Puerta A para P0-01 y P0-02.
-- Todas las entidades de prueba se revierten mediante una subtransaccion.

CREATE TEMP TABLE prueba_surtido_detalle (
  lote_id text NOT NULL,
  unidad_logistica_id text,
  ubicacion_origen_id text NOT NULL,
  unidad_id text NOT NULL
) ON COMMIT DROP;

CREATE TRIGGER trg_prueba_validar_lote_surtido
BEFORE INSERT OR UPDATE ON prueba_surtido_detalle
FOR EACH ROW EXECUTE FUNCTION public.validar_lote_apto_para_surtido();

DO $tests$
DECLARE
  v_apto boolean;
  v_prueba_completa boolean := false;
  v_reversion_completa boolean := false;
  v_error text;
BEGIN
  -- Caso real obligatorio: 260810 permanece CUARENTENA/BLOQUEADO.
  SELECT apto_para_surtido
    INTO v_apto
    FROM public.vw_app_inventario
   WHERE codigo_lote = '260810'
     AND estado_inventario = 'DISPONIBLE'
     AND existencia > 0
   LIMIT 1;

  IF v_apto IS DISTINCT FROM false THEN
    RAISE EXCEPTION 'P0_01_FALLO: lote 260810 aparece elegible';
  END IF;

  BEGIN
    INSERT INTO prueba_surtido_detalle
      (lote_id, unidad_logistica_id, ubicacion_origen_id, unidad_id)
    VALUES
      ('LOT-OP-ab7300d6', NULL, 'UB-AL-RECEP-PP', 'UNIDAD-PZA');
    RAISE EXCEPTION 'P0_01_FALLO: trigger acepto lote 260810';
  EXCEPTION WHEN SQLSTATE 'P0001' THEN
    GET STACKED DIAGNOSTICS v_error = MESSAGE_TEXT;
    IF v_error NOT LIKE 'LOTE_CALIDAD_NO_APROBADA:%' THEN
      RAISE;
    END IF;
  END;

  -- Datos controlados para CUARENTENA, RECHAZADO y APROBADO/LIBERADO.
  BEGIN
    INSERT INTO public.lotes (
      id, codigo_lote, articulo_id, tipo_origen, proveedor_id,
      area_origen_id, orden_produccion_id, lote_proveedor,
      fecha_recepcion, fecha_fabricacion, fecha_caducidad,
      estado_calidad, estado_liberacion, analisis_calidad_id, activo
    )
    SELECT v.id, v.codigo_lote, l.articulo_id, l.tipo_origen, l.proveedor_id,
           l.area_origen_id, NULL, l.lote_proveedor,
           l.fecha_recepcion, l.fecha_fabricacion, l.fecha_caducidad,
           v.estado_calidad, v.estado_liberacion, NULL, true
      FROM public.lotes l
      CROSS JOIN (VALUES
        ('TEST-P0-CUARENTENA', 'TEST-P0-CUARENTENA', 'CUARENTENA', 'BLOQUEADO'),
        ('TEST-P0-BLOQUEADO',  'TEST-P0-BLOQUEADO',  'APROBADO',   'BLOQUEADO'),
        ('TEST-P0-RECHAZADO',  'TEST-P0-RECHAZADO',  'RECHAZADO',  'BLOQUEADO'),
        ('TEST-P0-APROBADO',   'TEST-P0-APROBADO',   'APROBADO',   'LIBERADO')
      ) AS v(id, codigo_lote, estado_calidad, estado_liberacion)
     WHERE l.id = 'LOT-REC-2624178b';

    INSERT INTO public.movimientos_inventario (
      id, tipo_movimiento, lote_id, unidad_logistica_id, cantidad, unidad_id,
      ubicacion_origen_id, estado_origen, ubicacion_destino_id, estado_destino,
      estado_movimiento, fecha_efectiva, confirmado_por,
      movimiento_reversado_id, motivo_ajuste, creado_por
    )
    SELECT 'MOV-' || v.sufijo,
           'AJUSTE_PRUEBA_P0', v.lote_id, NULL, 10, 'UNIDAD-KG',
           NULL, NULL, 'UB-AL-RECEP-PP', 'DISPONIBLE',
           'CONFIRMADO', clock_timestamp(), m.confirmado_por,
           NULL, 'Prueba transaccional P0-01', m.creado_por
      FROM public.movimientos_inventario m
      CROSS JOIN (VALUES
        ('P0-CUARENTENA', 'TEST-P0-CUARENTENA'),
        ('P0-BLOQUEADO',  'TEST-P0-BLOQUEADO'),
        ('P0-RECHAZADO',  'TEST-P0-RECHAZADO'),
        ('P0-APROBADO',   'TEST-P0-APROBADO')
      ) AS v(sufijo, lote_id)
     WHERE m.id = 'MOV-RP-aed9a2ae';

    IF EXISTS (
      SELECT 1 FROM public.vw_app_inventario
       WHERE lote_id IN (
         'TEST-P0-CUARENTENA', 'TEST-P0-BLOQUEADO', 'TEST-P0-RECHAZADO'
       )
         AND apto_para_surtido
    ) THEN
      RAISE EXCEPTION 'P0_01_FALLO: vista acepto CUARENTENA o RECHAZADO';
    END IF;

    SELECT apto_para_surtido INTO v_apto
      FROM public.vw_app_inventario
     WHERE lote_id = 'TEST-P0-APROBADO'
       AND estado_inventario = 'DISPONIBLE';
    IF v_apto IS DISTINCT FROM true THEN
      RAISE EXCEPTION 'P0_01_FALLO: vista rechazo APROBADO/LIBERADO';
    END IF;

    BEGIN
      INSERT INTO prueba_surtido_detalle VALUES
        ('TEST-P0-CUARENTENA', NULL, 'UB-AL-RECEP-PP', 'UNIDAD-KG');
      RAISE EXCEPTION 'P0_01_FALLO: trigger acepto CUARENTENA';
    EXCEPTION WHEN SQLSTATE 'P0001' THEN
      GET STACKED DIAGNOSTICS v_error = MESSAGE_TEXT;
      IF v_error NOT LIKE 'LOTE_CALIDAD_NO_APROBADA:%' THEN RAISE; END IF;
    END;

    BEGIN
      INSERT INTO prueba_surtido_detalle VALUES
        ('TEST-P0-BLOQUEADO', NULL, 'UB-AL-RECEP-PP', 'UNIDAD-KG');
      RAISE EXCEPTION 'P0_01_FALLO: trigger acepto BLOQUEADO';
    EXCEPTION WHEN SQLSTATE 'P0001' THEN
      GET STACKED DIAGNOSTICS v_error = MESSAGE_TEXT;
      IF v_error NOT LIKE 'LOTE_NO_LIBERADO:%' THEN RAISE; END IF;
    END;

    BEGIN
      INSERT INTO prueba_surtido_detalle VALUES
        ('TEST-P0-RECHAZADO', NULL, 'UB-AL-RECEP-PP', 'UNIDAD-KG');
      RAISE EXCEPTION 'P0_01_FALLO: trigger acepto RECHAZADO';
    EXCEPTION WHEN SQLSTATE 'P0001' THEN
      GET STACKED DIAGNOSTICS v_error = MESSAGE_TEXT;
      IF v_error NOT LIKE 'LOTE_CALIDAD_NO_APROBADA:%' THEN RAISE; END IF;
    END;

    INSERT INTO prueba_surtido_detalle VALUES
      ('TEST-P0-APROBADO', NULL, 'UB-AL-RECEP-PP', 'UNIDAD-KG');

    v_prueba_completa := true;
    RAISE EXCEPTION USING ERRCODE = 'P0002', MESSAGE = 'ROLLBACK_DATOS_P0_01';
  EXCEPTION WHEN SQLSTATE 'P0002' THEN
    IF SQLERRM <> 'ROLLBACK_DATOS_P0_01' THEN RAISE; END IF;
  END;

  IF NOT v_prueba_completa THEN
    RAISE EXCEPTION 'P0_01_FALLO: prueba transaccional incompleta';
  END IF;

  -- P0-02: la correccion puntual y la regla global deben quedar vigentes.
  IF EXISTS (
    SELECT 1 FROM public.recepciones_materiales
     WHERE id = '2624178b'
       AND NOT (
         estado = 'ACTIVA'
         AND reversion_recepcion_id IS NULL
         AND revertida_en IS NULL
       )
  ) THEN
    RAISE EXCEPTION 'P0_02_FALLO: recepcion 2624178b sigue inconsistente';
  END IF;

  IF EXISTS (
    SELECT 1 FROM public.recepciones_materiales
     WHERE NOT (
       (estado = 'ACTIVA' AND reversion_recepcion_id IS NULL AND revertida_en IS NULL)
       OR
       (estado = 'REVERTIDA' AND reversion_recepcion_id IS NOT NULL AND revertida_en IS NOT NULL)
     )
  ) THEN
    RAISE EXCEPTION 'P0_02_FALLO: existen recepciones inconsistentes';
  END IF;

  -- Reversion normal y segundo intento invalido; el bloque exterior revierte
  -- incluso la reversion valida para conservar intactos los datos operativos.
  BEGIN
    INSERT INTO public.reversiones_recepciones_materiales (
      id, recepcion_id, solicitado_por, autorizado_por, motivo,
      movimiento_reversion_id, evento_reversion_id
    ) VALUES (
      'TEST-P0-REV-OK', '2624178b', '66afb827', '717ae505',
      'Prueba transaccional P0-02',
      'TEST-P0-MOV-REV', 'TEST-P0-EVT-REV'
    );

    IF NOT EXISTS (
      SELECT 1 FROM public.recepciones_materiales
       WHERE id = '2624178b'
         AND estado = 'REVERTIDA'
         AND reversion_recepcion_id = 'TEST-P0-REV-OK'
         AND revertida_en IS NOT NULL
    ) THEN
      RAISE EXCEPTION 'P0_02_FALLO: la reversion normal no fue aplicada';
    END IF;

    BEGIN
      INSERT INTO public.reversiones_recepciones_materiales (
        id, recepcion_id, solicitado_por, autorizado_por, motivo,
        movimiento_reversion_id, evento_reversion_id
      ) VALUES (
        'TEST-P0-REV-DUP', '2624178b', '66afb827', '717ae505',
        'Segundo intento invalido P0-02',
        'TEST-P0-MOV-DUP', 'TEST-P0-EVT-DUP'
      );
      RAISE EXCEPTION 'P0_02_FALLO: se acepto una segunda reversion';
    EXCEPTION WHEN OTHERS THEN
      GET STACKED DIAGNOSTICS v_error = MESSAGE_TEXT;
      IF v_error = 'P0_02_FALLO: se acepto una segunda reversion' THEN
        RAISE;
      END IF;
    END;

    v_reversion_completa := true;
    RAISE EXCEPTION USING ERRCODE = 'P0002', MESSAGE = 'ROLLBACK_DATOS_P0_02';
  EXCEPTION WHEN SQLSTATE 'P0002' THEN
    IF SQLERRM <> 'ROLLBACK_DATOS_P0_02' THEN RAISE; END IF;
  END;

  IF NOT v_reversion_completa THEN
    RAISE EXCEPTION 'P0_02_FALLO: prueba de reversion incompleta';
  END IF;
END;
$tests$;
