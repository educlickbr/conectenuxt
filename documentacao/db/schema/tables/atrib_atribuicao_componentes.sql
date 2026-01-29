--
-- PostgreSQL database dump
--

\restrict hi6gRvuF7cxrKJRspVKZAJ1CgXAw6p5PmQdWZo2gf8VFtg7XmEvsc3xgYy0GnAa

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
-- Name: atrib_atribuicao_componentes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.atrib_atribuicao_componentes (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    id_turma uuid NOT NULL,
    id_carga_horaria uuid NOT NULL,
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
-- Name: atrib_atribuicao_componentes atrib_atribuicao_componentes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.atrib_atribuicao_componentes
    ADD CONSTRAINT atrib_atribuicao_componentes_pkey PRIMARY KEY (id);


--
-- Name: atrib_comp_prof_empresa_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX atrib_comp_prof_empresa_idx ON public.atrib_atribuicao_componentes USING btree (id_professor, id_empresa);


--
-- Name: atrib_comp_prof_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX atrib_comp_prof_idx ON public.atrib_atribuicao_componentes USING btree (id_professor);


--
-- Name: atrib_comp_turma_ch_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX atrib_comp_turma_ch_idx ON public.atrib_atribuicao_componentes USING btree (id_turma, id_carga_horaria);


--
-- Name: atrib_atribuicao_componentes atrib_atribuicao_componentes_id_ch_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.atrib_atribuicao_componentes
    ADD CONSTRAINT atrib_atribuicao_componentes_id_ch_fkey FOREIGN KEY (id_carga_horaria) REFERENCES public.carga_horaria(uuid) ON DELETE CASCADE;


--
-- Name: atrib_atribuicao_componentes atrib_atribuicao_componentes_id_empresa_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.atrib_atribuicao_componentes
    ADD CONSTRAINT atrib_atribuicao_componentes_id_empresa_fkey FOREIGN KEY (id_empresa) REFERENCES public.empresa(id) ON DELETE CASCADE;


--
-- Name: atrib_atribuicao_componentes atrib_atribuicao_componentes_id_professor_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.atrib_atribuicao_componentes
    ADD CONSTRAINT atrib_atribuicao_componentes_id_professor_fkey FOREIGN KEY (id_professor) REFERENCES public.user_expandido(id) ON DELETE CASCADE;


--
-- Name: atrib_atribuicao_componentes atrib_atribuicao_componentes_id_turma_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.atrib_atribuicao_componentes
    ADD CONSTRAINT atrib_atribuicao_componentes_id_turma_fkey FOREIGN KEY (id_turma) REFERENCES public.turmas(id) ON DELETE CASCADE;


--
-- Name: atrib_atribuicao_componentes Admin pode tudo em atrib_componentes; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admin pode tudo em atrib_componentes" ON public.atrib_atribuicao_componentes TO authenticated USING ((((auth.jwt() ->> 'papeis_user'::text) = 'admin'::text) AND (((auth.jwt() ->> 'empresa_id'::text))::uuid = id_empresa))) WITH CHECK ((((auth.jwt() ->> 'papeis_user'::text) = 'admin'::text) AND (((auth.jwt() ->> 'empresa_id'::text))::uuid = id_empresa)));


--
-- Name: atrib_atribuicao_componentes Professor ve suas atrib_componentes; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Professor ve suas atrib_componentes" ON public.atrib_atribuicao_componentes FOR SELECT TO authenticated USING ((((auth.jwt() ->> 'papeis_user'::text) = ANY (ARRAY['professor'::text, 'professor_funcao_extra'::text])) AND (((auth.jwt() ->> 'empresa_id'::text))::uuid = id_empresa) AND (id_professor IN ( SELECT ue.id
   FROM public.user_expandido ue
  WHERE (ue.user_id = auth.uid())))));


--
-- Name: atrib_atribuicao_componentes; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.atrib_atribuicao_componentes ENABLE ROW LEVEL SECURITY;

--
-- PostgreSQL database dump complete
--

\unrestrict hi6gRvuF7cxrKJRspVKZAJ1CgXAw6p5PmQdWZo2gf8VFtg7XmEvsc3xgYy0GnAa

