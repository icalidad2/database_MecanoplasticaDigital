-- Puerta A / P0 reproducible. No depende de lotes ni recepciones historicas.
CREATE TEMP TABLE prueba_surtido_detalle(lote_id text NOT NULL,unidad_logistica_id text,ubicacion_origen_id text NOT NULL,unidad_id text NOT NULL) ON COMMIT DROP;
CREATE TRIGGER trg_prueba_validar_lote_surtido BEFORE INSERT OR UPDATE ON prueba_surtido_detalle FOR EACH ROW EXECUTE FUNCTION public.validar_lote_apto_para_surtido();

DO $tests$
DECLARE v_apto boolean; v_error text;
BEGIN
  BEGIN
    INSERT INTO public.lotes(id,codigo_lote,articulo_id,tipo_origen,estado_calidad,estado_liberacion,activo) VALUES
      ('TEST-P0-CUAR','TEST-P0-CUAR','HDI2061','PROVEEDOR','CUARENTENA','BLOQUEADO',true),
      ('TEST-P0-RECH','TEST-P0-RECH','HDI2061','PROVEEDOR','RECHAZADO','BLOQUEADO',true),
      ('TEST-P0-OK','TEST-P0-OK','HDI2061','PROVEEDOR','APROBADO','LIBERADO',true);
    INSERT INTO public.movimientos_inventario(id,tipo_movimiento,lote_id,cantidad,unidad_id,ubicacion_destino_id,estado_destino,estado_movimiento,confirmado_por,creado_por) VALUES
      ('TEST-P0-MOV-CUAR','AJUSTE_PRUEBA','TEST-P0-CUAR',1,'UNIDAD-KG','UB-AL-LIB-RES','DISPONIBLE','CONFIRMADO','66afb827','66afb827'),
      ('TEST-P0-MOV-RECH','AJUSTE_PRUEBA','TEST-P0-RECH',1,'UNIDAD-KG','UB-AL-LIB-RES','DISPONIBLE','CONFIRMADO','66afb827','66afb827'),
      ('TEST-P0-MOV-OK','AJUSTE_PRUEBA','TEST-P0-OK',1,'UNIDAD-KG','UB-AL-LIB-RES','DISPONIBLE','CONFIRMADO','66afb827','66afb827');

    IF EXISTS(SELECT 1 FROM public.vw_app_inventario WHERE lote_id IN('TEST-P0-CUAR','TEST-P0-RECH') AND apto_para_surtido) THEN RAISE EXCEPTION 'P0_01_FALLO_VISTA'; END IF;
    SELECT apto_para_surtido INTO v_apto FROM public.vw_app_inventario WHERE lote_id='TEST-P0-OK';
    IF v_apto IS DISTINCT FROM true THEN RAISE EXCEPTION 'P0_01_FALLO_POSITIVO'; END IF;

    BEGIN
      INSERT INTO prueba_surtido_detalle VALUES('TEST-P0-CUAR',NULL,'UB-AL-LIB-RES','UNIDAD-KG');
      RAISE EXCEPTION 'P0_01_FALLO_TRIGGER';
    EXCEPTION WHEN SQLSTATE 'P0001' THEN
      GET STACKED DIAGNOSTICS v_error=MESSAGE_TEXT;
      IF v_error NOT LIKE 'LOTE_CALIDAD_NO_APROBADA:%' THEN RAISE; END IF;
    END;

    RAISE EXCEPTION USING ERRCODE='P0002',MESSAGE='ROLLBACK_P0_01';
  EXCEPTION WHEN SQLSTATE 'P0002' THEN
    IF SQLERRM<>'ROLLBACK_P0_01' THEN RAISE; END IF;
  END;

  BEGIN
    INSERT INTO public.recepciones_materiales(id,articulo_id,tipo_analisis,numero_analisis,folio_ft_al_01,codigo_lote,lote_proveedor,proveedor_id,cantidad_capturada,unidad_capturada_id,ubicacion_cuarentena_id,recibido_por)
    VALUES('TEST-P0-REC','HDI2061','MP_EXTERNA','TEST-P0-ANL','TEST-P0-FT','TEST-P0-LOTE','TEST-P0-PROV','PROV-PLAST-COMP',1,'UNIDAD-KG','UB-AL-CUAR-MP','717ae505');
    INSERT INTO public.reversiones_recepciones_materiales(id,recepcion_id,solicitado_por,autorizado_por,motivo)
    VALUES('TEST-P0-REV','TEST-P0-REC','66afb827','717ae505','Prueba reproducible P0-02');
    IF NOT EXISTS(SELECT 1 FROM public.recepciones_materiales WHERE id='TEST-P0-REC' AND estado='REVERTIDA' AND revertida_en IS NOT NULL) THEN RAISE EXCEPTION 'P0_02_FALLO'; END IF;
    RAISE EXCEPTION USING ERRCODE='P0002',MESSAGE='ROLLBACK_P0_02';
  EXCEPTION WHEN SQLSTATE 'P0002' THEN
    IF SQLERRM<>'ROLLBACK_P0_02' THEN RAISE; END IF;
  END;
END;
$tests$;
