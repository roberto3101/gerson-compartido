-- ====================================================================
-- sesga_grupo5_capacidades.sql  -  Grupo 5 (activos-e-inversion + cierre-mensual)
-- Esquema local funcional para CockroachDB v26.
-- Stubs de otras capacidades + 13 tablas + indices + 26 procedimientos.
-- Generado desde codeplexMaster (fuente de verdad). Script unificado de las capacidades del Grupo 5 (activos-e-inversion + cierre-mensual).
-- ====================================================================
DROP DATABASE IF EXISTS sesga_test CASCADE;
CREATE DATABASE sesga_test;
SET database = sesga_test;

-- ---- STUBS (otras capacidades; version minima para pruebas) ----
CREATE TABLE empresa (id UUID PRIMARY KEY DEFAULT gen_random_uuid(), estado STRING NOT NULL DEFAULT 'ACTIVO', eliminado_en TIMESTAMPTZ);
CREATE TABLE usuario (id UUID PRIMARY KEY DEFAULT gen_random_uuid());
CREATE TABLE contrato (id UUID PRIMARY KEY DEFAULT gen_random_uuid(), id_empresa UUID, estado STRING NOT NULL DEFAULT 'ACTIVO', eliminado_en TIMESTAMPTZ);
CREATE TABLE zona (id UUID PRIMARY KEY DEFAULT gen_random_uuid(), id_empresa UUID, estado STRING NOT NULL DEFAULT 'ACTIVO', eliminado_en TIMESTAMPTZ);
CREATE TABLE periodo (id UUID PRIMARY KEY DEFAULT gen_random_uuid(), id_empresa UUID, eliminado_en TIMESTAMPTZ);
CREATE TABLE operario (id UUID PRIMARY KEY DEFAULT gen_random_uuid());

-- ---- TABLAS (13) ----
-- >>> entidad_tipo_adquisicion_activo.sql
CREATE TABLE tipo_adquisicion_activo (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_empresa UUID NOT NULL,
  codigo STRING NOT NULL,
  descripcion STRING NOT NULL,
  estado STRING NOT NULL DEFAULT 'ACTIVO',
  creado_en TIMESTAMPTZ NOT NULL DEFAULT now(),
  creado_por_usuario_id UUID,
  actualizado_en TIMESTAMPTZ NOT NULL DEFAULT now(),
  actualizado_por_usuario_id UUID,
  eliminado_en TIMESTAMPTZ,
  eliminado_por_usuario_id UUID,
  CONSTRAINT ck_tipo_adquisicion_activo_estado CHECK (estado IN ('ACTIVO', 'INACTIVO'))
);

ALTER TABLE tipo_adquisicion_activo ADD CONSTRAINT fk_tipo_adquisicion_activo_empresa FOREIGN KEY (id_empresa) REFERENCES empresa (id) ON DELETE RESTRICT;
ALTER TABLE tipo_adquisicion_activo ADD CONSTRAINT fk_tipo_adquisicion_activo_creado_por FOREIGN KEY (creado_por_usuario_id) REFERENCES usuario (id) ON DELETE RESTRICT;
ALTER TABLE tipo_adquisicion_activo ADD CONSTRAINT fk_tipo_adquisicion_activo_actualizado_por FOREIGN KEY (actualizado_por_usuario_id) REFERENCES usuario (id) ON DELETE RESTRICT;
ALTER TABLE tipo_adquisicion_activo ADD CONSTRAINT fk_tipo_adquisicion_activo_eliminado_por FOREIGN KEY (eliminado_por_usuario_id) REFERENCES usuario (id) ON DELETE RESTRICT;

-- >>> entidad_clasificacion_activo.sql
CREATE TABLE clasificacion_activo (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_empresa UUID NOT NULL,
  codigo STRING NOT NULL,
  descripcion STRING NOT NULL,
  es_capitalizable BOOL NOT NULL DEFAULT true,
  estado STRING NOT NULL DEFAULT 'ACTIVO',
  creado_en TIMESTAMPTZ NOT NULL DEFAULT now(),
  creado_por_usuario_id UUID,
  actualizado_en TIMESTAMPTZ NOT NULL DEFAULT now(),
  actualizado_por_usuario_id UUID,
  eliminado_en TIMESTAMPTZ,
  eliminado_por_usuario_id UUID,
  CONSTRAINT ck_clasificacion_activo_estado CHECK (estado IN ('ACTIVO', 'INACTIVO'))
);

ALTER TABLE clasificacion_activo ADD CONSTRAINT fk_clasificacion_activo_empresa FOREIGN KEY (id_empresa) REFERENCES empresa (id) ON DELETE RESTRICT;
ALTER TABLE clasificacion_activo ADD CONSTRAINT fk_clasificacion_activo_creado_por FOREIGN KEY (creado_por_usuario_id) REFERENCES usuario (id) ON DELETE RESTRICT;
ALTER TABLE clasificacion_activo ADD CONSTRAINT fk_clasificacion_activo_actualizado_por FOREIGN KEY (actualizado_por_usuario_id) REFERENCES usuario (id) ON DELETE RESTRICT;
ALTER TABLE clasificacion_activo ADD CONSTRAINT fk_clasificacion_activo_eliminado_por FOREIGN KEY (eliminado_por_usuario_id) REFERENCES usuario (id) ON DELETE RESTRICT;

-- >>> entidad_tipo_herramienta.sql
CREATE TABLE tipo_herramienta (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_empresa UUID NOT NULL,
  codigo STRING NOT NULL,
  descripcion STRING NOT NULL,
  estado STRING NOT NULL DEFAULT 'ACTIVO',
  creado_en TIMESTAMPTZ NOT NULL DEFAULT now(),
  creado_por_usuario_id UUID,
  actualizado_en TIMESTAMPTZ NOT NULL DEFAULT now(),
  actualizado_por_usuario_id UUID,
  eliminado_en TIMESTAMPTZ,
  eliminado_por_usuario_id UUID,
  CONSTRAINT ck_tipo_herramienta_estado CHECK (estado IN ('ACTIVO', 'INACTIVO'))
);

ALTER TABLE tipo_herramienta ADD CONSTRAINT fk_tipo_herramienta_empresa FOREIGN KEY (id_empresa) REFERENCES empresa (id) ON DELETE RESTRICT;
ALTER TABLE tipo_herramienta ADD CONSTRAINT fk_tipo_herramienta_creado_por FOREIGN KEY (creado_por_usuario_id) REFERENCES usuario (id) ON DELETE RESTRICT;
ALTER TABLE tipo_herramienta ADD CONSTRAINT fk_tipo_herramienta_actualizado_por FOREIGN KEY (actualizado_por_usuario_id) REFERENCES usuario (id) ON DELETE RESTRICT;
ALTER TABLE tipo_herramienta ADD CONSTRAINT fk_tipo_herramienta_eliminado_por FOREIGN KEY (eliminado_por_usuario_id) REFERENCES usuario (id) ON DELETE RESTRICT;

-- >>> entidad_activo.sql
CREATE TABLE activo (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_empresa UUID NOT NULL,
  id_clasificacion_activo UUID NOT NULL,
  id_tipo_adquisicion_activo UUID,
  codigo STRING,
  descripcion STRING NOT NULL,
  placa STRING,
  marca STRING,
  modelo STRING,
  numero_serie STRING,
  anio_fabricacion INT2,
  costo_adquisicion DECIMAL(18,2) NOT NULL,
  tiempo_vida_meses INT,
  depreciacion_mensual DECIMAL(18,2),
  importe_base_recuperable DECIMAL(18,2),
  fecha_inicio_depreciacion DATE,
  fecha_fin_depreciacion DATE,
  estado STRING NOT NULL DEFAULT 'ACTIVO',
  creado_en TIMESTAMPTZ NOT NULL DEFAULT now(),
  creado_por_usuario_id UUID,
  actualizado_en TIMESTAMPTZ NOT NULL DEFAULT now(),
  actualizado_por_usuario_id UUID,
  eliminado_en TIMESTAMPTZ,
  eliminado_por_usuario_id UUID,
  CONSTRAINT ck_activo_costo_adquisicion CHECK (costo_adquisicion > 0),
  CONSTRAINT ck_activo_tiempo_vida_meses CHECK (tiempo_vida_meses > 0),
  CONSTRAINT ck_activo_depreciacion_mensual CHECK (depreciacion_mensual >= 0),
  CONSTRAINT ck_activo_importe_base_recuperable CHECK (importe_base_recuperable >= 0),
  CONSTRAINT ck_activo_fechas_depreciacion CHECK (fecha_fin_depreciacion >= fecha_inicio_depreciacion),
  CONSTRAINT ck_activo_estado CHECK (estado IN ('ACTIVO', 'PARADO', 'EN_TRASLADO', 'BAJA'))
);

ALTER TABLE activo ADD CONSTRAINT fk_activo_empresa FOREIGN KEY (id_empresa) REFERENCES empresa (id) ON DELETE RESTRICT;
ALTER TABLE activo ADD CONSTRAINT fk_activo_clasificacion_activo FOREIGN KEY (id_clasificacion_activo) REFERENCES clasificacion_activo (id) ON DELETE RESTRICT;
ALTER TABLE activo ADD CONSTRAINT fk_activo_tipo_adquisicion_activo FOREIGN KEY (id_tipo_adquisicion_activo) REFERENCES tipo_adquisicion_activo (id) ON DELETE RESTRICT;
ALTER TABLE activo ADD CONSTRAINT fk_activo_creado_por FOREIGN KEY (creado_por_usuario_id) REFERENCES usuario (id) ON DELETE RESTRICT;
ALTER TABLE activo ADD CONSTRAINT fk_activo_actualizado_por FOREIGN KEY (actualizado_por_usuario_id) REFERENCES usuario (id) ON DELETE RESTRICT;
ALTER TABLE activo ADD CONSTRAINT fk_activo_eliminado_por FOREIGN KEY (eliminado_por_usuario_id) REFERENCES usuario (id) ON DELETE RESTRICT;

-- >>> entidad_herramienta.sql
CREATE TABLE herramienta (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_empresa UUID NOT NULL,
  id_tipo_herramienta UUID,
  codigo STRING,
  descripcion STRING,
  marca STRING,
  modelo STRING,
  numero_serie STRING,
  costo_adquisicion DECIMAL(18,2),
  tiempo_vida_meses INT,
  fecha_inicio_depreciacion DATE,
  fecha_fin_depreciacion DATE,
  estado STRING NOT NULL DEFAULT 'ACTIVO',
  creado_en TIMESTAMPTZ NOT NULL DEFAULT now(),
  creado_por_usuario_id UUID,
  actualizado_en TIMESTAMPTZ NOT NULL DEFAULT now(),
  actualizado_por_usuario_id UUID,
  eliminado_en TIMESTAMPTZ,
  eliminado_por_usuario_id UUID,
  CONSTRAINT ck_herramienta_costo_adquisicion CHECK (costo_adquisicion >= 0),
  CONSTRAINT ck_herramienta_tiempo_vida_meses CHECK (tiempo_vida_meses > 0),
  CONSTRAINT ck_herramienta_fechas_depreciacion CHECK (fecha_fin_depreciacion >= fecha_inicio_depreciacion),
  CONSTRAINT ck_herramienta_estado CHECK (estado IN ('ACTIVO', 'BAJA'))
);

ALTER TABLE herramienta ADD CONSTRAINT fk_herramienta_empresa FOREIGN KEY (id_empresa) REFERENCES empresa (id) ON DELETE RESTRICT;
ALTER TABLE herramienta ADD CONSTRAINT fk_herramienta_tipo_herramienta FOREIGN KEY (id_tipo_herramienta) REFERENCES tipo_herramienta (id) ON DELETE RESTRICT;
ALTER TABLE herramienta ADD CONSTRAINT fk_herramienta_creado_por FOREIGN KEY (creado_por_usuario_id) REFERENCES usuario (id) ON DELETE RESTRICT;
ALTER TABLE herramienta ADD CONSTRAINT fk_herramienta_actualizado_por FOREIGN KEY (actualizado_por_usuario_id) REFERENCES usuario (id) ON DELETE RESTRICT;
ALTER TABLE herramienta ADD CONSTRAINT fk_herramienta_eliminado_por FOREIGN KEY (eliminado_por_usuario_id) REFERENCES usuario (id) ON DELETE RESTRICT;

-- >>> entidad_relacion_activo_asignacion_contrato.sql
CREATE TABLE activo_asignacion_contrato (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_empresa UUID NOT NULL,
  id_activo UUID NOT NULL,
  id_contrato UUID NOT NULL,
  id_zona UUID NOT NULL,
  inversion_asignada DECIMAL(18,2) NOT NULL,
  saldo_inversion_pendiente DECIMAL(18,2) NOT NULL,
  cuota_recuperacion_mensual DECIMAL(18,2) NOT NULL,
  fecha_inicio DATE NOT NULL,
  fecha_fin DATE,
  estado STRING NOT NULL DEFAULT 'ACTIVO',
  creado_en TIMESTAMPTZ NOT NULL DEFAULT now(),
  creado_por_usuario_id UUID,
  actualizado_en TIMESTAMPTZ NOT NULL DEFAULT now(),
  actualizado_por_usuario_id UUID,
  eliminado_en TIMESTAMPTZ,
  eliminado_por_usuario_id UUID,
  CONSTRAINT ck_activo_asignacion_contrato_inversion CHECK (inversion_asignada >= 0),
  CONSTRAINT ck_activo_asignacion_contrato_saldo CHECK (saldo_inversion_pendiente >= 0),
  CONSTRAINT ck_activo_asignacion_contrato_cuota CHECK (cuota_recuperacion_mensual >= 0),
  CONSTRAINT ck_activo_asignacion_contrato_fechas CHECK (fecha_fin >= fecha_inicio),
  CONSTRAINT ck_activo_asignacion_contrato_estado CHECK (estado IN ('ACTIVO', 'CERRADO', 'TRASLADADO')),
  CONSTRAINT uq_activo_asignacion_contrato UNIQUE (id_activo, id_contrato, id_zona, fecha_inicio)
);

