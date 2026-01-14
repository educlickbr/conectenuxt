-- Fix mismatch: column "tipo" is of type tipo_feriado but expression is of type text
-- Explicitly cast input text to tipo_feriado

DROP FUNCTION IF EXISTS public.mtz_feriados_upsert;
CREATE OR REPLACE FUNCTION public.mtz_feriados_upsert(p_data jsonb, p_id_empresa uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
    v_id uuid;
    v_registro_salvo public.mtz_feriados;
    v_user_id uuid;
begin
    v_id := coalesce((p_data ->> 'id')::uuid, gen_random_uuid());
    v_user_id := (p_data ->> 'id_usuario')::uuid;

    if not exists (select 1 from public.empresa where id = p_id_empresa) then
        return jsonb_build_object('status', 'error', 'message', 'Empresa não encontrada ou acesso negado.');
    end if;
    
    insert into public.mtz_feriados as t (
        id, id_empresa, nome_feriado, tipo, data_inicio, data_fim, criado_por, criado_em, modificado_por, modificado_em
    )
    values (
        v_id, 
        p_id_empresa, 
        p_data ->> 'nome_feriado', 
        (p_data ->> 'tipo')::tipo_feriado, -- CAST HERE
        ((p_data ->> 'data_inicio')::timestamp AT TIME ZONE 'America/Sao_Paulo'), 
        ((p_data ->> 'data_fim')::timestamp AT TIME ZONE 'America/Sao_Paulo'), 
        v_user_id, 
        now(), 
        v_user_id, 
        now()
    )
    on conflict (id) do update 
    set nome_feriado = coalesce(excluded.nome_feriado, t.nome_feriado),
        tipo = coalesce(excluded.tipo, t.tipo),
        data_inicio = coalesce(excluded.data_inicio, t.data_inicio),
        data_fim = coalesce(excluded.data_fim, t.data_fim),
        modificado_por = v_user_id,
        modificado_em = now()
    where t.id_empresa = p_id_empresa
    returning * into v_registro_salvo;

    return to_jsonb(v_registro_salvo);
exception when others then
    return jsonb_build_object('status', 'error', 'message', SQLERRM, 'code', SQLSTATE);
end;
$function$;
ALTER FUNCTION public.mtz_feriados_upsert(jsonb, uuid) OWNER TO postgres;
