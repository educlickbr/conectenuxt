--
-- PostgreSQL database dump
--

\restrict zEvaF6gHUZmQwNUVWRwgy2eEObFEdzT0lD2ZWcEjwebH5QdC0yUiHs0NFBtOTQV

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
-- Name: carga_horaria; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.carga_horaria (
    uuid uuid DEFAULT gen_random_uuid() NOT NULL,
    id_componente uuid NOT NULL,
    id_ano_etapa uuid NOT NULL,
    carga_horaria integer NOT NULL,
    id_empresa uuid NOT NULL,
    criado_por uuid,
    modifica_por uuid,
    criado_em timestamp with time zone DEFAULT now(),
    modificado_em timestamp with time zone DEFAULT now(),
    polivalente boolean DEFAULT false
);


--
-- Name: carga_horaria carga_horaria_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.carga_horaria
    ADD CONSTRAINT carga_horaria_pkey PRIMARY KEY (uuid);


--
-- Name: carga_horaria carga_horaria_unicidade; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.carga_horaria
    ADD CONSTRAINT carga_horaria_unicidade UNIQUE (id_empresa, id_ano_etapa, id_componente);


--
-- Name: ix_ch_ano; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_ch_ano ON public.carga_horaria USING btree (id_ano_etapa);


--
-- Name: ix_ch_comp; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_ch_comp ON public.carga_horaria USING btree (id_componente);


--
-- Name: ix_ch_empresa; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_ch_empresa ON public.carga_horaria USING btree (id_empresa);


--
-- Name: carga_horaria carga_horaria_criado_por_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.carga_horaria
    ADD CONSTRAINT carga_horaria_criado_por_fkey FOREIGN KEY (criado_por) REFERENCES public.user_expandido(id) ON DELETE SET NULL;


--
-- Name: carga_horaria carga_horaria_id_ano_etapa_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.carga_horaria
    ADD CONSTRAINT carga_horaria_id_ano_etapa_fkey FOREIGN KEY (id_ano_etapa) REFERENCES public.ano_etapa(id) ON DELETE CASCADE;


--
-- Name: carga_horaria carga_horaria_id_componente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.carga_horaria
    ADD CONSTRAINT carga_horaria_id_componente_fkey FOREIGN KEY (id_componente) REFERENCES public.componente(uuid) ON DELETE CASCADE;


--
-- Name: carga_horaria carga_horaria_id_empresa_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.carga_horaria
    ADD CONSTRAINT carga_horaria_id_empresa_fkey FOREIGN KEY (id_empresa) REFERENCES public.empresa(id) ON DELETE CASCADE;


--
-- Name: carga_horaria carga_horaria_modifica_por_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.carga_horaria
    ADD CONSTRAINT carga_horaria_modifica_por_fkey FOREIGN KEY (modifica_por) REFERENCES public.user_expandido(id) ON DELETE SET NULL;


--
-- Name: carga_horaria admin pode tudo; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "admin pode tudo" ON public.carga_horaria TO authenticated USING (((auth.jwt() ->> 'papeis_user'::text) = 'admin'::text)) WITH CHECK (((auth.jwt() ->> 'papeis_user'::text) = 'admin'::text));


--
-- Name: carga_horaria; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.carga_horaria ENABLE ROW LEVEL SECURITY;

--
-- PostgreSQL database dump complete
--

\unrestrict zEvaF6gHUZmQwNUVWRwgy2eEObFEdzT0lD2ZWcEjwebH5QdC0yUiHs0NFBtOTQV

