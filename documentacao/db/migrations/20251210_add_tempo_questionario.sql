ALTER TABLE public.lms_item_conteudo 
ADD COLUMN IF NOT EXISTS tempo_questionario integer DEFAULT NULL;

COMMENT ON COLUMN public.lms_item_conteudo.tempo_questionario IS 'Tempo em minutos para responder o questionário. Se NULL, é ilimitado.';
