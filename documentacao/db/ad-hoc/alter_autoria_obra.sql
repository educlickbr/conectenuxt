BEGIN;
UPDATE public.bbtk_dim_autoria 
SET principal = true;
COMMIT;
