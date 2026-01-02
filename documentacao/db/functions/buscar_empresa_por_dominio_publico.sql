CREATE OR REPLACE FUNCTION public.buscar_empresa_por_dominio_publico(
    p_dominio text DEFAULT NULL
)
RETURNS TABLE (
    empresa_id uuid,
    nome text,
    logo_pequeno text,
    logo_grande text,
    dominio text
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
BEGIN
    RETURN QUERY
    SELECT
        e.id AS empresa_id,
        e.nome,
        e.logo_fechado AS logo_pequeno, -- Mapeando para o nome que você usou
        e.logo_aberto AS logo_grande,   -- Mapeando para o nome que você usou
        e.dominio
    FROM
        public.empresa e
    WHERE
        e.dominio = p_dominio
    LIMIT 1;

END;
$function$;

-- Opcional: Grant de execução para o papel 'anon' (necessário para acesso público)
GRANT EXECUTE ON FUNCTION public.buscar_empresa_por_dominio_publico(text) TO anon;