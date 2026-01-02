CREATE OR REPLACE FUNCTION public.validar_acesso_matricula(
	p_id_processo uuid)
    RETURNS jsonb
    LANGUAGE sql
    COST 100
    VOLATILE SECURITY DEFINER PARALLEL UNSAFE
AS $BODY$

SELECT
  CASE 
    WHEN p.id IS NULL THEN
      jsonb_build_object('ok', false, 'motivo', 'processo_inexistente')

    WHEN p.user_id <> auth.uid() THEN
      jsonb_build_object('ok', false, 'motivo', 'processo_nao_e_do_usuario')

    WHEN p.status <> 'Aprovado' THEN
      jsonb_build_object('ok', false, 'motivo', 'status_nao_aprovado')

    WHEN t.dt_ini_mat IS NOT NULL AND now() < t.dt_ini_mat THEN
      jsonb_build_object('ok', false, 'motivo', 'antes_do_periodo')

    WHEN t.dt_fim_mat IS NOT NULL AND now() > (t.dt_fim_mat + INTERVAL '1 day') THEN
      jsonb_build_object('ok', false, 'motivo', 'apos_periodo')

    ELSE
      jsonb_build_object('ok', true)
  END AS resultado

FROM processos p
LEFT JOIN turmas t ON t.id = p.turma_id
WHERE p.id = p_id_processo;

$BODY$;

ALTER FUNCTION public.validar_acesso_matricula(p_id_processo uuid)
    OWNER TO postgres;
