create or replace function public.ano_etapa_delete(
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
    -- Deleta o registro, garantindo que pertença à empresa correta
    delete from public.ano_etapa
    where id = p_id
      and id_empresa = p_id_empresa;
      
    get diagnostics v_deleted_count = ROW_COUNT;

    if v_deleted_count > 0 then
        return jsonb_build_object('status', 'success', 'message', 'Registro deletado com sucesso.', 'id', p_id);
    else
        return jsonb_build_object('status', 'error', 'message', 'Registro não encontrado ou não pertence à empresa.', 'id', p_id);
    end if;

exception when others then
    -- Retorna JSON de erro estruturado
    return jsonb_build_object(
        'status', 'error',
        'message', SQLERRM,
        'code', SQLSTATE
    );
end;
$$;
