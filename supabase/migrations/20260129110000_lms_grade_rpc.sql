DROP FUNCTION IF EXISTS public.lms_submissao_avaliar;

CREATE OR REPLACE FUNCTION public.lms_submissao_avaliar(
    p_id_submissao uuid,
    p_nota numeric,
    p_comentario text,
    p_user_id uuid DEFAULT auth.uid()
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_papel_id uuid;
    v_admin_role uuid := 'd3410ac7-5a4a-4f02-8923-610b9fd87c4d';
    v_prof_role uuid := '3c4c1d8c-1ad8-4abc-9eea-12829ab7d7f1';
    v_user_expandido_id uuid;
BEGIN
    -- Check permissions (Simplified: Admin or Professor)
    SELECT ue.id, ue.papel_id INTO v_user_expandido_id, v_papel_id
    FROM public.user_expandido ue
    WHERE ue.user_id = p_user_id;

    IF v_papel_id IS NULL OR (v_papel_id != v_admin_role AND v_papel_id != v_prof_role) THEN
        RETURN jsonb_build_object('status', 'error', 'message', 'Permissão negada.');
    END IF;

    -- Update Submission
    UPDATE public.lms_submissao
    SET 
        nota = p_nota,
        comentario_professor = p_comentario,
        status = CASE WHEN p_nota IS NOT NULL THEN 'avaliado'::text ELSE 'pendente'::text END,
        modificado_em = now()
    WHERE id = p_id_submissao;

    IF NOT FOUND THEN
        RETURN jsonb_build_object('status', 'error', 'message', 'Submissão não encontrada.');
    END IF;

    RETURN jsonb_build_object('status', 'success', 'message', 'Avaliação registrada com sucesso.');
END;
$$;
