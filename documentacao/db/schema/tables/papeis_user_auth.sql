CREATE TABLE IF NOT EXISTS public.papeis_user_auth
(
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL,
    papel_id uuid NOT NULL,
    empresa_id uuid NOT NULL,
    CONSTRAINT papeis_user_auth_pkey PRIMARY KEY (id),
    CONSTRAINT papeis_user_auth_user_id_papel_id_empresa_id_key UNIQUE (user_id, papel_id, empresa_id),
    CONSTRAINT papeis_user_auth_empresa_id_fkey FOREIGN KEY (empresa_id)
        REFERENCES public.empresa (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT papeis_user_auth_papel_id_fkey FOREIGN KEY (papel_id)
        REFERENCES public.papeis_user (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT papeis_user_auth_user_id_fkey FOREIGN KEY (user_id)
        REFERENCES auth.users (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE
)

TABLESPACE pg_default;

ALTER TABLE public.papeis_user_auth
    OWNER to postgres;

-- Index: public.idx_pua_user_empresa_papel
CREATE INDEX IF NOT EXISTS idx_pua_user_empresa_papel
    ON public.papeis_user_auth USING btree
    (user_id ASC NULLS LAST, empresa_id ASC NULLS LAST, papel_id ASC NULLS LAST)
    TABLESPACE pg_default;
-- Trigger: trg_log_papeis_user_auth
CREATE OR REPLACE TRIGGER trg_log_papeis_user_auth
    BEFORE UPDATE 
    ON public.papeis_user_auth
    FOR EACH ROW
    EXECUTE FUNCTION public.log_update_papeis_user_auth();