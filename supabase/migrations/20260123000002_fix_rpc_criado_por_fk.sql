-- Drop the function to update logic
DROP FUNCTION IF EXISTS public.lms_conteudo_upsert;

-- Re-create with user_expandido lookup logic
CREATE OR REPLACE FUNCTION public.lms_conteudo_upsert(
    p_id uuid,
    p_id_empresa uuid,
    p_titulo text,
    p_descricao text,
    p_escopo text,
    p_id_ano_etapa uuid DEFAULT NULL,
    p_id_turma uuid DEFAULT NULL,
    p_id_meta_turma uuid DEFAULT NULL,
    p_id_componente uuid DEFAULT NULL,
    p_id_aluno uuid DEFAULT NULL,
    p_visivel_para_alunos boolean DEFAULT true,
    p_data_disponivel timestamp with time zone DEFAULT NULL,
    p_liberar_por text DEFAULT 'Conteúdo',
    p_criado_por uuid DEFAULT NULL 
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
DECLARE
    v_id uuid;
    v_result json;
    v_user_id uuid;
BEGIN
    -- Resolve user_expandido.id for the currently authenticated user
    SELECT id INTO v_user_id
    FROM public.user_expandido
    WHERE user_id = auth.uid()
    LIMIT 1;

    -- Optional: If not found via auth (e.g. system call?), fall back to passed param if valid, or error.
    -- For now, prioritize the auth lookup as requested.
    IF v_user_id IS NULL THEN
        -- Fallback or Error. Given the constraint, we need a valid ID.
        -- Assuming p_criado_por might be a valid user_expandido id passed manually in some cases?
        v_user_id := p_criado_por;
    END IF;

    IF v_user_id IS NULL THEN
         RETURN json_build_object(
            'success', false,
            'message', 'Usuário não encontrado (user_expandido).',
            'detail', 'auth.uid() não retornou vínculo em user_expandido.'
        );
    END IF;

    IF p_id IS NULL THEN
        -- Insert
        INSERT INTO public.lms_conteudo (
            id_empresa,
            titulo,
            descricao,
            escopo,
            id_ano_etapa,
            id_turma,
            id_meta_turma,
            id_componente,
            id_aluno,
            visivel_para_alunos,
            data_disponivel,
            liberar_por,
            criado_por
        ) VALUES (
            p_id_empresa,
            p_titulo,
            p_descricao,
            p_escopo,
            p_id_ano_etapa,
            p_id_turma,
            p_id_meta_turma,
            p_id_componente,
            p_id_aluno,
            p_visivel_para_alunos,
            p_data_disponivel,
            p_liberar_por::liberacao_conteudo_enum,
            v_user_id
        ) RETURNING id INTO v_id;
    ELSE
        -- Update
        UPDATE public.lms_conteudo SET
            titulo = p_titulo,
            descricao = p_descricao,
            escopo = p_escopo,
            id_ano_etapa = p_id_ano_etapa,
            id_turma = p_id_turma,
            id_meta_turma = p_id_meta_turma,
            id_componente = p_id_componente,
            id_aluno = p_id_aluno,
            visivel_para_alunos = p_visivel_para_alunos,
            data_disponivel = p_data_disponivel,
            liberar_por = p_liberar_por::liberacao_conteudo_enum
        WHERE id = p_id AND id_empresa = p_id_empresa
        RETURNING id INTO v_id;
    END IF;

    SELECT json_build_object(
        'success', true,
        'id', v_id
    ) INTO v_result;

    RETURN v_result;
EXCEPTION WHEN OTHERS THEN
    RETURN json_build_object(
        'success', false,
        'message', SQLERRM,
        'detail', SQLSTATE
    );
END;
$function$;
