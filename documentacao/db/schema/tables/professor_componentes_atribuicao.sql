--
-- PostgreSQL database dump
--

\restrict jN0eXDOa9bwkDjhsg5kiagyRS0Uys0KwTF9rrcEmTxe2a5tYat27ucIS6gdexnU

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
-- Name: professor_componentes_atribuicao; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.professor_componentes_atribuicao (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    id_unidade_atribuicao uuid NOT NULL,
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
-- Name: professor_componentes_atribuicao professor_componentes_atribuicao_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.professor_componentes_atribuicao
    ADD CONSTRAINT professor_componentes_atribuicao_pkey PRIMARY KEY (id);


--
-- Name: pca_prof_empresa_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX pca_prof_empresa_idx ON public.professor_componentes_atribuicao USING btree (id_professor, id_empresa);


--
-- Name: pca_prof_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX pca_prof_idx ON public.professor_componentes_atribuicao USING btree (id_professor);


--
-- Name: pca_unid_emp_fim_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX pca_unid_emp_fim_idx ON public.professor_componentes_atribuicao USING btree (id_unidade_atribuicao, id_empresa, data_fim);


--
-- Name: pca_unid_empresa_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX pca_unid_empresa_idx ON public.professor_componentes_atribuicao USING btree (id_unidade_atribuicao, id_empresa);


--
-- Name: pca_unid_nivel_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX pca_unid_nivel_idx ON public.professor_componentes_atribuicao USING btree (id_unidade_atribuicao, nivel_substituicao);


--
-- Name: professor_componentes_atribuicao pca_id_empresa_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.professor_componentes_atribuicao
    ADD CONSTRAINT pca_id_empresa_fk FOREIGN KEY (id_empresa) REFERENCES public.empresa(id) ON DELETE CASCADE;


--
-- Name: professor_componentes_atribuicao pca_id_professor_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.professor_componentes_atribuicao
    ADD CONSTRAINT pca_id_professor_fk FOREIGN KEY (id_professor) REFERENCES public.user_expandido(id) ON DELETE CASCADE;


--
-- Name: professor_componentes_atribuicao pca_id_unidatr_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.professor_componentes_atribuicao
    ADD CONSTRAINT pca_id_unidatr_fk FOREIGN KEY (id_unidade_atribuicao) REFERENCES public.unidade_atribuicao(uuid) ON DELETE CASCADE;


--
-- Name: professor_componentes_atribuicao; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.professor_componentes_atribuicao ENABLE ROW LEVEL SECURITY;

--
-- PostgreSQL database dump complete
--

\unrestrict jN0eXDOa9bwkDjhsg5kiagyRS0Uys0KwTF9rrcEmTxe2a5tYat27ucIS6gdexnU

