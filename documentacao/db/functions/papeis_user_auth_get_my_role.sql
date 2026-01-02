CREATE OR REPLACE FUNCTION public.papeis_user_auth_get_my_role()
 RETURNS TABLE(papel_id uuid, nome text)
 LANGUAGE sql
AS $function$
    SELECT 
        pu.papel_id,
        p.nome
    FROM 
        papeis_user_auth pu
    JOIN 
        papeis_user p ON pu.papel_id = p.id
    WHERE 
        pu.user_id = auth.uid();
$function$;
