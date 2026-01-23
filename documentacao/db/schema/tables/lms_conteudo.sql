--
-- PostgreSQL database dump
--

\restrict guhNQwesFfKIm8rIXUohSwNSai7s1X5avh2hVRbdr8U8Ahmr1IdcXINmLrLqTz0

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
-- Name: lms_conteudo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lms_conteudo (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    id_empresa uuid NOT NULL,
    id_ano_etapa uuid,
    id_turma uuid,
    id_meta_turma uuid,
    id_componente uuid,
    id_aluno uuid,
    titulo text NOT NULL,
    descricao text,
    liberar_por public.liberacao_conteudo_enum DEFAULT 'Conteúdo'::public.liberacao_conteudo_enum NOT NULL,
    escopo text NOT NULL,
    visivel_para_alunos boolean DEFAULT true NOT NULL,
    data_disponivel timestamp with time zone,
    criado_por uuid NOT NULL,
    criado_em timestamp with time zone DEFAULT now(),
    CONSTRAINT lms_conteudo_escopo_check CHECK (((escopo = 'Global'::text) OR ((escopo = 'AnoEtapa'::text) AND (id_ano_etapa IS NOT NULL)) OR ((escopo = 'Turma'::text) AND (id_turma IS NOT NULL)) OR ((escopo = 'Grupo'::text) AND (id_meta_turma IS NOT NULL)) OR ((escopo = 'Componente'::text) AND (id_componente IS NOT NULL)) OR ((escopo = 'Aluno'::text) AND (id_aluno IS NOT NULL)))),
    CONSTRAINT lms_conteudo_escopo_enum_check CHECK ((escopo = ANY (ARRAY['Global'::text, 'AnoEtapa'::text, 'Turma'::text, 'Grupo'::text, 'Componente'::text, 'Aluno'::text])))
);


--
-- Name: lms_conteudo lms_conteudo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lms_conteudo
    ADD CONSTRAINT lms_conteudo_pkey PRIMARY KEY (id);


--
-- Name: lms_conteudo_criado_por_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX lms_conteudo_criado_por_idx ON public.lms_conteudo USING btree (criado_por);


--
-- Name: lms_conteudo_escopo_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX lms_conteudo_escopo_idx ON public.lms_conteudo USING btree (escopo);


--
-- Name: lms_conteudo_id_empresa_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX lms_conteudo_id_empresa_idx ON public.lms_conteudo USING btree (id_empresa);


--
-- Name: lms_conteudo_ids_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX lms_conteudo_ids_idx ON public.lms_conteudo USING btree (id_turma, id_aluno, id_meta_turma, id_componente, id_ano_etapa);


--
-- Name: lms_conteudo lms_conteudo_criado_por_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lms_conteudo
    ADD CONSTRAINT lms_conteudo_criado_por_fkey FOREIGN KEY (criado_por) REFERENCES public.user_expandido(id);


--
-- Name: lms_conteudo lms_conteudo_id_aluno_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lms_conteudo
    ADD CONSTRAINT lms_conteudo_id_aluno_fkey FOREIGN KEY (id_aluno) REFERENCES public.user_expandido(id) ON DELETE CASCADE;


--
-- Name: lms_conteudo lms_conteudo_id_ano_etapa_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lms_conteudo
    ADD CONSTRAINT lms_conteudo_id_ano_etapa_fkey FOREIGN KEY (id_ano_etapa) REFERENCES public.ano_etapa(id);


--
-- Name: lms_conteudo lms_conteudo_id_componente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lms_conteudo
    ADD CONSTRAINT lms_conteudo_id_componente_fkey FOREIGN KEY (id_componente) REFERENCES public.componente(uuid) ON DELETE CASCADE;


--
-- Name: lms_conteudo lms_conteudo_id_empresa_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lms_conteudo
    ADD CONSTRAINT lms_conteudo_id_empresa_fkey FOREIGN KEY (id_empresa) REFERENCES public.empresa(id);


--
-- Name: lms_conteudo lms_conteudo_id_meta_turma_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lms_conteudo
    ADD CONSTRAINT lms_conteudo_id_meta_turma_fkey FOREIGN KEY (id_meta_turma) REFERENCES public.meta_turma(id) ON DELETE CASCADE;


--
-- Name: lms_conteudo lms_conteudo_id_turma_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lms_conteudo
    ADD CONSTRAINT lms_conteudo_id_turma_fkey FOREIGN KEY (id_turma) REFERENCES public.turmas(id) ON DELETE CASCADE;


--
-- Name: lms_conteudo Enable all for authenticated users based on company; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Enable all for authenticated users based on company" ON public.lms_conteudo USING ((id_empresa = ((auth.jwt() ->> 'empresa_id'::text))::uuid)) WITH CHECK ((id_empresa = ((auth.jwt() ->> 'empresa_id'::text))::uuid));


--
-- Name: lms_conteudo; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.lms_conteudo ENABLE ROW LEVEL SECURITY;

--
-- PostgreSQL database dump complete
--

\unrestrict guhNQwesFfKIm8rIXUohSwNSai7s1X5avh2hVRbdr8U8Ahmr1IdcXINmLrLqTz0

