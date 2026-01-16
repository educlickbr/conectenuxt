-- Migration for Student Gradebook Grid
-- Function: avaliacao_diario_get_grid

-- This function returns ALL active students in a class, joined with their potential evaluation answers.
-- It ensures that even if a student hasn't taken the test, they appear in the list.

CREATE OR REPLACE FUNCTION public.avaliacao_diario_get_grid(
    p_id_empresa uuid,
    p_id_turma uuid,
    p_id_modelo uuid
)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    v_itens jsonb;
BEGIN
    SELECT jsonb_agg(row_to_json(t)) INTO v_itens
    FROM (
        SELECT 
            -- Student Info
            ue.id as id_aluno,
            ue.nome_completo as nome_aluno,
            m.id as id_matricula,
            m.status as status_matricula,
            
            -- Evaluation Header (if exists)
            aa.id as id_avaliacao,
            aa.status as status_avaliacao,
            aa.observacao as observacao_avaliacao,
            
            -- Nested Answers (if exists)
            (
                SELECT jsonb_agg(jsonb_build_object(
                    'id_item', aar.id_item_avaliacao,
                    'conceito', aar.conceito,
                    'id_resposta', aar.id
                ))
                FROM public.avaliacao_aluno_resposta aar
                WHERE aar.id_avaliacao_aluno = aa.id
            ) as respostas
            
        FROM public.matriculas m
        JOIN public.user_expandido ue ON ue.id = m.id_aluno
        -- Join Header (Left Join to include students without evals)
        LEFT JOIN public.avaliacao_aluno aa ON aa.id_aluno = ue.id 
                                        AND aa.id_turma = p_id_turma 
                                        AND aa.id_modelo_avaliacao = p_id_modelo
                                        AND aa.id_empresa = p_id_empresa
                                        
        WHERE m.id_empresa = p_id_empresa
          -- Filter mainly by active students in the class context ??
          -- Ideally we should check matricula_turma history too, but sticking to matriculas linked to current view logic? 
          -- Usually we assume matricula represents the current state or we filter by matricula_turma.
          -- For simplicity and robustness, let's use the standard "Students in this Turma" logic.
          -- Finding students actually allocated to this turma:
          AND EXISTS (
              SELECT 1 FROM public.matricula_turma mt
              WHERE mt.id_matricula = m.id
                AND mt.id_turma = p_id_turma
                AND mt.status = 'ativa'
                AND mt.id_empresa = p_id_empresa
          )
        ORDER BY ue.nome_completo ASC
    ) t;
    
    return coalesce(v_itens, '[]'::jsonb);
END;
$function$;
ALTER FUNCTION public.avaliacao_diario_get_grid(uuid, uuid, uuid) OWNER TO postgres;
