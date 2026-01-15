-- Migration: Update diario_presenca to use enum status ('P', 'F', 'A') instead of boolean
-- Date: 2026-01-14

-- 1. Create Enum
DO $$ BEGIN
    CREATE TYPE public.tipo_presenca_enum AS ENUM ('P', 'F', 'A');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- 2. Alter Table
ALTER TABLE public.diario_presenca ADD COLUMN IF NOT EXISTS status public.tipo_presenca_enum DEFAULT 'P';

-- Migrate existing data (true -> P, false -> F)
UPDATE public.diario_presenca SET status = CASE WHEN presente = true THEN 'P'::public.tipo_presenca_enum ELSE 'F'::public.tipo_presenca_enum END;

-- Drop boolean column
ALTER TABLE public.diario_presenca DROP COLUMN IF EXISTS presente;

-- 3. Update RPCs

-- 3.1 Update diario_presenca_upsert_batch
DROP FUNCTION IF EXISTS public.diario_presenca_upsert_batch;
CREATE OR REPLACE FUNCTION public.diario_presenca_upsert_batch(
    p_payload jsonb, -- Expects array of objects with 'status' ('P', 'F', 'A')
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
BEGIN
    -- Iterate over the array
    FOR v_item IN SELECT * FROM jsonb_array_elements(p_payload)
    LOOP
        v_user_id := (v_item ->> 'id_usuario')::uuid;

        INSERT INTO public.diario_presenca (
            id,
            id_empresa,
            id_matricula,
            id_turma,
            id_componente,
            data,
            status, -- Changed from presente
            observacao,
            registrado_por,
            registrado_em
        )
        VALUES (
            coalesce(nullif(v_item ->> 'id', '')::uuid, gen_random_uuid()),
            p_id_empresa,
            (v_item ->> 'id_matricula')::uuid,
            (v_item ->> 'id_turma')::uuid,
            (v_item ->> 'id_componente')::uuid,
            (v_item ->> 'data')::date,
            coalesce((v_item ->> 'status')::public.tipo_presenca_enum, 'P'::public.tipo_presenca_enum), -- Changed type cast
            (v_item ->> 'observacao'),
            v_user_id,
            now()
        )
        ON CONFLICT (id) DO UPDATE
        SET
            status = EXCLUDED.status, -- Changed from presente
            observacao = EXCLUDED.observacao,
            registrado_por = v_user_id
        WHERE public.diario_presenca.id_empresa = p_id_empresa;

        v_count := v_count + 1;
    END LOOP;

    RETURN jsonb_build_object('status', 'success', 'processed_count', v_count);
END;
$$;


-- 3.2 Update diario_presenca_get_por_turma
DROP FUNCTION IF EXISTS public.diario_presenca_get_por_turma;
CREATE OR REPLACE FUNCTION public.diario_presenca_get_por_turma(
    p_id_empresa uuid,
    p_id_turma uuid,
    p_data date,
    p_id_componente uuid DEFAULT NULL
)
RETURNS TABLE(
    id_matricula uuid,
    aluno_nome text,
    aluno_avatar text,
    turma_nome text,
    escola_nome text,
    turno_nome text,
    ano_etapa_nome text,
    id_presenca uuid,
    status public.tipo_presenca_enum, -- Changed from boolean
    observacao text,
    data_presenca date,
    registrado_em timestamp with time zone,
    status_matricula text
)
LANGUAGE plpgsql
AS $function$
BEGIN
    RETURN QUERY
    SELECT
        m.id AS id_matricula,
        u.nome_completo AS aluno_nome,
        NULL::text AS aluno_avatar,
        
        -- Joining Context Data
        c.nome AS turma_nome,
        e.nome AS escola_nome,
        he.periodo::text AS turno_nome,
        ae.nome AS ano_etapa_nome,
        
        -- Presence Data
        dp.id AS id_presenca,
        dp.status, -- Changed from presente
        dp.observacao,
        dp.data AS data_presenca,
        dp.registrado_em,
        
        m.status AS status_matricula
    FROM
        public.matricula_turma mt
    JOIN
        public.matriculas m ON m.id = mt.id_matricula
    JOIN
        public.user_expandido u ON u.id = m.id_aluno
    JOIN
        public.turmas t ON t.id = mt.id_turma
    LEFT JOIN 
        public.classe c ON c.id = t.id_classe
    JOIN
        public.escolas e ON e.id = t.id_escola
    LEFT JOIN
        public.horarios_escola he ON he.id = t.id_horario
    JOIN
        public.ano_etapa ae ON ae.id = t.id_ano_etapa

    -- Left Join Presence
    LEFT JOIN
        public.diario_presenca dp ON
            dp.id_matricula = m.id
            AND dp.id_turma = p_id_turma
            AND dp.data = p_data
            AND (
                (p_id_componente IS NULL AND dp.id_componente IS NULL) OR
                (dp.id_componente = p_id_componente)
            )

    WHERE
        mt.id_empresa = p_id_empresa
        AND mt.id_turma = p_id_turma
        AND mt.status = 'ativa'
        AND m.status = 'ativa'
        AND u.soft_delete IS FALSE
        
    ORDER BY
        u.nome_completo ASC;
END;
$function$;
