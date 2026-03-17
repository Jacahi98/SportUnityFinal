-- Crear tabla de actividades
CREATE TABLE actividades (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id),
  titulo TEXT NOT NULL,
  deporte TEXT NOT NULL,
  descripcion TEXT,
  fecha DATE NOT NULL,
  hora TIME NOT NULL,
  latitud DOUBLE PRECISION NOT NULL,
  longitud DOUBLE PRECISION NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Habilitar RLS
ALTER TABLE actividades ENABLE ROW LEVEL SECURITY;

-- Política: Todos los autenticados pueden ver actividades
CREATE POLICY "ver actividades"
  ON actividades
  FOR SELECT
  TO authenticated
  USING (true);

-- Política: Solo el creador puede insertar sus actividades
CREATE POLICY "crear actividades"
  ON actividades
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- Política: Solo el creador puede borrar sus actividades
CREATE POLICY "borrar propias"
  ON actividades
  FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);

-- Crear índice para búsquedas por user_id
CREATE INDEX actividades_user_id_idx ON actividades(user_id);
