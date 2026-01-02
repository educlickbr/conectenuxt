DROP FUNCTION public.turmas_upsert;
CREATE OR REPLACE FUNCTION public.turmas_upsert(
    p_id_empresa uuid,
    p_turma jsonb
)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
DECLARE
    v_id uuid;
BEGIN
    IF (p_turma->>'id') IS NULL THEN
        INSERT INTO public.turmas (
            id_empresa,
            id_escola,
            id_ano_etapa,
            id_classe,
            id_horario,
            ano
        ) VALUES (
            p_id_empresa,
            (p_turma->>'id_escola')::uuid,
            (p_turma->>'id_ano_etapa')::uuid,
            (p_turma->>'id_classe')::uuid,
            (p_turma->>'id_horario')::uuid,
            (p_turma->>'ano')::text
        )
        RETURNING id INTO v_id;
    ELSE
        UPDATE public.turmas
        SET
            id_escola = (p_turma->>'id_escola')::uuid,
            id_ano_etapa = (p_turma->>'id_ano_etapa')::uuid,
            id_classe = (p_turma->>'id_classe')::uuid,
            id_horario = (p_turma->>'id_horario')::uuid,
            ano = (p_turma->>'ano')::text,
            atualizado_em = now()
        WHERE id = (p_turma->>'id')::uuid
        AND id_empresa = p_id_empresa
        RETURNING id INTO v_id;
    END IF;

    RETURN v_id;
END;
$$;
