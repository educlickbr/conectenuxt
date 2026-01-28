-- RPCs for Linkage: Tutors and Integrantes

-- 1. Upsert Tutor
CREATE OR REPLACE FUNCTION public.grp_tutor_upsert(
    p_id_empresa uuid,
    p_id_grupo uuid,
    p_id_user uuid,
    p_ano int DEFAULT NULL,
    p_status text DEFAULT 'ATIVO'
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
DECLARE
    v_user_id uuid;
    v_id uuid;
BEGIN
    SELECT id INTO v_user_id FROM public.user_expandido WHERE user_id = auth.uid() LIMIT 1;
    IF v_user_id IS NULL THEN RETURN json_build_object('success', false, 'message', 'User not found'); END IF;

    INSERT INTO public.grp_tutores (id_empresa, id_grupo, id_user, ano, status, criado_por, criado_em, modificado_por, modificado_em)
    VALUES (p_id_empresa, p_id_grupo, p_id_user, p_ano, p_status::status_grp, v_user_id, now(), v_user_id, now())
    ON CONFLICT (id_grupo, id_user)
    DO UPDATE SET
        status = p_status::status_grp,
        ano = EXCLUDED.ano,
        modificado_por = v_user_id,
        modificado_em = now()
    RETURNING id INTO v_id;

    RETURN json_build_object('success', true, 'id', v_id);
END;
$function$;


-- 2. Upsert Integrante
CREATE OR REPLACE FUNCTION public.grp_integrante_upsert(
    p_id_empresa uuid,
    p_id_grupo uuid,
    p_id_user uuid,
    p_ano int DEFAULT NULL,
    p_status text DEFAULT 'ATIVO'
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
DECLARE
    v_user_id uuid;
    v_id uuid;
BEGIN
    SELECT id INTO v_user_id FROM public.user_expandido WHERE user_id = auth.uid() LIMIT 1;
    IF v_user_id IS NULL THEN RETURN json_build_object('success', false, 'message', 'User not found'); END IF;

    INSERT INTO public.grp_integrantes (id_empresa, id_grupo, id_user, ano, status, criado_por, criado_em, modificado_por, modificado_em)
    VALUES (p_id_empresa, p_id_grupo, p_id_user, p_ano, p_status::status_grp, v_user_id, now(), v_user_id, now())
    ON CONFLICT (id_grupo, id_user)
    DO UPDATE SET
        status = p_status::status_grp,
        ano = EXCLUDED.ano,
        modificado_por = v_user_id,
        modificado_em = now()
    RETURNING id INTO v_id;

    RETURN json_build_object('success', true, 'id', v_id);
END;
$function$;

-- 3. Remove Tutor (Hard Delete or Soft? Usually Unlink = Hard Delete if history tracks elsewhere, but let's do Hard Delete as per request "remover" usually)
-- Actually user didn't specify delete for members, but usually needed.
CREATE OR REPLACE FUNCTION public.grp_tutor_remove(
    p_id_grupo uuid,
    p_id_user uuid
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
BEGIN
    DELETE FROM public.grp_tutores WHERE id_grupo = p_id_grupo AND id_user = p_id_user;
    RETURN json_build_object('success', true);
END;
$function$;

-- 4. Remove Integrante
CREATE OR REPLACE FUNCTION public.grp_integrante_remove(
    p_id_grupo uuid,
    p_id_user uuid
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
BEGIN
    DELETE FROM public.grp_integrantes WHERE id_grupo = p_id_grupo AND id_user = p_id_user;
    RETURN json_build_object('success', true);
END;
$function$;
