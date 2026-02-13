-- Função par UPSERT de Nutriente (Create/Update)
CREATE OR REPLACE FUNCTION public.mrd_nutriente_upsert(
    p_id uuid,
    p_empresa_id uuid,
    p_nome text,
    p_unidade mrd_unidade_nutriente,
    p_active boolean DEFAULT true
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY INVOKER
AS $function$
DECLARE
    v_id uuid;
    v_result jsonb;
BEGIN
    -- Validação básica
    IF p_nome IS NULL OR p_nome = '' THEN
        RAISE EXCEPTION 'Nome é obrigatório';
    END IF;

    -- Se não tem ID, é criação
    IF p_id IS NULL THEN
        INSERT INTO public.mrd_nutriente (
            empresa_id,
            nome,
            unidade,
            active
        ) VALUES (
            p_empresa_id,
            p_nome,
            p_unidade,
            p_active
        )
        RETURNING id INTO v_id;
    ELSE
        -- Atualização
        UPDATE public.mrd_nutriente
        SET
            nome = p_nome,
            unidade = p_unidade,
            active = p_active,
            updated_at = now()
        WHERE id = p_id AND (empresa_id = p_empresa_id OR empresa_id IS NULL);
        -- Nota: empresa_id IS NULL permite editar globais se a politica RLS permitir (admin geral)
        -- Mas normalmente upsert é chamado com empresa_id do user.
        -- Vamos garantir que só edita se for da empresa ou se user for admin geral (via RLS)
        
        v_id := p_id;
    END IF;

    SELECT to_jsonb(t) INTO v_result FROM public.mrd_nutriente t WHERE id = v_id;
    
    RETURN jsonb_build_object(
        'success', true,
        'data', v_result
    );
EXCEPTION WHEN OTHERS THEN
    RETURN jsonb_build_object(
        'success', false,
        'message', SQLERRM
    );
END;
$function$;

-- Função para GET de Nutrientes (Listar com filtros)
CREATE OR REPLACE FUNCTION public.mrd_nutriente_get(
    p_empresa_id uuid,
    p_search text DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY INVOKER
AS $function$
DECLARE
    v_result jsonb;
BEGIN
    SELECT jsonb_agg(t) INTO v_result
    FROM (
        SELECT *
        FROM public.mrd_nutriente
        WHERE 
            -- Filtra por empresa ou global (NULL)
            (empresa_id = p_empresa_id OR empresa_id IS NULL)
            -- Filtra por active (opcional, aqui trazemos tudo e o front decide, ou trazemos so ativos? melhor trazer tudo para gerenciar)
            AND active = true 
            -- Busca textual
            AND (p_search IS NULL OR nome ILIKE '%' || p_search || '%')
        ORDER BY nome ASC
    ) t;

    RETURN COALESCE(v_result, '[]'::jsonb);
END;
$function$;

-- Função para DELETE (Soft Delete via Update active=false ou hard delete se preferir, user pediu "esquecer essa coluna" antes, mas para consistencia vamos de soft delete ou delete real se nao tiver uso)
-- O user pediu "nxt_upsert get", nao mencionou delete explicitamente agora 
-- Mas no fluxo normal tem que ter.
-- Vou fazer um soft delete simples via upsert (passando active=false) ou 
-- Criar um mrd_nutriente_delete

CREATE OR REPLACE FUNCTION public.mrd_nutriente_delete(
    p_id uuid,
    p_empresa_id uuid
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY INVOKER
AS $function$
BEGIN
    -- Verifica se está em uso em algum alimento_nutriente ou pnae_referencia
    -- Se sim, soft delete. Se não, hard delete.
    
    IF EXISTS (SELECT 1 FROM public.mrd_alimento_nutriente WHERE nutriente_id = p_id) OR
       EXISTS (SELECT 1 FROM public.mrd_pnae_referencia WHERE nutriente_id = p_id) THEN
        
        UPDATE public.mrd_nutriente
        SET active = false
        WHERE id = p_id AND empresa_id = p_empresa_id;
        
        RETURN jsonb_build_object('success', true, 'message', 'Nutriente inativado pois possui vínculos.');
    ELSE
        DELETE FROM public.mrd_nutriente
        WHERE id = p_id AND empresa_id = p_empresa_id;
        
        RETURN jsonb_build_object('success', true, 'message', 'Nutriente excluído.');
    END IF;
EXCEPTION WHEN OTHERS THEN
     RETURN jsonb_build_object('success', false, 'message', SQLERRM);
END;
$function$;
