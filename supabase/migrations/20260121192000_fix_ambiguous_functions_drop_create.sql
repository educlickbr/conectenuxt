-- Fix ambiguous functions by DROPPING all variations before recreating
-- This ensures we don't have overloaded functions with different parameter types (date vs timestamptz)

-- DROP all known variations of bbtk_reserva_create
DROP FUNCTION IF EXISTS public.bbtk_reserva_create(uuid, uuid, uuid, date); -- Original (4 args)
DROP FUNCTION IF EXISTS public.bbtk_reserva_create(uuid, uuid, date);       -- Intermediate (3 args, date)
DROP FUNCTION IF EXISTS public.bbtk_reserva_create(uuid, uuid, timestamptz); -- New (3 args, timestamptz)

-- DROP bbtk_reserva_get_paginado
DROP FUNCTION IF EXISTS public.bbtk_reserva_get_paginado(uuid, integer, integer, text);

-- Recreate bbtk_reserva_create (Final Version)
CREATE OR REPLACE FUNCTION public.bbtk_reserva_create(
    p_copia_uuid uuid,
    p_id_empresa uuid,
    p_data_inicio timestamptz DEFAULT CURRENT_TIMESTAMP
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
DECLARE
    v_user_uuid uuid;
    v_data_prevista timestamptz;
BEGIN
    -- Resolve user_expandido.id for the currently authenticated user
    SELECT id INTO v_user_uuid
    FROM public.user_expandido
    WHERE user_id = auth.uid()
    LIMIT 1;

    -- Raise exception if profile not found
    IF v_user_uuid IS NULL THEN
        RAISE EXCEPTION 'Perfil de usuário não encontrado para o usuário logado.';
    END IF;
    
    -- Calculate expected return date (7 days default)
    v_data_prevista := p_data_inicio + INTERVAL '7 days';

    -- Insert into history with audit fields
    INSERT INTO public.bbtk_historico_interacao (
        uuid,
        copia_uuid,
        user_uuid,
        tipo_interacao,
        data_inicio,
        data_prevista_devolucao,
        status_reserva,
        id_empresa,
        criado_por,
        criado_em,
        modificado_por,
        modificado_em
    ) VALUES (
        gen_random_uuid(),
        p_copia_uuid,
        v_user_uuid,
        'Reserva'::public.bbtk_tipo_interacao,
        p_data_inicio,
        v_data_prevista,
        'Reservado'::public.bbtk_status_reserva,
        p_id_empresa,
        v_user_uuid, -- criado_por
        NOW(),       -- criado_em
        v_user_uuid, -- modificado_por
        NOW()        -- modificado_em
    );

    -- Update copy status
    UPDATE public.bbtk_inventario_copia
    SET status_copia = 'Reservado'::public.bbtk_status_copia
    WHERE uuid = p_copia_uuid;

END;
$function$;

-- Recreate bbtk_reserva_get_paginado (Final Version)
CREATE OR REPLACE FUNCTION public.bbtk_reserva_get_paginado(
    p_id_empresa uuid,
    p_offset integer,
    p_limit integer,
    p_filtro text
)
RETURNS json
LANGUAGE plpgsql
AS $function$
DECLARE
    v_total integer;
    v_result json;
BEGIN
    SELECT count(*)
    INTO v_total
    FROM bbtk_historico_interacao hi
    JOIN bbtk_inventario_copia cop ON hi.copia_uuid = cop.uuid
    JOIN bbtk_edicao ed ON cop.edicao_uuid = ed.uuid
    JOIN bbtk_obra ob ON ed.obra_uuid = ob.uuid
    LEFT JOIN user_expandido ue ON hi.user_uuid = ue.id
    WHERE hi.id_empresa = p_id_empresa
      AND hi.tipo_interacao = 'Reserva'
      AND (
          p_filtro IS NULL OR
          ob.titulo_principal ILIKE '%' || p_filtro || '%' OR
          ue.nome_completo ILIKE '%' || p_filtro || '%'
      );

    SELECT json_agg(t) INTO v_result
    FROM (
        SELECT
            hi.uuid,
            hi.data_inicio,
            hi.data_prevista_devolucao,
            hi.data_fim,
            hi.status_reserva,
            hi.criado_em,
            hi.criado_por,
            hi.modificado_em,
            hi.modificado_por,
            hi.recebido_em,
            hi.recebido_por,
            ob.titulo_principal as livro_titulo,
            ed.arquivo_capa as livro_capa,
            ue.nome_completo as usuario_nome,
            ue.matricula as usuario_matricula,
            CASE
                WHEN hi.status_reserva = 'Entregue' THEN 'Entregue'
                WHEN hi.status_reserva = 'Cancelado' THEN 'Cancelado'
                WHEN hi.status_reserva = 'Reservado' AND hi.data_prevista_devolucao < CURRENT_TIMESTAMP THEN 'Atrasado'
                ELSE 'No Prazo'
            END as status_calculado
        FROM bbtk_historico_interacao hi
        JOIN bbtk_inventario_copia cop ON hi.copia_uuid = cop.uuid
        JOIN bbtk_edicao ed ON cop.edicao_uuid = ed.uuid
        JOIN bbtk_obra ob ON ed.obra_uuid = ob.uuid
        LEFT JOIN user_expandido ue ON hi.user_uuid = ue.id
        WHERE hi.id_empresa = p_id_empresa
          AND hi.tipo_interacao = 'Reserva'
          AND (
              p_filtro IS NULL OR
              ob.titulo_principal ILIKE '%' || p_filtro || '%' OR
              ue.nome_completo ILIKE '%' || p_filtro || '%'
          )
        ORDER BY 
            CASE 
                WHEN hi.status_reserva = 'Reservado' THEN 0 
                ELSE 1 
            END,
            hi.data_inicio DESC
        LIMIT p_limit OFFSET p_offset
    ) t;

    RETURN json_build_object('total', v_total, 'data', COALESCE(v_result, '[]'::json));
END;
$function$;
