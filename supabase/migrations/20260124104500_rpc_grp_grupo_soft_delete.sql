-- RPC: Soft Delete Group
DROP FUNCTION IF EXISTS public.grp_grupo_soft_delete;

CREATE OR REPLACE FUNCTION public.grp_grupo_soft_delete(
    p_id uuid,
    p_id_empresa uuid
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
DECLARE
    v_user_id uuid;
BEGIN
    -- Resolve user
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

    -- Update soft_delete
    UPDATE public.grp_grupos
    SET 
        soft_delete = true,
        modificado_por = v_user_id,
        modificado_em = now()
    WHERE id = p_id AND id_empresa = p_id_empresa;

    IF FOUND THEN
        RETURN json_build_object('success', true);
    ELSE
        RETURN json_build_object('success', false, 'message', 'Grupo não encontrado.');
    END IF;
END;
$function$;
