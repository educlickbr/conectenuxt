SELECT id,
       nome,
       logo_fechado,
       logo_aberto,
       created_at,
       dominio
FROM public.empresa
LIMIT 1000;