-- public.mrd_alimento definition

-- Drop table

-- DROP TABLE public.mrd_alimento;

CREATE TABLE public.mrd_alimento (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	empresa_id uuid NOT NULL,
	nome text NOT NULL,
	unidade_medida public."mrd_unidade_medida" NOT NULL,
	ata_registro_ref text NULL,
	categoria text NULL,
	valor_nutricional_100g jsonb NULL,
	preco_medio numeric(10, 2) NULL,
	fornecedor_preferencial text NULL,
	created_at timestamptz DEFAULT now() NULL,
	updated_at timestamptz DEFAULT now() NULL,
	created_by uuid NULL,
	updated_by uuid NULL,
	ativo bool DEFAULT true NULL,
	CONSTRAINT mrd_alimento_pkey PRIMARY KEY (id),
	CONSTRAINT mrd_alimento_created_by_fkey FOREIGN KEY (created_by) REFERENCES auth.users(id),
	CONSTRAINT mrd_alimento_empresa_fkey FOREIGN KEY (empresa_id) REFERENCES public.empresa(id),
	CONSTRAINT mrd_alimento_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES auth.users(id)
);

-- public.mrd_cardapio_etapa definition

-- Drop table

-- DROP TABLE public.mrd_cardapio_etapa;

CREATE TABLE public.mrd_cardapio_etapa (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	cardapio_grupo_id uuid NOT NULL,
	ano_etapa_id uuid NOT NULL,
	empresa_id uuid NOT NULL,
	created_at timestamptz DEFAULT now() NULL,
	created_by uuid NULL,
	CONSTRAINT mrd_cardapio_etapa_pkey PRIMARY KEY (id),
	CONSTRAINT mrd_cardapio_etapa_unique_pair UNIQUE (cardapio_grupo_id, ano_etapa_id),
	CONSTRAINT mrd_cardapio_etapa_ano_etapa_fkey FOREIGN KEY (ano_etapa_id) REFERENCES public.ano_etapa(id),
	CONSTRAINT mrd_cardapio_etapa_created_by_fkey FOREIGN KEY (created_by) REFERENCES auth.users(id),
	CONSTRAINT mrd_cardapio_etapa_empresa_fkey FOREIGN KEY (empresa_id) REFERENCES public.empresa(id),
	CONSTRAINT mrd_cardapio_etapa_grupo_fkey FOREIGN KEY (cardapio_grupo_id) REFERENCES public.mrd_cardapio_grupo(id) ON DELETE CASCADE
);

-- public.mrd_cardapio_grupo definition

-- Drop table

-- DROP TABLE public.mrd_cardapio_grupo;

CREATE TABLE public.mrd_cardapio_grupo (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	empresa_id uuid NOT NULL,
	nome text NOT NULL,
	data_inicio timestamptz NOT NULL,
	data_fim timestamptz NOT NULL,
	created_at timestamptz DEFAULT now() NULL,
	updated_at timestamptz DEFAULT now() NULL,
	created_by uuid NULL,
	updated_by uuid NULL,
	ativo bool DEFAULT true NULL,
	CONSTRAINT mrd_cardapio_grupo_pkey PRIMARY KEY (id),
	CONSTRAINT mrd_cardapio_grupo_created_by_fkey FOREIGN KEY (created_by) REFERENCES auth.users(id),
	CONSTRAINT mrd_cardapio_grupo_empresa_fkey FOREIGN KEY (empresa_id) REFERENCES public.empresa(id),
	CONSTRAINT mrd_cardapio_grupo_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES auth.users(id)
);


-- public.mrd_cardapio_semanal definition

-- Drop table

-- DROP TABLE public.mrd_cardapio_semanal;

