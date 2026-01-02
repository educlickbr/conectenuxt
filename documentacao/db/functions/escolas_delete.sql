create or replace function public.escolas_delete(
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
    -- Deleta a escola, garantindo que pertença à empresa correta
    delete from public.escolas
    where id = p_id
      and id_empresa = p_id_empresa;
      
    get diagnostics v_deleted_count = ROW_COUNT;

    if v_deleted_count > 0 then
        return jsonb_build_object('status', 'success', 'message', 'Escola deletada com sucesso.', 'id', p_id);
    else
        return jsonb_build_object('status', 'error', 'message', 'Escola não encontrada ou não pertence à empresa.', 'id', p_id);
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