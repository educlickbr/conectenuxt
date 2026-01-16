-- Fix: Change valor_numerico to INTEGER and multiply existing values by 100

-- 1. Alter Table
ALTER TABLE public.itens_criterio 
ALTER COLUMN valor_numerico TYPE INTEGER USING (valor_numerico * 100)::INTEGER;

-- 2. Update Upsert Function to accept/cast to INTEGER
CREATE OR REPLACE FUNCTION public.itens_criterio_upsert(p_data jsonb, p_id_empresa uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
    v_id uuid;
    v_registro_salvo public.itens_criterio;
    v_user_id uuid;
begin
    v_id := coalesce((p_data ->> 'id')::uuid, gen_random_uuid());
    v_user_id := (p_data ->> 'id_usuario')::uuid;

    insert into public.itens_criterio as t (
        id, id_empresa, id_modelo_criterio, rotulo, valor_numerico, criado_por, criado_em, modificado_por, modificado_em
    )
    values (
        v_id, 
        p_id_empresa, 
        (p_data ->> 'id_modelo_criterio')::uuid,
        p_data ->> 'rotulo',
        (p_data ->> 'valor_numerico')::integer, -- Changed to integer
        v_user_id, 
        now(), 
        v_user_id, 
        now()
    )
    on conflict (id) do update 
    set rotulo = coalesce(excluded.rotulo, t.rotulo),
        valor_numerico = coalesce(excluded.valor_numerico, t.valor_numerico),
        modificado_por = v_user_id,
        modificado_em = now()
    where t.id_empresa = p_id_empresa
    returning * into v_registro_salvo;

    return to_jsonb(v_registro_salvo);
exception when others then
    return jsonb_build_object('status', 'error', 'message', SQLERRM, 'code', SQLSTATE);
end;
$function$;
ALTER FUNCTION public.itens_criterio_upsert(jsonb, uuid) OWNER TO postgres;