CREATE TABLE public.mrd_cardapio_semanal (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	cardapio_grupo_id uuid NOT NULL,
	ano int4 NOT NULL,
	semana_iso int4 NOT NULL,
	p_dia_semana timestamptz NOT NULL,
	u_dia_semana timestamptz NOT NULL,
	dia_semana_indice int4 NOT NULL,
	refeicao_tipo_id uuid NOT NULL,
	prato_id uuid NOT NULL,
	prato_alternativo_id uuid NULL,
	observacoes text NULL,
	status text DEFAULT 'PLANEJADO'::text NULL,
	aprovado_por uuid NULL,
	aprovado_em timestamptz NULL,
	created_at timestamptz DEFAULT now() NULL,
	updated_at timestamptz DEFAULT now() NULL,
	created_by uuid NULL,
	updated_by uuid NULL,
	ativo bool DEFAULT true NULL,
	empresa_id uuid NULL,
	CONSTRAINT mrd_cardapio_semanal_pkey PRIMARY KEY (id),
	CONSTRAINT mrd_cardapio_semanal_aprovado_por_fkey FOREIGN KEY (aprovado_por) REFERENCES auth.users(id),
	CONSTRAINT mrd_cardapio_semanal_created_by_fkey FOREIGN KEY (created_by) REFERENCES auth.users(id),
	CONSTRAINT mrd_cardapio_semanal_empresa_id_fkey FOREIGN KEY (empresa_id) REFERENCES public.empresa(id),
	CONSTRAINT mrd_cardapio_semanal_grupo_fkey FOREIGN KEY (cardapio_grupo_id) REFERENCES public.mrd_cardapio_grupo(id),
	CONSTRAINT mrd_cardapio_semanal_prato_alt_fkey FOREIGN KEY (prato_alternativo_id) REFERENCES public.mrd_prato(id),
	CONSTRAINT mrd_cardapio_semanal_prato_fkey FOREIGN KEY (prato_id) REFERENCES public.mrd_prato(id),
	CONSTRAINT mrd_cardapio_semanal_tipo_fkey FOREIGN KEY (refeicao_tipo_id) REFERENCES public.mrd_refeicao_tipo(id),
	CONSTRAINT mrd_cardapio_semanal_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES auth.users(id)
);

-- public.mrd_ficha_tecnica definition

-- Drop table

-- DROP TABLE public.mrd_ficha_tecnica;

CREATE TABLE public.mrd_ficha_tecnica (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	prato_id uuid NOT NULL,
	alimento_id uuid NOT NULL,
	quantidade numeric(10, 4) NOT NULL,
	modo_preparo_complementar text NULL,
	ordem_adicao int4 DEFAULT 1 NULL,
	opcional bool DEFAULT false NULL,
	substituivel_por uuid NULL,
	created_at timestamptz DEFAULT now() NULL,
	updated_at timestamptz DEFAULT now() NULL,
	created_by uuid NULL,
	updated_by uuid NULL,
	ativo bool DEFAULT true NULL,
	empresa_id uuid NULL,
	CONSTRAINT mrd_ficha_tecnica_pkey PRIMARY KEY (id),
	CONSTRAINT mrd_ficha_tecnica_alimento_fkey FOREIGN KEY (alimento_id) REFERENCES public.mrd_alimento(id),
	CONSTRAINT mrd_ficha_tecnica_created_by_fkey FOREIGN KEY (created_by) REFERENCES auth.users(id),
	CONSTRAINT mrd_ficha_tecnica_empresa_id_fkey FOREIGN KEY (empresa_id) REFERENCES public.empresa(id),
	CONSTRAINT mrd_ficha_tecnica_prato_fkey FOREIGN KEY (prato_id) REFERENCES public.mrd_prato(id),
	CONSTRAINT mrd_ficha_tecnica_subst_fkey FOREIGN KEY (substituivel_por) REFERENCES public.mrd_alimento(id),
	CONSTRAINT mrd_ficha_tecnica_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES auth.users(id)
);

-- public.mrd_prato definition

-- Drop table

-- DROP TABLE public.mrd_prato;

CREATE TABLE public.mrd_prato (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	empresa_id uuid NOT NULL,
	nome text NOT NULL,
	modo_preparo text NULL,
	created_at timestamptz DEFAULT now() NULL,
	updated_at timestamptz DEFAULT now() NULL,
	created_by uuid NULL,
	updated_by uuid NULL,
	ativo bool DEFAULT true NULL,
	rendimento int4 DEFAULT 1 NULL,
	CONSTRAINT mrd_prato_pkey PRIMARY KEY (id),
	CONSTRAINT mrd_prato_created_by_fkey FOREIGN KEY (created_by) REFERENCES auth.users(id),
	CONSTRAINT mrd_prato_empresa_fkey FOREIGN KEY (empresa_id) REFERENCES public.empresa(id),
	CONSTRAINT mrd_prato_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES auth.users(id)
);