ALTER TABLE activo_asignacion_contrato ADD CONSTRAINT fk_activo_asignacion_contrato_empresa FOREIGN KEY (id_empresa) REFERENCES empresa (id) ON DELETE RESTRICT;
ALTER TABLE activo_asignacion_contrato ADD CONSTRAINT fk_activo_asignacion_contrato_activo FOREIGN KEY (id_activo) REFERENCES activo (id) ON DELETE RESTRICT;
ALTER TABLE activo_asignacion_contrato ADD CONSTRAINT fk_activo_asignacion_contrato_contrato FOREIGN KEY (id_contrato) REFERENCES contrato (id) ON DELETE RESTRICT;
ALTER TABLE activo_asignacion_contrato ADD CONSTRAINT fk_activo_asignacion_contrato_zona FOREIGN KEY (id_zona) REFERENCES zona (id) ON DELETE RESTRICT;
ALTER TABLE activo_asignacion_contrato ADD CONSTRAINT fk_activo_asignacion_contrato_creado_por FOREIGN KEY (creado_por_usuario_id) REFERENCES usuario (id) ON DELETE RESTRICT;
ALTER TABLE activo_asignacion_contrato ADD CONSTRAINT fk_activo_asignacion_contrato_actualizado_por FOREIGN KEY (actualizado_por_usuario_id) REFERENCES usuario (id) ON DELETE RESTRICT;
ALTER TABLE activo_asignacion_contrato ADD CONSTRAINT fk_activo_asignacion_contrato_eliminado_por FOREIGN KEY (eliminado_por_usuario_id) REFERENCES usuario (id) ON DELETE RESTRICT;

-- >>> entidad_activo_registro_trabajo.sql
CREATE TABLE activo_registro_trabajo (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_empresa UUID NOT NULL,
  id_activo UUID NOT NULL,
  id_contrato UUID NOT NULL,
  id_zona UUID,
  id_operario UUID,
  id_periodo UUID NOT NULL,
  fecha DATE NOT NULL,
  fecha_hora_inicio TIMESTAMPTZ,
  fecha_hora_fin TIMESTAMPTZ,
  horas_trabajadas DECIMAL(6,2),
  descripcion_trabajo STRING,
  valorizacion_trabajo DECIMAL(18,2),
  dias_depreciados DECIMAL(6,2),
  kilometraje_inicio INT,
  kilometraje_fin INT,
  creado_en TIMESTAMPTZ NOT NULL DEFAULT now(),
  creado_por_usuario_id UUID,
  actualizado_en TIMESTAMPTZ NOT NULL DEFAULT now(),
  actualizado_por_usuario_id UUID,
  eliminado_en TIMESTAMPTZ,
  eliminado_por_usuario_id UUID,
  CONSTRAINT ck_activo_registro_trabajo_horas CHECK (horas_trabajadas >= 0),
  CONSTRAINT ck_activo_registro_trabajo_valorizacion CHECK (valorizacion_trabajo >= 0),
  CONSTRAINT ck_activo_registro_trabajo_dias CHECK (dias_depreciados >= 0),
  CONSTRAINT ck_activo_registro_trabajo_kilometraje CHECK (kilometraje_fin >= kilometraje_inicio)
);

ALTER TABLE activo_registro_trabajo ADD CONSTRAINT fk_activo_registro_trabajo_empresa FOREIGN KEY (id_empresa) REFERENCES empresa (id) ON DELETE RESTRICT;
ALTER TABLE activo_registro_trabajo ADD CONSTRAINT fk_activo_registro_trabajo_activo FOREIGN KEY (id_activo) REFERENCES activo (id) ON DELETE RESTRICT;
ALTER TABLE activo_registro_trabajo ADD CONSTRAINT fk_activo_registro_trabajo_contrato FOREIGN KEY (id_contrato) REFERENCES contrato (id) ON DELETE RESTRICT;
ALTER TABLE activo_registro_trabajo ADD CONSTRAINT fk_activo_registro_trabajo_zona FOREIGN KEY (id_zona) REFERENCES zona (id) ON DELETE RESTRICT;
ALTER TABLE activo_registro_trabajo ADD CONSTRAINT fk_activo_registro_trabajo_periodo FOREIGN KEY (id_periodo) REFERENCES periodo (id) ON DELETE RESTRICT;
ALTER TABLE activo_registro_trabajo ADD CONSTRAINT fk_activo_registro_trabajo_creado_por FOREIGN KEY (creado_por_usuario_id) REFERENCES usuario (id) ON DELETE RESTRICT;
ALTER TABLE activo_registro_trabajo ADD CONSTRAINT fk_activo_registro_trabajo_actualizado_por FOREIGN KEY (actualizado_por_usuario_id) REFERENCES usuario (id) ON DELETE RESTRICT;
ALTER TABLE activo_registro_trabajo ADD CONSTRAINT fk_activo_registro_trabajo_eliminado_por FOREIGN KEY (eliminado_por_usuario_id) REFERENCES usuario (id) ON DELETE RESTRICT;

-- >>> entidad_activo_traslado.sql
CREATE TABLE activo_traslado (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_empresa UUID NOT NULL,
  id_activo UUID NOT NULL,
  id_contrato_origen UUID,
  id_zona_origen UUID,
  id_contrato_destino UUID,
  id_zona_destino UUID,
  fecha_traslado DATE NOT NULL,
  saldo_trasladado DECIMAL(18,2),
  motivo STRING,
  creado_en TIMESTAMPTZ NOT NULL DEFAULT now(),
  creado_por_usuario_id UUID,
  CONSTRAINT ck_activo_traslado_saldo CHECK (saldo_trasladado >= 0)
);

ALTER TABLE activo_traslado ADD CONSTRAINT fk_activo_traslado_empresa FOREIGN KEY (id_empresa) REFERENCES empresa (id) ON DELETE RESTRICT;
ALTER TABLE activo_traslado ADD CONSTRAINT fk_activo_traslado_activo FOREIGN KEY (id_activo) REFERENCES activo (id) ON DELETE RESTRICT;
ALTER TABLE activo_traslado ADD CONSTRAINT fk_activo_traslado_contrato_origen FOREIGN KEY (id_contrato_origen) REFERENCES contrato (id) ON DELETE RESTRICT;
ALTER TABLE activo_traslado ADD CONSTRAINT fk_activo_traslado_zona_origen FOREIGN KEY (id_zona_origen) REFERENCES zona (id) ON DELETE RESTRICT;
ALTER TABLE activo_traslado ADD CONSTRAINT fk_activo_traslado_contrato_destino FOREIGN KEY (id_contrato_destino) REFERENCES contrato (id) ON DELETE RESTRICT;
ALTER TABLE activo_traslado ADD CONSTRAINT fk_activo_traslado_zona_destino FOREIGN KEY (id_zona_destino) REFERENCES zona (id) ON DELETE RESTRICT;
ALTER TABLE activo_traslado ADD CONSTRAINT fk_activo_traslado_creado_por FOREIGN KEY (creado_por_usuario_id) REFERENCES usuario (id) ON DELETE RESTRICT;

-- >>> entidad_recuperacion_inversion_mensual.sql
CREATE TABLE recuperacion_inversion_mensual (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_empresa UUID NOT NULL,
  id_activo UUID NOT NULL,
  id_contrato UUID NOT NULL,
  id_periodo UUID NOT NULL,
  importe_recuperado DECIMAL(18,2) NOT NULL,
  saldo_antes DECIMAL(18,2),
  saldo_despues DECIMAL(18,2),
  parado BOOL NOT NULL DEFAULT false,
  creado_en TIMESTAMPTZ NOT NULL DEFAULT now(),
  creado_por_usuario_id UUID,
  CONSTRAINT ck_recuperacion_inversion_mensual_importe CHECK (importe_recuperado >= 0),
  CONSTRAINT ck_recuperacion_inversion_mensual_saldo_antes CHECK (saldo_antes >= 0),
  CONSTRAINT ck_recuperacion_inversion_mensual_saldo_despues CHECK (saldo_despues >= 0),
  CONSTRAINT uq_recuperacion_inversion_mensual UNIQUE (id_activo, id_contrato, id_periodo)
);

ALTER TABLE recuperacion_inversion_mensual ADD CONSTRAINT fk_recuperacion_inversion_mensual_empresa FOREIGN KEY (id_empresa) REFERENCES empresa (id) ON DELETE RESTRICT;
ALTER TABLE recuperacion_inversion_mensual ADD CONSTRAINT fk_recuperacion_inversion_mensual_activo FOREIGN KEY (id_activo) REFERENCES activo (id) ON DELETE RESTRICT;
ALTER TABLE recuperacion_inversion_mensual ADD CONSTRAINT fk_recuperacion_inversion_mensual_contrato FOREIGN KEY (id_contrato) REFERENCES contrato (id) ON DELETE RESTRICT;
ALTER TABLE recuperacion_inversion_mensual ADD CONSTRAINT fk_recuperacion_inversion_mensual_periodo FOREIGN KEY (id_periodo) REFERENCES periodo (id) ON DELETE RESTRICT;
ALTER TABLE recuperacion_inversion_mensual ADD CONSTRAINT fk_recuperacion_inversion_mensual_creado_por FOREIGN KEY (creado_por_usuario_id) REFERENCES usuario (id) ON DELETE RESTRICT;

-- >>> entidad_herramienta_movimiento.sql
CREATE TABLE herramienta_movimiento (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_empresa UUID NOT NULL,
  id_herramienta UUID NOT NULL,
  id_periodo UUID NOT NULL,
  tipo_movimiento STRING NOT NULL,
  fecha DATE NOT NULL,
  id_contrato_origen UUID,
  id_zona_origen UUID,
  id_contrato_destino UUID,
  id_zona_destino UUID,
  cantidad DECIMAL(10,2),
  costo DECIMAL(18,2),
  valorizacion DECIMAL(18,2),
  motivo STRING,
  creado_en TIMESTAMPTZ NOT NULL DEFAULT now(),
  creado_por_usuario_id UUID,
  CONSTRAINT ck_herramienta_movimiento_tipo CHECK (tipo_movimiento IN ('ENTRADA', 'SALIDA', 'TRASLADO', 'BAJA')),
  CONSTRAINT ck_herramienta_movimiento_cantidad CHECK (cantidad >= 0),
  CONSTRAINT ck_herramienta_movimiento_costo CHECK (costo >= 0),
  CONSTRAINT ck_herramienta_movimiento_valorizacion CHECK (valorizacion >= 0)
);

ALTER TABLE herramienta_movimiento ADD CONSTRAINT fk_herramienta_movimiento_empresa FOREIGN KEY (id_empresa) REFERENCES empresa (id) ON DELETE RESTRICT;
ALTER TABLE herramienta_movimiento ADD CONSTRAINT fk_herramienta_movimiento_herramienta FOREIGN KEY (id_herramienta) REFERENCES herramienta (id) ON DELETE RESTRICT;
ALTER TABLE herramienta_movimiento ADD CONSTRAINT fk_herramienta_movimiento_periodo FOREIGN KEY (id_periodo) REFERENCES periodo (id) ON DELETE RESTRICT;
ALTER TABLE herramienta_movimiento ADD CONSTRAINT fk_herramienta_movimiento_contrato_origen FOREIGN KEY (id_contrato_origen) REFERENCES contrato (id) ON DELETE RESTRICT;
ALTER TABLE herramienta_movimiento ADD CONSTRAINT fk_herramienta_movimiento_zona_origen FOREIGN KEY (id_zona_origen) REFERENCES zona (id) ON DELETE RESTRICT;
ALTER TABLE herramienta_movimiento ADD CONSTRAINT fk_herramienta_movimiento_contrato_destino FOREIGN KEY (id_contrato_destino) REFERENCES contrato (id) ON DELETE RESTRICT;
ALTER TABLE herramienta_movimiento ADD CONSTRAINT fk_herramienta_movimiento_zona_destino FOREIGN KEY (id_zona_destino) REFERENCES zona (id) ON DELETE RESTRICT;
ALTER TABLE herramienta_movimiento ADD CONSTRAINT fk_herramienta_movimiento_creado_por FOREIGN KEY (creado_por_usuario_id) REFERENCES usuario (id) ON DELETE RESTRICT;

-- >>> entidad_penalidad.sql
CREATE TABLE penalidad (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_empresa UUID NOT NULL,
  id_contrato UUID NOT NULL,
  id_periodo UUID NOT NULL,
  descripcion STRING,
  importe DECIMAL(18,2) NOT NULL,
  creado_en TIMESTAMPTZ NOT NULL DEFAULT now(),
  creado_por_usuario_id UUID,
  actualizado_en TIMESTAMPTZ NOT NULL DEFAULT now(),
  actualizado_por_usuario_id UUID,
  eliminado_en TIMESTAMPTZ,
  eliminado_por_usuario_id UUID,
  CONSTRAINT ck_penalidad_importe CHECK (importe > 0)
);

ALTER TABLE penalidad ADD CONSTRAINT fk_penalidad_empresa FOREIGN KEY (id_empresa) REFERENCES empresa (id) ON DELETE RESTRICT;
ALTER TABLE penalidad ADD CONSTRAINT fk_penalidad_contrato FOREIGN KEY (id_contrato) REFERENCES contrato (id) ON DELETE RESTRICT;
ALTER TABLE penalidad ADD CONSTRAINT fk_penalidad_periodo FOREIGN KEY (id_periodo) REFERENCES periodo (id) ON DELETE RESTRICT;
ALTER TABLE penalidad ADD CONSTRAINT fk_penalidad_creado_por FOREIGN KEY (creado_por_usuario_id) REFERENCES usuario (id) ON DELETE RESTRICT;
ALTER TABLE penalidad ADD CONSTRAINT fk_penalidad_actualizado_por FOREIGN KEY (actualizado_por_usuario_id) REFERENCES usuario (id) ON DELETE RESTRICT;
ALTER TABLE penalidad ADD CONSTRAINT fk_penalidad_eliminado_por FOREIGN KEY (eliminado_por_usuario_id) REFERENCES usuario (id) ON DELETE RESTRICT;

