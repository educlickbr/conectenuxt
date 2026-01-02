CREATE OR REPLACE FUNCTION public.familia_get_detalhes(
    p_id uuid
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
DECLARE
    v_familia record;
    v_responsaveis jsonb;
    v_alunos jsonb;
    v_id_pergunta_cpf uuid := 'bec8701a-c56e-47c2-82d3-3123ad26bc2f';
BEGIN
    SELECT * INTO v_familia FROM public.user_familia WHERE id = p_id;
    
    IF NOT FOUND THEN
        RETURN NULL;
    END IF;

    -- Fetch Responsaveis
    SELECT jsonb_agg(
        jsonb_build_object(
            'id', ue.id,
            'nome_completo', ue.nome_completo,
            'email', ue.email,
            'telefone', ue.telefone,
            'cpf', ru_cpf.resposta,
            'papel', COALESCE(rel.papel, 'Pai') -- Default if missing
        )
    ) INTO v_responsaveis
    FROM (
        SELECT DISTINCT id FROM (
            SELECT id_responsavel_principal as id FROM public.user_familia WHERE id = p_id AND id_responsavel_principal IS NOT NULL
            UNION
            SELECT id_responsavel FROM public.user_responsavel_aluno WHERE id_familia = p_id
        ) ids
    ) r_ids
    JOIN public.user_expandido ue ON r_ids.id = ue.id
    LEFT JOIN public.respostas_user ru_cpf ON ue.id = ru_cpf.id_user AND ru_cpf.id_pergunta = v_id_pergunta_cpf
    LEFT JOIN LATERAL (
        SELECT papel 
        FROM public.user_responsavel_aluno 
        WHERE id_familia = p_id AND id_responsavel = ue.id
        LIMIT 1
    ) rel ON true;

    -- Fetch Alunos
    SELECT jsonb_agg(
        jsonb_build_object(
            'id', ue.id,
            'nome_completo', ue.nome_completo,
            'matricula', ue.matricula
        )
    ) INTO v_alunos
    FROM (
        SELECT DISTINCT id_aluno 
        FROM public.user_responsavel_aluno 
        WHERE id_familia = p_id
    ) a_ids
    JOIN public.user_expandido ue ON a_ids.id_aluno = ue.id;

    RETURN jsonb_build_object(
        'id', v_familia.id,
        'nome_familia', v_familia.nome_familia,
        'id_responsavel_principal', v_familia.id_responsavel_principal,
        'responsaveis', COALESCE(v_responsaveis, '[]'::jsonb),
        'alunos', COALESCE(v_alunos, '[]'::jsonb)
    );
END;
$$;

ALTER FUNCTION public.familia_get_detalhes(uuid)
    OWNER TO postgres;
