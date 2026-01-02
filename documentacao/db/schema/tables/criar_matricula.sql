DROP FUNCTION IF EXISTS public.criar_matricula;
CREATE OR REPLACE FUNCTION public.criar_matricula(
	p_id_processo uuid
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_user_sessao uuid;          -- usuário logado
  v_user_do_processo uuid;     -- user_id do processo
  v_turma uuid;                -- turma vinculada ao processo
  v_user_expandido uuid;       -- aluno (user_expandido)
  v_dt_ini timestamptz;
  v_dt_fim timestamptz;
  v_status text;
  v_matricula_existente uuid;
  v_matricula_id uuid;
BEGIN
  ---------------------------------------------------------
  -- 1) Usuário logado
  ---------------------------------------------------------
  v_user_sessao := auth.uid();

  ---------------------------------------------------------
  -- 2) Busca do processo
  ---------------------------------------------------------
  SELECT 
      p.user_id,
      p.turma_id,
      p.user_expandido_id,
      p.status,
      t.dt_ini_mat,
      t.dt_fim_mat
  INTO 
      v_user_do_processo,
      v_turma,
      v_user_expandido,
      v_status,
      v_dt_ini,
      v_dt_fim
  FROM processos p
  LEFT JOIN turmas t ON t.id = p.turma_id
  WHERE p.id = p_id_processo;

  IF v_user_do_processo IS NULL THEN
    RETURN jsonb_build_object('ok', false, 'motivo', 'processo_inexistente');
  END IF;

  ---------------------------------------------------------
  -- 3) Processo pertence ao usuário?
  ---------------------------------------------------------
  IF v_user_do_processo <> v_user_sessao THEN
    RETURN jsonb_build_object('ok', false, 'motivo', 'processo_nao_e_do_usuario');
  END IF;

  ---------------------------------------------------------
  -- 4) Status aprovado?
  ---------------------------------------------------------
  IF v_status <> 'Aprovado' THEN
    RETURN jsonb_build_object('ok', false, 'motivo', 'status_nao_aprovado');
  END IF;

  ---------------------------------------------------------
  -- 5) Período permitido (com 1 dia extra no fim)
  ---------------------------------------------------------
  IF v_dt_ini IS NOT NULL AND now() < v_dt_ini THEN
    RETURN jsonb_build_object('ok', false, 'motivo', 'antes_do_periodo');
  END IF;

  IF v_dt_fim IS NOT NULL AND now() > (v_dt_fim + INTERVAL '1 day') THEN
    RETURN jsonb_build_object('ok', false, 'motivo', 'apos_periodo');
  END IF;

  ---------------------------------------------------------
  -- 6) Matrícula já existe?
  ---------------------------------------------------------
  SELECT id INTO v_matricula_existente
  FROM matriculas
  WHERE id_aluno = v_user_expandido
    AND id_turma = v_turma;

  IF v_matricula_existente IS NOT NULL THEN
    -- Atualiza o processo se ainda estiver aprovado
    UPDATE processos 
    SET status = 'Matriculado', modificado_em = now(), modificado_por = v_user_sessao
    WHERE id = p_id_processo AND status = 'Aprovado';

    RETURN jsonb_build_object(
      'ok', true,
      'motivo', 'ja_existe',
      'id_matricula', v_matricula_existente
    );
  END IF;

  ---------------------------------------------------------
  -- 7) Criar matrícula nova
  ---------------------------------------------------------
  INSERT INTO matriculas (id_aluno, id_turma, status)
  VALUES (v_user_expandido, v_turma, 'Ativo')
  RETURNING id INTO v_matricula_id;

  ---------------------------------------------------------
  -- 8) Atualizar processo
  ---------------------------------------------------------
  UPDATE processos
  SET 
    status = 'Matriculado',
    modificado_em = now(),
    modificado_por = v_user_sessao
  WHERE id = p_id_processo;

  ---------------------------------------------------------
  -- 9) Retorno final
  ---------------------------------------------------------
  RETURN jsonb_build_object(
    'ok', true,
    'motivo', 'criada',
    'id_matricula', v_matricula_id
  );

END;
$$;