-- >>> entidad_provision.sql
CREATE TABLE provision (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_empresa UUID NOT NULL,
  id_contrato UUID,
  id_periodo UUID NOT NULL,
  descripcion STRING,
  importe DECIMAL(18,2) NOT NULL,
  aplicado BOOL NOT NULL DEFAULT false,
  creado_en TIMESTAMPTZ NOT NULL DEFAULT now(),
  creado_por_usuario_id UUID,
  actualizado_en TIMESTAMPTZ NOT NULL DEFAULT now(),
  actualizado_por_usuario_id UUID,
  eliminado_en TIMESTAMPTZ,
  eliminado_por_usuario_id UUID,
  CONSTRAINT ck_provision_importe CHECK (importe > 0)
);

ALTER TABLE provision ADD CONSTRAINT fk_provision_empresa FOREIGN KEY (id_empresa) REFERENCES empresa (id) ON DELETE RESTRICT;
ALTER TABLE provision ADD CONSTRAINT fk_provision_contrato FOREIGN KEY (id_contrato) REFERENCES contrato (id) ON DELETE RESTRICT;
ALTER TABLE provision ADD CONSTRAINT fk_provision_periodo FOREIGN KEY (id_periodo) REFERENCES periodo (id) ON DELETE RESTRICT;
ALTER TABLE provision ADD CONSTRAINT fk_provision_creado_por FOREIGN KEY (creado_por_usuario_id) REFERENCES usuario (id) ON DELETE RESTRICT;
ALTER TABLE provision ADD CONSTRAINT fk_provision_actualizado_por FOREIGN KEY (actualizado_por_usuario_id) REFERENCES usuario (id) ON DELETE RESTRICT;
ALTER TABLE provision ADD CONSTRAINT fk_provision_eliminado_por FOREIGN KEY (eliminado_por_usuario_id) REFERENCES usuario (id) ON DELETE RESTRICT;

-- >>> entidad_cierre_mensual.sql
CREATE TABLE cierre_mensual (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_empresa UUID NOT NULL,
  id_contrato UUID NOT NULL,
  id_periodo UUID NOT NULL,
  total_facturado DECIMAL(18,2) NOT NULL DEFAULT 0,
  total_produccion DECIMAL(18,2) NOT NULL DEFAULT 0,
  gastos_directos DECIMAL(18,2) NOT NULL DEFAULT 0,
  gastos_varios_fijos DECIMAL(18,2) NOT NULL DEFAULT 0,
  gastos_iniciales_periodo DECIMAL(18,2) NOT NULL DEFAULT 0,
  recuperacion_inversion DECIMAL(18,2) NOT NULL DEFAULT 0,
  gastos_administrativos DECIMAL(18,2) NOT NULL DEFAULT 0,
  gastos_indirectos DECIMAL(18,2) NOT NULL DEFAULT 0,
  gastos_financieros DECIMAL(18,2) NOT NULL DEFAULT 0,
  gastos_sig DECIMAL(18,2) NOT NULL DEFAULT 0,
  total_gastos DECIMAL(18,2) NOT NULL DEFAULT 0,
  utilidad_bruta DECIMAL(18,2) NOT NULL DEFAULT 0,
  impuesto_renta DECIMAL(18,2) NOT NULL DEFAULT 0,
  renta_adicional DECIMAL(18,2) NOT NULL DEFAULT 0,
  reparto_utilidades DECIMAL(18,2) NOT NULL DEFAULT 0,
  penalidades DECIMAL(18,2) NOT NULL DEFAULT 0,
  utilidad_neta DECIMAL(18,2) NOT NULL DEFAULT 0,
  utilidad_final DECIMAL(18,2) NOT NULL DEFAULT 0,
  estado STRING NOT NULL DEFAULT 'BORRADOR',
  fecha_cierre TIMESTAMPTZ,
  cerrado_por_usuario_id UUID,
  creado_en TIMESTAMPTZ NOT NULL DEFAULT now(),
  creado_por_usuario_id UUID,
  actualizado_en TIMESTAMPTZ NOT NULL DEFAULT now(),
  actualizado_por_usuario_id UUID,
  eliminado_en TIMESTAMPTZ,
  eliminado_por_usuario_id UUID,
  CONSTRAINT ck_cierre_mensual_total_facturado CHECK (total_facturado >= 0),
  CONSTRAINT ck_cierre_mensual_total_produccion CHECK (total_produccion >= 0),
  CONSTRAINT ck_cierre_mensual_gastos_directos CHECK (gastos_directos >= 0),
  CONSTRAINT ck_cierre_mensual_gastos_varios_fijos CHECK (gastos_varios_fijos >= 0),
  CONSTRAINT ck_cierre_mensual_gastos_iniciales_periodo CHECK (gastos_iniciales_periodo >= 0),
  CONSTRAINT ck_cierre_mensual_recuperacion_inversion CHECK (recuperacion_inversion >= 0),
  CONSTRAINT ck_cierre_mensual_gastos_administrativos CHECK (gastos_administrativos >= 0),
  CONSTRAINT ck_cierre_mensual_gastos_indirectos CHECK (gastos_indirectos >= 0),
  CONSTRAINT ck_cierre_mensual_gastos_financieros CHECK (gastos_financieros >= 0),
  CONSTRAINT ck_cierre_mensual_gastos_sig CHECK (gastos_sig >= 0),
  CONSTRAINT ck_cierre_mensual_total_gastos CHECK (total_gastos >= 0),
  CONSTRAINT ck_cierre_mensual_impuesto_renta CHECK (impuesto_renta >= 0),
  CONSTRAINT ck_cierre_mensual_renta_adicional CHECK (renta_adicional >= 0),
  CONSTRAINT ck_cierre_mensual_reparto_utilidades CHECK (reparto_utilidades >= 0),
  CONSTRAINT ck_cierre_mensual_estado CHECK (estado IN ('BORRADOR', 'CERRADO', 'REABIERTO')),
  CONSTRAINT uq_cierre_mensual UNIQUE (id_contrato, id_periodo)
);

ALTER TABLE cierre_mensual ADD CONSTRAINT fk_cierre_mensual_empresa FOREIGN KEY (id_empresa) REFERENCES empresa (id) ON DELETE RESTRICT;
ALTER TABLE cierre_mensual ADD CONSTRAINT fk_cierre_mensual_contrato FOREIGN KEY (id_contrato) REFERENCES contrato (id) ON DELETE RESTRICT;
ALTER TABLE cierre_mensual ADD CONSTRAINT fk_cierre_mensual_periodo FOREIGN KEY (id_periodo) REFERENCES periodo (id) ON DELETE RESTRICT;
ALTER TABLE cierre_mensual ADD CONSTRAINT fk_cierre_mensual_cerrado_por FOREIGN KEY (cerrado_por_usuario_id) REFERENCES usuario (id) ON DELETE RESTRICT;
ALTER TABLE cierre_mensual ADD CONSTRAINT fk_cierre_mensual_creado_por FOREIGN KEY (creado_por_usuario_id) REFERENCES usuario (id) ON DELETE RESTRICT;
ALTER TABLE cierre_mensual ADD CONSTRAINT fk_cierre_mensual_actualizado_por FOREIGN KEY (actualizado_por_usuario_id) REFERENCES usuario (id) ON DELETE RESTRICT;
ALTER TABLE cierre_mensual ADD CONSTRAINT fk_cierre_mensual_eliminado_por FOREIGN KEY (eliminado_por_usuario_id) REFERENCES usuario (id) ON DELETE RESTRICT;

-- ---- INDICES ----
-- >>> indice_activo.sql
CREATE INDEX indice_activo_estado ON activo (id_empresa, estado) WHERE eliminado_en IS NULL;
CREATE INDEX indice_activo_listado ON activo (id_empresa, creado_en DESC, id DESC) STORING (codigo, descripcion, estado, placa, marca, modelo, anio_fabricacion, costo_adquisicion, id_clasificacion_activo, id_tipo_adquisicion_activo) WHERE eliminado_en IS NULL;

-- >>> indice_activo_asignacion_contrato.sql
CREATE INDEX indice_activo_asignacion_contrato_activo ON activo_asignacion_contrato (id_activo, id_contrato);
CREATE INDEX indice_activo_asignacion_contrato_empresa ON activo_asignacion_contrato (id_empresa);
CREATE INDEX indice_activo_asignacion_contrato_estado ON activo_asignacion_contrato (id_activo, id_contrato) WHERE estado = 'ACTIVO';
CREATE INDEX indice_activo_asignacion_contrato_listado ON activo_asignacion_contrato (id_empresa, id_activo, creado_en DESC, id DESC) STORING (id_contrato, id_zona, inversion_asignada, saldo_inversion_pendiente, cuota_recuperacion_mensual, fecha_inicio, fecha_fin, estado) WHERE eliminado_en IS NULL;

-- >>> indice_activo_registro_trabajo.sql
CREATE INDEX indice_activo_registro_trabajo_activo ON activo_registro_trabajo (id_activo, id_periodo);
CREATE INDEX indice_activo_registro_trabajo_contrato ON activo_registro_trabajo (id_contrato, id_periodo);
CREATE INDEX indice_activo_registro_trabajo_listado ON activo_registro_trabajo (id_empresa, id_activo, creado_en DESC, id DESC) STORING (id_contrato, id_zona, id_operario, id_periodo, fecha, horas_trabajadas, descripcion_trabajo, valorizacion_trabajo, dias_depreciados, kilometraje_inicio, kilometraje_fin) WHERE eliminado_en IS NULL;

-- >>> indice_activo_traslado.sql
CREATE INDEX indice_activo_traslado_activo ON activo_traslado (id_activo);
CREATE INDEX indice_activo_traslado_listado ON activo_traslado (id_empresa, id_activo, creado_en DESC, id DESC) STORING (id_contrato_origen, id_zona_origen, id_contrato_destino, id_zona_destino, fecha_traslado, saldo_trasladado, motivo);

-- >>> indice_clasificacion_activo.sql
CREATE UNIQUE INDEX indice_clasificacion_activo_codigo ON clasificacion_activo (id_empresa, codigo) WHERE eliminado_en IS NULL;

-- >>> indice_herramienta.sql
CREATE INDEX indice_herramienta_listado ON herramienta (id_empresa, creado_en DESC, id DESC) STORING (codigo, descripcion, marca, modelo, numero_serie, estado, costo_adquisicion, id_tipo_herramienta) WHERE eliminado_en IS NULL;

-- >>> indice_herramienta_movimiento.sql
CREATE INDEX indice_herramienta_movimiento_periodo ON herramienta_movimiento (id_empresa, id_periodo);
CREATE INDEX indice_herramienta_movimiento_origen ON herramienta_movimiento (id_contrato_origen);
CREATE INDEX indice_herramienta_movimiento_destino ON herramienta_movimiento (id_contrato_destino);
CREATE INDEX indice_herramienta_movimiento_listado ON herramienta_movimiento (id_empresa, id_herramienta, creado_en DESC, id DESC) STORING (tipo_movimiento, fecha, id_periodo, id_contrato_origen, id_zona_origen, id_contrato_destino, id_zona_destino, cantidad, costo, valorizacion, motivo);

-- >>> indice_recuperacion_inversion_mensual.sql
CREATE INDEX indice_recuperacion_inversion_mensual_contrato ON recuperacion_inversion_mensual (id_contrato, id_periodo);
CREATE INDEX indice_recuperacion_inversion_mensual_activo ON recuperacion_inversion_mensual (id_activo);
CREATE INDEX indice_recuperacion_inversion_mensual_listado ON recuperacion_inversion_mensual (id_empresa, creado_en DESC, id DESC) STORING (id_activo, id_contrato, id_periodo, importe_recuperado, saldo_antes, saldo_despues, parado);

-- >>> indice_tipo_adquisicion_activo.sql
CREATE UNIQUE INDEX indice_tipo_adquisicion_activo_codigo ON tipo_adquisicion_activo (id_empresa, codigo) WHERE eliminado_en IS NULL;

-- >>> indice_tipo_herramienta.sql
CREATE UNIQUE INDEX indice_tipo_herramienta_codigo ON tipo_herramienta (id_empresa, codigo) WHERE eliminado_en IS NULL;

-- >>> indice_cierre_mensual.sql
CREATE INDEX indice_cierre_mensual_estado ON cierre_mensual (id_empresa, estado);
CREATE INDEX indice_cierre_mensual_listado ON cierre_mensual (id_empresa, creado_en DESC, id DESC) STORING (id_contrato, id_periodo, total_facturado, total_gastos, utilidad_bruta, utilidad_neta, utilidad_final, estado, fecha_cierre) WHERE eliminado_en IS NULL;

-- >>> indice_penalidad.sql
CREATE INDEX indice_penalidad_contrato_periodo ON penalidad (id_contrato, id_periodo);
CREATE INDEX indice_penalidad_listado ON penalidad (id_empresa, creado_en DESC, id DESC) STORING (id_contrato, id_periodo, descripcion, importe) WHERE eliminado_en IS NULL;

-- >>> indice_provision.sql
CREATE INDEX indice_provision_contrato_periodo ON provision (id_contrato, id_periodo);
CREATE INDEX indice_provision_listado ON provision (id_empresa, creado_en DESC, id DESC) STORING (id_contrato, id_periodo, descripcion, importe, aplicado) WHERE eliminado_en IS NULL;

