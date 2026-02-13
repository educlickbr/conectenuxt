UPDATE public.bbtk_edicao e SET id_empresa = o.id_empresa FROM public.bbtk_obra o WHERE e.obra_uuid = o.uuid AND e.id_empresa IS NULL;
