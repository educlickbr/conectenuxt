-- Migration: Create functions for pl_plano_referencias
-- 1. get_by_aula
-- 2. upsert_batch

-- 1. pl_plano_referencias_get_by_aula
CREATE OR REPLACE FUNCTION public.pl_plano_referencias_get_by_aula(p_id_empresa uuid, p_id_aula uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
    v_itens jsonb;
BEGIN
    SELECT jsonb_agg(t ORDER BY t.criado_em ASC) INTO v_itens
    FROM (
        SELECT r.*,
               coalesce(be.titulo_principal, be.titulo_obra) as titulo,
               be.autor_principal as autor,
               be.capa as capa
        FROM public.pl_plano_referencias r
        LEFT JOIN public.bbtk_edicao be ON be.uuid = r.id_edicao_biblioteca
        WHERE r.id_plano_aula_item = p_id_aula 
          AND r.id_empresa = p_id_empresa
    ) t;
    
    RETURN coalesce(v_itens, '[]'::jsonb);
END;
$function$;
ALTER FUNCTION public.pl_plano_referencias_get_by_aula(uuid, uuid) OWNER TO postgres;

-- 2. pl_plano_referencias_upsert_batch
CREATE OR REPLACE FUNCTION public.pl_plano_referencias_upsert_batch(p_id_empresa uuid, p_id_aula uuid, p_itens jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
    -- Validate Access
    if not exists (select 1 from public.pl_plano_de_aulas_itens where id = p_id_aula and id_empresa = p_id_empresa) then
         return jsonb_build_object('status', 'error', 'message', 'Aula não encontrada ou acesso negado.');
    end if;

    -- Delete existing references for this aula (Clean slate approach)
    DELETE FROM public.pl_plano_referencias 
    WHERE id_plano_aula_item = p_id_aula AND id_empresa = p_id_empresa;

    -- Insert new items
    -- p_itens expected format: [{ "id_edicao_biblioteca": uuid, "descricao": text, ... }]
    IF p_itens IS NOT NULL AND jsonb_array_length(p_itens) > 0 THEN
        INSERT INTO public.pl_plano_referencias (
            id_empresa,
            id_plano_aula_item,
            id_edicao_biblioteca,
            descricao_manual,
            usa_biblioteca_rede,
            criado_por,
            modificado_por
        )
        SELECT 
            p_id_empresa,
            p_id_aula,
            (item ->> 'id_edicao_biblioteca')::uuid,
            item ->> 'descricao',
            coalesce((item ->> 'usa_biblioteca_rede')::boolean, false),
            auth.uid(), -- user from context
            auth.uid()
        FROM jsonb_array_elements(p_itens) AS item;
    END IF;

    RETURN jsonb_build_object('status', 'success', 'message', 'Referências atualizadas com sucesso.');

EXCEPTION WHEN OTHERS THEN
    RETURN jsonb_build_object('status', 'error', 'message', SQLERRM, 'code', SQLSTATE);
END;
$function$;
ALTER FUNCTION public.pl_plano_referencias_upsert_batch(uuid, uuid, jsonb) OWNER TO postgres;