-- ---- PROCEDIMIENTOS (26) ----
-- >>> fn_registrar_activo.sql
CREATE OR REPLACE FUNCTION fn_registrar_activo(
  p_id_empresa UUID,
  p_id_usuario_accion UUID,
  p_id_clasificacion_activo UUID,
  p_id_tipo_adquisicion_activo UUID,
  p_codigo STRING,
  p_descripcion STRING,
  p_placa STRING,
  p_marca STRING,
  p_modelo STRING,
  p_numero_serie STRING,
  p_anio_fabricacion INT2,
  p_costo_adquisicion DECIMAL,
  p_tiempo_vida_meses INT,
  p_depreciacion_mensual DECIMAL,
  p_importe_base_recuperable DECIMAL,
  p_fecha_inicio_depreciacion DATE,
  p_fecha_fin_depreciacion DATE
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_id_activo UUID;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  IF p_descripcion IS NULL OR char_length(trim(p_descripcion)) = 0 THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'DESCRIPCION_OBLIGATORIA', 'mensaje', 'La descripcion del activo es obligatoria');
  END IF;

  IF p_costo_adquisicion IS NULL OR p_costo_adquisicion <= 0 THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'COSTO_INVALIDO', 'mensaje', 'El costo de adquisicion debe ser mayor a 0');
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM clasificacion_activo
    WHERE id = p_id_clasificacion_activo AND id_empresa = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL
  ) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'CLASIFICACION_ACTIVO_NO_VALIDA', 'mensaje', 'La clasificacion no existe o no pertenece a la empresa');
  END IF;

  IF p_id_tipo_adquisicion_activo IS NOT NULL AND NOT EXISTS (
    SELECT 1 FROM tipo_adquisicion_activo
    WHERE id = p_id_tipo_adquisicion_activo AND id_empresa = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL
  ) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'TIPO_ADQUISICION_NO_VALIDO', 'mensaje', 'El tipo de adquisicion no existe o no pertenece a la empresa');
  END IF;

  INSERT INTO activo (
    id_empresa, id_clasificacion_activo, id_tipo_adquisicion_activo,
    codigo, descripcion, placa, marca, modelo, numero_serie,
    anio_fabricacion, costo_adquisicion, tiempo_vida_meses,
    depreciacion_mensual, importe_base_recuperable,
    fecha_inicio_depreciacion, fecha_fin_depreciacion,
    creado_por_usuario_id
  ) VALUES (
    p_id_empresa, p_id_clasificacion_activo, p_id_tipo_adquisicion_activo,
    NULLIF(trim(p_codigo), ''), trim(p_descripcion), NULLIF(trim(p_placa), ''),
    NULLIF(trim(p_marca), ''), NULLIF(trim(p_modelo), ''), NULLIF(trim(p_numero_serie), ''),
    p_anio_fabricacion, p_costo_adquisicion, p_tiempo_vida_meses,
    p_depreciacion_mensual, p_importe_base_recuperable,
    p_fecha_inicio_depreciacion, p_fecha_fin_depreciacion,
    p_id_usuario_accion
  ) RETURNING id INTO v_id_activo;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'ACTIVO_REGISTRADO',
    'mensaje', 'El activo fue registrado correctamente',
    'datos', jsonb_build_object('id_activo', v_id_activo)
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'ACTIVO_REGISTRO_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al registrar el activo');
END;
$$;

-- >>> fn_asignar_activo_a_contrato.sql
CREATE OR REPLACE FUNCTION fn_asignar_activo_a_contrato(
  p_id_empresa UUID,
  p_id_usuario_accion UUID,
  p_id_activo UUID,
  p_id_contrato UUID,
  p_id_zona UUID,
  p_inversion_asignada DECIMAL,
  p_cuota_recuperacion_mensual DECIMAL,
  p_fecha_inicio DATE
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_id_asignacion UUID;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM activo
    WHERE id = p_id_activo AND id_empresa = p_id_empresa AND eliminado_en IS NULL AND estado <> 'BAJA'
  ) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'ACTIVO_NO_DISPONIBLE', 'mensaje', 'El activo no existe, no pertenece a la empresa o esta dado de baja');
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM contrato
    WHERE id = p_id_contrato AND id_empresa = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL
  ) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'CONTRATO_NO_VALIDO', 'mensaje', 'El contrato no existe, no pertenece a la empresa o no esta vigente');
  END IF;

  IF EXISTS (
    SELECT 1 FROM activo_asignacion_contrato
    WHERE id_activo = p_id_activo AND id_contrato = p_id_contrato AND eliminado_en IS NULL AND estado = 'ACTIVO'
  ) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'ACTIVO_YA_ASIGNADO', 'mensaje', 'El activo ya tiene una asignacion vigente en ese contrato');
  END IF;

  IF p_id_zona IS NULL THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'ZONA_OBLIGATORIA', 'mensaje', 'La zona es obligatoria para asignar el activo al contrato');
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM zona
    WHERE id = p_id_zona AND id_empresa = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL
  ) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'ZONA_NO_VALIDA', 'mensaje', 'La zona no existe, no pertenece a la empresa o no esta vigente');
  END IF;

  INSERT INTO activo_asignacion_contrato (
    id_empresa, id_activo, id_contrato, id_zona,
    inversion_asignada, saldo_inversion_pendiente, cuota_recuperacion_mensual, fecha_inicio,
    creado_por_usuario_id
  ) VALUES (
    p_id_empresa, p_id_activo, p_id_contrato, p_id_zona,
    p_inversion_asignada, p_inversion_asignada, p_cuota_recuperacion_mensual, p_fecha_inicio,
    p_id_usuario_accion
  ) RETURNING id INTO v_id_asignacion;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'ACTIVO_ASIGNADO',
    'mensaje', 'El activo fue asignado al contrato correctamente',
    'datos', jsonb_build_object('id_asignacion', v_id_asignacion)
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'ACTIVO_ASIGNACION_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al asignar el activo');
END;
$$;

-- >>> fn_registrar_trabajo_activo.sql
CREATE OR REPLACE FUNCTION fn_registrar_trabajo_activo(
  p_id_empresa UUID,
  p_id_usuario_accion UUID,
  p_id_activo UUID,
  p_id_contrato UUID,
  p_id_zona UUID,
  p_id_operario UUID,
  p_id_periodo UUID,
  p_fecha DATE,
  p_fecha_hora_inicio TIMESTAMPTZ,
  p_fecha_hora_fin TIMESTAMPTZ,
  p_horas_trabajadas DECIMAL,
  p_descripcion_trabajo STRING,
  p_valorizacion_trabajo DECIMAL,
  p_dias_depreciados DECIMAL,
  p_kilometraje_inicio INT,
  p_kilometraje_fin INT
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_id_registro UUID;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM activo
    WHERE id = p_id_activo AND id_empresa = p_id_empresa AND eliminado_en IS NULL AND estado <> 'BAJA'
  ) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'ACTIVO_NO_DISPONIBLE', 'mensaje', 'El activo no existe, no pertenece a la empresa o esta dado de baja');
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM contrato
    WHERE id = p_id_contrato AND id_empresa = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL
  ) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'CONTRATO_NO_VALIDO', 'mensaje', 'El contrato no existe, no pertenece a la empresa o no esta vigente');
  END IF;

  IF p_id_zona IS NOT NULL AND NOT EXISTS (
    SELECT 1 FROM zona
    WHERE id = p_id_zona AND id_empresa = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL
  ) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'ZONA_NO_VALIDA', 'mensaje', 'La zona no existe, no pertenece a la empresa o no esta vigente');
  END IF;

  IF p_fecha IS NULL THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'FECHA_OBLIGATORIA', 'mensaje', 'La fecha del trabajo es obligatoria');
  END IF;

  IF p_kilometraje_inicio IS NOT NULL AND p_kilometraje_fin IS NOT NULL AND p_kilometraje_fin < p_kilometraje_inicio THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'KILOMETRAJE_INVALIDO', 'mensaje', 'El kilometraje final no puede ser menor que el inicial');
  END IF;

  INSERT INTO activo_registro_trabajo (
    id_empresa, id_activo, id_contrato, id_zona, id_operario, id_periodo,
    fecha, fecha_hora_inicio, fecha_hora_fin, horas_trabajadas,
    descripcion_trabajo, valorizacion_trabajo, dias_depreciados,
    kilometraje_inicio, kilometraje_fin, creado_por_usuario_id
  ) VALUES (
    p_id_empresa, p_id_activo, p_id_contrato, p_id_zona, p_id_operario, p_id_periodo,
    p_fecha, p_fecha_hora_inicio, p_fecha_hora_fin, p_horas_trabajadas,
    NULLIF(trim(p_descripcion_trabajo), ''), p_valorizacion_trabajo, p_dias_depreciados,
    p_kilometraje_inicio, p_kilometraje_fin, p_id_usuario_accion
  ) RETURNING id INTO v_id_registro;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'TRABAJO_REGISTRADO',
    'mensaje', 'El trabajo del activo fue registrado correctamente',
    'datos', jsonb_build_object('id_registro_trabajo', v_id_registro)
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'TRABAJO_REGISTRO_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al registrar el trabajo del activo');
END;
$$;

-- >>> fn_ejecutar_recuperacion_mensual.sql
CREATE OR REPLACE FUNCTION fn_ejecutar_recuperacion_mensual(
  p_id_empresa UUID,
  p_id_usuario_accion UUID,
  p_id_activo UUID,
  p_id_contrato UUID,
  p_id_periodo UUID,
  p_parado BOOL
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_saldo_pendiente DECIMAL(18,2);
  v_cuota DECIMAL(18,2);
  v_importe DECIMAL(18,2);
  v_saldo_despues DECIMAL(18,2);
  v_id_recuperacion UUID;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM contrato
    WHERE id = p_id_contrato AND id_empresa = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL
  ) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'CONTRATO_NO_VALIDO', 'mensaje', 'El contrato no existe, no pertenece a la empresa o no esta vigente');
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM periodo
    WHERE id = p_id_periodo AND id_empresa = p_id_empresa AND eliminado_en IS NULL
  ) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'PERIODO_NO_VALIDO', 'mensaje', 'El periodo no existe o no pertenece a la empresa');
  END IF;

  SELECT saldo_inversion_pendiente, cuota_recuperacion_mensual
    INTO v_saldo_pendiente, v_cuota
  FROM activo_asignacion_contrato
  WHERE id_empresa = p_id_empresa AND id_activo = p_id_activo AND id_contrato = p_id_contrato AND eliminado_en IS NULL AND estado = 'ACTIVO';

  IF v_saldo_pendiente IS NULL THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'ACTIVO_NO_ASIGNADO_AL_CONTRATO', 'mensaje', 'El activo no esta asignado a ese contrato');
  END IF;

  IF EXISTS (
    SELECT 1 FROM recuperacion_inversion_mensual
    WHERE id_activo = p_id_activo AND id_contrato = p_id_contrato AND id_periodo = p_id_periodo
  ) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'RECUPERACION_YA_REGISTRADA', 'mensaje', 'Ya existe una recuperacion para ese activo, contrato y periodo');
  END IF;

  IF p_parado THEN
    v_importe := 0;
  ELSE
    v_importe := LEAST(COALESCE(v_cuota, 0), COALESCE(v_saldo_pendiente, 0));
  END IF;

  v_saldo_despues := COALESCE(v_saldo_pendiente, 0) - v_importe;

  INSERT INTO recuperacion_inversion_mensual (
    id_empresa, id_activo, id_contrato, id_periodo,
    importe_recuperado, saldo_antes, saldo_despues, parado, creado_por_usuario_id
  ) VALUES (
    p_id_empresa, p_id_activo, p_id_contrato, p_id_periodo,
    v_importe, v_saldo_pendiente, v_saldo_despues, p_parado, p_id_usuario_accion
  ) RETURNING id INTO v_id_recuperacion;

  UPDATE activo_asignacion_contrato
    SET saldo_inversion_pendiente = v_saldo_despues,
        actualizado_en = now(),
        actualizado_por_usuario_id = p_id_usuario_accion
  WHERE id_empresa = p_id_empresa AND id_activo = p_id_activo AND id_contrato = p_id_contrato AND eliminado_en IS NULL AND estado = 'ACTIVO';

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'RECUPERACION_REGISTRADA',
    'mensaje', 'Recuperacion registrada correctamente',
    'datos', jsonb_build_object(
      'id_recuperacion', v_id_recuperacion,
      'importe_recuperado', v_importe,
      'saldo_despues', v_saldo_despues
    )
  );
EXCEPTION
  WHEN unique_violation THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'RECUPERACION_YA_REGISTRADA', 'mensaje', 'Ya existe una recuperacion para ese activo, contrato y periodo');
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'RECUPERACION_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al ejecutar la recuperacion');
END;
$$;

-- >>> fn_registrar_traslado_activo.sql
CREATE OR REPLACE FUNCTION fn_registrar_traslado_activo(
  p_id_empresa UUID,
  p_id_usuario_accion UUID,
  p_id_activo UUID,
  p_id_contrato_origen UUID,
  p_id_zona_origen UUID,
  p_id_contrato_destino UUID,
  p_id_zona_destino UUID,
  p_fecha_traslado DATE,
  p_motivo STRING
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_saldo DECIMAL(18,2);
  v_cuota DECIMAL(18,2);
  v_id_traslado UUID;
  v_id_asignacion_destino UUID;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  IF NOT EXISTS (SELECT 1 FROM activo WHERE id = p_id_activo AND id_empresa = p_id_empresa AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'ACTIVO_NO_VALIDO', 'mensaje', 'El activo no existe o no pertenece a la empresa');
  END IF;

  IF p_id_contrato_origen IS NOT NULL AND NOT EXISTS (
    SELECT 1 FROM contrato
    WHERE id = p_id_contrato_origen AND id_empresa = p_id_empresa AND eliminado_en IS NULL
  ) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'CONTRATO_ORIGEN_NO_VALIDO', 'mensaje', 'El contrato origen no existe o no pertenece a la empresa');
  END IF;

  IF p_id_zona_origen IS NOT NULL AND NOT EXISTS (
    SELECT 1 FROM zona
    WHERE id = p_id_zona_origen AND id_empresa = p_id_empresa AND eliminado_en IS NULL
  ) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'ZONA_ORIGEN_NO_VALIDA', 'mensaje', 'La zona origen no existe o no pertenece a la empresa');
  END IF;

  SELECT saldo_inversion_pendiente, cuota_recuperacion_mensual
    INTO v_saldo, v_cuota
  FROM activo_asignacion_contrato
  WHERE id_empresa = p_id_empresa AND id_activo = p_id_activo AND id_contrato = p_id_contrato_origen
    AND eliminado_en IS NULL AND estado = 'ACTIVO';

  IF v_saldo IS NULL THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'ACTIVO_NO_ASIGNADO_ORIGEN', 'mensaje', 'El activo no tiene asignacion vigente en el contrato origen');
  END IF;

  IF p_id_contrato_destino IS NULL THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'CONTRATO_DESTINO_OBLIGATORIO', 'mensaje', 'El contrato destino es obligatorio para trasladar el activo');
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM contrato
    WHERE id = p_id_contrato_destino AND id_empresa = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL
  ) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'CONTRATO_DESTINO_NO_VALIDO', 'mensaje', 'El contrato destino no existe, no pertenece a la empresa o no esta vigente');
  END IF;

  IF p_id_zona_destino IS NULL THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'ZONA_DESTINO_OBLIGATORIA', 'mensaje', 'La zona destino es obligatoria para trasladar el activo');
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM zona
    WHERE id = p_id_zona_destino AND id_empresa = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL
  ) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'ZONA_DESTINO_NO_VALIDA', 'mensaje', 'La zona destino no existe, no pertenece a la empresa o no esta vigente');
  END IF;

  INSERT INTO activo_traslado (
    id_empresa, id_activo, id_contrato_origen, id_zona_origen,
    id_contrato_destino, id_zona_destino, fecha_traslado, saldo_trasladado, motivo, creado_por_usuario_id
  ) VALUES (
    p_id_empresa, p_id_activo, p_id_contrato_origen, p_id_zona_origen,
    p_id_contrato_destino, p_id_zona_destino, p_fecha_traslado, v_saldo, NULLIF(trim(p_motivo), ''), p_id_usuario_accion
  ) RETURNING id INTO v_id_traslado;

  UPDATE activo_asignacion_contrato
    SET estado = 'TRASLADADO', fecha_fin = p_fecha_traslado, actualizado_en = now(), actualizado_por_usuario_id = p_id_usuario_accion
  WHERE id_empresa = p_id_empresa AND id_activo = p_id_activo AND id_contrato = p_id_contrato_origen
    AND eliminado_en IS NULL AND estado = 'ACTIVO';

  INSERT INTO activo_asignacion_contrato (
    id_empresa, id_activo, id_contrato, id_zona,
    inversion_asignada, saldo_inversion_pendiente, cuota_recuperacion_mensual, fecha_inicio, creado_por_usuario_id
  ) VALUES (
    p_id_empresa, p_id_activo, p_id_contrato_destino, p_id_zona_destino,
    v_saldo, v_saldo, v_cuota, p_fecha_traslado, p_id_usuario_accion
  ) RETURNING id INTO v_id_asignacion_destino;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'ACTIVO_TRASLADADO',
    'mensaje', 'El traslado fue registrado y el saldo se traslado al contrato destino',
    'datos', jsonb_build_object(
      'id_traslado', v_id_traslado,
      'id_asignacion_destino', v_id_asignacion_destino,
      'saldo_trasladado', v_saldo
    )
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'TRASLADO_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al registrar el traslado');
END;
$$;

