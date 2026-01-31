-- Migration: Create matricula_turma table and allocation RPCs

-- 1. Create Table
CREATE TABLE IF NOT EXISTS public.matricula_turma (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  id_matricula uuid NOT NULL,
  id_turma uuid NOT NULL,
  id_empresa uuid NOT NULL,
  data_entrada date NOT NULL DEFAULT CURRENT_DATE,
  data_saida date NULL,
  status text NOT NULL DEFAULT 'ativa'::text,
  criado_em timestamp with time zone NULL DEFAULT now(),
  CONSTRAINT matricula_turma_pkey PRIMARY KEY (id),
  CONSTRAINT matricula_turma_id_empresa_fkey FOREIGN KEY (id_empresa) REFERENCES empresa (id) ON DELETE CASCADE,
  CONSTRAINT matricula_turma_id_matricula_fkey FOREIGN KEY (id_matricula) REFERENCES matriculas (id) ON DELETE CASCADE,
  CONSTRAINT matricula_turma_id_turma_fkey FOREIGN KEY (id_turma) REFERENCES turmas (id) ON DELETE CASCADE
) TABLESPACE pg_default;

-- Indices
CREATE UNIQUE INDEX IF NOT EXISTS idx_matricula_turma_unica_ativa ON public.matricula_turma USING btree (id_matricula) TABLESPACE pg_default WHERE (status = 'ativa'::text);
CREATE INDEX IF NOT EXISTS idx_matricula_turma_matricula ON public.matricula_turma USING btree (id_matricula) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS idx_matricula_turma_turma ON public.matricula_turma USING btree (id_turma) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS idx_matricula_turma_empresa ON public.matricula_turma USING btree (id_empresa) TABLESPACE pg_default;

-- 2. RPC: Alocar Turma (History Logic)
CREATE OR REPLACE FUNCTION public.matricula_alocar_turma(p_id_empresa uuid, p_data jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    v_id_matricula uuid;
    v_id_turma uuid;
    v_current_active_id uuid;
    v_current_turma_id uuid;
BEGIN
    v_id_matricula := (p_data->>'id_matricula')::uuid;
    v_id_turma := (p_data->>'id_turma')::uuid;

    -- 1. Idempotency Check: Is student already active in this class?
    SELECT id, id_turma INTO v_current_active_id, v_current_turma_id
    FROM public.matricula_turma
    WHERE id_matricula = v_id_matricula 
      AND status = 'ativa';

    IF v_current_turma_id = v_id_turma THEN
        -- Already allocated, do nothing
        RETURN jsonb_build_object('success', true, 'message', 'Aluno já alocado nesta turma.');
    END IF;

    -- 2. Close existing allocation if present
    IF v_current_active_id IS NOT NULL THEN
        UPDATE public.matricula_turma
        SET 
            status = 'transferida',
            data_saida = CURRENT_DATE
        WHERE id = v_current_active_id;
    END IF;

    -- 3. Insert new allocation
    INSERT INTO public.matricula_turma (
        id_empresa,
        id_matricula,
        id_turma,
        data_entrada,
        status
    ) VALUES (
        p_id_empresa,
        v_id_matricula,
        v_id_turma,
        CURRENT_DATE,
        'ativa'
    );

    -- 4. Sync Main Matricula Table (Optional but good for simpler queries)
    -- Assuming matriculas table has id_turma column based on previous context
    UPDATE public.matriculas
    SET id_turma = v_id_turma
    WHERE id = v_id_matricula;

    RETURN jsonb_build_object('success', true);
EXCEPTION WHEN OTHERS THEN
    RETURN jsonb_build_object('success', false, 'message', SQLERRM);
END;
$function$;

-- 3. RPC: Get Historico
CREATE OR REPLACE FUNCTION public.matricula_turma_get_historico(p_id_empresa uuid, p_id_matricula uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
AS $function$
DECLARE
    v_items jsonb;
BEGIN
    SELECT jsonb_agg(
        jsonb_build_object(
            'id', mt.id,
            'id_turma', mt.id_turma,
            'turma_nome', t.nome_turma, -- Using nome_turma standard
            'ano', t.ano,
            'periodo', h.periodo,
            'escola_nome', e.nome,
            'data_entrada', mt.data_entrada,
            'data_saida', mt.data_saida,
            'status', mt.status
        ) ORDER BY mt.data_entrada DESC
    ) INTO v_items
    FROM public.matricula_turma mt
    JOIN public.turmas t ON t.id = mt.id_turma
    LEFT JOIN public.escolas e ON e.id = t.id_escola
    LEFT JOIN public.horarios_escola h ON h.id = t.id_horario
    WHERE mt.id_empresa = p_id_empresa
      AND mt.id_matricula = p_id_matricula;

    RETURN jsonb_build_object('items', COALESCE(v_items, '[]'::jsonb));
END;
$function$;
