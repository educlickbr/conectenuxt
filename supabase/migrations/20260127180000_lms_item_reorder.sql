-- Migration: Create Reorder RPC for LMS Items
-- Safe batch update for 'ordem' column only.

CREATE OR REPLACE FUNCTION public.lms_item_reorder(
    p_id_empresa uuid,
    p_items jsonb -- Array of objects: [{id: uuid, ordem: int}, ...]
)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
DECLARE
    item jsonb;
BEGIN
    FOR item IN SELECT * FROM jsonb_array_elements(p_items)
    LOOP
        UPDATE public.lms_item_conteudo
        SET ordem = (item->>'ordem')::integer
        WHERE id = (item->>'id')::uuid
          AND id_empresa = p_id_empresa;
    END LOOP;

    RETURN true;
END;
$function$;