-- >>> fn_registrar_herramienta.sql
CREATE OR REPLACE FUNCTION fn_registrar_herramienta(
  p_id_empresa UUID,
  p_id_usuario_accion UUID,
  p_id_tipo_herramienta UUID,
  p_codigo STRING,
  p_descripcion STRING,
  p_marca STRING,
  p_modelo STRING,
  p_numero_serie STRING,
  p_costo_adquisicion DECIMAL,
  p_tiempo_vida_meses INT,
  p_fecha_inicio_depreciacion DATE,
  p_fecha_fin_depreciacion DATE
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_id_herramienta UUID;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  IF p_id_tipo_herramienta IS NOT NULL AND NOT EXISTS (
    SELECT 1 FROM tipo_herramienta
    WHERE id = p_id_tipo_herramienta AND id_empresa = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL
  ) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'TIPO_HERRAMIENTA_NO_VALIDO', 'mensaje', 'El tipo de herramienta no existe o no pertenece a la empresa');
  END IF;

  INSERT INTO herramienta (
    id_empresa, id_tipo_herramienta, codigo, descripcion, marca, modelo, numero_serie,
    costo_adquisicion, tiempo_vida_meses, fecha_inicio_depreciacion, fecha_fin_depreciacion, creado_por_usuario_id
  ) VALUES (
    p_id_empresa, p_id_tipo_herramienta, NULLIF(trim(p_codigo), ''), NULLIF(trim(p_descripcion), ''),
    NULLIF(trim(p_marca), ''), NULLIF(trim(p_modelo), ''), NULLIF(trim(p_numero_serie), ''),
    p_costo_adquisicion, p_tiempo_vida_meses, p_fecha_inicio_depreciacion, p_fecha_fin_depreciacion, p_id_usuario_accion
  ) RETURNING id INTO v_id_herramienta;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'HERRAMIENTA_REGISTRADA',
    'mensaje', 'La herramienta fue registrada correctamente',
    'datos', jsonb_build_object('id_herramienta', v_id_herramienta)
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'HERRAMIENTA_REGISTRO_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al registrar la herramienta');
END;
$$;

-- >>> fn_mover_herramienta.sql
CREATE OR REPLACE FUNCTION fn_mover_herramienta(
  p_id_empresa UUID,
  p_id_usuario_accion UUID,
  p_id_herramienta UUID,
  p_id_periodo UUID,
  p_tipo_movimiento STRING,
  p_fecha DATE,
  p_id_contrato_origen UUID,
  p_id_zona_origen UUID,
  p_id_contrato_destino UUID,
  p_id_zona_destino UUID,
  p_cantidad DECIMAL,
  p_costo DECIMAL,
  p_valorizacion DECIMAL,
  p_motivo STRING
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_id_movimiento UUID;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  IF NOT EXISTS (SELECT 1 FROM herramienta WHERE id = p_id_herramienta AND id_empresa = p_id_empresa AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'HERRAMIENTA_NO_VALIDA', 'mensaje', 'La herramienta no existe o no pertenece a la empresa');
  END IF;

  IF p_tipo_movimiento NOT IN ('ENTRADA', 'SALIDA', 'TRASLADO', 'BAJA') THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'TIPO_MOVIMIENTO_NO_VALIDO', 'mensaje', 'El tipo de movimiento no es valido');
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM periodo
    WHERE id = p_id_periodo AND id_empresa = p_id_empresa AND eliminado_en IS NULL
  ) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'PERIODO_NO_VALIDO', 'mensaje', 'El periodo no existe o no pertenece a la empresa');
  END IF;

  IF p_id_contrato_origen IS NOT NULL AND NOT EXISTS (
    SELECT 1 FROM contrato
    WHERE id = p_id_contrato_origen AND id_empresa = p_id_empresa AND eliminado_en IS NULL
  ) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'CONTRATO_ORIGEN_NO_VALIDO', 'mensaje', 'El contrato origen no existe o no pertenece a la empresa');
  END IF;

  IF p_id_zona_origen IS NOT NULL AND NOT EXISTS (
    SELECT 1 FROM zona
    WHERE id = p_id_zona_origen AND id_empresa = p_id_empresa AND eliminado_en IS NULL
  ) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'ZONA_ORIGEN_NO_VALIDA', 'mensaje', 'La zona origen no existe o no pertenece a la empresa');
  END IF;

  IF p_id_contrato_destino IS NOT NULL AND NOT EXISTS (
    SELECT 1 FROM contrato
    WHERE id = p_id_contrato_destino AND id_empresa = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL
  ) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'CONTRATO_DESTINO_NO_VALIDO', 'mensaje', 'El contrato destino no existe, no pertenece a la empresa o no esta vigente');
  END IF;

  IF p_id_zona_destino IS NOT NULL AND NOT EXISTS (
    SELECT 1 FROM zona
    WHERE id = p_id_zona_destino AND id_empresa = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL
  ) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'ZONA_DESTINO_NO_VALIDA', 'mensaje', 'La zona destino no existe, no pertenece a la empresa o no esta vigente');
  END IF;

  INSERT INTO herramienta_movimiento (
    id_empresa, id_herramienta, id_periodo, tipo_movimiento, fecha,
    id_contrato_origen, id_zona_origen, id_contrato_destino, id_zona_destino,
    cantidad, costo, valorizacion, motivo, creado_por_usuario_id
  ) VALUES (
    p_id_empresa, p_id_herramienta, p_id_periodo, p_tipo_movimiento, p_fecha,
    p_id_contrato_origen, p_id_zona_origen, p_id_contrato_destino, p_id_zona_destino,
    p_cantidad, p_costo, p_valorizacion, NULLIF(trim(p_motivo), ''), p_id_usuario_accion
  ) RETURNING id INTO v_id_movimiento;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'HERRAMIENTA_MOVIDA',
    'mensaje', 'El movimiento de herramienta fue registrado correctamente',
    'datos', jsonb_build_object('id_movimiento', v_id_movimiento)
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'HERRAMIENTA_MOVIMIENTO_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al mover la herramienta');
END;
$$;

-- >>> fn_registrar_penalidad.sql
CREATE OR REPLACE FUNCTION fn_registrar_penalidad(
  p_id_empresa UUID,
  p_id_usuario_accion UUID,
  p_id_contrato UUID,
  p_id_periodo UUID,
  p_descripcion STRING,
  p_importe DECIMAL
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_id_penalidad UUID;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM contrato
    WHERE id = p_id_contrato AND id_empresa = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL
  ) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'CONTRATO_NO_VALIDO', 'mensaje', 'El contrato no existe, no pertenece a la empresa o no esta vigente');
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM periodo
    WHERE id = p_id_periodo AND id_empresa = p_id_empresa AND eliminado_en IS NULL
  ) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'PERIODO_NO_VALIDO', 'mensaje', 'El periodo no existe o no pertenece a la empresa');
  END IF;

  IF p_importe IS NULL OR p_importe <= 0 THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'IMPORTE_NO_VALIDO', 'mensaje', 'El importe de la penalidad debe ser mayor a cero');
  END IF;

  INSERT INTO penalidad (
    id_empresa, id_contrato, id_periodo, descripcion, importe, creado_por_usuario_id
  ) VALUES (
    p_id_empresa, p_id_contrato, p_id_periodo, NULLIF(trim(p_descripcion), ''), p_importe, p_id_usuario_accion
  ) RETURNING id INTO v_id_penalidad;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'PENALIDAD_REGISTRADA',
    'mensaje', 'La penalidad fue registrada correctamente',
    'datos', jsonb_build_object('id_penalidad', v_id_penalidad)
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'PENALIDAD_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al registrar la penalidad');
END;
$$;

-- >>> fn_registrar_provision.sql
CREATE OR REPLACE FUNCTION fn_registrar_provision(
  p_id_empresa UUID,
  p_id_usuario_accion UUID,
  p_id_contrato UUID,
  p_id_periodo UUID,
  p_descripcion STRING,
  p_importe DECIMAL
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_id_provision UUID;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  IF p_id_contrato IS NOT NULL AND NOT EXISTS (
    SELECT 1 FROM contrato
    WHERE id = p_id_contrato AND id_empresa = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL
  ) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'CONTRATO_NO_VALIDO', 'mensaje', 'El contrato no existe, no pertenece a la empresa o no esta vigente');
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM periodo
    WHERE id = p_id_periodo AND id_empresa = p_id_empresa AND eliminado_en IS NULL
  ) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'PERIODO_NO_VALIDO', 'mensaje', 'El periodo no existe o no pertenece a la empresa');
  END IF;

  IF p_importe IS NULL OR p_importe <= 0 THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'IMPORTE_NO_VALIDO', 'mensaje', 'El importe de la provision debe ser mayor a cero');
  END IF;

  INSERT INTO provision (
    id_empresa, id_contrato, id_periodo, descripcion, importe, creado_por_usuario_id
  ) VALUES (
    p_id_empresa, p_id_contrato, p_id_periodo, NULLIF(trim(p_descripcion), ''), p_importe, p_id_usuario_accion
  ) RETURNING id INTO v_id_provision;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'PROVISION_REGISTRADA',
    'mensaje', 'La provision fue registrada correctamente',
    'datos', jsonb_build_object('id_provision', v_id_provision)
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'PROVISION_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al registrar la provision');
END;
$$;

