INSERT INTO public.componente (nome, id_empresa, title_sharepoint, id_sharepoint, cor)
SELECT nome, '0709fe87-3b42-4f1d-9919-51dea9228cfd'::uuid, title_sharepoint, id_sharepoint, cor
FROM public.componente
WHERE id_empresa = '0a9d8682-4da9-4e02-9022-fd293a9b0704'::uuid;
