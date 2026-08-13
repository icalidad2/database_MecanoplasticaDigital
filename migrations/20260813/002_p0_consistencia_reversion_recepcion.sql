-- P0-02 — Coherencia entre el estado de una recepción y su reversión.
-- Reproducible: corrige el dato histórico únicamente si existe y está inconsistente.
-- En una reconstrucción limpia, la ausencia de 2624178b no es un error.

DO $migration$
BEGIN
  IF EXISTS (
    SELECT 1
      FROM public.recepciones_materiales r
     WHERE r.id = '2624178b'
       AND r.estado = 'ACTIVA'
       AND r.reversion_recepcion_id IS NULL
       AND r.revertida_en IS NOT NULL
  ) THEN
    IF EXISTS (
      SELECT 1
        FROM public.reversiones_recepciones_materiales rr
       WHERE rr.recepcion_id = '2624178b'
    ) THEN
      RAISE EXCEPTION
        'PRECONDICION_P0_02: la recepcion 2624178b tiene reversion asociada y no puede limpiarse automaticamente';
    END IF;

    ALTER TABLE public.recepciones_materiales
      DISABLE TRIGGER trg_proteger_recepcion_material;

    UPDATE public.recepciones_materiales
       SET revertida_en = NULL
     WHERE id = '2624178b'
       AND estado = 'ACTIVA'
       AND reversion_recepcion_id IS NULL
       AND revertida_en IS NOT NULL;

    ALTER TABLE public.recepciones_materiales
      ENABLE TRIGGER trg_proteger_recepcion_material;
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