-- >>> fn_ejecutar_cierre_mensual.sql
CREATE OR REPLACE FUNCTION fn_ejecutar_cierre_mensual(
  p_id_empresa UUID,
  p_id_usuario_accion UUID,
  p_id_contrato UUID,
  p_id_periodo UUID,
  p_total_facturado DECIMAL,
  p_total_produccion DECIMAL,
  p_gastos_directos DECIMAL,
  p_gastos_varios_fijos DECIMAL,
  p_gastos_iniciales_periodo DECIMAL,
  p_gastos_administrativos DECIMAL,
  p_gastos_indirectos DECIMAL,
  p_gastos_financieros DECIMAL,
  p_gastos_sig DECIMAL,
  p_impuesto_renta DECIMAL,
  p_renta_adicional DECIMAL,
  p_reparto_utilidades DECIMAL
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_estado STRING;
  v_recuperacion DECIMAL(18,2);
  v_penalidades DECIMAL(18,2);
  v_total_gastos DECIMAL(18,2);
  v_utilidad_bruta DECIMAL(18,2);
  v_utilidad_neta DECIMAL(18,2);
  v_utilidad_final DECIMAL(18,2);
  v_id_cierre UUID;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM contrato
    WHERE id = p_id_contrato AND id_empresa = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL
  ) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'CONTRATO_NO_VALIDO', 'mensaje', 'El contrato no existe, no pertenece a la empresa o no esta vigente');
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM periodo
    WHERE id = p_id_periodo AND id_empresa = p_id_empresa AND eliminado_en IS NULL
  ) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'PERIODO_NO_VALIDO', 'mensaje', 'El periodo no existe o no pertenece a la empresa');
  END IF;

  SELECT estado INTO v_estado
  FROM cierre_mensual
  WHERE id_empresa = p_id_empresa AND id_contrato = p_id_contrato AND id_periodo = p_id_periodo AND eliminado_en IS NULL;

  IF v_estado = 'CERRADO' THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'CIERRE_YA_CERRADO', 'mensaje', 'El cierre del periodo ya esta cerrado; debe reabrirse para recalcular');
  END IF;

  SELECT COALESCE(SUM(importe_recuperado), 0) INTO v_recuperacion
  FROM recuperacion_inversion_mensual
  WHERE id_empresa = p_id_empresa AND id_contrato = p_id_contrato AND id_periodo = p_id_periodo;

  SELECT COALESCE(SUM(importe), 0) INTO v_penalidades
  FROM penalidad
  WHERE id_empresa = p_id_empresa AND id_contrato = p_id_contrato AND id_periodo = p_id_periodo AND eliminado_en IS NULL;

  v_total_gastos := COALESCE(p_gastos_directos, 0)
    + COALESCE(p_gastos_varios_fijos, 0)
    + COALESCE(p_gastos_iniciales_periodo, 0)
    + v_recuperacion
    + COALESCE(p_gastos_administrativos, 0)
    + COALESCE(p_gastos_indirectos, 0)
    + COALESCE(p_gastos_financieros, 0)
    + COALESCE(p_gastos_sig, 0);

  v_utilidad_bruta := COALESCE(p_total_facturado, 0) - v_total_gastos;

  v_utilidad_neta := v_utilidad_bruta
    - COALESCE(p_impuesto_renta, 0)
    - COALESCE(p_renta_adicional, 0)
    - COALESCE(p_reparto_utilidades, 0);

  v_utilidad_final := v_utilidad_neta - v_penalidades;

  INSERT INTO cierre_mensual (
    id_empresa, id_contrato, id_periodo,
    total_facturado, total_produccion, gastos_directos, gastos_varios_fijos, gastos_iniciales_periodo,
    recuperacion_inversion, gastos_administrativos, gastos_indirectos, gastos_financieros, gastos_sig,
    total_gastos, utilidad_bruta, impuesto_renta, renta_adicional, reparto_utilidades, penalidades,
    utilidad_neta, utilidad_final, estado, creado_por_usuario_id
  ) VALUES (
    p_id_empresa, p_id_contrato, p_id_periodo,
    COALESCE(p_total_facturado, 0), COALESCE(p_total_produccion, 0), COALESCE(p_gastos_directos, 0), COALESCE(p_gastos_varios_fijos, 0), COALESCE(p_gastos_iniciales_periodo, 0),
    v_recuperacion, COALESCE(p_gastos_administrativos, 0), COALESCE(p_gastos_indirectos, 0), COALESCE(p_gastos_financieros, 0), COALESCE(p_gastos_sig, 0),
    v_total_gastos, v_utilidad_bruta, COALESCE(p_impuesto_renta, 0), COALESCE(p_renta_adicional, 0), COALESCE(p_reparto_utilidades, 0), v_penalidades,
    v_utilidad_neta, v_utilidad_final, 'BORRADOR', p_id_usuario_accion
  )
  ON CONFLICT (id_contrato, id_periodo) DO UPDATE SET
    total_facturado = excluded.total_facturado,
    total_produccion = excluded.total_produccion,
    gastos_directos = excluded.gastos_directos,
    gastos_varios_fijos = excluded.gastos_varios_fijos,
    gastos_iniciales_periodo = excluded.gastos_iniciales_periodo,
    recuperacion_inversion = excluded.recuperacion_inversion,
    gastos_administrativos = excluded.gastos_administrativos,
    gastos_indirectos = excluded.gastos_indirectos,
    gastos_financieros = excluded.gastos_financieros,
    gastos_sig = excluded.gastos_sig,
    total_gastos = excluded.total_gastos,
    utilidad_bruta = excluded.utilidad_bruta,
    impuesto_renta = excluded.impuesto_renta,
    renta_adicional = excluded.renta_adicional,
    reparto_utilidades = excluded.reparto_utilidades,
    penalidades = excluded.penalidades,
    utilidad_neta = excluded.utilidad_neta,
    utilidad_final = excluded.utilidad_final,
    estado = 'BORRADOR',
    actualizado_en = now(),
    actualizado_por_usuario_id = p_id_usuario_accion
  RETURNING id INTO v_id_cierre;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'CIERRE_CALCULADO',
    'mensaje', 'El cierre preliminar fue calculado en estado BORRADOR',
    'datos', jsonb_build_object(
      'id_cierre', v_id_cierre,
      'total_gastos', v_total_gastos,
      'recuperacion_inversion', v_recuperacion,
      'utilidad_bruta', v_utilidad_bruta,
      'penalidades', v_penalidades,
      'utilidad_neta', v_utilidad_neta,
      'utilidad_final', v_utilidad_final
    )
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'CIERRE_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al ejecutar el cierre');
END;
$$;

-- >>> fn_recalcular_cierre_mensual.sql
CREATE OR REPLACE FUNCTION fn_recalcular_cierre_mensual(
  p_id_empresa UUID,
  p_id_usuario_accion UUID,
  p_id_contrato UUID,
  p_id_periodo UUID,
  p_total_facturado DECIMAL,
  p_total_produccion DECIMAL,
  p_gastos_directos DECIMAL,
  p_gastos_varios_fijos DECIMAL,
  p_gastos_iniciales_periodo DECIMAL,
  p_gastos_administrativos DECIMAL,
  p_gastos_indirectos DECIMAL,
  p_gastos_financieros DECIMAL,
  p_gastos_sig DECIMAL,
  p_impuesto_renta DECIMAL,
  p_renta_adicional DECIMAL,
  p_reparto_utilidades DECIMAL
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_id_cierre UUID;
  v_estado_actual STRING;
  v_estado_nuevo STRING;
  v_recuperacion DECIMAL(18,2);
  v_penalidades DECIMAL(18,2);
  v_total_gastos DECIMAL(18,2);
  v_utilidad_bruta DECIMAL(18,2);
  v_utilidad_neta DECIMAL(18,2);
  v_utilidad_final DECIMAL(18,2);
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM contrato
    WHERE id = p_id_contrato AND id_empresa = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL
  ) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'CONTRATO_NO_VALIDO', 'mensaje', 'El contrato no existe, no pertenece a la empresa o no esta vigente');
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM periodo
    WHERE id = p_id_periodo AND id_empresa = p_id_empresa AND eliminado_en IS NULL
  ) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'PERIODO_NO_VALIDO', 'mensaje', 'El periodo no existe o no pertenece a la empresa');
  END IF;

  SELECT id, estado INTO v_id_cierre, v_estado_actual
  FROM cierre_mensual
  WHERE id_empresa = p_id_empresa AND id_contrato = p_id_contrato AND id_periodo = p_id_periodo AND eliminado_en IS NULL;

  IF v_id_cierre IS NULL THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'CIERRE_NO_ENCONTRADO', 'mensaje', 'No existe un cierre para recalcular; primero ejecute el cierre');
  END IF;

  SELECT COALESCE(SUM(importe_recuperado), 0) INTO v_recuperacion
  FROM recuperacion_inversion_mensual
  WHERE id_empresa = p_id_empresa AND id_contrato = p_id_contrato AND id_periodo = p_id_periodo;

  SELECT COALESCE(SUM(importe), 0) INTO v_penalidades
  FROM penalidad
  WHERE id_empresa = p_id_empresa AND id_contrato = p_id_contrato AND id_periodo = p_id_periodo AND eliminado_en IS NULL;

  v_total_gastos := COALESCE(p_gastos_directos, 0)
    + COALESCE(p_gastos_varios_fijos, 0)
    + COALESCE(p_gastos_iniciales_periodo, 0)
    + v_recuperacion
    + COALESCE(p_gastos_administrativos, 0)
    + COALESCE(p_gastos_indirectos, 0)
    + COALESCE(p_gastos_financieros, 0)
    + COALESCE(p_gastos_sig, 0);

  v_utilidad_bruta := COALESCE(p_total_facturado, 0) - v_total_gastos;

  v_utilidad_neta := v_utilidad_bruta
    - COALESCE(p_impuesto_renta, 0)
    - COALESCE(p_renta_adicional, 0)
    - COALESCE(p_reparto_utilidades, 0);

  v_utilidad_final := v_utilidad_neta - v_penalidades;

  IF v_estado_actual = 'CERRADO' THEN
    v_estado_nuevo := 'REABIERTO';
  ELSE
    v_estado_nuevo := v_estado_actual;
  END IF;

  UPDATE cierre_mensual SET
    total_facturado = COALESCE(p_total_facturado, 0),
    total_produccion = COALESCE(p_total_produccion, 0),
    gastos_directos = COALESCE(p_gastos_directos, 0),
    gastos_varios_fijos = COALESCE(p_gastos_varios_fijos, 0),
    gastos_iniciales_periodo = COALESCE(p_gastos_iniciales_periodo, 0),
    recuperacion_inversion = v_recuperacion,
    gastos_administrativos = COALESCE(p_gastos_administrativos, 0),
    gastos_indirectos = COALESCE(p_gastos_indirectos, 0),
    gastos_financieros = COALESCE(p_gastos_financieros, 0),
    gastos_sig = COALESCE(p_gastos_sig, 0),
    total_gastos = v_total_gastos,
    utilidad_bruta = v_utilidad_bruta,
    impuesto_renta = COALESCE(p_impuesto_renta, 0),
    renta_adicional = COALESCE(p_renta_adicional, 0),
    reparto_utilidades = COALESCE(p_reparto_utilidades, 0),
    penalidades = v_penalidades,
    utilidad_neta = v_utilidad_neta,
    utilidad_final = v_utilidad_final,
    estado = v_estado_nuevo,
    fecha_cierre = CASE WHEN v_estado_nuevo = 'REABIERTO' THEN NULL ELSE fecha_cierre END,
    actualizado_en = now(),
    actualizado_por_usuario_id = p_id_usuario_accion
  WHERE id = v_id_cierre;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'CIERRE_RECALCULADO',
    'mensaje', 'El cierre fue recalculado',
    'datos', jsonb_build_object(
      'id_cierre', v_id_cierre,
      'estado', v_estado_nuevo,
      'total_gastos', v_total_gastos,
      'recuperacion_inversion', v_recuperacion,
      'utilidad_bruta', v_utilidad_bruta,
      'penalidades', v_penalidades,
      'utilidad_neta', v_utilidad_neta,
      'utilidad_final', v_utilidad_final
    )
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'CIERRE_RECALCULO_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al recalcular el cierre');
END;
$$;

-- >>> fn_cerrar_cierre_mensual.sql
CREATE OR REPLACE FUNCTION fn_cerrar_cierre_mensual(
  p_id_empresa UUID,
  p_id_usuario_accion UUID,
  p_id_contrato UUID,
  p_id_periodo UUID
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_id_cierre UUID;
  v_estado STRING;
  v_fecha_cierre TIMESTAMPTZ;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  SELECT id, estado INTO v_id_cierre, v_estado
  FROM cierre_mensual
  WHERE id_empresa = p_id_empresa AND id_contrato = p_id_contrato AND id_periodo = p_id_periodo AND eliminado_en IS NULL;

  IF v_id_cierre IS NULL THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'CIERRE_NO_ENCONTRADO', 'mensaje', 'No existe un cierre para cerrar; primero ejecute el cierre del periodo');
  END IF;

  IF v_estado = 'CERRADO' THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'CIERRE_YA_CERRADO', 'mensaje', 'El cierre del periodo ya esta cerrado');
  END IF;

  UPDATE cierre_mensual SET
    estado = 'CERRADO',
    fecha_cierre = now(),
    cerrado_por_usuario_id = p_id_usuario_accion,
    actualizado_en = now(),
    actualizado_por_usuario_id = p_id_usuario_accion
  WHERE id = v_id_cierre
  RETURNING fecha_cierre INTO v_fecha_cierre;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'CIERRE_CERRADO',
    'mensaje', 'El cierre del periodo fue cerrado',
    'datos', jsonb_build_object(
      'id_cierre', v_id_cierre,
      'estado', 'CERRADO',
      'fecha_cierre', v_fecha_cierre
    )
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'CIERRE_CERRAR_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al cerrar el cierre');
END;
$$;

-- >>> fn_consultar_resultado_contrato.sql
CREATE OR REPLACE FUNCTION fn_consultar_resultado_contrato(
  p_id_empresa UUID,
  p_id_contrato UUID,
  p_id_periodo UUID
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_datos JSONB;
BEGIN
  SELECT to_jsonb(c) INTO v_datos
  FROM cierre_mensual c
  WHERE c.id_empresa = p_id_empresa AND c.id_contrato = p_id_contrato AND c.id_periodo = p_id_periodo AND c.eliminado_en IS NULL;

  IF v_datos IS NULL THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'CIERRE_NO_ENCONTRADO', 'mensaje', 'No existe cierre para ese contrato y periodo');
  END IF;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'RESULTADO_CONTRATO',
    'mensaje', 'Resultado del contrato obtenido',
    'datos', v_datos
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'RESULTADO_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al consultar el resultado');
END;
$$;

-- >>> fn_listar_activos.sql
CREATE OR REPLACE FUNCTION fn_listar_activos(
  p_id_empresa UUID,
  p_estado STRING,
  p_id_clasificacion_activo UUID,
  p_busqueda STRING,
  p_limite INT,
  p_cursor_creado_en TIMESTAMPTZ,
  p_cursor_id UUID
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_limite INT;
  v_items JSONB;
  v_hay_mas BOOL;
  v_n INT;
  v_cursor JSONB;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  v_limite := LEAST(GREATEST(COALESCE(p_limite, 20), 1), 100);

  WITH base AS (
    SELECT a.id, a.codigo, a.descripcion, a.estado, a.placa, a.marca, a.modelo,
           a.anio_fabricacion, a.costo_adquisicion, a.id_clasificacion_activo,
           a.id_tipo_adquisicion_activo, a.creado_en,
           row_number() OVER (ORDER BY a.creado_en DESC, a.id DESC) AS _rn
    FROM activo a
    WHERE a.id_empresa = p_id_empresa
      AND a.eliminado_en IS NULL
      AND (p_estado IS NULL OR a.estado = p_estado)
      AND (p_id_clasificacion_activo IS NULL OR a.id_clasificacion_activo = p_id_clasificacion_activo)
      AND (p_busqueda IS NULL OR a.codigo ILIKE '%' || p_busqueda || '%' OR a.descripcion ILIKE '%' || p_busqueda || '%')
      AND (p_cursor_creado_en IS NULL OR (a.creado_en, a.id) < (p_cursor_creado_en, p_cursor_id))
    ORDER BY a.creado_en DESC, a.id DESC
    LIMIT v_limite + 1
  )
  SELECT
    COALESCE(jsonb_agg(to_jsonb(base) - '_rn' ORDER BY base._rn) FILTER (WHERE base._rn <= v_limite), '[]'::jsonb),
    count(*) > v_limite
  INTO v_items, v_hay_mas
  FROM base;

  v_n := jsonb_array_length(v_items);
  IF v_hay_mas AND v_n > 0 THEN
    v_cursor := jsonb_build_object(
      'creado_en', v_items -> (v_n - 1) -> 'creado_en',
      'id', v_items -> (v_n - 1) -> 'id'
    );
  ELSE
    v_cursor := NULL;
  END IF;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'ACTIVOS_LISTADOS',
    'mensaje', 'Listado de activos obtenido',
    'datos', jsonb_build_object(
      'items', v_items,
      'paginacion', jsonb_build_object(
        'limite', v_limite,
        'hay_mas', v_hay_mas,
        'cursor_siguiente', v_cursor
      )
    )
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'ACTIVOS_LISTADO_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al listar los activos');
END;
$$;

