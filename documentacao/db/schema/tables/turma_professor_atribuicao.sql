SELECT *
FROM public.professor_componente
WHERE id_empresa = 'db5a4c52-074f-47c2-9aba-ac89111039d9'
;

--
-- PostgreSQL database dump
--

\restrict 61TL3hVxdsfXHfossNhKUC2yPogA0IjQGJmNYEDyGotZDLDm3S1YKLgU7aw3L1P

-- Dumped from database version 15.8
-- Dumped by pg_dump version 17.7 (Debian 17.7-0+deb13u1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_table_access_method = heap;

--
-- Name: turma_professor_atribuicao; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.turma_professor_atribuicao (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    id_turma uuid NOT NULL,
    id_empresa uuid NOT NULL,
    ano smallint NOT NULL,
    id_professor uuid NOT NULL,
    data_inicio date NOT NULL,
    data_fim date,
    motivo_substituicao text,
    nivel_substituicao integer DEFAULT 0,
    created_at timestamp with time zone DEFAULT now(),
    editando_por uuid,
    editando_email text
);


--
-- Name: turma_professor_atribuicao turma_professor_atribuicao_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.turma_professor_atribuicao
    ADD CONSTRAINT turma_professor_atribuicao_pkey PRIMARY KEY (id);


--
-- Name: atp_id_turma_id_empresa_data_fim_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX atp_id_turma_id_empresa_data_fim_idx ON public.turma_professor_atribuicao USING btree (id_turma, id_empresa, data_fim);


--
-- Name: idx_atp_id_professor; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_atp_id_professor ON public.turma_professor_atribuicao USING btree (id_professor);


--
-- Name: idx_atp_id_turma_nivel; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_atp_id_turma_nivel ON public.turma_professor_atribuicao USING btree (id_turma, nivel_substituicao);


--
-- Name: turma_prof_atrib_prof_empresa_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX turma_prof_atrib_prof_empresa_idx ON public.turma_professor_atribuicao USING btree (id_professor, id_empresa);


--
-- Name: turma_prof_atrib_turma_empresa_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX turma_prof_atrib_turma_empresa_idx ON public.turma_professor_atribuicao USING btree (id_turma, id_empresa);


--
-- Name: turma_professor_atribuicao turma_professor_atribuicao_id_empresa_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.turma_professor_atribuicao
    ADD CONSTRAINT turma_professor_atribuicao_id_empresa_fkey FOREIGN KEY (id_empresa) REFERENCES public.empresa(id) ON DELETE CASCADE;


--
-- Name: turma_professor_atribuicao turma_professor_atribuicao_id_professor_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.turma_professor_atribuicao
    ADD CONSTRAINT turma_professor_atribuicao_id_professor_fkey FOREIGN KEY (id_professor) REFERENCES public.user_expandido(id) ON DELETE CASCADE;


--
-- Name: turma_professor_atribuicao turma_professor_atribuicao_id_turma_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.turma_professor_atribuicao
    ADD CONSTRAINT turma_professor_atribuicao_id_turma_fkey FOREIGN KEY (id_turma) REFERENCES public.turmas(id) ON DELETE CASCADE;


--
-- Name: turma_professor_atribuicao Admin pode tudo nas atribuições da sua empresa; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admin pode tudo nas atribuições da sua empresa" ON public.turma_professor_atribuicao TO authenticated USING ((((auth.jwt() ->> 'papeis_user'::text) = 'admin'::text) AND (((auth.jwt() ->> 'empresa_id'::text))::uuid = id_empresa))) WITH CHECK ((((auth.jwt() ->> 'papeis_user'::text) = 'admin'::text) AND (((auth.jwt() ->> 'empresa_id'::text))::uuid = id_empresa)));


--
-- Name: turma_professor_atribuicao admin_tpa_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY admin_tpa_all ON public.turma_professor_atribuicao TO authenticated USING ((((auth.jwt() ->> 'papeis_user'::text) = 'admin'::text) AND (((auth.jwt() ->> 'empresa_id'::text))::uuid = id_empresa))) WITH CHECK ((((auth.jwt() ->> 'papeis_user'::text) = 'admin'::text) AND (((auth.jwt() ->> 'empresa_id'::text))::uuid = id_empresa)));


--
-- Name: turma_professor_atribuicao prof_ver_suas_atribuicoes; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY prof_ver_suas_atribuicoes ON public.turma_professor_atribuicao FOR SELECT TO authenticated USING ((((auth.jwt() ->> 'papeis_user'::text) = ANY (ARRAY['professor'::text, 'professor_funcao_extra'::text])) AND (((auth.jwt() ->> 'empresa_id'::text))::uuid = id_empresa) AND (id_professor IN ( SELECT ue.id
   FROM public.user_expandido ue
  WHERE (ue.user_id = auth.uid())))));


--
-- Name: turma_professor_atribuicao; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.turma_professor_atribuicao ENABLE ROW LEVEL SECURITY;

--
-- PostgreSQL database dump complete
--

\unrestrict 61TL3hVxdsfXHfossNhKUC2yPogA0IjQGJmNYEDyGotZDLDm3S1YKLgU7aw3L1P

