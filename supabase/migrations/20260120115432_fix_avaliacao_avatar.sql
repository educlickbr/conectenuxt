-- Fix: Remove dependency on non-existent avatar_url column
-- Replaces u.avatar_url with NULL

CREATE OR REPLACE FUNCTION public.avaliacao_diario_get_grid(
    p_id_empresa uuid,
    p_id_turma uuid,
    p_id_modelo uuid
)
RETURNS jsonb
LANGUAGE plpgsql
AS $function$
DECLARE
    v_result jsonb;
BEGIN
    SELECT jsonb_agg(sub)
    INTO v_result
    FROM (
        SELECT
            u.id AS id_aluno,
            u.nome_completo AS nome_aluno,
            NULL::text AS foto_aluno, -- FIXED: Column avatar_url does not exist on user_expandido
            m.status AS status_matricula,
            -- Aggregated Responses for this Student & Model
            (
                SELECT jsonb_agg(jsonb_build_object(
                    'id_item', ar.id_item,
                    'conceito', ar.conceito,
                    'observacao', ar.observacao,
                    'id_resposta', ar.id
                ))
                FROM public.avaliacao_resposta ar
                WHERE ar.id_empresa = p_id_empresa
                  AND ar.id_turma = p_id_turma
                  AND ar.id_modelo = p_id_modelo
                  AND ar.id_aluno = u.id
            ) AS respostas,
            -- Optional: Student level observation for this model?
            (
                 SELECT ar.observacao 
                 FROM public.avaliacao_resposta ar
                 WHERE ar.id_empresa = p_id_empresa
                  AND ar.id_turma = p_id_turma
                  AND ar.id_modelo = p_id_modelo
                  AND ar.id_aluno = u.id
                 LIMIT 1 
            ) AS observacao_avaliacao
        FROM
            public.matricula_turma mt
        JOIN
            public.matriculas m ON m.id = mt.id_matricula
        JOIN
            public.user_expandido u ON u.id = m.id_aluno
        WHERE
            mt.id_empresa = p_id_empresa
            AND mt.id_turma = p_id_turma
            AND mt.status = 'ativa'
            AND m.status = 'ativa'
            AND u.soft_delete IS FALSE
        ORDER BY
            u.nome_completo ASC
    ) sub;

    RETURN COALESCE(v_result, '[]'::jsonb);
END;
$function$;
