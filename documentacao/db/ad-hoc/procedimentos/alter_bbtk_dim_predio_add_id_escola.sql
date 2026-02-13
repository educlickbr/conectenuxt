ALTER TABLE public.bbtk_dim_predio
ADD COLUMN IF NOT EXISTS id_escola uuid,
ADD CONSTRAINT bbtk_dim_predio_id_escola_fkey FOREIGN KEY (id_escola)
    REFERENCES public.escolas (id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE CASCADE;
