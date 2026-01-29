--
-- PostgreSQL database dump
--

\restrict aZGdgUM7z6Eybao8d3hEWreFjPRE1JOJp2PzASHFk3kPTUonwAtSTFgSRFxbuL3

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
-- Name: atrib_atribuicao_turmas; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.atrib_atribuicao_turmas (
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
-- Name: atrib_atribuicao_turmas atrib_atribuicao_turmas_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.atrib_atribuicao_turmas
    ADD CONSTRAINT atrib_atribuicao_turmas_pkey PRIMARY KEY (id);


--
-- Name: atrib_turmas_id_professor_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX atrib_turmas_id_professor_idx ON public.atrib_atribuicao_turmas USING btree (id_professor);


--
-- Name: atrib_turmas_id_turma_empresa_fim_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX atrib_turmas_id_turma_empresa_fim_idx ON public.atrib_atribuicao_turmas USING btree (id_turma, id_empresa, data_fim);


--
-- Name: atrib_turmas_prof_empresa_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX atrib_turmas_prof_empresa_idx ON public.atrib_atribuicao_turmas USING btree (id_professor, id_empresa);


--
-- Name: atrib_atribuicao_turmas atrib_atribuicao_turmas_id_empresa_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.atrib_atribuicao_turmas
    ADD CONSTRAINT atrib_atribuicao_turmas_id_empresa_fkey FOREIGN KEY (id_empresa) REFERENCES public.empresa(id) ON DELETE CASCADE;


--
-- Name: atrib_atribuicao_turmas atrib_atribuicao_turmas_id_professor_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.atrib_atribuicao_turmas
    ADD CONSTRAINT atrib_atribuicao_turmas_id_professor_fkey FOREIGN KEY (id_professor) REFERENCES public.user_expandido(id) ON DELETE CASCADE;


--
-- Name: atrib_atribuicao_turmas atrib_atribuicao_turmas_id_turma_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.atrib_atribuicao_turmas
    ADD CONSTRAINT atrib_atribuicao_turmas_id_turma_fkey FOREIGN KEY (id_turma) REFERENCES public.turmas(id) ON DELETE CASCADE;


--
-- Name: atrib_atribuicao_turmas Admin pode tudo em atrib_turmas; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admin pode tudo em atrib_turmas" ON public.atrib_atribuicao_turmas TO authenticated USING ((((auth.jwt() ->> 'papeis_user'::text) = 'admin'::text) AND (((auth.jwt() ->> 'empresa_id'::text))::uuid = id_empresa))) WITH CHECK ((((auth.jwt() ->> 'papeis_user'::text) = 'admin'::text) AND (((auth.jwt() ->> 'empresa_id'::text))::uuid = id_empresa)));


--
-- Name: atrib_atribuicao_turmas Professor ve suas atrib_turmas; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Professor ve suas atrib_turmas" ON public.atrib_atribuicao_turmas FOR SELECT TO authenticated USING ((((auth.jwt() ->> 'papeis_user'::text) = ANY (ARRAY['professor'::text, 'professor_funcao_extra'::text])) AND (((auth.jwt() ->> 'empresa_id'::text))::uuid = id_empresa) AND (id_professor IN ( SELECT ue.id
   FROM public.user_expandido ue
  WHERE (ue.user_id = auth.uid())))));


--
-- Name: atrib_atribuicao_turmas; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.atrib_atribuicao_turmas ENABLE ROW LEVEL SECURITY;

--
-- PostgreSQL database dump complete
--

\unrestrict aZGdgUM7z6Eybao8d3hEWreFjPRE1JOJp2PzASHFk3kPTUonwAtSTFgSRFxbuL3

