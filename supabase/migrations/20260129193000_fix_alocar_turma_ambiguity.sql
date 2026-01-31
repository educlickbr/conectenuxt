-- Migration: Fix Ambiguous matricula_alocar_turma
-- Reason: Error "Could not choose the best candidate function" indicates multiple definitions exist.
-- We must DROP both potential signatures and recreate the canonical one.

-- 1. Explictly Drop Possible Overloads
DROP FUNCTION IF EXISTS public.matricula_alocar_turma(uuid, jsonb);
DROP FUNCTION IF EXISTS public.matricula_alocar_turma(jsonb, uuid);

-- 2. Recreate Canonical Function
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

    -- 4. Sync Main Matricula Table
    UPDATE public.matriculas
    SET id_turma = v_id_turma
    WHERE id = v_id_matricula;

    RETURN jsonb_build_object('success', true);
EXCEPTION WHEN OTHERS THEN
    RETURN jsonb_build_object('success', false, 'message', SQLERRM);
END;
$function$;
