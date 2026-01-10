-- Debug version of aluno_get_detalhes_cpx to see where it fails
CREATE OR REPLACE FUNCTION public.aluno_get_detalhes_cpx_debug(
    p_id_empresa uuid,
    p_id_aluno uuid
)
RETURNS json
LANGUAGE plpgsql
AS $BODY$
DECLARE
    v_dados_gerais json;
    v_respostas json;
    v_papel_id uuid;
    v_debug json;
    v_user_count integer;
BEGIN
    -- Check if user exists
    SELECT COUNT(*) INTO v_user_count
    FROM public.user_expandido
    WHERE id = p_id_aluno AND id_empresa = p_id_empresa;
    
    -- Try to get dados_gerais
    SELECT 
        json_build_object(
            'user_id', u.user_id,
            'user_expandido_id', u.id,
            'email', u.email,
            'nome_completo', u.nome_completo,
            'matricula', u.matricula,
            'telefone', u.telefone,
            'status', u.status_contrato,
            'id_escola', e.id,
            'nome_escola', e.nome
        ),
        u.papel_id
    INTO v_dados_gerais, v_papel_id
    FROM public.user_expandido u
    LEFT JOIN public.escolas e ON u.id_escola = e.id
    WHERE u.id = p_id_aluno AND u.id_empresa = p_id_empresa;

    -- Return debug info
    RETURN json_build_object(
        'debug', true,
        'user_count', v_user_count,
        'dados_gerais_is_null', v_dados_gerais IS NULL,
        'papel_id', v_papel_id,
        'p_id_empresa', p_id_empresa,
        'p_id_aluno', p_id_aluno,
        'dados_gerais', v_dados_gerais
    );
END;
$BODY$;
