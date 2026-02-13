-- Seed Foods and Nutrients for Specific Company
-- Date: 2026-02-13

DO $$
DECLARE
    v_empresa_id uuid := 'db5a4c52-074f-47c2-9aba-ac89111039d9';
    
    -- Foods
    v_frango_id uuid;
    v_arroz_id uuid;
    v_alface_id uuid;
    v_alho_id uuid;
    v_cebola_id uuid;
    v_azeite_id uuid;
    v_sal_id uuid;

    -- Nutrients (Hardcoded IDs provided by user)
    v_kcal_id uuid := '6e24f6a2-b4b1-42fa-a583-6b743fa80949';
    v_kj_id uuid := '27ab3eaf-031f-443d-a740-6d9ff4c5d05f';
    v_carb_id uuid := '4c5f44da-a27f-4373-a78f-a2bc2daafd10';
    v_prot_id uuid := '6256121e-ee06-4f12-8f7c-45a1de632c01';
    v_lip_id uuid := '17e0de14-d091-4a22-a3af-4ed88216d8ea';
    v_calc_id uuid := '42a64325-6e11-4974-a22a-7691cd50deb3';
    v_ferro_id uuid := 'ff0f6ebc-2eb7-4fad-bccd-95cd018de112';
    v_retinol_id uuid := '2948436c-372a-476f-ba5a-f42b91efbf3d';
    v_vitc_id uuid := '5e4893e5-ae60-4ac3-b5a5-b950d9b8beb8';
    v_sodio_id uuid := 'fc74a5f5-eadf-4c78-98bb-a5e2f5532c1e';
    v_fibras_id uuid := '987455b5-b3ec-4057-8f39-8fd4c4c94629';
    v_gord_sat_id uuid := '6d099588-5087-40b2-b6ec-8f0d74a3733d';
    v_gord_trans_id uuid := '5e2b4e3f-27b2-4734-9aa6-623d61194a40';
