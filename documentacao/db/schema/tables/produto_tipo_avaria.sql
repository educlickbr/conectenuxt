--
-- PostgreSQL database dump
--

\restrict 7GIltfaz1G9aBPvlC1atbnC6ipAw3h9Jl2fr6TMfuDS4B6GdMG6ei6ZLxDZENOV

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
-- Name: produto_tipo_avaria; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.produto_tipo_avaria (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    avaria text NOT NULL
);


--
-- Name: produto_tipo_avaria produto_tipo_avaria_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.produto_tipo_avaria
    ADD CONSTRAINT produto_tipo_avaria_pkey PRIMARY KEY (id);


--
-- Name: produto_tipo_avaria; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.produto_tipo_avaria ENABLE ROW LEVEL SECURITY;

--
-- Name: produto_tipo_avaria todos_veem_tipo_avaria; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY todos_veem_tipo_avaria ON public.produto_tipo_avaria FOR SELECT USING (true);


--
-- PostgreSQL database dump complete
--

\unrestrict 7GIltfaz1G9aBPvlC1atbnC6ipAw3h9Jl2fr6TMfuDS4B6GdMG6ei6ZLxDZENOV

