-- RPC: Upsert Group
DROP FUNCTION IF EXISTS public.grp_grupo_upsert;

CREATE OR REPLACE FUNCTION public.grp_grupo_upsert(
    p_id uuid,
    p_id_empresa uuid,
    p_nome_grupo text,
    p_descricao text,
    p_status text DEFAULT 'ATIVO' 
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
    -- Resolve user_expandido.id
    SELECT id INTO v_user_id
    FROM public.user_expandido
    WHERE user_id = auth.uid()
    LIMIT 1;

    IF v_user_id IS NULL THEN
         RETURN json_build_object(
            'success', false,
            'message', 'Usuário não encontrado.'
        );
    END IF;

    IF p_id IS NULL THEN
        -- Insert
        INSERT INTO public.grp_grupos (
            id_empresa,
            nome_grupo,
            descricao,
            status,
            criado_por,
            criado_em,
            modificado_por,
            modificado_em
        ) VALUES (
            p_id_empresa,
            p_nome_grupo,
            p_descricao,
            p_status::status_grp,
            v_user_id,
            now(),
            v_user_id,
            now()
        ) RETURNING id INTO v_id;
    ELSE
        -- Update
        UPDATE public.grp_grupos SET
            nome_grupo = p_nome_grupo,
            descricao = p_descricao,
            status = p_status::status_grp,
            modificado_por = v_user_id,
            modificado_em = now()
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
        'message', SQLERRM
    );
END;
$function$;
