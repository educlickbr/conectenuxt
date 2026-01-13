-- Migration: Add id_modelo_calendario to ano_etapa and update upsert function
-- Date: 2026-01-11

-- 1. Alter Table
ALTER TABLE public.ano_etapa 
ADD COLUMN IF NOT EXISTS id_modelo_calendario uuid;

DO $$ 
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'ano_etapa_modelo_calendario_fkey') THEN 
        ALTER TABLE public.ano_etapa 
        ADD CONSTRAINT ano_etapa_modelo_calendario_fkey 
        FOREIGN KEY (id_modelo_calendario) 
        REFERENCES public.mtz_modelo_calendario (id) 
        MATCH SIMPLE 
        ON UPDATE NO ACTION 
        ON DELETE RESTRICT;
    END IF; 
END $$;

-- 2. Update Function
CREATE OR REPLACE FUNCTION public.ano_etapa_upsert(p_data jsonb, p_id_empresa uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
    v_id uuid;
    v_ano_etapa_salva public.ano_etapa;
begin
    -- Tenta obter o ID, se não existir, um novo ID será gerado
    v_id := coalesce((p_data ->> 'id')::uuid, gen_random_uuid());

    -- Verifica se a operação é permitida para a empresa
    if not exists (select 1 from public.empresa where id = p_id_empresa) then
        return jsonb_build_object('status', 'error', 'message', 'Empresa não encontrada ou acesso negado.');
    end if;

    -- Executa o UPSERT (INSERT/UPDATE)
    insert into public.ano_etapa as t (
        id, 
        id_empresa, 
        nome, 
        tipo, 
        carg_horaria, 
        title_sharepoint, 
        id_sharepoint,
        id_modelo_calendario
    )
    values (
        v_id,
        p_id_empresa,
        p_data ->> 'nome',
        (p_data ->> 'tipo')::tipo_ano_etapa,
        (p_data ->> 'carg_horaria')::integer,
        p_data ->> 'title_sharepoint',
        p_data ->> 'id_sharepoint',
        (p_data ->> 'id_modelo_calendario')::uuid
    )
    on conflict (id) do update 
    set 
        nome = coalesce(excluded.nome, t.nome),
        tipo = coalesce(excluded.tipo, t.tipo),
        carg_horaria = coalesce(excluded.carg_horaria, t.carg_horaria),
        title_sharepoint = coalesce(excluded.title_sharepoint, t.title_sharepoint),
        id_sharepoint = coalesce(excluded.id_sharepoint, t.id_sharepoint),
        id_modelo_calendario = coalesce(excluded.id_modelo_calendario, t.id_modelo_calendario)
    where t.id_empresa = p_id_empresa -- Garante que o UPDATE só ocorra dentro da empresa correta
    returning * into v_ano_etapa_salva;

    -- Retorna o registro salvo em formato JSON
    return to_jsonb(v_ano_etapa_salva);

exception when others then
    -- Em caso de erro, retorna um JSON de erro estruturado
    return jsonb_build_object(
        'status', 'error',
        'message', SQLERRM,
        'code', SQLSTATE
    );
end;
$function$;
