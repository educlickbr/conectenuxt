create or replace function public.bbtk_dim_estante_delete(
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
    -- Delete com JOIN implícito para validar empresa
    delete from public.bbtk_dim_estante e
    using public.bbtk_dim_sala s, public.bbtk_dim_predio p
    where e.sala_uuid = s.uuid
      and s.predio_uuid = p.uuid
      and e.uuid = p_id
      and p.id_empresa = p_id_empresa;
      
    get diagnostics v_deleted_count = ROW_COUNT;

    if v_deleted_count > 0 then
        return jsonb_build_object('status', 'success', 'message', 'Registro deletado com sucesso.', 'id', p_id);
    else
        return jsonb_build_object('status', 'error', 'message', 'Registro não encontrado ou não pertence à empresa.', 'id', p_id);
    end if;

exception when others then
    return jsonb_build_object(
        'status', 'error',
        'message', SQLERRM,
        'code', SQLSTATE
    );
end;
$$;
