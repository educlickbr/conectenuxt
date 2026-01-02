create or replace function public.aluno_delete(
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
    -- Realiza o Soft Delete
    update public.user_expandido
    set soft_delete = true,
        modificado_em = now()
    where id = p_id
      and id_empresa = p_id_empresa;
      
    get diagnostics v_deleted_count = ROW_COUNT;

    if v_deleted_count > 0 then
        return jsonb_build_object(
            'status', 'success', 
            'message', 'Aluno deletado com sucesso (soft delete).', 
            'id', p_id
        );
    else
        return jsonb_build_object(
            'status', 'error', 
            'message', 'Aluno não encontrado ou não pertence à empresa.', 
            'id', p_id
        );
    end if;

exception when others then
    return jsonb_build_object(
        'status', 'error',
        'message', SQLERRM,
        'code', SQLSTATE
    );
end;
$$;

ALTER FUNCTION public.aluno_delete(uuid, uuid)
    OWNER TO postgres;