-- >>> fn_obtener_detalle_activo.sql
CREATE OR REPLACE FUNCTION fn_obtener_detalle_activo(
  p_id_empresa UUID,
  p_id_activo UUID
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_activo JSONB;
  v_asignacion JSONB;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  SELECT to_jsonb(a) INTO v_activo
  FROM activo a
  WHERE a.id = p_id_activo AND a.id_empresa = p_id_empresa AND a.eliminado_en IS NULL;

  IF v_activo IS NULL THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'ACTIVO_NO_ENCONTRADO', 'mensaje', 'El activo no existe o no pertenece a la empresa');
  END IF;

  SELECT to_jsonb(ac) INTO v_asignacion
  FROM activo_asignacion_contrato ac
  WHERE ac.id_activo = p_id_activo AND ac.id_empresa = p_id_empresa AND ac.estado = 'ACTIVO' AND ac.eliminado_en IS NULL
  ORDER BY ac.fecha_inicio DESC, ac.id DESC
  LIMIT 1;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'ACTIVO_OBTENIDO',
    'mensaje', 'Detalle del activo obtenido',
    'datos', jsonb_build_object(
      'activo', v_activo,
      'asignacion_vigente', COALESCE(v_asignacion, 'null'::jsonb)
    )
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'ACTIVO_DETALLE_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al obtener el activo');
END;
$$;

-- >>> fn_listar_herramientas.sql
CREATE OR REPLACE FUNCTION fn_listar_herramientas(
  p_id_empresa UUID,
  p_estado STRING,
  p_id_tipo_herramienta UUID,
  p_busqueda STRING,
  p_limite INT,
  p_cursor_creado_en TIMESTAMPTZ,
  p_cursor_id UUID
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_limite INT;
  v_items JSONB;
  v_hay_mas BOOL;
  v_n INT;
  v_cursor JSONB;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  v_limite := LEAST(GREATEST(COALESCE(p_limite, 20), 1), 100);

  WITH base AS (
    SELECT h.id, h.codigo, h.descripcion, h.marca, h.modelo, h.numero_serie,
           h.estado, h.costo_adquisicion, h.id_tipo_herramienta, h.creado_en,
           row_number() OVER (ORDER BY h.creado_en DESC, h.id DESC) AS _rn
    FROM herramienta h
    WHERE h.id_empresa = p_id_empresa
      AND h.eliminado_en IS NULL
      AND (p_estado IS NULL OR h.estado = p_estado)
      AND (p_id_tipo_herramienta IS NULL OR h.id_tipo_herramienta = p_id_tipo_herramienta)
      AND (p_busqueda IS NULL OR h.codigo ILIKE '%' || p_busqueda || '%' OR h.descripcion ILIKE '%' || p_busqueda || '%')
      AND (p_cursor_creado_en IS NULL OR (h.creado_en, h.id) < (p_cursor_creado_en, p_cursor_id))
    ORDER BY h.creado_en DESC, h.id DESC
    LIMIT v_limite + 1
  )
  SELECT
    COALESCE(jsonb_agg(to_jsonb(base) - '_rn' ORDER BY base._rn) FILTER (WHERE base._rn <= v_limite), '[]'::jsonb),
    count(*) > v_limite
  INTO v_items, v_hay_mas
  FROM base;

  v_n := jsonb_array_length(v_items);
  IF v_hay_mas AND v_n > 0 THEN
    v_cursor := jsonb_build_object('creado_en', v_items -> (v_n - 1) -> 'creado_en', 'id', v_items -> (v_n - 1) -> 'id');
  ELSE
    v_cursor := NULL;
  END IF;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'HERRAMIENTAS_LISTADAS',
    'mensaje', 'Listado de herramientas obtenido',
    'datos', jsonb_build_object(
      'items', v_items,
      'paginacion', jsonb_build_object('limite', v_limite, 'hay_mas', v_hay_mas, 'cursor_siguiente', v_cursor)
    )
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'HERRAMIENTAS_LISTADO_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al listar las herramientas');
END;
$$;

-- >>> fn_obtener_detalle_herramienta.sql
CREATE OR REPLACE FUNCTION fn_obtener_detalle_herramienta(
  p_id_empresa UUID,
  p_id_herramienta UUID
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_herramienta JSONB;
  v_ultimo_movimiento JSONB;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  SELECT to_jsonb(h) INTO v_herramienta
  FROM herramienta h
  WHERE h.id = p_id_herramienta AND h.id_empresa = p_id_empresa AND h.eliminado_en IS NULL;

  IF v_herramienta IS NULL THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'HERRAMIENTA_NO_ENCONTRADA', 'mensaje', 'La herramienta no existe o no pertenece a la empresa');
  END IF;

  SELECT to_jsonb(m) INTO v_ultimo_movimiento
  FROM herramienta_movimiento m
  WHERE m.id_herramienta = p_id_herramienta AND m.id_empresa = p_id_empresa
  ORDER BY m.fecha DESC, m.creado_en DESC, m.id DESC
  LIMIT 1;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'HERRAMIENTA_OBTENIDA',
    'mensaje', 'Detalle de la herramienta obtenido',
    'datos', jsonb_build_object(
      'herramienta', v_herramienta,
      'ultimo_movimiento', COALESCE(v_ultimo_movimiento, 'null'::jsonb)
    )
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'HERRAMIENTA_DETALLE_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al obtener la herramienta');
END;
$$;

-- >>> fn_listar_movimientos_herramienta.sql
CREATE OR REPLACE FUNCTION fn_listar_movimientos_herramienta(
  p_id_empresa UUID,
  p_id_herramienta UUID,
  p_id_periodo UUID,
  p_tipo_movimiento STRING,
  p_limite INT,
  p_cursor_creado_en TIMESTAMPTZ,
  p_cursor_id UUID
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_limite INT;
  v_items JSONB;
  v_hay_mas BOOL;
  v_n INT;
  v_cursor JSONB;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  IF NOT EXISTS (SELECT 1 FROM herramienta WHERE id = p_id_herramienta AND id_empresa = p_id_empresa AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'HERRAMIENTA_NO_VALIDA', 'mensaje', 'La herramienta no existe o no pertenece a la empresa');
  END IF;

  v_limite := LEAST(GREATEST(COALESCE(p_limite, 20), 1), 100);

  WITH base AS (
    SELECT m.id, m.tipo_movimiento, m.fecha, m.id_periodo,
           m.id_contrato_origen, m.id_zona_origen, m.id_contrato_destino, m.id_zona_destino,
           m.cantidad, m.costo, m.valorizacion, m.motivo, m.creado_en,
           row_number() OVER (ORDER BY m.creado_en DESC, m.id DESC) AS _rn
    FROM herramienta_movimiento m
    WHERE m.id_empresa = p_id_empresa
      AND m.id_herramienta = p_id_herramienta
      AND (p_id_periodo IS NULL OR m.id_periodo = p_id_periodo)
      AND (p_tipo_movimiento IS NULL OR m.tipo_movimiento = p_tipo_movimiento)
      AND (p_cursor_creado_en IS NULL OR (m.creado_en, m.id) < (p_cursor_creado_en, p_cursor_id))
    ORDER BY m.creado_en DESC, m.id DESC
    LIMIT v_limite + 1
  )
  SELECT
    COALESCE(jsonb_agg(to_jsonb(base) - '_rn' ORDER BY base._rn) FILTER (WHERE base._rn <= v_limite), '[]'::jsonb),
    count(*) > v_limite
  INTO v_items, v_hay_mas
  FROM base;

  v_n := jsonb_array_length(v_items);
  IF v_hay_mas AND v_n > 0 THEN
    v_cursor := jsonb_build_object('creado_en', v_items -> (v_n - 1) -> 'creado_en', 'id', v_items -> (v_n - 1) -> 'id');
  ELSE
    v_cursor := NULL;
  END IF;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'MOVIMIENTOS_HERRAMIENTA_LISTADOS',
    'mensaje', 'Listado de movimientos de la herramienta obtenido',
    'datos', jsonb_build_object(
      'items', v_items,
      'paginacion', jsonb_build_object('limite', v_limite, 'hay_mas', v_hay_mas, 'cursor_siguiente', v_cursor)
    )
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'MOVIMIENTOS_HERRAMIENTA_LISTADO_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al listar los movimientos');
END;
$$;

-- >>> fn_listar_asignaciones_activo.sql
CREATE OR REPLACE FUNCTION fn_listar_asignaciones_activo(
  p_id_empresa UUID,
  p_id_activo UUID,
  p_estado STRING,
  p_limite INT,
  p_cursor_creado_en TIMESTAMPTZ,
  p_cursor_id UUID
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_limite INT;
  v_items JSONB;
  v_hay_mas BOOL;
  v_n INT;
  v_cursor JSONB;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  IF NOT EXISTS (SELECT 1 FROM activo WHERE id = p_id_activo AND id_empresa = p_id_empresa AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'ACTIVO_NO_VALIDO', 'mensaje', 'El activo no existe o no pertenece a la empresa');
  END IF;

  v_limite := LEAST(GREATEST(COALESCE(p_limite, 20), 1), 100);

  WITH base AS (
    SELECT ac.id, ac.id_contrato, ac.id_zona, ac.inversion_asignada, ac.saldo_inversion_pendiente,
           ac.cuota_recuperacion_mensual, ac.fecha_inicio, ac.fecha_fin, ac.estado, ac.creado_en,
           row_number() OVER (ORDER BY ac.creado_en DESC, ac.id DESC) AS _rn
    FROM activo_asignacion_contrato ac
    WHERE ac.id_empresa = p_id_empresa
      AND ac.id_activo = p_id_activo
      AND ac.eliminado_en IS NULL
      AND (p_estado IS NULL OR ac.estado = p_estado)
      AND (p_cursor_creado_en IS NULL OR (ac.creado_en, ac.id) < (p_cursor_creado_en, p_cursor_id))
    ORDER BY ac.creado_en DESC, ac.id DESC
    LIMIT v_limite + 1
  )
  SELECT
    COALESCE(jsonb_agg(to_jsonb(base) - '_rn' ORDER BY base._rn) FILTER (WHERE base._rn <= v_limite), '[]'::jsonb),
    count(*) > v_limite
  INTO v_items, v_hay_mas
  FROM base;

  v_n := jsonb_array_length(v_items);
  IF v_hay_mas AND v_n > 0 THEN
    v_cursor := jsonb_build_object('creado_en', v_items -> (v_n - 1) -> 'creado_en', 'id', v_items -> (v_n - 1) -> 'id');
  ELSE
    v_cursor := NULL;
  END IF;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'ASIGNACIONES_ACTIVO_LISTADAS',
    'mensaje', 'Listado de asignaciones del activo obtenido',
    'datos', jsonb_build_object(
      'items', v_items,
      'paginacion', jsonb_build_object('limite', v_limite, 'hay_mas', v_hay_mas, 'cursor_siguiente', v_cursor)
    )
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'ASIGNACIONES_ACTIVO_LISTADO_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al listar las asignaciones');
END;
$$;

-- >>> fn_listar_trabajos_activo.sql
CREATE OR REPLACE FUNCTION fn_listar_trabajos_activo(
  p_id_empresa UUID,
  p_id_activo UUID,
  p_id_contrato UUID,
  p_id_periodo UUID,
  p_limite INT,
  p_cursor_creado_en TIMESTAMPTZ,
  p_cursor_id UUID
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_limite INT;
  v_items JSONB;
  v_hay_mas BOOL;
  v_n INT;
  v_cursor JSONB;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  IF NOT EXISTS (SELECT 1 FROM activo WHERE id = p_id_activo AND id_empresa = p_id_empresa AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'ACTIVO_NO_VALIDO', 'mensaje', 'El activo no existe o no pertenece a la empresa');
  END IF;

  v_limite := LEAST(GREATEST(COALESCE(p_limite, 20), 1), 100);

  WITH base AS (
    SELECT t.id, t.id_contrato, t.id_zona, t.id_operario, t.id_periodo, t.fecha,
           t.horas_trabajadas, t.descripcion_trabajo, t.valorizacion_trabajo, t.dias_depreciados,
           t.kilometraje_inicio, t.kilometraje_fin, t.creado_en,
           row_number() OVER (ORDER BY t.creado_en DESC, t.id DESC) AS _rn
    FROM activo_registro_trabajo t
    WHERE t.id_empresa = p_id_empresa
      AND t.id_activo = p_id_activo
      AND t.eliminado_en IS NULL
      AND (p_id_contrato IS NULL OR t.id_contrato = p_id_contrato)
      AND (p_id_periodo IS NULL OR t.id_periodo = p_id_periodo)
      AND (p_cursor_creado_en IS NULL OR (t.creado_en, t.id) < (p_cursor_creado_en, p_cursor_id))
    ORDER BY t.creado_en DESC, t.id DESC
    LIMIT v_limite + 1
  )
  SELECT
    COALESCE(jsonb_agg(to_jsonb(base) - '_rn' ORDER BY base._rn) FILTER (WHERE base._rn <= v_limite), '[]'::jsonb),
    count(*) > v_limite
  INTO v_items, v_hay_mas
  FROM base;

  v_n := jsonb_array_length(v_items);
  IF v_hay_mas AND v_n > 0 THEN
    v_cursor := jsonb_build_object('creado_en', v_items -> (v_n - 1) -> 'creado_en', 'id', v_items -> (v_n - 1) -> 'id');
  ELSE
    v_cursor := NULL;
  END IF;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'TRABAJOS_ACTIVO_LISTADOS',
    'mensaje', 'Listado de trabajos del activo obtenido',
    'datos', jsonb_build_object(
      'items', v_items,
      'paginacion', jsonb_build_object('limite', v_limite, 'hay_mas', v_hay_mas, 'cursor_siguiente', v_cursor)
    )
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'TRABAJOS_ACTIVO_LISTADO_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al listar los trabajos');
END;
$$;

