-- Create Enum Type
DO $$ BEGIN
    CREATE TYPE public.bbtk_status_reserva AS ENUM ('Reservado', 'Entregue', 'Cancelado');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- Add column to table
ALTER TABLE public.bbtk_historico_interacao
ADD COLUMN IF NOT EXISTS status_reserva bbtk_status_reserva;

-- Backfill existing data
UPDATE public.bbtk_historico_interacao
SET status_reserva = CASE
    WHEN data_fim IS NOT NULL THEN 'Entregue'::bbtk_status_reserva
    ELSE 'Reservado'::bbtk_status_reserva
END
WHERE status_reserva IS NULL AND tipo_interacao = 'Reserva';
