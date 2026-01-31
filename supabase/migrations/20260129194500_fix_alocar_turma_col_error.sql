-- Migration: Fix matricula_alocar_turma Invalid Column Access
-- Reason: The table 'matriculas' does not have a column 'id_turma'. This logic is exclusively in 'matricula_turma'.
-- We are removing the redundant/invalid UPDATE block.

CREATE OR REPLACE FUNCTION public.matricula_alocar_turma(p_id_empresa uuid, p_data jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path = public, extensions, pg_temp
AS $function$
DECLARE
    v_id_matricula uuid;
    v_id_turma uuid;
    v_current_active_id uuid;
    v_current_turma_id uuid;
BEGIN
    v_id_matricula := (p_data->>'id_matricula')::uuid;
    v_id_turma := (p_data->>'id_turma')::uuid;

    -- 1. Idempotency Check: Is student already active in this class?
    SELECT id, id_turma INTO v_current_active_id, v_current_turma_id
    FROM public.matricula_turma
    WHERE id_matricula = v_id_matricula 
      AND status = 'ativa';

    IF v_current_turma_id = v_id_turma THEN
        -- Already allocated, do nothing
        RETURN jsonb_build_object('success', true, 'message', 'Aluno já alocado nesta turma.');
    END IF;

    -- 2. Close existing allocation if present
    IF v_current_active_id IS NOT NULL THEN
        UPDATE public.matricula_turma
        SET 
            status = 'transferida',
            data_saida = CURRENT_DATE
        WHERE id = v_current_active_id;
    END IF;

    -- 3. Insert new allocation
    INSERT INTO public.matricula_turma (
        id_empresa,
        id_matricula,
        id_turma,
        data_entrada,
        status
    ) VALUES (
        p_id_empresa,
        v_id_matricula,
        v_id_turma,
        CURRENT_DATE,
        'ativa'
    );

    -- 4. REMOVED: Sync Update to matriculas table
    -- Reason: matriculas table does not have id_turma column.

    RETURN jsonb_build_object('success', true);
EXCEPTION WHEN OTHERS THEN
    RETURN jsonb_build_object('success', false, 'message', SQLERRM);
END;
$function$;
