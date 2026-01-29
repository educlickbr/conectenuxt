DROP FUNCTION IF EXISTS public.lms_avaliacoes_get;
CREATE OR REPLACE FUNCTION public.lms_avaliacoes_get(
    p_id_empresa uuid,
    p_user_id uuid DEFAULT auth.uid(),
    p_filtro_status text DEFAULT NULL,    -- 'pendente', 'avaliado', or NULL for all
    p_filtro_turma_id uuid DEFAULT NULL,
    p_filtro_aluno_id uuid DEFAULT NULL,
    p_filtro_escopo text DEFAULT NULL
)
RETURNS TABLE (
    id_submissao uuid,
    id_aluno uuid,
    aluno_nome text,
    aluno_avatar text,
    id_turma uuid,
    turma_nome text,
    id_conteudo uuid,
    conteudo_titulo text,
    escopo text,
    id_item uuid,
    item_titulo text,
    data_envio timestamp with time zone,
    status text,
    nota numeric,
    pontuacao_maxima numeric,
    comentario_professor text
)
LANGUAGE plpgsql
SET search_path TO 'public'
AS $$
DECLARE
    v_user_expandido_id uuid;
    v_papel_id uuid;
    v_admin_role uuid := 'd3410ac7-5a4a-4f02-8923-610b9fd87c4d';
    v_prof_role uuid := '3c4c1d8c-1ad8-4abc-9eea-12829ab7d7f1';
    v_aluno_role uuid := 'b7f53d6e-70b5-453b-b564-728aeb4635d5';
BEGIN
    -- Get User Info
    SELECT ue.id, ue.papel_id
    INTO v_user_expandido_id, v_papel_id
    FROM public.user_expandido ue
    WHERE ue.user_id = p_user_id AND ue.id_empresa = p_id_empresa;

    RETURN QUERY
    SELECT DISTINCT ON (s.id) -- Avoid duplicates if multiple matriculas match logic
        s.id AS id_submissao,
        ue_aluno.id AS id_aluno,
        ue_aluno.nome_completo AS aluno_nome,
        NULL::text AS aluno_avatar, -- Field does not exist in user_expandido
        t.id AS id_turma,
        (t.ano || ' - ' || c_turma.nome)::text AS turma_nome,
        c.id AS id_conteudo,
        c.titulo AS conteudo_titulo,
        c.escopo,
        ic.id AS id_item,
        ic.titulo AS item_titulo,
        s.data_envio,
        s.status,
        s.nota,
        ic.pontuacao_maxima,
        s.comentario_professor
    FROM public.lms_submissao s
    JOIN public.lms_item_conteudo ic ON ic.id = s.id_item_conteudo
    JOIN public.lms_conteudo c ON c.id = ic.id_lms_conteudo
    JOIN public.user_expandido ue_aluno ON ue_aluno.id = s.id_aluno
    -- Join with Matriculas to find Turma (Optional but helpful for context)
    LEFT JOIN public.matriculas m ON m.id_aluno = s.id_aluno AND m.status = 'ativa'
    LEFT JOIN public.turmas t ON t.id = m.id_turma
    LEFT JOIN public.classe c_turma ON c_turma.id = t.id_classe
    WHERE 
        c.id_empresa = p_id_empresa
        -- Optional Filters
        AND (p_filtro_status IS NULL OR 
             (p_filtro_status = 'pendente' AND s.nota IS NULL) OR 
             (p_filtro_status = 'avaliado' AND s.nota IS NOT NULL) OR
             (s.status = p_filtro_status)
            )
        AND (p_filtro_turma_id IS NULL OR m.id_turma = p_filtro_turma_id)
        AND (p_filtro_aluno_id IS NULL OR s.id_aluno = p_filtro_aluno_id)
        AND (p_filtro_escopo IS NULL OR c.escopo = p_filtro_escopo)
        
        -- Permission Logic
        AND (
            -- Admin sees all
            (v_papel_id = v_admin_role)
            OR
            -- Aluno: Sees ONLY their own submissions
            (v_papel_id = v_aluno_role AND s.id_aluno = v_user_expandido_id)
            OR
            -- Professor Logic
            (
                v_papel_id = v_prof_role AND (
                    -- Created by the Professor (Direct Ownership)
                    (ic.criado_por = v_user_expandido_id)
                    OR
                    -- Content Global: Processor pulls all
                    (c.escopo = 'Global')
                    OR
                    -- Turma Content: Professor attributed to the CONTENT'S target Turma
                    (c.escopo = 'Turma' AND c.id_turma IN (
                        SELECT at.id_turma 
                        FROM public.atrib_atribuicao_turmas at
                        WHERE at.id_professor = v_user_expandido_id
                        AND (at.data_fim IS NULL OR at.data_fim >= CURRENT_DATE)
                        UNION
                        SELECT ac.id_turma 
                        FROM public.atrib_atribuicao_componentes ac
                        WHERE ac.id_professor = v_user_expandido_id
                        AND (ac.data_fim IS NULL OR ac.data_fim >= CURRENT_DATE)
                    ))
                    OR
                    -- Individual Content: Professor and Student share ANY active Turma
                    (c.escopo = 'Aluno' AND EXISTS (
                        SELECT 1
                        FROM public.matriculas m_aluno
                        WHERE m_aluno.id_aluno = s.id_aluno
                        AND m_aluno.status = 'ativa'
                        AND m_aluno.id_turma IN (
                            SELECT at.id_turma 
                            FROM public.atrib_atribuicao_turmas at
                            WHERE at.id_professor = v_user_expandido_id
                            AND (at.data_fim IS NULL OR at.data_fim >= CURRENT_DATE)
                            UNION
                            SELECT ac.id_turma 
                            FROM public.atrib_atribuicao_componentes ac
                            WHERE ac.id_professor = v_user_expandido_id
                            AND (ac.data_fim IS NULL OR ac.data_fim >= CURRENT_DATE)
                        )
                    ))
                )
            )
        )
    ORDER BY s.id, s.data_envio DESC;
END;
$$;
