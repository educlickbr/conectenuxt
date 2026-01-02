CREATE OR REPLACE FUNCTION public.bbtk_obra_upsert_cpx(
    p_data jsonb,
    p_id_empresa uuid
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO public
AS $$
DECLARE
    v_obra_data jsonb;
    v_edicoes_data jsonb;
    v_obra_uuid uuid;
    v_edicao_item jsonb;
    v_ano_lancamento int;
    v_ano_lancamento_date date;
BEGIN
    v_obra_data := p_data->'obra';
    v_edicoes_data := p_data->'edicoes';
    
    -- 1. Upsert Obra
    IF (v_obra_data->>'uuid') IS NULL OR (v_obra_data->>'uuid') = '' THEN
        INSERT INTO public.bbtk_obra (
            titulo_principal,
            sub_titulo_principal,
            categoria_uuid,
            cdu_uuid,
            id_autoria,
            id_empresa
        ) VALUES (
            v_obra_data->>'titulo_principal',
            v_obra_data->>'sub_titulo_principal',
            (v_obra_data->>'categoria_uuid')::uuid,
            (v_obra_data->>'cdu_uuid')::uuid,
            (v_obra_data->>'id_autoria')::uuid,
            p_id_empresa
        ) RETURNING uuid INTO v_obra_uuid;
    ELSE
        UPDATE public.bbtk_obra SET
            titulo_principal = v_obra_data->>'titulo_principal',
            sub_titulo_principal = v_obra_data->>'sub_titulo_principal',
            categoria_uuid = (v_obra_data->>'categoria_uuid')::uuid,
            cdu_uuid = (v_obra_data->>'cdu_uuid')::uuid,
            id_autoria = (v_obra_data->>'id_autoria')::uuid
        WHERE uuid = (v_obra_data->>'uuid')::uuid AND id_empresa = p_id_empresa
        RETURNING uuid INTO v_obra_uuid;
    END IF;

    -- 2. Upsert Edicoes
    FOR v_edicao_item IN SELECT * FROM jsonb_array_elements(v_edicoes_data)
    LOOP
        -- Parse Year (assuming input is purely YYYY or empty)
        v_ano_lancamento := NULL;
        IF (v_edicao_item->>'ano_lancamento') IS NOT NULL AND (v_edicao_item->>'ano_lancamento') <> '' THEN
            v_ano_lancamento := (v_edicao_item->>'ano_lancamento')::int;
        END IF;

        -- Convert to Date (YYYY-01-01) for storage
        v_ano_lancamento_date := NULL;
        IF v_ano_lancamento IS NOT NULL THEN
            v_ano_lancamento_date := make_date(v_ano_lancamento, 1, 1);
        END IF;

        IF (v_edicao_item->>'uuid') IS NULL OR (v_edicao_item->>'uuid') = '' THEN
            INSERT INTO public.bbtk_edicao (
                obra_uuid,
                editora_uuid,
                ano_lancamento,
                isbn,
                tipo_livro,
                livro_retiravel,
                livro_recomendado,
                id_empresa
            ) VALUES (
                v_obra_uuid,
                (v_edicao_item->>'editora_uuid')::uuid,
                v_ano_lancamento_date,
                v_edicao_item->>'isbn',
                (v_edicao_item->>'tipo_livro')::public.bbtk_tipo_livro,
                COALESCE((v_edicao_item->>'livro_retiravel')::boolean, true),
                COALESCE((v_edicao_item->>'livro_recomendado')::boolean, false),
                p_id_empresa
            );
        ELSE
            UPDATE public.bbtk_edicao SET
                editora_uuid = (v_edicao_item->>'editora_uuid')::uuid,
                ano_lancamento = v_ano_lancamento_date,
                isbn = v_edicao_item->>'isbn',
                tipo_livro = (v_edicao_item->>'tipo_livro')::public.bbtk_tipo_livro,
                livro_retiravel = COALESCE((v_edicao_item->>'livro_retiravel')::boolean, true),
                livro_recomendado = COALESCE((v_edicao_item->>'livro_recomendado')::boolean, false)
            WHERE uuid = (v_edicao_item->>'uuid')::uuid AND id_empresa = p_id_empresa;
        END IF;
    END LOOP;

    RETURN jsonb_build_object('success', true, 'uuid', v_obra_uuid);
END;
$$;
