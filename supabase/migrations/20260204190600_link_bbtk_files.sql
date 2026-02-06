-- Update Capas
UPDATE public.bbtk_edicao
SET id_arquivo_capa = ga.id
FROM public.global_arquivos ga
WHERE ga.nome_original = bbtk_edicao.arquivo_capa
  AND ga.escopo = 'biblioteca_capa'
  AND ga.bucket = 'conecte';

-- Update PDFs
UPDATE public.bbtk_edicao
SET id_arquivo_livro = ga.id
FROM public.global_arquivos ga
WHERE ga.nome_original = bbtk_edicao.arquivo_pdf
  AND ga.escopo = 'biblioteca_arquivo'
  AND ga.bucket = 'conecte';
