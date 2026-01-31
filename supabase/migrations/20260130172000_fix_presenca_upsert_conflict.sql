-- Fix diario_presenca_upsert_batch to correctly handle ON CONFLICT
-- The previous version referenced a constraint "idx_diario_presenca_unique" which is actually an INDEX, not a CONSTRAINT.
-- We must use the exact expression definition of the unique index to target it in ON CONFLICT.

DROP FUNCTION IF EXISTS public.diario_presenca_upsert_batch(jsonb, uuid);

CREATE OR REPLACE FUNCTION public.diario_presenca_upsert_batch(
    p_payload jsonb,
    p_id_empresa uuid
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_item jsonb;
    v_count integer := 0;
    v_user_id uuid;
    v_componentes_dia jsonb;
    v_componente jsonb;
    v_id_turma uuid;
    v_data date;
    v_status tipo_presenca_enum;
    v_observacao text;
BEGIN
    -- Iterate over the array
    FOR v_item IN SELECT * FROM jsonb_array_elements(p_payload)
    LOOP
        v_user_id := (v_item ->> 'id_usuario')::uuid;
        v_id_turma := (v_item ->> 'id_turma')::uuid;
        v_data := (v_item ->> 'data')::date;
        v_status := coalesce((v_item ->> 'status')::public.tipo_presenca_enum, 'P'::public.tipo_presenca_enum);
        v_observacao := (v_item ->> 'observacao');

        -- Check if this is "dia inteiro" (id_componente is null OR empty string in payload)
        IF (v_item ->> 'id_componente') IS NULL OR (v_item ->> 'id_componente') = '' THEN
            -- Get components for this day using diario_validar_dia
            SELECT componentes INTO v_componentes_dia
            FROM diario_validar_dia(p_id_empresa, v_id_turma, v_data);

            -- If no components found, skip this item
            IF v_componentes_dia IS NULL OR v_componentes_dia = '[]'::jsonb THEN
                CONTINUE;
            END IF;

            -- Loop through each component and create individual attendance records
            FOR v_componente IN SELECT * FROM jsonb_array_elements(v_componentes_dia)
            LOOP
                INSERT INTO public.diario_presenca (
                    id,
                    id_empresa,
                    id_matricula,
                    id_turma,
                    id_componente,
                    data,
                    status,
                    observacao,
                    registrado_por,
                    registrado_em
                )
                VALUES (
                    gen_random_uuid(),
                    p_id_empresa,
                    (v_item ->> 'id_matricula')::uuid,
                    v_id_turma,
                    (v_componente ->> 'id')::uuid,  -- Component ID from the loop
                    v_data,
                    v_status,
                    v_observacao,
                    v_user_id,
                    now()
                )
                -- Match the unique index definition: (id_matricula, id_turma, data, COALESCE(id_componente, '00000000-0000-0000-0000-000000000000'))
                ON CONFLICT (id_matricula, id_turma, data, COALESCE(id_componente, '00000000-0000-0000-0000-000000000000'::uuid)) 
                DO UPDATE
                SET
                    status = EXCLUDED.status,
                    observacao = EXCLUDED.observacao,
                    registrado_por = EXCLUDED.registrado_por,
                    registrado_em = now()
                WHERE public.diario_presenca.id_empresa = p_id_empresa;

                v_count := v_count + 1;
            END LOOP;
        ELSE
            -- Single component attendance (original logic)
            INSERT INTO public.diario_presenca (
                id,
                id_empresa,
                id_matricula,
                id_turma,
                id_componente,
                data,
                status,
                observacao,
                registrado_por,
                registrado_em
            )
            VALUES (
                coalesce(nullif(v_item ->> 'id', '')::uuid, gen_random_uuid()),
                p_id_empresa,
                (v_item ->> 'id_matricula')::uuid,
                v_id_turma,
                (v_item ->> 'id_componente')::uuid,
                v_data,
                v_status,
                v_observacao,
                v_user_id,
                now()
            )
            -- Use the same unique index conflict target for consistency, or ID if available. 
            -- But frontend often sends ephemeral IDs. Business key conflict is safer.
            ON CONFLICT (id_matricula, id_turma, data, COALESCE(id_componente, '00000000-0000-0000-0000-000000000000'::uuid))
            DO UPDATE
            SET
                status = EXCLUDED.status,
                observacao = EXCLUDED.observacao,
                registrado_por = EXCLUDED.registrado_por,
                registrado_em = now()
            WHERE public.diario_presenca.id_empresa = p_id_empresa;

            v_count := v_count + 1;
        END IF;
    END LOOP;

    RETURN jsonb_build_object('status', 'success', 'processed_count', v_count);
END;
$$;

GRANT EXECUTE ON FUNCTION public.diario_presenca_upsert_batch(jsonb, uuid) TO authenticated;
