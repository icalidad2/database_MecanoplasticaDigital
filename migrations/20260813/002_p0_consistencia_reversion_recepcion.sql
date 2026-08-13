-- P0-02 — Coherencia entre el estado de una recepcion y su reversion.
-- Precondicion comprobada el 13/08/2026 en diseno-nucleo-v0-2:
-- la recepcion 2624178b esta ACTIVA, no tiene reversion asociada y conserva
-- indebidamente revertida_en.

DO $migration$
DECLARE
  v_actualizadas integer;
BEGIN
  IF EXISTS (
    SELECT 1
      FROM public.reversiones_recepciones_materiales rr
     WHERE rr.recepcion_id = '2624178b'
  ) THEN
    RAISE EXCEPTION
      'PRECONDICION_P0_02: la recepcion 2624178b ya tiene una reversion asociada';
  END IF;

  ALTER TABLE public.recepciones_materiales
    DISABLE TRIGGER trg_proteger_recepcion_material;

  UPDATE public.recepciones_materiales
     SET revertida_en = NULL
   WHERE id = '2624178b'
     AND estado = 'ACTIVA'
     AND reversion_recepcion_id IS NULL
     AND revertida_en IS NOT NULL;

  GET DIAGNOSTICS v_actualizadas = ROW_COUNT;

  ALTER TABLE public.recepciones_materiales
    ENABLE TRIGGER trg_proteger_recepcion_material;

  IF v_actualizadas <> 1 THEN
    RAISE EXCEPTION
      'PRECONDICION_P0_02: se esperaba corregir 1 recepcion; se corrigieron %',
      v_actualizadas;
  END IF;
END;
$migration$;

DO $constraint$
BEGIN
  IF NOT EXISTS (
    SELECT 1
      FROM pg_constraint
     WHERE conrelid = 'public.recepciones_materiales'::regclass
       AND conname = 'recepciones_materiales_reversion_consistencia_ck'
  ) THEN
    ALTER TABLE public.recepciones_materiales
      ADD CONSTRAINT recepciones_materiales_reversion_consistencia_ck
      CHECK (
        (
          estado = 'ACTIVA'
          AND reversion_recepcion_id IS NULL
          AND revertida_en IS NULL
        )
        OR
        (
          estado = 'REVERTIDA'
          AND reversion_recepcion_id IS NOT NULL
          AND revertida_en IS NOT NULL
        )
      ) NOT VALID;
  END IF;
END;
$constraint$;

ALTER TABLE public.recepciones_materiales
  VALIDATE CONSTRAINT recepciones_materiales_reversion_consistencia_ck;

