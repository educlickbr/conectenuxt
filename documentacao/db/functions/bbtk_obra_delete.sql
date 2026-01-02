CREATE OR REPLACE FUNCTION public.bbtk_obra_delete(
    p_uuid uuid,
    p_id_empresa uuid
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO public
AS $$
DECLARE
    v_deleted_count integer;
BEGIN
    -- Realiza o Soft Delete
    UPDATE public.bbtk_obra
    SET soft_delete = true
    WHERE uuid = p_uuid
      AND id_empresa = p_id_empresa;
      
    GET DIAGNOSTICS v_deleted_count = ROW_COUNT;

    IF v_deleted_count > 0 THEN
        RETURN jsonb_build_object(
            'status', 'success', 
            'message', 'Obra deletada com sucesso (soft delete).', 
            'uuid', p_uuid
        );
    ELSE
        RETURN jsonb_build_object(
            'status', 'error', 
            'message', 'Obra não encontrada ou não pertence à empresa.', 
            'uuid', p_uuid
        );
    END IF;

EXCEPTION WHEN OTHERS THEN
    RETURN jsonb_build_object(
        'status', 'error',
        'message', SQLERRM,
        'code', SQLSTATE
    );
END;
$$;

ALTER FUNCTION public.bbtk_obra_delete(uuid, uuid)
    OWNER TO postgres;
