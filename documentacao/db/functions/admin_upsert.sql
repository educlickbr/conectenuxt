CREATE OR REPLACE FUNCTION public.admin_upsert(
    p_id_empresa uuid,
    p_data jsonb
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
DECLARE
    v_id uuid;
    v_papel_admin uuid := 'd3410ac7-5a4a-4f02-8923-610b9fd87c4d';
    v_matricula text;
BEGIN
    v_id := (p_data->>'id')::uuid;

    -- Generate Matricula if new
    IF v_id IS NULL THEN
        v_matricula := 'ADM-' || floor(extract(epoch from now()) * 1000)::text || '-' || floor(random() * 1000)::text;
        
        INSERT INTO public.user_expandido (
            id_empresa,
            nome_completo,
            email,
            telefone,
            matricula,
            papel_id,
            status_contrato
        ) VALUES (
            p_id_empresa,
            p_data->>'nome_completo',
            p_data->>'email',
            p_data->>'telefone',
            v_matricula,
            v_papel_admin,
            'Ativo'
        ) RETURNING id INTO v_id;
    ELSE
        UPDATE public.user_expandido
        SET 
            nome_completo = p_data->>'nome_completo',
            email = p_data->>'email',
            telefone = p_data->>'telefone'
        WHERE id = v_id AND id_empresa = p_id_empresa;
    END IF;

    RETURN jsonb_build_object('id', v_id);
END;
$$;

ALTER FUNCTION public.admin_upsert(uuid, jsonb)
    OWNER TO postgres;
