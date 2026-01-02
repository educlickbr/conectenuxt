CREATE OR REPLACE FUNCTION public.aluno_get_detalhes_cpx(
    p_id_empresa uuid,
    p_id_aluno uuid -- user_expandido.id
)
RETURNS json
LANGUAGE plpgsql
COST 100
VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
    v_dados_gerais json;
    v_respostas json;
    v_papel_id uuid;
BEGIN
    -- 1. Buscar Dados Gerais e o Papel do Aluno
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

    -- Se não encontrar o aluno, retorna nulo ou objeto vazio
    IF v_dados_gerais IS NULL THEN
        RETURN NULL;
    END IF;

    -- 2. Buscar Perguntas e Respostas
    -- Filtra perguntas onde o papel do aluno está contido no array 'papel' da pergunta
    SELECT COALESCE(json_agg(row_to_json(t)), '[]'::json) INTO v_respostas
    FROM (
        SELECT 
            p.id AS id_pergunta,
            p.label,
            p.tipo,
            p.ordem,
            r.resposta,
            r.id AS id_resposta
        FROM public.perguntas_user p
        LEFT JOIN public.respostas_user r ON p.id = r.id_pergunta AND r.id_user = p_id_aluno
        WHERE 
            p.papel @> jsonb_build_array(v_papel_id::text)
        ORDER BY p.ordem ASC
    ) t;

    -- 3. Retornar Objeto Completo
    RETURN json_build_object(
        'dados_gerais', v_dados_gerais,
        'respostas', v_respostas
    );
END;
$BODY$;

ALTER FUNCTION public.aluno_get_detalhes_cpx(uuid, uuid)
    OWNER TO postgres;
