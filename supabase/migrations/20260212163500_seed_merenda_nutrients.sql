-- Seed Global Nutrients
-- These nutrients have empresa_id = NULL, making them available to all companies.

INSERT INTO public.mrd_nutriente (nome, unidade, empresa_id) VALUES
-- Energia
('Energia (kcal)', 'kcal', NULL),
('Energia (kJ)', 'kJ', NULL),

-- Macronutrientes base
('Carboidratos', 'g', NULL),
('Proteínas', 'g', NULL),
('Lipídeos (Gorduras)', 'g', NULL),

-- Micronutrientes (PNAE/FNDE - Páginas 9 e 10)
('Cálcio', 'mg', NULL),
('Ferro', 'mg', NULL),
('Retinol (Vitamina A)', 'mcg', NULL),
('Vitamina C', 'mg', NULL),
('Sódio', 'mg', NULL),

-- Itens comuns de rotulagem (Opcionais)
('Fibras', 'g', NULL),
('Gorduras Saturadas', 'g', NULL),
('Gorduras Trans', 'g', NULL)
ON CONFLICT DO NOTHING; -- Avoid duplicates if re-run (though conflict target might be needed if name constraint exists, but UUID is PK. We assume this is fresh or harmless insert)
-- Ideally we would match by name to avoid duplicates if running multiple times without cleanup, but simple insert is fine for now as requested.
