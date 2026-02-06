ALTER TABLE public.bbtk_edicao ADD COLUMN id_arquivo_livro uuid NULL;
ALTER TABLE public.bbtk_edicao ADD COLUMN id_arquivo_capa uuid NULL;

ALTER TABLE public.bbtk_edicao 
    ADD CONSTRAINT bbtk_edicao_id_arquivo_livro_fkey 
    FOREIGN KEY (id_arquivo_livro) REFERENCES public.global_arquivos (id);

ALTER TABLE public.bbtk_edicao 
    ADD CONSTRAINT bbtk_edicao_id_arquivo_capa_fkey 
    FOREIGN KEY (id_arquivo_capa) REFERENCES public.global_arquivos (id);