BEGIN

    -- 1. Sobrecoxa Frango (Assada, s/ pele)
    INSERT INTO public.mrd_alimento (empresa_id, nome, unidade_medida, categoria, preco_medio, ativo, created_by, updated_by)
    VALUES (v_empresa_id, 'Sobrecoxa Frango (Assada, s/ pele)', 'KG', 'Proteína', 0, true, NULL, NULL)
    RETURNING id INTO v_frango_id;

    INSERT INTO public.mrd_alimento_nutriente (empresa_id, alimento_id, nutriente_id, quantidade_100g) VALUES
    (v_empresa_id, v_frango_id, v_kcal_id, 23300),
    (v_empresa_id, v_frango_id, v_kj_id, 97800),
    (v_empresa_id, v_frango_id, v_carb_id, 0),
    (v_empresa_id, v_frango_id, v_prot_id, 2920), -- 29.2 * 100
    (v_empresa_id, v_frango_id, v_lip_id, 1200), -- 12.0 * 100
    (v_empresa_id, v_frango_id, v_calc_id, 1230), -- 12.3 * 100
    (v_empresa_id, v_frango_id, v_ferro_id, 120), -- 1.2 * 100
    (v_empresa_id, v_frango_id, v_retinol_id, 1070), -- 10.7 * 100
    (v_empresa_id, v_frango_id, v_vitc_id, 20), -- 0.2 * 100
    (v_empresa_id, v_frango_id, v_sodio_id, 10610), -- 106.1 * 100
    (v_empresa_id, v_frango_id, v_fibras_id, 0),
    (v_empresa_id, v_frango_id, v_gord_sat_id, 330), -- 3.3 * 100
    (v_empresa_id, v_frango_id, v_gord_trans_id, 0);

    -- 2. Arroz Branco (Cozido)
    INSERT INTO public.mrd_alimento (empresa_id, nome, unidade_medida, categoria, preco_medio, ativo, created_by, updated_by)
    VALUES (v_empresa_id, 'Arroz Branco (Cozido)', 'KG', 'Estocável', 0, true, NULL, NULL)
    RETURNING id INTO v_arroz_id;

    INSERT INTO public.mrd_alimento_nutriente (empresa_id, alimento_id, nutriente_id, quantidade_100g) VALUES
    (v_empresa_id, v_arroz_id, v_kcal_id, 12800),
    (v_empresa_id, v_arroz_id, v_kj_id, 53600),
    (v_empresa_id, v_arroz_id, v_carb_id, 2810), -- 28.1 * 100
    (v_empresa_id, v_arroz_id, v_prot_id, 250), -- 2.5 * 100
    (v_empresa_id, v_arroz_id, v_lip_id, 20), -- 0.2 * 100
    (v_empresa_id, v_arroz_id, v_calc_id, 400), -- 4.0 * 100
    (v_empresa_id, v_arroz_id, v_ferro_id, 10), -- 0.1 * 100
    (v_empresa_id, v_arroz_id, v_retinol_id, 0),
    (v_empresa_id, v_arroz_id, v_vitc_id, 0),
    (v_empresa_id, v_arroz_id, v_sodio_id, 100), -- 1.0 * 100
    (v_empresa_id, v_arroz_id, v_fibras_id, 40), -- 0.4 * 100
    (v_empresa_id, v_arroz_id, v_gord_sat_id, 5), -- 0.05 * 100
    (v_empresa_id, v_arroz_id, v_gord_trans_id, 0);

    -- 3. Alface Crespa (Crua)
    INSERT INTO public.mrd_alimento (empresa_id, nome, unidade_medida, categoria, preco_medio, ativo, created_by, updated_by)
    VALUES (v_empresa_id, 'Alface Crespa (Crua)', 'KG', 'Hortifruti', 0, true, NULL, NULL)
    RETURNING id INTO v_alface_id;

    INSERT INTO public.mrd_alimento_nutriente (empresa_id, alimento_id, nutriente_id, quantidade_100g) VALUES
    (v_empresa_id, v_alface_id, v_kcal_id, 1100),
    (v_empresa_id, v_alface_id, v_kj_id, 4500),
    (v_empresa_id, v_alface_id, v_carb_id, 170), -- 1.7 * 100
    (v_empresa_id, v_alface_id, v_prot_id, 130), -- 1.3 * 100
    (v_empresa_id, v_alface_id, v_lip_id, 20), -- 0.2 * 100
    (v_empresa_id, v_alface_id, v_calc_id, 3800), -- 38.0 * 100
    (v_empresa_id, v_alface_id, v_ferro_id, 40), -- 0.4 * 100
    (v_empresa_id, v_alface_id, v_retinol_id, 23400), -- 234.0 * 100
    (v_empresa_id, v_alface_id, v_vitc_id, 1560), -- 15.6 * 100
    (v_empresa_id, v_alface_id, v_sodio_id, 300), -- 3.0 * 100
    (v_empresa_id, v_alface_id, v_fibras_id, 180), -- 1.8 * 100
    (v_empresa_id, v_alface_id, v_gord_sat_id, 0),
    (v_empresa_id, v_alface_id, v_gord_trans_id, 0);

    -- 4. Alho (Cru)
    INSERT INTO public.mrd_alimento (empresa_id, nome, unidade_medida, categoria, preco_medio, ativo, created_by, updated_by)
    VALUES (v_empresa_id, 'Alho (Cru)', 'KG', 'Hortifruti', 0, true, NULL, NULL)
    RETURNING id INTO v_alho_id;

    INSERT INTO public.mrd_alimento_nutriente (empresa_id, alimento_id, nutriente_id, quantidade_100g) VALUES
    (v_empresa_id, v_alho_id, v_kcal_id, 11300),
    (v_empresa_id, v_alho_id, v_kj_id, 51400),
    (v_empresa_id, v_alho_id, v_carb_id, 2390), -- 23.9 * 100
    (v_empresa_id, v_alho_id, v_prot_id, 700), -- 7.0 * 100
    (v_empresa_id, v_alho_id, v_lip_id, 20), -- 0.2 * 100
    (v_empresa_id, v_alho_id, v_calc_id, 1400), -- 14.0 * 100
    (v_empresa_id, v_alho_id, v_ferro_id, 80), -- 0.8 * 100
    (v_empresa_id, v_alho_id, v_retinol_id, 0),
    (v_empresa_id, v_alho_id, v_vitc_id, 2480), -- 24.8 * 100
    (v_empresa_id, v_alho_id, v_sodio_id, 500), -- 5.0 * 100
    (v_empresa_id, v_alho_id, v_fibras_id, 320), -- 3.2 * 100
    (v_empresa_id, v_alho_id, v_gord_sat_id, 4), -- 0.04 * 100
    (v_empresa_id, v_alho_id, v_gord_trans_id, 0);

    -- 5. Cebola (Crua)
    INSERT INTO public.mrd_alimento (empresa_id, nome, unidade_medida, categoria, preco_medio, ativo, created_by, updated_by)
    VALUES (v_empresa_id, 'Cebola (Crua)', 'KG', 'Hortifruti', 0, true, NULL, NULL)
    RETURNING id INTO v_cebola_id;

    INSERT INTO public.mrd_alimento_nutriente (empresa_id, alimento_id, nutriente_id, quantidade_100g) VALUES
    (v_empresa_id, v_cebola_id, v_kcal_id, 3900),
    (v_empresa_id, v_cebola_id, v_kj_id, 16400),
    (v_empresa_id, v_cebola_id, v_carb_id, 890), -- 8.9 * 100
    (v_empresa_id, v_cebola_id, v_prot_id, 170), -- 1.7 * 100
    (v_empresa_id, v_cebola_id, v_lip_id, 10), -- 0.1 * 100
    (v_empresa_id, v_cebola_id, v_calc_id, 2300), -- 23.0 * 100
    (v_empresa_id, v_cebola_id, v_ferro_id, 20), -- 0.2 * 100
    (v_empresa_id, v_cebola_id, v_retinol_id, 0),
    (v_empresa_id, v_cebola_id, v_vitc_id, 740), -- 7.4 * 100
    (v_empresa_id, v_cebola_id, v_sodio_id, 100), -- 1.0 * 100
    (v_empresa_id, v_cebola_id, v_fibras_id, 220), -- 2.2 * 100
    (v_empresa_id, v_cebola_id, v_gord_sat_id, 0),
    (v_empresa_id, v_cebola_id, v_gord_trans_id, 0);

    -- 6. Azeite de Oliva (Extra V.)
    INSERT INTO public.mrd_alimento (empresa_id, nome, unidade_medida, categoria, preco_medio, ativo, created_by, updated_by)
    VALUES (v_empresa_id, 'Azeite de Oliva (Extra V.)', 'LITRO', 'Estocável', 0, true, NULL, NULL)
    RETURNING id INTO v_azeite_id;

    INSERT INTO public.mrd_alimento_nutriente (empresa_id, alimento_id, nutriente_id, quantidade_100g) VALUES
    (v_empresa_id, v_azeite_id, v_kcal_id, 88400),
    (v_empresa_id, v_azeite_id, v_kj_id, 369900),
    (v_empresa_id, v_azeite_id, v_carb_id, 0),
    (v_empresa_id, v_azeite_id, v_prot_id, 0),
    (v_empresa_id, v_azeite_id, v_lip_id, 10000), -- 100.0 * 100
    (v_empresa_id, v_azeite_id, v_calc_id, 0),
    (v_empresa_id, v_azeite_id, v_ferro_id, 0),
    (v_empresa_id, v_azeite_id, v_retinol_id, 0),
    (v_empresa_id, v_azeite_id, v_vitc_id, 0),
    (v_empresa_id, v_azeite_id, v_sodio_id, 0),
    (v_empresa_id, v_azeite_id, v_fibras_id, 0),
    (v_empresa_id, v_azeite_id, v_gord_sat_id, 1440), -- 14.4 * 100
    (v_empresa_id, v_azeite_id, v_gord_trans_id, 0);

    -- 7. Sal Refinado 
    INSERT INTO public.mrd_alimento (empresa_id, nome, unidade_medida, categoria, preco_medio, ativo, created_by, updated_by)
    VALUES (v_empresa_id, 'Sal Refinado', 'KG', 'Estocável', 0, true, NULL, NULL)
    RETURNING id INTO v_sal_id;

    INSERT INTO public.mrd_alimento_nutriente (empresa_id, alimento_id, nutriente_id, quantidade_100g) VALUES
    (v_empresa_id, v_sal_id, v_kcal_id, 0),
    (v_empresa_id, v_sal_id, v_kj_id, 0),
    (v_empresa_id, v_sal_id, v_carb_id, 0),
    (v_empresa_id, v_sal_id, v_prot_id, 0),
    (v_empresa_id, v_sal_id, v_lip_id, 0),
    (v_empresa_id, v_sal_id, v_calc_id, 0),
    (v_empresa_id, v_sal_id, v_ferro_id, 0),
    (v_empresa_id, v_sal_id, v_retinol_id, 0),
    (v_empresa_id, v_sal_id, v_vitc_id, 0),
    (v_empresa_id, v_sal_id, v_sodio_id, 3875800), -- 38758.0 * 100
    (v_empresa_id, v_sal_id, v_fibras_id, 0),
    (v_empresa_id, v_sal_id, v_gord_sat_id, 0),
    (v_empresa_id, v_sal_id, v_gord_trans_id, 0);

END $$;
