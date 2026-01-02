-- Function to Get Evaluations (Submissions)
-- Permissions:
-- Admin: All
-- Professor:
--   - Content Global: All
--   - Content Turma: Only if attributed to Turma
--   - Content Aluno: Only if Student and Professor share a Turma
DROP FUNCTION IF EXISTS public.lms_avaliacoes_get;
CREATE OR REPLACE FUNCTION public.lms_avaliacoes_get(
    p_id_empresa uuid,
    p_user_id uuid,
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
BEGIN
    -- Get User Info
    SELECT ue.id, ue.papel_id
    INTO v_user_expandido_id, v_papel_id
    FROM public.user_expandido ue
    WHERE ue.user_id = p_user_id AND ue.id_empresa = p_id_empresa;

    RETURN QUERY
    SELECT 
        s.id AS id_submissao,
        ue_aluno.id AS id_aluno,
        ue_aluno.nome_completo AS aluno_nome,
        NULL::text AS aluno_avatar, -- Avatar not in user_expandido yet
        m.id_turma,
        t.ano || ' - ' || c_turma.nome AS turma_nome, -- Constructing a display name, usually Turma has more info but simplistic for now
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
    -- Resolving Turma for the student (Active Matricula)
    -- Needed for filtering and display. Submissions themselves don't link to Turma directly, 
    -- but students do. We take the active matricula or one relevant to the content if possible.
    -- If content is Turma Scoped, we use that. If not, we take student's current active class.
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
            -- Professor Logic
            (
                v_papel_id = v_prof_role AND (
                    -- Global Content: Processor pulls all
                    (c.escopo = 'Global')
                    OR
                    -- Turma Content: Professor attributed to the CONTENT'S target Turma
                    -- Note: Conteudo has id_turma if scope is Turma
                    (c.escopo = 'Turma' AND c.id_turma IN (
                        SELECT tpa.id_turma 
                        FROM public.turma_professor_atribuicao tpa
                        WHERE tpa.id_professor = v_user_expandido_id
                        AND (tpa.data_fim IS NULL OR tpa.data_fim >= CURRENT_DATE)
                    ))
                    OR
                    -- Individual Content: Professor and Student share ANY active Turma
                    -- Note: Content has id_aluno if scope is Aluno (Individual)
                    (c.escopo = 'Aluno' AND EXISTS (
                        -- Check if there is an intersection of Turmas between Professor and Student
                        SELECT 1
                        FROM public.matriculas m_aluno
                        JOIN public.turma_professor_atribuicao tpa_prof ON tpa_prof.id_turma = m_aluno.id_turma
                        WHERE m_aluno.id_aluno = s.id_aluno
                        AND tpa_prof.id_professor = v_user_expandido_id
                        AND m_aluno.status = 'ativa'
                        AND (tpa_prof.data_fim IS NULL OR tpa_prof.data_fim >= CURRENT_DATE)
                    ))
                )
            )
        )
    ORDER BY s.data_envio DESC;
END;
$$;
