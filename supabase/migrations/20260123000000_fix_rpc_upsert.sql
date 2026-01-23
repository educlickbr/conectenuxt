-- Drop the old function explicitly to avoid signature mismatch issues
DROP FUNCTION IF EXISTS public.lms_conteudo_upsert;

-- Re-create the function with all parameters including p_data_disponivel and p_liberar_por
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
    p_data_referencia date DEFAULT NULL,
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
    -- Get Current User if not provided (fallback)
    v_user_id := coalesce(p_criado_por, auth.uid()); 

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
            data_referencia,
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
            p_data_referencia,
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
            data_referencia = p_data_referencia,
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