-- >>> fn_listar_traslados_activo.sql
CREATE OR REPLACE FUNCTION fn_listar_traslados_activo(
  p_id_empresa UUID,
  p_id_activo UUID,
  p_limite INT,
  p_cursor_creado_en TIMESTAMPTZ,
  p_cursor_id UUID
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_limite INT;
  v_items JSONB;
  v_hay_mas BOOL;
  v_n INT;
  v_cursor JSONB;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  IF NOT EXISTS (SELECT 1 FROM activo WHERE id = p_id_activo AND id_empresa = p_id_empresa AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'ACTIVO_NO_VALIDO', 'mensaje', 'El activo no existe o no pertenece a la empresa');
  END IF;

  v_limite := LEAST(GREATEST(COALESCE(p_limite, 20), 1), 100);

  WITH base AS (
    SELECT t.id, t.id_contrato_origen, t.id_zona_origen, t.id_contrato_destino, t.id_zona_destino,
           t.fecha_traslado, t.saldo_trasladado, t.motivo, t.creado_en,
           row_number() OVER (ORDER BY t.creado_en DESC, t.id DESC) AS _rn
    FROM activo_traslado t
    WHERE t.id_empresa = p_id_empresa
      AND t.id_activo = p_id_activo
      AND (p_cursor_creado_en IS NULL OR (t.creado_en, t.id) < (p_cursor_creado_en, p_cursor_id))
    ORDER BY t.creado_en DESC, t.id DESC
    LIMIT v_limite + 1
  )
  SELECT
    COALESCE(jsonb_agg(to_jsonb(base) - '_rn' ORDER BY base._rn) FILTER (WHERE base._rn <= v_limite), '[]'::jsonb),
    count(*) > v_limite
  INTO v_items, v_hay_mas
  FROM base;

  v_n := jsonb_array_length(v_items);
  IF v_hay_mas AND v_n > 0 THEN
    v_cursor := jsonb_build_object('creado_en', v_items -> (v_n - 1) -> 'creado_en', 'id', v_items -> (v_n - 1) -> 'id');
  ELSE
    v_cursor := NULL;
  END IF;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'TRASLADOS_ACTIVO_LISTADOS',
    'mensaje', 'Listado de traslados del activo obtenido',
    'datos', jsonb_build_object(
      'items', v_items,
      'paginacion', jsonb_build_object('limite', v_limite, 'hay_mas', v_hay_mas, 'cursor_siguiente', v_cursor)
    )
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'TRASLADOS_ACTIVO_LISTADO_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al listar los traslados');
END;
$$;

-- >>> fn_listar_recuperaciones_inversion.sql
CREATE OR REPLACE FUNCTION fn_listar_recuperaciones_inversion(
  p_id_empresa UUID,
  p_id_activo UUID,
  p_id_contrato UUID,
  p_id_periodo UUID,
  p_limite INT,
  p_cursor_creado_en TIMESTAMPTZ,
  p_cursor_id UUID
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_limite INT;
  v_items JSONB;
  v_hay_mas BOOL;
  v_n INT;
  v_cursor JSONB;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  v_limite := LEAST(GREATEST(COALESCE(p_limite, 20), 1), 100);

  WITH base AS (
    SELECT r.id, r.id_activo, r.id_contrato, r.id_periodo, r.importe_recuperado,
           r.saldo_antes, r.saldo_despues, r.parado, r.creado_en,
           row_number() OVER (ORDER BY r.creado_en DESC, r.id DESC) AS _rn
    FROM recuperacion_inversion_mensual r
    WHERE r.id_empresa = p_id_empresa
      AND (p_id_activo IS NULL OR r.id_activo = p_id_activo)
      AND (p_id_contrato IS NULL OR r.id_contrato = p_id_contrato)
      AND (p_id_periodo IS NULL OR r.id_periodo = p_id_periodo)
      AND (p_cursor_creado_en IS NULL OR (r.creado_en, r.id) < (p_cursor_creado_en, p_cursor_id))
    ORDER BY r.creado_en DESC, r.id DESC
    LIMIT v_limite + 1
  )
  SELECT
    COALESCE(jsonb_agg(to_jsonb(base) - '_rn' ORDER BY base._rn) FILTER (WHERE base._rn <= v_limite), '[]'::jsonb),
    count(*) > v_limite
  INTO v_items, v_hay_mas
  FROM base;

  v_n := jsonb_array_length(v_items);
  IF v_hay_mas AND v_n > 0 THEN
    v_cursor := jsonb_build_object('creado_en', v_items -> (v_n - 1) -> 'creado_en', 'id', v_items -> (v_n - 1) -> 'id');
  ELSE
    v_cursor := NULL;
  END IF;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'RECUPERACIONES_LISTADAS',
    'mensaje', 'Listado de recuperaciones de inversion obtenido',
    'datos', jsonb_build_object(
      'items', v_items,
      'paginacion', jsonb_build_object('limite', v_limite, 'hay_mas', v_hay_mas, 'cursor_siguiente', v_cursor)
    )
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'RECUPERACIONES_LISTADO_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al listar las recuperaciones');
END;
$$;

-- >>> fn_listar_cierres_mensuales.sql
CREATE OR REPLACE FUNCTION fn_listar_cierres_mensuales(
  p_id_empresa UUID,
  p_id_contrato UUID,
  p_id_periodo UUID,
  p_estado STRING,
  p_limite INT,
  p_cursor_creado_en TIMESTAMPTZ,
  p_cursor_id UUID
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_limite INT;
  v_items JSONB;
  v_hay_mas BOOL;
  v_n INT;
  v_cursor JSONB;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  v_limite := LEAST(GREATEST(COALESCE(p_limite, 20), 1), 100);

  WITH base AS (
    SELECT c.id, c.id_contrato, c.id_periodo, c.total_facturado, c.total_gastos,
           c.utilidad_bruta, c.utilidad_neta, c.utilidad_final, c.estado, c.fecha_cierre, c.creado_en,
           row_number() OVER (ORDER BY c.creado_en DESC, c.id DESC) AS _rn
    FROM cierre_mensual c
    WHERE c.id_empresa = p_id_empresa
      AND c.eliminado_en IS NULL
      AND (p_id_contrato IS NULL OR c.id_contrato = p_id_contrato)
      AND (p_id_periodo IS NULL OR c.id_periodo = p_id_periodo)
      AND (p_estado IS NULL OR c.estado = p_estado)
      AND (p_cursor_creado_en IS NULL OR (c.creado_en, c.id) < (p_cursor_creado_en, p_cursor_id))
    ORDER BY c.creado_en DESC, c.id DESC
    LIMIT v_limite + 1
  )
  SELECT
    COALESCE(jsonb_agg(to_jsonb(base) - '_rn' ORDER BY base._rn) FILTER (WHERE base._rn <= v_limite), '[]'::jsonb),
    count(*) > v_limite
  INTO v_items, v_hay_mas
  FROM base;

  v_n := jsonb_array_length(v_items);
  IF v_hay_mas AND v_n > 0 THEN
    v_cursor := jsonb_build_object('creado_en', v_items -> (v_n - 1) -> 'creado_en', 'id', v_items -> (v_n - 1) -> 'id');
  ELSE
    v_cursor := NULL;
  END IF;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'CIERRES_MENSUALES_LISTADOS',
    'mensaje', 'Listado de cierres mensuales obtenido',
    'datos', jsonb_build_object(
      'items', v_items,
      'paginacion', jsonb_build_object('limite', v_limite, 'hay_mas', v_hay_mas, 'cursor_siguiente', v_cursor)
    )
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'CIERRES_MENSUALES_LISTADO_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al listar los cierres');
END;
$$;

-- >>> fn_listar_penalidades.sql
CREATE OR REPLACE FUNCTION fn_listar_penalidades(
  p_id_empresa UUID,
  p_id_contrato UUID,
  p_id_periodo UUID,
  p_limite INT,
  p_cursor_creado_en TIMESTAMPTZ,
  p_cursor_id UUID
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_limite INT;
  v_items JSONB;
  v_hay_mas BOOL;
  v_n INT;
  v_cursor JSONB;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  v_limite := LEAST(GREATEST(COALESCE(p_limite, 20), 1), 100);

  WITH base AS (
    SELECT pe.id, pe.id_contrato, pe.id_periodo, pe.descripcion, pe.importe, pe.creado_en,
           row_number() OVER (ORDER BY pe.creado_en DESC, pe.id DESC) AS _rn
    FROM penalidad pe
    WHERE pe.id_empresa = p_id_empresa
      AND pe.eliminado_en IS NULL
      AND (p_id_contrato IS NULL OR pe.id_contrato = p_id_contrato)
      AND (p_id_periodo IS NULL OR pe.id_periodo = p_id_periodo)
      AND (p_cursor_creado_en IS NULL OR (pe.creado_en, pe.id) < (p_cursor_creado_en, p_cursor_id))
    ORDER BY pe.creado_en DESC, pe.id DESC
    LIMIT v_limite + 1
  )
  SELECT
    COALESCE(jsonb_agg(to_jsonb(base) - '_rn' ORDER BY base._rn) FILTER (WHERE base._rn <= v_limite), '[]'::jsonb),
    count(*) > v_limite
  INTO v_items, v_hay_mas
  FROM base;

  v_n := jsonb_array_length(v_items);
  IF v_hay_mas AND v_n > 0 THEN
    v_cursor := jsonb_build_object('creado_en', v_items -> (v_n - 1) -> 'creado_en', 'id', v_items -> (v_n - 1) -> 'id');
  ELSE
    v_cursor := NULL;
  END IF;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'PENALIDADES_LISTADAS',
    'mensaje', 'Listado de penalidades obtenido',
    'datos', jsonb_build_object(
      'items', v_items,
      'paginacion', jsonb_build_object('limite', v_limite, 'hay_mas', v_hay_mas, 'cursor_siguiente', v_cursor)
    )
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'PENALIDADES_LISTADO_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al listar las penalidades');
END;
$$;

-- >>> fn_listar_provisiones.sql
CREATE OR REPLACE FUNCTION fn_listar_provisiones(
  p_id_empresa UUID,
  p_id_contrato UUID,
  p_id_periodo UUID,
  p_limite INT,
  p_cursor_creado_en TIMESTAMPTZ,
  p_cursor_id UUID
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_limite INT;
  v_items JSONB;
  v_hay_mas BOOL;
  v_n INT;
  v_cursor JSONB;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  v_limite := LEAST(GREATEST(COALESCE(p_limite, 20), 1), 100);

  WITH base AS (
    SELECT pr.id, pr.id_contrato, pr.id_periodo, pr.descripcion, pr.importe, pr.aplicado, pr.creado_en,
           row_number() OVER (ORDER BY pr.creado_en DESC, pr.id DESC) AS _rn
    FROM provision pr
    WHERE pr.id_empresa = p_id_empresa
      AND pr.eliminado_en IS NULL
      AND (p_id_contrato IS NULL OR pr.id_contrato = p_id_contrato)
      AND (p_id_periodo IS NULL OR pr.id_periodo = p_id_periodo)
      AND (p_cursor_creado_en IS NULL OR (pr.creado_en, pr.id) < (p_cursor_creado_en, p_cursor_id))
    ORDER BY pr.creado_en DESC, pr.id DESC
    LIMIT v_limite + 1
  )
  SELECT
    COALESCE(jsonb_agg(to_jsonb(base) - '_rn' ORDER BY base._rn) FILTER (WHERE base._rn <= v_limite), '[]'::jsonb),
    count(*) > v_limite
  INTO v_items, v_hay_mas
  FROM base;

  v_n := jsonb_array_length(v_items);
  IF v_hay_mas AND v_n > 0 THEN
    v_cursor := jsonb_build_object('creado_en', v_items -> (v_n - 1) -> 'creado_en', 'id', v_items -> (v_n - 1) -> 'id');
  ELSE
    v_cursor := NULL;
  END IF;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'PROVISIONES_LISTADAS',
    'mensaje', 'Listado de provisiones obtenido',
    'datos', jsonb_build_object(
      'items', v_items,
      'paginacion', jsonb_build_object('limite', v_limite, 'hay_mas', v_hay_mas, 'cursor_siguiente', v_cursor)
    )
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'PROVISIONES_LISTADO_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al listar las provisiones');
END;
$$;

-- >>> fn_obtener_resumen_cierre_por_periodo.sql
CREATE OR REPLACE FUNCTION fn_obtener_resumen_cierre_por_periodo(
  p_id_empresa UUID,
  p_id_periodo UUID
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_resumen JSONB;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  IF NOT EXISTS (SELECT 1 FROM periodo WHERE id = p_id_periodo AND id_empresa = p_id_empresa AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'PERIODO_NO_VALIDO', 'mensaje', 'El periodo no existe o no pertenece a la empresa');
  END IF;

  SELECT jsonb_build_object(
    'total_contratos', count(*),
    'cerrados', count(*) FILTER (WHERE estado = 'CERRADO'),
    'borradores', count(*) FILTER (WHERE estado = 'BORRADOR'),
    'reabiertos', count(*) FILTER (WHERE estado = 'REABIERTO'),
    'total_facturado', COALESCE(sum(total_facturado), 0),
    'total_gastos', COALESCE(sum(total_gastos), 0),
    'utilidad_bruta', COALESCE(sum(utilidad_bruta), 0),
    'utilidad_neta', COALESCE(sum(utilidad_neta), 0),
    'utilidad_final', COALESCE(sum(utilidad_final), 0),
    'total_penalidades', COALESCE(sum(penalidades), 0)
  ) INTO v_resumen
  FROM cierre_mensual
  WHERE id_empresa = p_id_empresa AND id_periodo = p_id_periodo AND eliminado_en IS NULL;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'RESUMEN_CIERRE_PERIODO',
    'mensaje', 'Resumen del cierre por periodo obtenido',
    'datos', jsonb_build_object('id_periodo', p_id_periodo, 'resumen', v_resumen)
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'RESUMEN_CIERRE_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al obtener el resumen');
END;
$$;

