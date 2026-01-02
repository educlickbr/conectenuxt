CREATE OR REPLACE FUNCTION public.bbtk_inventario_copia_upsert;
CREATE OR REPLACE FUNCTION public.bbtk_inventario_copia_upsert(
    p_id_empresa uuid,
    p_edicao_uuid uuid,
    p_estante_uuid uuid,
    p_status_copia text,
    p_doacao_ou_compra text,
    p_avaria_flag boolean DEFAULT false,
    p_descricao_avaria text DEFAULT NULL,
    p_quantidade integer DEFAULT 1,
    p_uuid uuid DEFAULT NULL,
    p_registro_bibliotecario text DEFAULT NULL,
    p_soft_delete boolean DEFAULT false
)
RETURNS json
LANGUAGE plpgsql
AS $function$
DECLARE
    v_uuid uuid;
    v_registro text;
    i integer;
    v_inserted_count integer := 0;
BEGIN
    -- Caso de Atualização (Update)
    IF p_uuid IS NOT NULL THEN
        UPDATE public.bbtk_inventario_copia
        SET
            estante_uuid = p_estante_uuid,
            status_copia = p_status_copia::public.bbtk_status_copia,
            doacao_ou_compra = p_doacao_ou_compra,
            avaria_flag = p_avaria_flag,
            descricao_avaria = p_descricao_avaria,
            registro_bibliotecario = COALESCE(p_registro_bibliotecario, registro_bibliotecario),
            soft_delete = p_soft_delete
        WHERE uuid = p_uuid
          AND id_empresa = p_id_empresa;

        IF FOUND THEN
            RETURN json_build_object('success', true, 'message', 'Cópia atualizada com sucesso', 'id', p_uuid);
        ELSE
             RETURN json_build_object('success', false, 'message', 'Cópia não encontrada ou pertence a outra empresa');
        END IF;

    -- Caso de Inserção (Insert)
    ELSE
        FOR i IN 1..p_quantidade LOOP
            v_uuid := gen_random_uuid();
            
            -- Gerar registro bibliotecário se não fornecido ou se quantidade > 1
            IF p_registro_bibliotecario IS NOT NULL AND p_quantidade = 1 THEN
                v_registro := p_registro_bibliotecario;
            ELSE
                -- Gera um código único baseado em prefixo 'REG-' mais parte de UUID para garantir unicidade
                v_registro := 'REG-' || SUBSTRING(gen_random_uuid()::text, 1, 12);
            END IF;

            INSERT INTO public.bbtk_inventario_copia (
                uuid,
                id_empresa,
                edicao_uuid,
                estante_uuid,
                registro_bibliotecario,
                status_copia,
                doacao_ou_compra,
                avaria_flag,
                descricao_avaria,
                soft_delete
            ) VALUES (
                v_uuid,
                p_id_empresa,
                p_edicao_uuid,
                p_estante_uuid,
                v_registro,
                p_status_copia::public.bbtk_status_copia,
                p_doacao_ou_compra,
                p_avaria_flag,
                p_descricao_avaria,
                p_soft_delete
            );
            
            v_inserted_count := v_inserted_count + 1;
        END LOOP;

        RETURN json_build_object(
            'success', true, 
            'message', format('%s cópia(s) criada(s) com sucesso', v_inserted_count),
            'qtd_criada', v_inserted_count
        );
    END IF;

EXCEPTION WHEN OTHERS THEN
    RETURN json_build_object('success', false, 'message', SQLERRM);
END;
$function$;

ALTER FUNCTION public.bbtk_inventario_copia_upsert(uuid, uuid, uuid, text, text, boolean, text, integer, uuid, text, boolean)
    OWNER TO postgres;
