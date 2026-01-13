CREATE OR REPLACE FUNCTION public.mtz_matriz_curricular_delete(
    p_id uuid,
    p_id_empresa uuid
)
returns jsonb
language plpgsql
security definer
set search_path to public
as $$
declare
    v_deleted_count integer;
begin
    -- Verificacao de dependencias (Placeholder - adicione constraints especificas se houver)
    -- Exemplo: IF EXISTS (SELECT 1 FROM tabela_filha WHERE pai_id = p_id) THEN ...
    
    delete from public.mtz_matriz_curricular
    where id = p_id
      and id_empresa = p_id_empresa;
      
    get diagnostics v_deleted_count = ROW_COUNT;

    if v_deleted_count > 0 then
        return jsonb_build_object('status', 'success', 'message', 'Registro deletado com sucesso.', 'id', p_id);
    else
        return jsonb_build_object('status', 'error', 'message', 'Registro não encontrado, não pertence à empresa ou possui dependências.', 'id', p_id);
    end if;

exception when others then
    return jsonb_build_object(
        'status', 'error',
        'message', SQLERRM,
        'code', SQLSTATE
    );
end;
$$;
ALTER FUNCTION public.mtz_matriz_curricular_delete(uuid, uuid) OWNER TO postgres;
