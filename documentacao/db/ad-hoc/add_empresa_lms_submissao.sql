DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'lms_submissao' AND column_name = 'id_empresa') THEN
        ALTER TABLE public.lms_submissao ADD COLUMN id_empresa uuid;
        -- Optional: Add Constraint if table clientes exists
        -- ALTER TABLE public.lms_submissao ADD CONSTRAINT lms_submissao_id_empresa_fkey FOREIGN KEY (id_empresa) REFERENCES public.clientes(id);
    END IF;
END $$;
