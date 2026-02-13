DO $$
DECLARE
    v_empresa_id uuid;
    v_result jsonb;
    v_new_id uuid;
BEGIN
    -- Get the first empresa ID found (or a specific one if known)
    SELECT id INTO v_empresa_id FROM public.empresa LIMIT 1;
    
    IF v_empresa_id IS NULL THEN
        RAISE NOTICE 'No empresa found to test with.';
        RETURN;
    END IF;

    RAISE NOTICE 'Testing with Empresa ID: %', v_empresa_id;

    -- Test 1: Creation (No ID)
    -- Simulating payload: {"nome": "Teste Insert Auto", "ordem": 10}
    SELECT public.classe_upsert('{"nome": "Teste Insert Auto", "ordem": 10}'::jsonb, v_empresa_id) INTO v_result;
    
    RAISE NOTICE 'Creation Result: %', v_result;
    
    v_new_id := (v_result ->> 'id')::uuid;
    
    IF v_new_id IS NULL THEN
        RAISE EXCEPTION 'Creation failed, no ID returned.';
    END IF;

    -- Test 2: Update (With ID)
    -- Simulating payload: {"id": "...", "nome": "Teste Update", "ordem": 20}
    SELECT public.classe_upsert(jsonb_build_object('id', v_new_id, 'nome', 'Teste Update', 'ordem', 20), v_empresa_id) INTO v_result;

    RAISE NOTICE 'Update Result: %', v_result;

    -- Cleanup
    DELETE FROM public.classe WHERE id = v_new_id;
    RAISE NOTICE 'Cleanup complete.';

END $$;
