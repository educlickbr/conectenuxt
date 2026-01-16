-- Migration: Wrapper RPC for BFF compatibility

CREATE OR REPLACE FUNCTION public.avaliacao_aluno_registrar_completa_wrapper(
    p_data jsonb,
    p_id_empresa uuid
)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    v_header jsonb;
    v_respostas jsonb;
BEGIN
    -- Extract header and respostas from the single payload object
    -- Expected p_data structure: { ...header_fields, respostas: [...] }
    
    v_header := p_data - 'respostas';
    v_respostas := p_data -> 'respostas';

    RETURN public.avaliacao_aluno_registrar_completa(p_id_empresa, v_header, v_respostas);
END;
$function$;
ALTER FUNCTION public.avaliacao_aluno_registrar_completa_wrapper(jsonb, uuid) OWNER TO postgres;
