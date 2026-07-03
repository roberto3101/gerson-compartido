-- ====================================================================
-- sesga_grupo5_capacidades.sql  -  Grupo 5 (activos-e-inversion + cierre-mensual)
-- Esquema local funcional para CockroachDB v26.
-- Stubs de otras capacidades + 18 tablas + indices + 82 procedimientos (41 nuevos: mantenimiento, incidencias, intervenciones, ajustes de recuperacion, parametros, y variantes de catalogo actualizar/baja/reactivar).
-- Generado desde codeplexMaster (fuente de verdad). Solo para pruebas locales.
-- ====================================================================
DROP DATABASE IF EXISTS sesga_test CASCADE;
CREATE DATABASE sesga_test;
SET database = sesga_test;

-- ---- STUBS (otras capacidades; version minima para pruebas) ----
CREATE TABLE empresa (id UUID PRIMARY KEY DEFAULT gen_random_uuid(), estado STRING NOT NULL DEFAULT 'ACTIVO', eliminado_en TIMESTAMPTZ);
CREATE TABLE usuario (id UUID PRIMARY KEY DEFAULT gen_random_uuid());
CREATE TABLE estado_contrato (id UUID PRIMARY KEY DEFAULT gen_random_uuid(), id_empresa UUID, es_vigente BOOL NOT NULL DEFAULT true, eliminado_en TIMESTAMPTZ);
INSERT INTO estado_contrato (id, es_vigente) VALUES ('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', true);
CREATE TABLE contrato (id UUID PRIMARY KEY DEFAULT gen_random_uuid(), id_empresa UUID, id_estado_contrato UUID NOT NULL DEFAULT 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', eliminado_en TIMESTAMPTZ);
CREATE TABLE zona (id UUID PRIMARY KEY DEFAULT gen_random_uuid(), id_empresa UUID, estado STRING NOT NULL DEFAULT 'ACTIVO', eliminado_en TIMESTAMPTZ);
CREATE TABLE periodo (id UUID PRIMARY KEY DEFAULT gen_random_uuid(), id_empresa UUID, anio INT2, mes INT2, eliminado_en TIMESTAMPTZ);
CREATE TABLE operario (id UUID PRIMARY KEY DEFAULT gen_random_uuid(), id_empresa UUID, eliminado_en TIMESTAMPTZ);

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
  recuperacion_inversion DECIMAL(18,2) NOT NULL DEFAULT 0,
  gastos_administrativos DECIMAL(18,2) NOT NULL DEFAULT 0,
  gastos_indirectos DECIMAL(18,2) NOT NULL DEFAULT 0,
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
  CONSTRAINT ck_cierre_mensual_recuperacion_inversion CHECK (recuperacion_inversion >= 0),
  CONSTRAINT ck_cierre_mensual_gastos_administrativos CHECK (gastos_administrativos >= 0),
  CONSTRAINT ck_cierre_mensual_gastos_indirectos CHECK (gastos_indirectos >= 0),
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
-- >>> idx_activo.sql
CREATE INDEX idx_activo_estado ON activo (id_empresa, estado) WHERE eliminado_en IS NULL;
CREATE INDEX idx_star_activo_listado ON activo (id_empresa, creado_en DESC, id DESC) STORING (codigo, descripcion, estado, placa, marca, modelo, anio_fabricacion, costo_adquisicion, id_clasificacion_activo, id_tipo_adquisicion_activo) WHERE eliminado_en IS NULL;

-- >>> idx_activo_asignacion_contrato.sql
CREATE INDEX idx_activo_asignacion_contrato_activo ON activo_asignacion_contrato (id_activo, id_contrato);
CREATE INDEX idx_activo_asignacion_contrato_empresa ON activo_asignacion_contrato (id_empresa);
CREATE INDEX idx_activo_asignacion_contrato_estado ON activo_asignacion_contrato (id_activo, id_contrato) WHERE estado = 'ACTIVO';
CREATE INDEX idx_star_activo_asignacion_contrato_listado ON activo_asignacion_contrato (id_empresa, id_activo, creado_en DESC, id DESC) STORING (id_contrato, id_zona, inversion_asignada, saldo_inversion_pendiente, cuota_recuperacion_mensual, fecha_inicio, fecha_fin, estado, creado_por_usuario_id) WHERE eliminado_en IS NULL;

-- >>> idx_activo_registro_trabajo.sql
CREATE INDEX idx_activo_registro_trabajo_activo ON activo_registro_trabajo (id_activo, id_periodo);
CREATE INDEX idx_activo_registro_trabajo_contrato ON activo_registro_trabajo (id_contrato, id_periodo);
CREATE INDEX idx_star_activo_registro_trabajo_listado ON activo_registro_trabajo (id_empresa, id_activo, creado_en DESC, id DESC) STORING (id_contrato, id_zona, id_operario, id_periodo, fecha, horas_trabajadas, descripcion_trabajo, valorizacion_trabajo, dias_depreciados, kilometraje_inicio, kilometraje_fin) WHERE eliminado_en IS NULL;

-- >>> idx_activo_traslado.sql
CREATE INDEX idx_activo_traslado_activo ON activo_traslado (id_activo);
CREATE INDEX idx_star_activo_traslado_listado ON activo_traslado (id_empresa, id_activo, creado_en DESC, id DESC) STORING (id_contrato_origen, id_zona_origen, id_contrato_destino, id_zona_destino, fecha_traslado, saldo_trasladado, motivo, creado_por_usuario_id);

-- >>> idx_clasificacion_activo.sql
CREATE UNIQUE INDEX idx_unico_clasificacion_activo_codigo ON clasificacion_activo (id_empresa, codigo) WHERE eliminado_en IS NULL;

-- >>> idx_herramienta.sql
CREATE INDEX idx_star_herramienta_listado ON herramienta (id_empresa, creado_en DESC, id DESC) STORING (codigo, descripcion, marca, modelo, numero_serie, estado, costo_adquisicion, id_tipo_herramienta) WHERE eliminado_en IS NULL;

-- >>> idx_herramienta_movimiento.sql
CREATE INDEX idx_herramienta_movimiento_periodo ON herramienta_movimiento (id_empresa, id_periodo);
CREATE INDEX idx_herramienta_movimiento_origen ON herramienta_movimiento (id_contrato_origen);
CREATE INDEX idx_herramienta_movimiento_destino ON herramienta_movimiento (id_contrato_destino);
CREATE INDEX idx_star_herramienta_movimiento_listado ON herramienta_movimiento (id_empresa, id_herramienta, creado_en DESC, id DESC) STORING (tipo_movimiento, fecha, id_periodo, id_contrato_origen, id_zona_origen, id_contrato_destino, id_zona_destino, cantidad, costo, valorizacion, motivo, creado_por_usuario_id);

-- >>> idx_recuperacion_inversion_mensual.sql
CREATE INDEX idx_recuperacion_inversion_mensual_contrato ON recuperacion_inversion_mensual (id_contrato, id_periodo);
CREATE INDEX idx_recuperacion_inversion_mensual_activo ON recuperacion_inversion_mensual (id_activo);
CREATE INDEX idx_star_recuperacion_inversion_mensual_listado ON recuperacion_inversion_mensual (id_empresa, creado_en DESC, id DESC) STORING (id_activo, id_contrato, id_periodo, importe_recuperado, saldo_antes, saldo_despues, parado);

-- >>> idx_tipo_adquisicion_activo.sql
CREATE UNIQUE INDEX idx_unico_tipo_adquisicion_activo_codigo ON tipo_adquisicion_activo (id_empresa, codigo) WHERE eliminado_en IS NULL;

-- >>> idx_tipo_herramienta.sql
CREATE UNIQUE INDEX idx_unico_tipo_herramienta_codigo ON tipo_herramienta (id_empresa, codigo) WHERE eliminado_en IS NULL;

-- >>> idx_cierre_mensual.sql
CREATE INDEX idx_cierre_mensual_estado ON cierre_mensual (id_empresa, estado);
CREATE INDEX idx_star_cierre_mensual_listado ON cierre_mensual (id_empresa, creado_en DESC, id DESC) STORING (id_contrato, id_periodo, total_facturado, total_gastos, utilidad_bruta, utilidad_neta, utilidad_final, estado, fecha_cierre) WHERE eliminado_en IS NULL;

-- >>> idx_penalidad.sql
CREATE INDEX idx_penalidad_contrato_periodo ON penalidad (id_contrato, id_periodo);
CREATE INDEX idx_star_penalidad_listado ON penalidad (id_empresa, creado_en DESC, id DESC) STORING (id_contrato, id_periodo, descripcion, importe) WHERE eliminado_en IS NULL;

-- >>> idx_provision.sql
CREATE INDEX idx_provision_contrato_periodo ON provision (id_contrato, id_periodo);
CREATE INDEX idx_star_provision_listado ON provision (id_empresa, creado_en DESC, id DESC) STORING (id_contrato, id_periodo, descripcion, importe, aplicado) WHERE eliminado_en IS NULL;

-- ---- PROCEDIMIENTOS (26: 13 comando + 13 lectura; lectura con lenguaje ubicuo de Gerson) ----
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
    SELECT 1 FROM contrato c
    JOIN estado_contrato ec ON ec.id = c.id_estado_contrato AND ec.eliminado_en IS NULL
    WHERE c.id = p_id_contrato AND c.id_empresa = p_id_empresa AND c.eliminado_en IS NULL AND ec.es_vigente = true
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
  v_periodo_anio INT2;
  v_periodo_mes INT2;
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
    SELECT 1 FROM contrato c
    JOIN estado_contrato ec ON ec.id = c.id_estado_contrato AND ec.eliminado_en IS NULL
    WHERE c.id = p_id_contrato AND c.id_empresa = p_id_empresa AND c.eliminado_en IS NULL AND ec.es_vigente = true
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

  SELECT anio, mes INTO v_periodo_anio, v_periodo_mes
  FROM periodo
  WHERE id = p_id_periodo AND id_empresa = p_id_empresa AND eliminado_en IS NULL;

  IF v_periodo_anio IS NULL THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'PERIODO_NO_VALIDO', 'mensaje', 'El periodo no existe o no pertenece a la empresa');
  END IF;

  IF EXTRACT(YEAR FROM p_fecha)::INT <> v_periodo_anio OR EXTRACT(MONTH FROM p_fecha)::INT <> v_periodo_mes THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'PERIODO_FECHA_INCOHERENTE', 'mensaje', 'La fecha del trabajo no corresponde al periodo seleccionado (deben ser del mismo mes y anio)');
  END IF;

  IF p_kilometraje_inicio IS NOT NULL AND p_kilometraje_fin IS NOT NULL AND p_kilometraje_fin < p_kilometraje_inicio THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'KILOMETRAJE_INVALIDO', 'mensaje', 'El kilometraje final no puede ser menor que el inicial');
  END IF;

  IF p_horas_trabajadas IS NULL OR p_horas_trabajadas <= 0 THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'HORAS_INVALIDAS', 'mensaje', 'Las horas trabajadas deben ser mayores a 0');
  END IF;

  IF COALESCE(p_valorizacion_trabajo, 0) < 0 OR COALESCE(p_dias_depreciados, 0) < 0 THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'MONTO_INVALIDO', 'mensaje', 'La valorizacion y los dias depreciados no pueden ser negativos');
  END IF;

  IF p_fecha_hora_inicio IS NOT NULL AND p_fecha_hora_fin IS NOT NULL AND p_fecha_hora_fin <= p_fecha_hora_inicio THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'RANGO_HORARIO_INVALIDO', 'mensaje', 'La fecha y hora de fin debe ser posterior a la de inicio');
  END IF;

  IF p_id_operario IS NOT NULL AND NOT EXISTS (
    SELECT 1 FROM operario WHERE id = p_id_operario AND id_empresa = p_id_empresa AND eliminado_en IS NULL
  ) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'OPERARIO_NO_VALIDO', 'mensaje', 'El operario no existe o no pertenece a la empresa');
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM activo_asignacion_contrato
    WHERE id_empresa = p_id_empresa AND id_activo = p_id_activo AND id_contrato = p_id_contrato
      AND eliminado_en IS NULL AND estado = 'ACTIVO'
  ) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'ACTIVO_NO_ASIGNADO_CONTRATO', 'mensaje', 'El activo no tiene una asignacion vigente en ese contrato; asigne el activo antes de registrar trabajo');
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
    SELECT 1 FROM contrato c
    JOIN estado_contrato ec ON ec.id = c.id_estado_contrato AND ec.eliminado_en IS NULL
    WHERE c.id = p_id_contrato AND c.id_empresa = p_id_empresa AND c.eliminado_en IS NULL AND ec.es_vigente = true
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
  v_fecha_inicio_origen DATE;
  v_id_traslado UUID;
  v_id_asignacion_destino UUID;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  IF NOT EXISTS (SELECT 1 FROM activo WHERE id = p_id_activo AND id_empresa = p_id_empresa AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'ACTIVO_NO_VALIDO', 'mensaje', 'El activo no existe o no pertenece a la empresa');
  END IF;

  IF EXISTS (SELECT 1 FROM activo WHERE id = p_id_activo AND id_empresa = p_id_empresa AND eliminado_en IS NULL AND estado = 'BAJA') THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'ACTIVO_DADO_DE_BAJA', 'mensaje', 'El activo esta dado de baja, no se puede trasladar');
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

  SELECT saldo_inversion_pendiente, cuota_recuperacion_mensual, fecha_inicio
    INTO v_saldo, v_cuota, v_fecha_inicio_origen
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
    SELECT 1 FROM contrato c
    JOIN estado_contrato ec ON ec.id = c.id_estado_contrato AND ec.eliminado_en IS NULL
    WHERE c.id = p_id_contrato_destino AND c.id_empresa = p_id_empresa AND c.eliminado_en IS NULL AND ec.es_vigente = true
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

  IF p_id_contrato_origen IS NOT DISTINCT FROM p_id_contrato_destino
     AND p_id_zona_origen IS NOT DISTINCT FROM p_id_zona_destino THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'TRASLADO_SIN_CAMBIO', 'mensaje', 'El traslado debe cambiar de contrato o de zona; el destino es igual al origen');
  END IF;

  IF p_fecha_traslado IS NULL THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'FECHA_TRASLADO_OBLIGATORIA', 'mensaje', 'La fecha de traslado es obligatoria');
  END IF;

  IF p_fecha_traslado > current_date THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'FECHA_TRASLADO_FUTURA', 'mensaje', 'La fecha de traslado no puede ser futura');
  END IF;

  IF p_fecha_traslado < v_fecha_inicio_origen THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'FECHA_TRASLADO_INVALIDA', 'mensaje', 'La fecha de traslado no puede ser anterior al inicio de la asignacion de origen');
  END IF;

  IF EXISTS (
    SELECT 1 FROM activo_asignacion_contrato
    WHERE id_empresa = p_id_empresa AND id_activo = p_id_activo AND id_contrato = p_id_contrato_destino
      AND eliminado_en IS NULL AND estado = 'ACTIVO'
  ) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'ACTIVO_YA_ASIGNADO_DESTINO', 'mensaje', 'El activo ya tiene una asignacion vigente en el contrato destino');
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
  v_periodo_anio INT2;
  v_periodo_mes INT2;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  IF NOT EXISTS (SELECT 1 FROM herramienta WHERE id = p_id_herramienta AND id_empresa = p_id_empresa AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'HERRAMIENTA_NO_VALIDA', 'mensaje', 'La herramienta no existe o no pertenece a la empresa');
  END IF;

  IF EXISTS (SELECT 1 FROM herramienta WHERE id = p_id_herramienta AND id_empresa = p_id_empresa AND eliminado_en IS NULL AND estado = 'BAJA') THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'HERRAMIENTA_DADA_DE_BAJA', 'mensaje', 'La herramienta esta dada de baja, no admite movimientos; debe reactivarse primero');
  END IF;

  IF p_tipo_movimiento NOT IN ('ENTRADA', 'SALIDA', 'TRASLADO', 'BAJA') THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'TIPO_MOVIMIENTO_NO_VALIDO', 'mensaje', 'El tipo de movimiento no es valido');
  END IF;

  IF p_cantidad IS NULL OR p_cantidad <= 0 THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'CANTIDAD_INVALIDA', 'mensaje', 'La cantidad del movimiento debe ser mayor a 0');
  END IF;

  IF COALESCE(p_costo, 0) < 0 OR COALESCE(p_valorizacion, 0) < 0 THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'MONTO_INVALIDO', 'mensaje', 'El costo y la valorizacion no pueden ser negativos');
  END IF;

  IF p_fecha IS NULL THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'FECHA_OBLIGATORIA', 'mensaje', 'La fecha del movimiento es obligatoria');
  END IF;

  IF p_fecha > current_date THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'FECHA_FUTURA', 'mensaje', 'La fecha del movimiento no puede ser futura');
  END IF;

  SELECT anio, mes INTO v_periodo_anio, v_periodo_mes
  FROM periodo
  WHERE id = p_id_periodo AND id_empresa = p_id_empresa AND eliminado_en IS NULL;

  IF v_periodo_anio IS NULL THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'PERIODO_NO_VALIDO', 'mensaje', 'El periodo no existe o no pertenece a la empresa');
  END IF;

  IF EXTRACT(YEAR FROM p_fecha)::INT <> v_periodo_anio OR EXTRACT(MONTH FROM p_fecha)::INT <> v_periodo_mes THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'PERIODO_FECHA_INCOHERENTE', 'mensaje', 'La fecha del movimiento no corresponde al periodo seleccionado (deben ser del mismo mes y anio)');
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
    SELECT 1 FROM contrato c
    JOIN estado_contrato ec ON ec.id = c.id_estado_contrato AND ec.eliminado_en IS NULL
    WHERE c.id = p_id_contrato_destino AND c.id_empresa = p_id_empresa AND c.eliminado_en IS NULL AND ec.es_vigente = true
  ) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'CONTRATO_DESTINO_NO_VALIDO', 'mensaje', 'El contrato destino no existe, no pertenece a la empresa o no esta vigente');
  END IF;

  IF p_id_zona_destino IS NOT NULL AND NOT EXISTS (
    SELECT 1 FROM zona
    WHERE id = p_id_zona_destino AND id_empresa = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL
  ) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'ZONA_DESTINO_NO_VALIDA', 'mensaje', 'La zona destino no existe, no pertenece a la empresa o no esta vigente');
  END IF;

  IF p_tipo_movimiento = 'ENTRADA' AND (p_id_contrato_destino IS NULL OR p_id_zona_destino IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'DESTINO_OBLIGATORIO', 'mensaje', 'Un movimiento de ENTRADA requiere contrato y zona de destino');
  END IF;

  IF p_tipo_movimiento IN ('SALIDA', 'BAJA') AND (p_id_contrato_origen IS NULL OR p_id_zona_origen IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'ORIGEN_OBLIGATORIO', 'mensaje', 'Un movimiento de SALIDA o BAJA requiere contrato y zona de origen');
  END IF;

  IF p_tipo_movimiento = 'TRASLADO' AND (p_id_contrato_origen IS NULL OR p_id_zona_origen IS NULL OR p_id_contrato_destino IS NULL OR p_id_zona_destino IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'ORIGEN_DESTINO_OBLIGATORIO', 'mensaje', 'Un movimiento de TRASLADO requiere contrato y zona de origen y de destino');
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
    SELECT 1 FROM contrato c
    JOIN estado_contrato ec ON ec.id = c.id_estado_contrato AND ec.eliminado_en IS NULL
    WHERE c.id = p_id_contrato AND c.id_empresa = p_id_empresa AND c.eliminado_en IS NULL AND ec.es_vigente = true
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
    SELECT 1 FROM contrato c
    JOIN estado_contrato ec ON ec.id = c.id_estado_contrato AND ec.eliminado_en IS NULL
    WHERE c.id = p_id_contrato AND c.id_empresa = p_id_empresa AND c.eliminado_en IS NULL AND ec.es_vigente = true
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

CREATE OR REPLACE FUNCTION fn_ejecutar_cierre_mensual(
  p_id_empresa UUID,
  p_id_usuario_accion UUID,
  p_id_contrato UUID,
  p_id_periodo UUID,
  p_total_facturado DECIMAL,
  p_total_produccion DECIMAL,
  p_gastos_directos DECIMAL,
  p_gastos_varios_fijos DECIMAL,
  p_gastos_administrativos DECIMAL,
  p_gastos_indirectos DECIMAL,
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
    SELECT 1 FROM contrato c
    JOIN estado_contrato ec ON ec.id = c.id_estado_contrato AND ec.eliminado_en IS NULL
    WHERE c.id = p_id_contrato AND c.id_empresa = p_id_empresa AND c.eliminado_en IS NULL AND ec.es_vigente = true
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
    + COALESCE(p_gastos_varios_fijos, 0);

  v_utilidad_bruta := COALESCE(p_total_facturado, 0) - v_total_gastos;

  v_utilidad_neta := v_utilidad_bruta
    - v_recuperacion
    - COALESCE(p_gastos_administrativos, 0)
    - COALESCE(p_gastos_indirectos, 0)
    - COALESCE(p_gastos_sig, 0)
    - COALESCE(p_impuesto_renta, 0)
    - COALESCE(p_renta_adicional, 0)
    - COALESCE(p_reparto_utilidades, 0);

  v_utilidad_final := v_utilidad_neta - v_penalidades;

  INSERT INTO cierre_mensual (
    id_empresa, id_contrato, id_periodo,
    total_facturado, total_produccion, gastos_directos, gastos_varios_fijos,
    recuperacion_inversion, gastos_administrativos, gastos_indirectos, gastos_sig,
    total_gastos, utilidad_bruta, impuesto_renta, renta_adicional, reparto_utilidades, penalidades,
    utilidad_neta, utilidad_final, estado, creado_por_usuario_id
  ) VALUES (
    p_id_empresa, p_id_contrato, p_id_periodo,
    COALESCE(p_total_facturado, 0), COALESCE(p_total_produccion, 0), COALESCE(p_gastos_directos, 0), COALESCE(p_gastos_varios_fijos, 0),
    v_recuperacion, COALESCE(p_gastos_administrativos, 0), COALESCE(p_gastos_indirectos, 0), COALESCE(p_gastos_sig, 0),
    v_total_gastos, v_utilidad_bruta, COALESCE(p_impuesto_renta, 0), COALESCE(p_renta_adicional, 0), COALESCE(p_reparto_utilidades, 0), v_penalidades,
    v_utilidad_neta, v_utilidad_final, 'BORRADOR', p_id_usuario_accion
  )
  ON CONFLICT (id_contrato, id_periodo) DO UPDATE SET
    total_facturado = excluded.total_facturado,
    total_produccion = excluded.total_produccion,
    gastos_directos = excluded.gastos_directos,
    gastos_varios_fijos = excluded.gastos_varios_fijos,
    recuperacion_inversion = excluded.recuperacion_inversion,
    gastos_administrativos = excluded.gastos_administrativos,
    gastos_indirectos = excluded.gastos_indirectos,
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

CREATE OR REPLACE FUNCTION fn_recalcular_cierre_mensual(
  p_id_empresa UUID,
  p_id_usuario_accion UUID,
  p_id_contrato UUID,
  p_id_periodo UUID,
  p_total_facturado DECIMAL,
  p_total_produccion DECIMAL,
  p_gastos_directos DECIMAL,
  p_gastos_varios_fijos DECIMAL,
  p_gastos_administrativos DECIMAL,
  p_gastos_indirectos DECIMAL,
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
    SELECT 1 FROM contrato c
    JOIN estado_contrato ec ON ec.id = c.id_estado_contrato AND ec.eliminado_en IS NULL
    WHERE c.id = p_id_contrato AND c.id_empresa = p_id_empresa AND c.eliminado_en IS NULL AND ec.es_vigente = true
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
    + COALESCE(p_gastos_varios_fijos, 0);

  v_utilidad_bruta := COALESCE(p_total_facturado, 0) - v_total_gastos;

  v_utilidad_neta := v_utilidad_bruta
    - v_recuperacion
    - COALESCE(p_gastos_administrativos, 0)
    - COALESCE(p_gastos_indirectos, 0)
    - COALESCE(p_gastos_sig, 0)
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
    recuperacion_inversion = v_recuperacion,
    gastos_administrativos = COALESCE(p_gastos_administrativos, 0),
    gastos_indirectos = COALESCE(p_gastos_indirectos, 0),
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

CREATE OR REPLACE FUNCTION fn_listar_activos(
  p_id_empresa UUID,
  p_estado STRING DEFAULT NULL,
  p_id_clasificacion_activo UUID DEFAULT NULL,
  p_busqueda STRING DEFAULT NULL,
  p_limite INT DEFAULT NULL,
  p_cursor_creado_en TIMESTAMPTZ DEFAULT NULL,
  p_cursor_id UUID DEFAULT NULL
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_limite_pagina INT;
  v_activos_pagina JSONB;
  v_existen_mas_activos BOOL;
  v_cantidad_activos_pagina INT;
  v_cursor_siguiente JSONB;
  v_total INT;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  v_limite_pagina := LEAST(GREATEST(COALESCE(p_limite, 20), 1), 100);

  SELECT count(*) INTO v_total
  FROM activo a
  WHERE a.id_empresa = p_id_empresa
    AND a.eliminado_en IS NULL
    AND (p_estado IS NULL OR a.estado = p_estado)
    AND (p_id_clasificacion_activo IS NULL OR a.id_clasificacion_activo = p_id_clasificacion_activo)
    AND (p_busqueda IS NULL OR a.codigo ILIKE '%' || p_busqueda || '%' OR a.descripcion ILIKE '%' || p_busqueda || '%' OR a.placa ILIKE '%' || p_busqueda || '%');

  WITH activos_ordenados_para_listado AS (
    SELECT a.id, a.codigo, a.descripcion, a.estado, a.placa, a.marca, a.modelo,
           a.anio_fabricacion, a.costo_adquisicion, a.id_clasificacion_activo,
           a.id_tipo_adquisicion_activo, a.creado_en,
           row_number() OVER (ORDER BY a.creado_en DESC, a.id DESC) AS orden_en_pagina
    FROM activo a
    WHERE a.id_empresa = p_id_empresa
      AND a.eliminado_en IS NULL
      AND (p_estado IS NULL OR a.estado = p_estado)
      AND (p_id_clasificacion_activo IS NULL OR a.id_clasificacion_activo = p_id_clasificacion_activo)
      AND (p_busqueda IS NULL OR a.codigo ILIKE '%' || p_busqueda || '%' OR a.descripcion ILIKE '%' || p_busqueda || '%' OR a.placa ILIKE '%' || p_busqueda || '%')
      AND (p_cursor_creado_en IS NULL OR (a.creado_en, a.id) < (p_cursor_creado_en, p_cursor_id))
    ORDER BY a.creado_en DESC, a.id DESC
    LIMIT v_limite_pagina + 1
  )
  SELECT
    COALESCE(
      jsonb_agg(to_jsonb(activos_ordenados_para_listado) - 'orden_en_pagina' ORDER BY activos_ordenados_para_listado.orden_en_pagina)
      FILTER (WHERE activos_ordenados_para_listado.orden_en_pagina <= v_limite_pagina),
      '[]'::jsonb
    ),
    count(*) > v_limite_pagina
  INTO v_activos_pagina, v_existen_mas_activos
  FROM activos_ordenados_para_listado;

  v_cantidad_activos_pagina := jsonb_array_length(v_activos_pagina);
  IF v_existen_mas_activos AND v_cantidad_activos_pagina > 0 THEN
    v_cursor_siguiente := jsonb_build_object(
      'creado_en', v_activos_pagina -> (v_cantidad_activos_pagina - 1) -> 'creado_en',
      'id', v_activos_pagina -> (v_cantidad_activos_pagina - 1) -> 'id'
    );
  ELSE
    v_cursor_siguiente := NULL;
  END IF;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'ACTIVOS_LISTADOS',
    'mensaje', 'Listado de activos obtenido',
    'datos', jsonb_build_object(
      'items', v_activos_pagina,
      'paginacion', jsonb_build_object(
        'limite', v_limite_pagina,
        'hay_mas', v_existen_mas_activos,
        'cursor_siguiente', v_cursor_siguiente,
        'total', v_total
      )
    )
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'ACTIVOS_LISTADO_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al listar los activos');
END;
$$;
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

CREATE OR REPLACE FUNCTION fn_listar_herramientas(
  p_id_empresa UUID,
  p_estado STRING DEFAULT NULL,
  p_id_tipo_herramienta UUID DEFAULT NULL,
  p_texto_busqueda  STRING DEFAULT NULL,
  p_limite_pagina  INT DEFAULT NULL,
  p_cursor_creado_en TIMESTAMPTZ DEFAULT NULL,
  p_cursor_id UUID DEFAULT NULL
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_limite_pagina INT;
  v_herramientas_pagina JSONB;
  v_existen_mas_herramientas BOOL;
  v_cantidad_herramientas_pagina INT;
  v_cursor_siguiente JSONB;
  v_total INT;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  v_limite_pagina := LEAST(GREATEST(COALESCE(p_limite_pagina , 20), 1), 100);

  SELECT count(*) INTO v_total
  FROM herramienta h
  WHERE h.id_empresa = p_id_empresa
    AND h.eliminado_en IS NULL
    AND (p_estado IS NULL OR h.estado = p_estado)
    AND (p_id_tipo_herramienta IS NULL OR h.id_tipo_herramienta = p_id_tipo_herramienta)
    AND (p_texto_busqueda IS NULL
         OR h.codigo ILIKE '%' || p_texto_busqueda || '%'
         OR h.descripcion ILIKE '%' || p_texto_busqueda || '%'
         OR h.marca ILIKE '%' || p_texto_busqueda || '%'
         OR h.modelo ILIKE '%' || p_texto_busqueda || '%'
         OR h.numero_serie ILIKE '%' || p_texto_busqueda || '%');

  WITH herramientas_ordenadas_para_listado AS (
    SELECT h.id, h.codigo, h.descripcion, h.marca, h.modelo, h.numero_serie,
           h.estado, h.costo_adquisicion, h.id_tipo_herramienta, h.creado_en,
           row_number() OVER (ORDER BY h.creado_en DESC, h.id DESC) AS orden_en_pagina
    FROM herramienta h
    WHERE h.id_empresa = p_id_empresa
      AND h.eliminado_en IS NULL
      AND (p_estado IS NULL OR h.estado = p_estado)
      AND (p_id_tipo_herramienta IS NULL OR h.id_tipo_herramienta = p_id_tipo_herramienta)
      AND (p_texto_busqueda IS NULL
           OR h.codigo ILIKE '%' || p_texto_busqueda || '%'
           OR h.descripcion ILIKE '%' || p_texto_busqueda || '%'
           OR h.marca ILIKE '%' || p_texto_busqueda || '%'
           OR h.modelo ILIKE '%' || p_texto_busqueda || '%'
           OR h.numero_serie ILIKE '%' || p_texto_busqueda || '%')
      AND (p_cursor_creado_en IS NULL OR (h.creado_en, h.id) < (p_cursor_creado_en, p_cursor_id))
    ORDER BY h.creado_en DESC, h.id DESC
    LIMIT v_limite_pagina + 1
  )
  SELECT
    COALESCE(
      jsonb_agg(to_jsonb(herramientas_ordenadas_para_listado) - 'orden_en_pagina' ORDER BY herramientas_ordenadas_para_listado.orden_en_pagina)
      FILTER (WHERE herramientas_ordenadas_para_listado.orden_en_pagina <= v_limite_pagina),
      '[]'::jsonb
    ),
    count(*) > v_limite_pagina
  INTO v_herramientas_pagina, v_existen_mas_herramientas
  FROM herramientas_ordenadas_para_listado;

  v_cantidad_herramientas_pagina := jsonb_array_length(v_herramientas_pagina);
  IF v_existen_mas_herramientas AND v_cantidad_herramientas_pagina > 0 THEN
    v_cursor_siguiente := jsonb_build_object(
      'creado_en', v_herramientas_pagina -> (v_cantidad_herramientas_pagina - 1) -> 'creado_en',
      'id', v_herramientas_pagina -> (v_cantidad_herramientas_pagina - 1) -> 'id'
    );
  ELSE
    v_cursor_siguiente := NULL;
  END IF;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'HERRAMIENTAS_LISTADAS',
    'mensaje', 'Listado de herramientas obtenido',
    'datos', jsonb_build_object(
      'items', v_herramientas_pagina,
      'paginacion', jsonb_build_object('limite', v_limite_pagina, 'hay_mas', v_existen_mas_herramientas, 'cursor_siguiente', v_cursor_siguiente, 'total', v_total)
    )
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'HERRAMIENTAS_LISTADO_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al listar las herramientas');
END;
$$;
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


CREATE OR REPLACE FUNCTION fn_listar_movimientos_herramienta(
  p_id_empresa UUID,
  p_id_herramienta UUID DEFAULT NULL,
  p_id_periodo UUID DEFAULT NULL,
  p_tipo_movimiento STRING DEFAULT NULL,
  p_limite INT DEFAULT NULL,
  p_cursor_creado_en TIMESTAMPTZ DEFAULT NULL,
  p_cursor_id UUID DEFAULT NULL
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_limite_pagina INT;
  v_movimientos_herramienta_pagina JSONB;
  v_existen_mas_movimientos BOOL;
  v_cantidad_movimientos_pagina INT;
  v_cursor_siguiente JSONB;
  v_total INT;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  IF NOT EXISTS (SELECT 1 FROM herramienta WHERE id = p_id_herramienta AND id_empresa = p_id_empresa AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'HERRAMIENTA_NO_VALIDA', 'mensaje', 'La herramienta no existe o no pertenece a la empresa');
  END IF;

  v_limite_pagina := LEAST(GREATEST(COALESCE(p_limite, 20), 1), 100);

  SELECT count(*) INTO v_total
  FROM herramienta_movimiento m
  WHERE m.id_empresa = p_id_empresa
    AND m.id_herramienta = p_id_herramienta
    AND (p_id_periodo IS NULL OR m.id_periodo = p_id_periodo)
    AND (p_tipo_movimiento IS NULL OR m.tipo_movimiento = p_tipo_movimiento);

  WITH movimientos_herramienta_ordenados_para_listado AS (
    SELECT m.id, m.tipo_movimiento, m.fecha, m.id_periodo,
           m.id_contrato_origen, m.id_zona_origen, m.id_contrato_destino, m.id_zona_destino,
           m.cantidad, m.costo, m.valorizacion, m.motivo, m.creado_en, m.creado_por_usuario_id,
           row_number() OVER (ORDER BY m.creado_en DESC, m.id DESC) AS orden_en_pagina
    FROM herramienta_movimiento m
    WHERE m.id_empresa = p_id_empresa
      AND m.id_herramienta = p_id_herramienta
      AND (p_id_periodo IS NULL OR m.id_periodo = p_id_periodo)
      AND (p_tipo_movimiento IS NULL OR m.tipo_movimiento = p_tipo_movimiento)
      AND (p_cursor_creado_en IS NULL OR (m.creado_en, m.id) < (p_cursor_creado_en, p_cursor_id))
    ORDER BY m.creado_en DESC, m.id DESC
    LIMIT v_limite_pagina + 1
  )
  SELECT
    COALESCE(
      jsonb_agg(to_jsonb(movimientos_herramienta_ordenados_para_listado) - 'orden_en_pagina' ORDER BY movimientos_herramienta_ordenados_para_listado.orden_en_pagina)
      FILTER (WHERE movimientos_herramienta_ordenados_para_listado.orden_en_pagina <= v_limite_pagina),
      '[]'::jsonb
    ),
    count(*) > v_limite_pagina
  INTO v_movimientos_herramienta_pagina, v_existen_mas_movimientos
  FROM movimientos_herramienta_ordenados_para_listado;

  v_cantidad_movimientos_pagina := jsonb_array_length(v_movimientos_herramienta_pagina);
  IF v_existen_mas_movimientos AND v_cantidad_movimientos_pagina > 0 THEN
    v_cursor_siguiente := jsonb_build_object(
      'creado_en', v_movimientos_herramienta_pagina -> (v_cantidad_movimientos_pagina - 1) -> 'creado_en',
      'id', v_movimientos_herramienta_pagina -> (v_cantidad_movimientos_pagina - 1) -> 'id'
    );
  ELSE
    v_cursor_siguiente := NULL;
  END IF;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'MOVIMIENTOS_HERRAMIENTA_LISTADOS',
    'mensaje', 'Listado de movimientos de la herramienta obtenido',
    'datos', jsonb_build_object(
      'items', v_movimientos_herramienta_pagina,
      'paginacion', jsonb_build_object('limite', v_limite_pagina, 'hay_mas', v_existen_mas_movimientos, 'cursor_siguiente', v_cursor_siguiente, 'total', v_total)
    )
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'MOVIMIENTOS_HERRAMIENTA_LISTADO_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al listar los movimientos');
END;
$$;
CREATE OR REPLACE FUNCTION fn_listar_asignaciones_activo(
  p_id_empresa UUID,
  p_id_activo UUID DEFAULT NULL,
  p_estado STRING DEFAULT NULL,
  p_creado_por UUID DEFAULT NULL,
  p_limite INT DEFAULT NULL,
  p_cursor_creado_en TIMESTAMPTZ DEFAULT NULL,
  p_cursor_id UUID DEFAULT NULL
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_limite_pagina INT;
  v_asignaciones_activo_pagina JSONB;
  v_existen_mas_asignaciones BOOL;
  v_cantidad_asignaciones_pagina INT;
  v_cursor_siguiente JSONB;
  v_total INT;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  IF p_id_activo IS NOT NULL AND NOT EXISTS (SELECT 1 FROM activo WHERE id = p_id_activo AND id_empresa = p_id_empresa AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'ACTIVO_NO_VALIDO', 'mensaje', 'El activo no existe o no pertenece a la empresa');
  END IF;

  v_limite_pagina := LEAST(GREATEST(COALESCE(p_limite, 20), 1), 100);

  SELECT count(*) INTO v_total
  FROM activo_asignacion_contrato ac
  WHERE ac.id_empresa = p_id_empresa
    AND (p_id_activo IS NULL OR ac.id_activo = p_id_activo)
    AND ac.eliminado_en IS NULL
    AND (p_estado IS NULL OR ac.estado = p_estado)
    AND (p_creado_por IS NULL OR ac.creado_por_usuario_id = p_creado_por);

  WITH asignaciones_activo_ordenadas_para_listado AS (
    SELECT ac.id, ac.id_contrato, ac.id_zona, ac.inversion_asignada, ac.saldo_inversion_pendiente,
           ac.cuota_recuperacion_mensual, ac.fecha_inicio, ac.fecha_fin, ac.estado, ac.creado_en,
           ac.creado_por_usuario_id,
           row_number() OVER (ORDER BY ac.creado_en DESC, ac.id DESC) AS _rn
    FROM activo_asignacion_contrato ac
    WHERE ac.id_empresa = p_id_empresa
      AND (p_id_activo IS NULL OR ac.id_activo = p_id_activo)
      AND ac.eliminado_en IS NULL
      AND (p_estado IS NULL OR ac.estado = p_estado)
      AND (p_creado_por IS NULL OR ac.creado_por_usuario_id = p_creado_por)
      AND (p_cursor_creado_en IS NULL OR (ac.creado_en, ac.id) < (p_cursor_creado_en, p_cursor_id))
    ORDER BY ac.creado_en DESC, ac.id DESC
    LIMIT v_limite_pagina + 1
  )
  SELECT
    COALESCE(jsonb_agg(to_jsonb(asignaciones_activo_ordenadas_para_listado) - '_rn' ORDER BY asignaciones_activo_ordenadas_para_listado._rn) FILTER (WHERE asignaciones_activo_ordenadas_para_listado._rn <= v_limite_pagina), '[]'::jsonb),
    count(*) > v_limite_pagina
  INTO v_asignaciones_activo_pagina, v_existen_mas_asignaciones
  FROM asignaciones_activo_ordenadas_para_listado;

  v_cantidad_asignaciones_pagina := jsonb_array_length(v_asignaciones_activo_pagina);
  IF v_existen_mas_asignaciones AND v_cantidad_asignaciones_pagina > 0 THEN
    v_cursor_siguiente := jsonb_build_object('creado_en', v_asignaciones_activo_pagina -> (v_cantidad_asignaciones_pagina - 1) -> 'creado_en', 'id', v_asignaciones_activo_pagina -> (v_cantidad_asignaciones_pagina - 1) -> 'id');
  ELSE
    v_cursor_siguiente := NULL;
  END IF;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'ASIGNACIONES_ACTIVO_LISTADAS',
    'mensaje', 'Listado de asignaciones del activo obtenido',
    'datos', jsonb_build_object(
      'items', v_asignaciones_activo_pagina,
      'paginacion', jsonb_build_object('limite', v_limite_pagina, 'hay_mas', v_existen_mas_asignaciones, 'cursor_siguiente', v_cursor_siguiente, 'total', v_total)
    )
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'ASIGNACIONES_ACTIVO_LISTADO_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al listar las asignaciones');
END;
$$;

CREATE OR REPLACE FUNCTION fn_listar_trabajos_activo(
  p_id_empresa UUID,
  p_id_activo UUID DEFAULT NULL,
  p_id_contrato UUID DEFAULT NULL,
  p_id_periodo UUID DEFAULT NULL,
  p_id_zona UUID DEFAULT NULL,
  p_limite INT DEFAULT NULL,
  p_cursor_creado_en TIMESTAMPTZ DEFAULT NULL,
  p_cursor_id UUID DEFAULT NULL
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_limite_pagina INT;
  v_trabajos_activo_pagina JSONB;
  v_existen_mas_trabajos BOOL;
  v_cantidad_trabajos_pagina INT;
  v_cursor_siguiente JSONB;
  v_total INT;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  IF p_id_activo IS NOT NULL AND NOT EXISTS (SELECT 1 FROM activo WHERE id = p_id_activo AND id_empresa = p_id_empresa AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'ACTIVO_NO_VALIDO', 'mensaje', 'El activo no existe o no pertenece a la empresa');
  END IF;

  v_limite_pagina := LEAST(GREATEST(COALESCE(p_limite, 20), 1), 100);

  SELECT count(*) INTO v_total
  FROM activo_registro_trabajo t
  WHERE t.id_empresa = p_id_empresa
    AND (p_id_activo IS NULL OR t.id_activo = p_id_activo)
    AND t.eliminado_en IS NULL
    AND (p_id_contrato IS NULL OR t.id_contrato = p_id_contrato)
    AND (p_id_periodo IS NULL OR t.id_periodo = p_id_periodo)
    AND (p_id_zona IS NULL OR t.id_zona = p_id_zona);

  WITH trabajos_activo_ordenados_para_listado AS (
    SELECT t.id, t.id_contrato, t.id_zona, t.id_operario, t.id_periodo, t.fecha,
           t.horas_trabajadas, t.descripcion_trabajo, t.valorizacion_trabajo, t.dias_depreciados,
           t.kilometraje_inicio, t.kilometraje_fin, t.creado_en,
           row_number() OVER (ORDER BY t.creado_en DESC, t.id DESC) AS orden_en_pagina
    FROM activo_registro_trabajo t
    WHERE t.id_empresa = p_id_empresa
      AND (p_id_activo IS NULL OR t.id_activo = p_id_activo)
      AND t.eliminado_en IS NULL
      AND (p_id_contrato IS NULL OR t.id_contrato = p_id_contrato)
      AND (p_id_periodo IS NULL OR t.id_periodo = p_id_periodo)
      AND (p_id_zona IS NULL OR t.id_zona = p_id_zona)
      AND (p_cursor_creado_en IS NULL OR (t.creado_en, t.id) < (p_cursor_creado_en, p_cursor_id))
    ORDER BY t.creado_en DESC, t.id DESC
    LIMIT v_limite_pagina + 1
  )
  SELECT
    COALESCE(
      jsonb_agg(to_jsonb(trabajos_activo_ordenados_para_listado) - 'orden_en_pagina' ORDER BY trabajos_activo_ordenados_para_listado.orden_en_pagina)
      FILTER (WHERE trabajos_activo_ordenados_para_listado.orden_en_pagina <= v_limite_pagina),
      '[]'::jsonb
    ),
    count(*) > v_limite_pagina
  INTO v_trabajos_activo_pagina, v_existen_mas_trabajos
  FROM trabajos_activo_ordenados_para_listado;

  v_cantidad_trabajos_pagina := jsonb_array_length(v_trabajos_activo_pagina);
  IF v_existen_mas_trabajos AND v_cantidad_trabajos_pagina > 0 THEN
    v_cursor_siguiente := jsonb_build_object(
      'creado_en', v_trabajos_activo_pagina -> (v_cantidad_trabajos_pagina - 1) -> 'creado_en',
      'id', v_trabajos_activo_pagina -> (v_cantidad_trabajos_pagina - 1) -> 'id'
    );
  ELSE
    v_cursor_siguiente := NULL;
  END IF;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'TRABAJOS_ACTIVO_LISTADOS',
    'mensaje', 'Listado de trabajos del activo obtenido',
    'datos', jsonb_build_object(
      'items', v_trabajos_activo_pagina,
      'paginacion', jsonb_build_object('limite', v_limite_pagina, 'hay_mas', v_existen_mas_trabajos, 'cursor_siguiente', v_cursor_siguiente, 'total', v_total)
    )
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'TRABAJOS_ACTIVO_LISTADO_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al listar los trabajos');
END;
$$;

CREATE OR REPLACE FUNCTION fn_listar_traslados_activo(
  p_id_empresa UUID,
  p_id_activo UUID DEFAULT NULL,
  p_limite INT DEFAULT NULL,
  p_cursor_creado_en TIMESTAMPTZ DEFAULT NULL,
  p_cursor_id UUID DEFAULT NULL
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_limite_pagina INT;
  v_traslados_activo_pagina JSONB;
  v_existen_mas_traslados BOOL;
  v_cantidad_traslados_pagina INT;
  v_cursor_siguiente JSONB;
  v_total INT;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  IF NOT EXISTS (SELECT 1 FROM activo WHERE id = p_id_activo AND id_empresa = p_id_empresa AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'ACTIVO_NO_VALIDO', 'mensaje', 'El activo no existe o no pertenece a la empresa');
  END IF;

  v_limite_pagina := LEAST(GREATEST(COALESCE(p_limite, 20), 1), 100);

  SELECT count(*) INTO v_total
  FROM activo_traslado t
  WHERE t.id_empresa = p_id_empresa
    AND t.id_activo = p_id_activo;

  WITH traslados_activo_ordenados_para_listado AS (
    SELECT t.id, t.id_contrato_origen, t.id_zona_origen, t.id_contrato_destino, t.id_zona_destino,
           t.fecha_traslado, t.saldo_trasladado, t.motivo, t.creado_en,
           t.creado_por_usuario_id,
           row_number() OVER (ORDER BY t.creado_en DESC, t.id DESC) AS orden_en_pagina
    FROM activo_traslado t
    WHERE t.id_empresa = p_id_empresa
      AND t.id_activo = p_id_activo
      AND (p_cursor_creado_en IS NULL OR (t.creado_en, t.id) < (p_cursor_creado_en, p_cursor_id))
    ORDER BY t.creado_en DESC, t.id DESC
    LIMIT v_limite_pagina + 1
  )
  SELECT
    COALESCE(
      jsonb_agg(to_jsonb(traslados_activo_ordenados_para_listado) - 'orden_en_pagina' ORDER BY traslados_activo_ordenados_para_listado.orden_en_pagina)
      FILTER (WHERE traslados_activo_ordenados_para_listado.orden_en_pagina <= v_limite_pagina),
      '[]'::jsonb
    ),
    count(*) > v_limite_pagina
  INTO v_traslados_activo_pagina, v_existen_mas_traslados
  FROM traslados_activo_ordenados_para_listado;

  v_cantidad_traslados_pagina := jsonb_array_length(v_traslados_activo_pagina);
  IF v_existen_mas_traslados AND v_cantidad_traslados_pagina > 0 THEN
    v_cursor_siguiente := jsonb_build_object(
      'creado_en', v_traslados_activo_pagina -> (v_cantidad_traslados_pagina - 1) -> 'creado_en',
      'id', v_traslados_activo_pagina -> (v_cantidad_traslados_pagina - 1) -> 'id'
    );
  ELSE
    v_cursor_siguiente := NULL;
  END IF;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'TRASLADOS_ACTIVO_LISTADOS',
    'mensaje', 'Listado de traslados del activo obtenido',
    'datos', jsonb_build_object(
      'items', v_traslados_activo_pagina,
      'paginacion', jsonb_build_object('limite', v_limite_pagina, 'hay_mas', v_existen_mas_traslados, 'cursor_siguiente', v_cursor_siguiente, 'total', v_total)
    )
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'TRASLADOS_ACTIVO_LISTADO_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al listar los traslados');
END;
$$;


CREATE OR REPLACE FUNCTION fn_listar_recuperaciones_inversion(
  p_id_empresa UUID,
  p_id_activo UUID DEFAULT NULL,
  p_id_contrato UUID DEFAULT NULL,
  p_id_periodo UUID DEFAULT NULL,
  p_limite INT DEFAULT NULL,
  p_cursor_creado_en TIMESTAMPTZ DEFAULT NULL,
  p_cursor_id UUID DEFAULT NULL
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_limite_pagina INT;
  v_recuperaciones_inversion_pagina JSONB;
  v_existen_mas_recuperaciones BOOL;
  v_cantidad_recuperaciones_pagina INT;
  v_cursor_siguiente JSONB;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  v_limite_pagina := LEAST(GREATEST(COALESCE(p_limite, 20), 1), 100);

  WITH recuperaciones_inversion_ordenadas_para_listado AS (
    SELECT r.id, r.id_activo, a.codigo AS activo_codigo, a.descripcion AS activo_descripcion,
           r.id_contrato, r.id_periodo, r.importe_recuperado,
           r.saldo_antes, r.saldo_despues, r.parado, r.creado_en,
           row_number() OVER (ORDER BY r.creado_en DESC, r.id DESC) AS orden_en_pagina
    FROM recuperacion_inversion_mensual r
    LEFT JOIN activo a ON a.id = r.id_activo
    WHERE r.id_empresa = p_id_empresa
      AND (p_id_activo IS NULL OR r.id_activo = p_id_activo)
      AND (p_id_contrato IS NULL OR r.id_contrato = p_id_contrato)
      AND (p_id_periodo IS NULL OR r.id_periodo = p_id_periodo)
      AND (p_cursor_creado_en IS NULL OR (r.creado_en, r.id) < (p_cursor_creado_en, p_cursor_id))
    ORDER BY r.creado_en DESC, r.id DESC
    LIMIT v_limite_pagina + 1
  )
  SELECT
    COALESCE(
      jsonb_agg(to_jsonb(recuperaciones_inversion_ordenadas_para_listado) - 'orden_en_pagina' ORDER BY recuperaciones_inversion_ordenadas_para_listado.orden_en_pagina)
      FILTER (WHERE recuperaciones_inversion_ordenadas_para_listado.orden_en_pagina <= v_limite_pagina),
      '[]'::jsonb
    ),
    count(*) > v_limite_pagina
  INTO v_recuperaciones_inversion_pagina, v_existen_mas_recuperaciones
  FROM recuperaciones_inversion_ordenadas_para_listado;

  v_cantidad_recuperaciones_pagina := jsonb_array_length(v_recuperaciones_inversion_pagina);
  IF v_existen_mas_recuperaciones AND v_cantidad_recuperaciones_pagina > 0 THEN
    v_cursor_siguiente := jsonb_build_object(
      'creado_en', v_recuperaciones_inversion_pagina -> (v_cantidad_recuperaciones_pagina - 1) -> 'creado_en',
      'id', v_recuperaciones_inversion_pagina -> (v_cantidad_recuperaciones_pagina - 1) -> 'id'
    );
  ELSE
    v_cursor_siguiente := NULL;
  END IF;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'RECUPERACIONES_LISTADAS',
    'mensaje', 'Listado de recuperaciones de inversion obtenido',
    'datos', jsonb_build_object(
      'items', v_recuperaciones_inversion_pagina,
      'paginacion', jsonb_build_object('limite', v_limite_pagina, 'hay_mas', v_existen_mas_recuperaciones, 'cursor_siguiente', v_cursor_siguiente)
    )
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'RECUPERACIONES_LISTADO_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al listar las recuperaciones');
END;
$$;

CREATE OR REPLACE FUNCTION fn_listar_cierres_mensuales(
  p_id_empresa UUID,
  p_id_contrato UUID DEFAULT NULL,
  p_id_periodo UUID DEFAULT NULL,
  p_estado STRING DEFAULT NULL,
  p_limite INT DEFAULT NULL,
  p_cursor_creado_en TIMESTAMPTZ DEFAULT NULL,
  p_cursor_id UUID DEFAULT NULL
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_limite_pagina INT;
  v_cierres_mensuales_pagina JSONB;
  v_existen_mas_cierres BOOL;
  v_cantidad_cierres_pagina INT;
  v_cursor_siguiente JSONB;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  v_limite_pagina := LEAST(GREATEST(COALESCE(p_limite, 20), 1), 100);

  WITH cierres_mensuales_ordenados_para_listado AS (
    SELECT c.id, c.id_contrato, c.id_periodo, c.total_facturado, c.total_gastos,
           c.utilidad_bruta, c.utilidad_neta, c.utilidad_final, c.estado, c.fecha_cierre, c.creado_en,
           row_number() OVER (ORDER BY c.creado_en DESC, c.id DESC) AS orden_en_pagina
    FROM cierre_mensual c
    WHERE c.id_empresa = p_id_empresa
      AND c.eliminado_en IS NULL
      AND (p_id_contrato IS NULL OR c.id_contrato = p_id_contrato)
      AND (p_id_periodo IS NULL OR c.id_periodo = p_id_periodo)
      AND (p_estado IS NULL OR c.estado = p_estado)
      AND (p_cursor_creado_en IS NULL OR (c.creado_en, c.id) < (p_cursor_creado_en, p_cursor_id))
    ORDER BY c.creado_en DESC, c.id DESC
    LIMIT v_limite_pagina + 1
  )
  SELECT
    COALESCE(
      jsonb_agg(to_jsonb(cierres_mensuales_ordenados_para_listado) - 'orden_en_pagina' ORDER BY cierres_mensuales_ordenados_para_listado.orden_en_pagina)
      FILTER (WHERE cierres_mensuales_ordenados_para_listado.orden_en_pagina <= v_limite_pagina),
      '[]'::jsonb
    ),
    count(*) > v_limite_pagina
  INTO v_cierres_mensuales_pagina, v_existen_mas_cierres
  FROM cierres_mensuales_ordenados_para_listado;

  v_cantidad_cierres_pagina := jsonb_array_length(v_cierres_mensuales_pagina);
  IF v_existen_mas_cierres AND v_cantidad_cierres_pagina > 0 THEN
    v_cursor_siguiente := jsonb_build_object(
      'creado_en', v_cierres_mensuales_pagina -> (v_cantidad_cierres_pagina - 1) -> 'creado_en',
      'id', v_cierres_mensuales_pagina -> (v_cantidad_cierres_pagina - 1) -> 'id'
    );
  ELSE
    v_cursor_siguiente := NULL;
  END IF;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'CIERRES_MENSUALES_LISTADOS',
    'mensaje', 'Listado de cierres mensuales obtenido',
    'datos', jsonb_build_object(
      'items', v_cierres_mensuales_pagina,
      'paginacion', jsonb_build_object('limite', v_limite_pagina, 'hay_mas', v_existen_mas_cierres, 'cursor_siguiente', v_cursor_siguiente)
    )
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'CIERRES_MENSUALES_LISTADO_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al listar los cierres');
END;
$$;
CREATE OR REPLACE FUNCTION fn_listar_penalidades(
  p_id_empresa UUID,
  p_id_contrato UUID DEFAULT NULL,
  p_id_periodo UUID DEFAULT NULL,
  p_limite INT DEFAULT NULL,
  p_cursor_creado_en TIMESTAMPTZ DEFAULT NULL,
  p_cursor_id UUID DEFAULT NULL
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_limite_pagina INT;
  v_penalidades_pagina JSONB;
  v_existen_mas_penalidades BOOL;
  v_cantidad_penalidades_pagina INT;
  v_cursor_siguiente JSONB;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  v_limite_pagina := LEAST(GREATEST(COALESCE(p_limite, 20), 1), 100);

  WITH penalidades_ordenadas_para_listado  AS (
    SELECT pe.id, pe.id_contrato, pe.id_periodo, pe.descripcion, pe.importe, pe.creado_en,
           row_number() OVER (ORDER BY pe.creado_en DESC, pe.id DESC) AS _rn
    FROM penalidad pe
    WHERE pe.id_empresa = p_id_empresa
      AND pe.eliminado_en IS NULL
      AND (p_id_contrato IS NULL OR pe.id_contrato = p_id_contrato)
      AND (p_id_periodo IS NULL OR pe.id_periodo = p_id_periodo)
      AND (p_cursor_creado_en IS NULL OR (pe.creado_en, pe.id) < (p_cursor_creado_en, p_cursor_id))
    ORDER BY pe.creado_en DESC, pe.id DESC
    LIMIT v_limite_pagina + 1
  )
  SELECT
    COALESCE(jsonb_agg(to_jsonb(penalidades_ordenadas_para_listado ) - '_rn' ORDER BY penalidades_ordenadas_para_listado ._rn) FILTER (WHERE penalidades_ordenadas_para_listado ._rn <= v_limite_pagina), '[]'::jsonb),
    count(*) > v_limite_pagina
  INTO v_penalidades_pagina, v_existen_mas_penalidades
  FROM penalidades_ordenadas_para_listado ;

  v_cantidad_penalidades_pagina := jsonb_array_length(v_penalidades_pagina);
  IF v_existen_mas_penalidades AND v_cantidad_penalidades_pagina > 0 THEN
    v_cursor_siguiente := jsonb_build_object('creado_en', v_penalidades_pagina -> (v_cantidad_penalidades_pagina - 1) -> 'creado_en', 'id', v_penalidades_pagina -> (v_cantidad_penalidades_pagina - 1) -> 'id');
  ELSE
    v_cursor_siguiente := NULL;
  END IF;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'PENALIDADES_LISTADAS',
    'mensaje', 'Listado de penalidades obtenido',
    'datos', jsonb_build_object(
      'items', v_penalidades_pagina,
      'paginacion', jsonb_build_object('limite', v_limite_pagina, 'hay_mas', v_existen_mas_penalidades, 'cursor_siguiente', v_cursor_siguiente)
    )
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'PENALIDADES_LISTADO_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al listar las penalidades');
END;
$$;

CREATE OR REPLACE FUNCTION fn_listar_provisiones(
  p_id_empresa UUID,
  p_id_contrato UUID DEFAULT NULL,
  p_id_periodo UUID DEFAULT NULL,
  p_limite INT DEFAULT NULL,
  p_cursor_creado_en TIMESTAMPTZ DEFAULT NULL,
  p_cursor_id UUID DEFAULT NULL
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_limite_pagina INT;
  v_provisiones_pagina JSONB;
  v_existen_mas_provisiones BOOL;
  v_cantidad_provisiones_pagina INT;
  v_cursor_siguiente JSONB;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  v_limite_pagina := LEAST(GREATEST(COALESCE(p_limite, 20), 1), 100);

  WITH provisiones_ordenadas_para_listado AS (
    SELECT pr.id, pr.id_contrato, pr.id_periodo, pr.descripcion, pr.importe, pr.aplicado, pr.creado_en,
           row_number() OVER (ORDER BY pr.creado_en DESC, pr.id DESC) AS orden_en_pagina
    FROM provision pr
    WHERE pr.id_empresa = p_id_empresa
      AND pr.eliminado_en IS NULL
      AND (p_id_contrato IS NULL OR pr.id_contrato = p_id_contrato)
      AND (p_id_periodo IS NULL OR pr.id_periodo = p_id_periodo)
      AND (p_cursor_creado_en IS NULL OR (pr.creado_en, pr.id) < (p_cursor_creado_en, p_cursor_id))
    ORDER BY pr.creado_en DESC, pr.id DESC
    LIMIT v_limite_pagina + 1
  )
  SELECT
    COALESCE(
      jsonb_agg(to_jsonb(provisiones_ordenadas_para_listado) - 'orden_en_pagina' ORDER BY provisiones_ordenadas_para_listado.orden_en_pagina)
      FILTER (WHERE provisiones_ordenadas_para_listado.orden_en_pagina <= v_limite_pagina),
      '[]'::jsonb
    ),
    count(*) > v_limite_pagina
  INTO v_provisiones_pagina, v_existen_mas_provisiones
  FROM provisiones_ordenadas_para_listado;

  v_cantidad_provisiones_pagina := jsonb_array_length(v_provisiones_pagina);
  IF v_existen_mas_provisiones AND v_cantidad_provisiones_pagina > 0 THEN
    v_cursor_siguiente := jsonb_build_object('creado_en', v_provisiones_pagina -> (v_cantidad_provisiones_pagina - 1) -> 'creado_en', 'id', v_provisiones_pagina -> (v_cantidad_provisiones_pagina - 1) -> 'id');
  ELSE
    v_cursor_siguiente := NULL;
  END IF;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'PROVISIONES_LISTADAS',
    'mensaje', 'Listado de provisiones obtenido',
    'datos', jsonb_build_object(
      'items', v_provisiones_pagina,
      'paginacion', jsonb_build_object('limite', v_limite_pagina, 'hay_mas', v_existen_mas_provisiones, 'cursor_siguiente', v_cursor_siguiente)
    )
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'PROVISIONES_LISTADO_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al listar las provisiones');
END;
$$;
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



-- >>> fn_listar_clasificaciones_activo.sql (Grupo 5 - catalogo)
CREATE OR REPLACE FUNCTION fn_listar_clasificaciones_activo(
  p_id_empresa UUID,
  p_estado STRING DEFAULT NULL,
  p_texto_busqueda STRING DEFAULT NULL,
  p_limite_pagina INT DEFAULT NULL,
  p_cursor_creado_en TIMESTAMPTZ DEFAULT NULL,
  p_cursor_id UUID DEFAULT NULL
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_limite_pagina INT;
  v_clasificaciones_pagina JSONB;
  v_existen_mas_clasificaciones BOOL;
  v_cantidad_clasificaciones_pagina INT;
  v_cursor_siguiente JSONB;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  v_limite_pagina := LEAST(GREATEST(COALESCE(p_limite_pagina, 20), 1), 100);

  WITH clasificaciones_ordenadas_para_listado AS (
    SELECT c.id, c.codigo, c.descripcion, c.es_capitalizable, c.estado, c.creado_en,
           row_number() OVER (ORDER BY c.creado_en DESC, c.id DESC) AS orden_en_pagina
    FROM clasificacion_activo c
    WHERE c.id_empresa = p_id_empresa
      AND c.eliminado_en IS NULL
      AND (p_estado IS NULL OR c.estado = p_estado)
      AND (p_texto_busqueda IS NULL OR c.codigo ILIKE '%' || p_texto_busqueda || '%' OR c.descripcion ILIKE '%' || p_texto_busqueda || '%')
      AND (p_cursor_creado_en IS NULL OR (c.creado_en, c.id) < (p_cursor_creado_en, p_cursor_id))
    ORDER BY c.creado_en DESC, c.id DESC
    LIMIT v_limite_pagina + 1
  )
  SELECT
    COALESCE(
      jsonb_agg(to_jsonb(clasificaciones_ordenadas_para_listado) - 'orden_en_pagina' ORDER BY clasificaciones_ordenadas_para_listado.orden_en_pagina)
      FILTER (WHERE clasificaciones_ordenadas_para_listado.orden_en_pagina <= v_limite_pagina),
      '[]'::jsonb
    ),
    count(*) > v_limite_pagina
  INTO v_clasificaciones_pagina, v_existen_mas_clasificaciones
  FROM clasificaciones_ordenadas_para_listado;

  v_cantidad_clasificaciones_pagina := jsonb_array_length(v_clasificaciones_pagina);
  IF v_existen_mas_clasificaciones AND v_cantidad_clasificaciones_pagina > 0 THEN
    v_cursor_siguiente := jsonb_build_object(
      'creado_en', v_clasificaciones_pagina -> (v_cantidad_clasificaciones_pagina - 1) -> 'creado_en',
      'id', v_clasificaciones_pagina -> (v_cantidad_clasificaciones_pagina - 1) -> 'id'
    );
  ELSE
    v_cursor_siguiente := NULL;
  END IF;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'CLASIFICACIONES_ACTIVO_LISTADAS',
    'mensaje', 'Listado de clasificaciones de activo obtenido',
    'datos', jsonb_build_object(
      'items', v_clasificaciones_pagina,
      'paginacion', jsonb_build_object('limite', v_limite_pagina, 'hay_mas', v_existen_mas_clasificaciones, 'cursor_siguiente', v_cursor_siguiente)
    )
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'CLASIFICACIONES_ACTIVO_LISTADO_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al listar las clasificaciones de activo');
END;
$$;


-- >>> fn_listar_tipos_adquisicion_activo.sql (Grupo 5 - catalogo)
CREATE OR REPLACE FUNCTION fn_listar_tipos_adquisicion_activo(
  p_id_empresa UUID,
  p_estado STRING DEFAULT NULL,
  p_texto_busqueda STRING DEFAULT NULL,
  p_limite_pagina INT DEFAULT NULL,
  p_cursor_creado_en TIMESTAMPTZ DEFAULT NULL,
  p_cursor_id UUID DEFAULT NULL
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_limite_pagina INT;
  v_tipos_pagina JSONB;
  v_existen_mas_tipos BOOL;
  v_cantidad_tipos_pagina INT;
  v_cursor_siguiente JSONB;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  v_limite_pagina := LEAST(GREATEST(COALESCE(p_limite_pagina, 20), 1), 100);

  WITH tipos_ordenados_para_listado AS (
    SELECT t.id, t.codigo, t.descripcion, t.estado, t.creado_en,
           row_number() OVER (ORDER BY t.creado_en DESC, t.id DESC) AS orden_en_pagina
    FROM tipo_adquisicion_activo t
    WHERE t.id_empresa = p_id_empresa
      AND t.eliminado_en IS NULL
      AND (p_estado IS NULL OR t.estado = p_estado)
      AND (p_texto_busqueda IS NULL OR t.codigo ILIKE '%' || p_texto_busqueda || '%' OR t.descripcion ILIKE '%' || p_texto_busqueda || '%')
      AND (p_cursor_creado_en IS NULL OR (t.creado_en, t.id) < (p_cursor_creado_en, p_cursor_id))
    ORDER BY t.creado_en DESC, t.id DESC
    LIMIT v_limite_pagina + 1
  )
  SELECT
    COALESCE(
      jsonb_agg(to_jsonb(tipos_ordenados_para_listado) - 'orden_en_pagina' ORDER BY tipos_ordenados_para_listado.orden_en_pagina)
      FILTER (WHERE tipos_ordenados_para_listado.orden_en_pagina <= v_limite_pagina),
      '[]'::jsonb
    ),
    count(*) > v_limite_pagina
  INTO v_tipos_pagina, v_existen_mas_tipos
  FROM tipos_ordenados_para_listado;

  v_cantidad_tipos_pagina := jsonb_array_length(v_tipos_pagina);
  IF v_existen_mas_tipos AND v_cantidad_tipos_pagina > 0 THEN
    v_cursor_siguiente := jsonb_build_object(
      'creado_en', v_tipos_pagina -> (v_cantidad_tipos_pagina - 1) -> 'creado_en',
      'id', v_tipos_pagina -> (v_cantidad_tipos_pagina - 1) -> 'id'
    );
  ELSE
    v_cursor_siguiente := NULL;
  END IF;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'TIPOS_ADQUISICION_ACTIVO_LISTADOS',
    'mensaje', 'Listado de tipos de adquisicion de activo obtenido',
    'datos', jsonb_build_object(
      'items', v_tipos_pagina,
      'paginacion', jsonb_build_object('limite', v_limite_pagina, 'hay_mas', v_existen_mas_tipos, 'cursor_siguiente', v_cursor_siguiente)
    )
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'TIPOS_ADQUISICION_ACTIVO_LISTADO_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al listar los tipos de adquisicion de activo');
END;
$$;


-- >>> fn_listar_tipos_herramienta.sql (Grupo 5 - catalogo)
CREATE OR REPLACE FUNCTION fn_listar_tipos_herramienta(
  p_id_empresa UUID,
  p_estado STRING DEFAULT NULL,
  p_texto_busqueda STRING DEFAULT NULL,
  p_limite_pagina INT DEFAULT NULL,
  p_cursor_creado_en TIMESTAMPTZ DEFAULT NULL,
  p_cursor_id UUID DEFAULT NULL
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_limite_pagina INT;
  v_tipos_pagina JSONB;
  v_existen_mas_tipos BOOL;
  v_cantidad_tipos_pagina INT;
  v_cursor_siguiente JSONB;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  v_limite_pagina := LEAST(GREATEST(COALESCE(p_limite_pagina, 20), 1), 100);

  WITH tipos_ordenados_para_listado AS (
    SELECT t.id, t.codigo, t.descripcion, t.estado, t.creado_en,
           row_number() OVER (ORDER BY t.creado_en DESC, t.id DESC) AS orden_en_pagina
    FROM tipo_herramienta t
    WHERE t.id_empresa = p_id_empresa
      AND t.eliminado_en IS NULL
      AND (p_estado IS NULL OR t.estado = p_estado)
      AND (p_texto_busqueda IS NULL OR t.codigo ILIKE '%' || p_texto_busqueda || '%' OR t.descripcion ILIKE '%' || p_texto_busqueda || '%')
      AND (p_cursor_creado_en IS NULL OR (t.creado_en, t.id) < (p_cursor_creado_en, p_cursor_id))
    ORDER BY t.creado_en DESC, t.id DESC
    LIMIT v_limite_pagina + 1
  )
  SELECT
    COALESCE(
      jsonb_agg(to_jsonb(tipos_ordenados_para_listado) - 'orden_en_pagina' ORDER BY tipos_ordenados_para_listado.orden_en_pagina)
      FILTER (WHERE tipos_ordenados_para_listado.orden_en_pagina <= v_limite_pagina),
      '[]'::jsonb
    ),
    count(*) > v_limite_pagina
  INTO v_tipos_pagina, v_existen_mas_tipos
  FROM tipos_ordenados_para_listado;

  v_cantidad_tipos_pagina := jsonb_array_length(v_tipos_pagina);
  IF v_existen_mas_tipos AND v_cantidad_tipos_pagina > 0 THEN
    v_cursor_siguiente := jsonb_build_object(
      'creado_en', v_tipos_pagina -> (v_cantidad_tipos_pagina - 1) -> 'creado_en',
      'id', v_tipos_pagina -> (v_cantidad_tipos_pagina - 1) -> 'id'
    );
  ELSE
    v_cursor_siguiente := NULL;
  END IF;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'TIPOS_HERRAMIENTA_LISTADOS',
    'mensaje', 'Listado de tipos de herramienta obtenido',
    'datos', jsonb_build_object(
      'items', v_tipos_pagina,
      'paginacion', jsonb_build_object('limite', v_limite_pagina, 'hay_mas', v_existen_mas_tipos, 'cursor_siguiente', v_cursor_siguiente)
    )
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'TIPOS_HERRAMIENTA_LISTADO_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al listar los tipos de herramienta');
END;
$$;

-- ---- INDICES ESTRELLA DE CATALOGO (listado) ----
CREATE INDEX idx_star_clasificacion_activo_listado ON clasificacion_activo (id_empresa, creado_en DESC, id DESC) STORING (codigo, descripcion, es_capitalizable, estado) WHERE eliminado_en IS NULL;
CREATE INDEX idx_star_tipo_adquisicion_activo_listado ON tipo_adquisicion_activo (id_empresa, creado_en DESC, id DESC) STORING (codigo, descripcion, estado) WHERE eliminado_en IS NULL;
CREATE INDEX idx_star_tipo_herramienta_listado ON tipo_herramienta (id_empresa, creado_en DESC, id DESC) STORING (codigo, descripcion, estado) WHERE eliminado_en IS NULL;

-- ---- PROCEDIMIENTOS NUEVOS (registro de catalogos + baja de activo) ----

CREATE OR REPLACE FUNCTION fn_registrar_clasificacion_activo(
  p_id_empresa UUID,
  p_id_usuario_accion UUID,
  p_codigo STRING,
  p_descripcion STRING,
  p_es_capitalizable BOOL DEFAULT true
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_id_clasificacion UUID;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  IF p_codigo IS NULL OR char_length(trim(p_codigo)) = 0 THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'CODIGO_OBLIGATORIO', 'mensaje', 'El codigo de la clasificacion es obligatorio');
  END IF;

  IF p_descripcion IS NULL OR char_length(trim(p_descripcion)) = 0 THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'DESCRIPCION_OBLIGATORIA', 'mensaje', 'La descripcion de la clasificacion es obligatoria');
  END IF;

  IF EXISTS (
    SELECT 1 FROM clasificacion_activo
    WHERE id_empresa = p_id_empresa AND codigo = trim(p_codigo) AND eliminado_en IS NULL
  ) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'CLASIFICACION_ACTIVO_CODIGO_DUPLICADO', 'mensaje', 'Ya existe una clasificacion de activo con ese codigo en la empresa');
  END IF;

  INSERT INTO clasificacion_activo (
    id_empresa, codigo, descripcion, es_capitalizable, estado, creado_por_usuario_id
  ) VALUES (
    p_id_empresa, trim(p_codigo), trim(p_descripcion), COALESCE(p_es_capitalizable, true), 'ACTIVO', p_id_usuario_accion
  ) RETURNING id INTO v_id_clasificacion;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'CLASIFICACION_ACTIVO_REGISTRADA',
    'mensaje', 'La clasificacion de activo fue registrada correctamente',
    'datos', jsonb_build_object('id_clasificacion_activo', v_id_clasificacion)
  );
EXCEPTION
  WHEN unique_violation THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'CLASIFICACION_ACTIVO_CODIGO_DUPLICADO', 'mensaje', 'Ya existe una clasificacion de activo con ese codigo en la empresa');
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'CLASIFICACION_ACTIVO_REGISTRO_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al registrar la clasificacion de activo');
END;
$$;

CREATE OR REPLACE FUNCTION fn_registrar_tipo_adquisicion_activo(
  p_id_empresa UUID,
  p_id_usuario_accion UUID,
  p_codigo STRING,
  p_descripcion STRING
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_id_tipo UUID;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  IF p_codigo IS NULL OR char_length(trim(p_codigo)) = 0 THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'CODIGO_OBLIGATORIO', 'mensaje', 'El codigo del tipo de adquisicion es obligatorio');
  END IF;

  IF p_descripcion IS NULL OR char_length(trim(p_descripcion)) = 0 THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'DESCRIPCION_OBLIGATORIA', 'mensaje', 'La descripcion del tipo de adquisicion es obligatoria');
  END IF;

  IF EXISTS (
    SELECT 1 FROM tipo_adquisicion_activo
    WHERE id_empresa = p_id_empresa AND codigo = trim(p_codigo) AND eliminado_en IS NULL
  ) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'TIPO_ADQUISICION_ACTIVO_CODIGO_DUPLICADO', 'mensaje', 'Ya existe un tipo de adquisicion con ese codigo en la empresa');
  END IF;

  INSERT INTO tipo_adquisicion_activo (
    id_empresa, codigo, descripcion, estado, creado_por_usuario_id
  ) VALUES (
    p_id_empresa, trim(p_codigo), trim(p_descripcion), 'ACTIVO', p_id_usuario_accion
  ) RETURNING id INTO v_id_tipo;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'TIPO_ADQUISICION_ACTIVO_REGISTRADO',
    'mensaje', 'El tipo de adquisicion de activo fue registrado correctamente',
    'datos', jsonb_build_object('id_tipo_adquisicion_activo', v_id_tipo)
  );
EXCEPTION
  WHEN unique_violation THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'TIPO_ADQUISICION_ACTIVO_CODIGO_DUPLICADO', 'mensaje', 'Ya existe un tipo de adquisicion con ese codigo en la empresa');
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'TIPO_ADQUISICION_ACTIVO_REGISTRO_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al registrar el tipo de adquisicion de activo');
END;
$$;

CREATE OR REPLACE FUNCTION fn_registrar_tipo_herramienta(
  p_id_empresa UUID,
  p_id_usuario_accion UUID,
  p_codigo STRING,
  p_descripcion STRING
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_id_tipo UUID;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  IF p_codigo IS NULL OR char_length(trim(p_codigo)) = 0 THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'CODIGO_OBLIGATORIO', 'mensaje', 'El codigo del tipo de herramienta es obligatorio');
  END IF;

  IF p_descripcion IS NULL OR char_length(trim(p_descripcion)) = 0 THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'DESCRIPCION_OBLIGATORIA', 'mensaje', 'La descripcion del tipo de herramienta es obligatoria');
  END IF;

  IF EXISTS (
    SELECT 1 FROM tipo_herramienta
    WHERE id_empresa = p_id_empresa AND codigo = trim(p_codigo) AND eliminado_en IS NULL
  ) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'TIPO_HERRAMIENTA_CODIGO_DUPLICADO', 'mensaje', 'Ya existe un tipo de herramienta con ese codigo en la empresa');
  END IF;

  INSERT INTO tipo_herramienta (
    id_empresa, codigo, descripcion, estado, creado_por_usuario_id
  ) VALUES (
    p_id_empresa, trim(p_codigo), trim(p_descripcion), 'ACTIVO', p_id_usuario_accion
  ) RETURNING id INTO v_id_tipo;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'TIPO_HERRAMIENTA_REGISTRADO',
    'mensaje', 'El tipo de herramienta fue registrado correctamente',
    'datos', jsonb_build_object('id_tipo_herramienta', v_id_tipo)
  );
EXCEPTION
  WHEN unique_violation THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'TIPO_HERRAMIENTA_CODIGO_DUPLICADO', 'mensaje', 'Ya existe un tipo de herramienta con ese codigo en la empresa');
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'TIPO_HERRAMIENTA_REGISTRO_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al registrar el tipo de herramienta');
END;
$$;

CREATE OR REPLACE FUNCTION fn_dar_de_baja_activo(
  p_id_empresa UUID,
  p_id_usuario_accion UUID,
  p_id_activo UUID
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_estado STRING;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  SELECT estado INTO v_estado
  FROM activo
  WHERE id = p_id_activo AND id_empresa = p_id_empresa AND eliminado_en IS NULL;

  IF v_estado IS NULL THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'ACTIVO_NO_ENCONTRADO', 'mensaje', 'El activo no existe o no pertenece a la empresa');
  END IF;

  IF v_estado = 'BAJA' THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'ACTIVO_YA_DADO_DE_BAJA', 'mensaje', 'El activo ya se encuentra dado de baja');
  END IF;

  IF EXISTS (
    SELECT 1 FROM activo_asignacion_contrato
    WHERE id_activo = p_id_activo AND id_empresa = p_id_empresa AND estado = 'ACTIVO'
      AND eliminado_en IS NULL AND saldo_inversion_pendiente > 0
  ) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'ACTIVO_CON_INVERSION_PENDIENTE', 'mensaje', 'No se puede dar de baja el activo: tiene una asignacion activa con inversion pendiente de recuperar');
  END IF;

  UPDATE activo
  SET estado = 'BAJA', actualizado_en = now(), actualizado_por_usuario_id = p_id_usuario_accion
  WHERE id = p_id_activo AND id_empresa = p_id_empresa;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'ACTIVO_DADO_DE_BAJA',
    'mensaje', 'El activo fue dado de baja correctamente',
    'datos', jsonb_build_object('id_activo', p_id_activo, 'estado', 'BAJA')
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'ACTIVO_BAJA_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al dar de baja el activo');
END;
$$;


-- ---- PROCEDIMIENTOS NUEVOS (edicion de activo/herramienta, reactivacion de activo, finalizacion de asignacion) ----
CREATE OR REPLACE FUNCTION fn_actualizar_activo(
  p_id_empresa UUID,
  p_id_usuario_accion UUID,
  p_id_activo UUID,
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
  v_estado STRING;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  SELECT estado INTO v_estado
  FROM activo
  WHERE id = p_id_activo AND id_empresa = p_id_empresa AND eliminado_en IS NULL;

  IF v_estado IS NULL THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'ACTIVO_NO_ENCONTRADO', 'mensaje', 'El activo no existe o no pertenece a la empresa');
  END IF;

  IF v_estado = 'BAJA' THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'ACTIVO_DADO_DE_BAJA', 'mensaje', 'El activo esta dado de baja; reactivelo antes de editar sus datos');
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

  UPDATE activo SET
    id_clasificacion_activo = p_id_clasificacion_activo,
    id_tipo_adquisicion_activo = p_id_tipo_adquisicion_activo,
    codigo = NULLIF(trim(p_codigo), ''),
    descripcion = trim(p_descripcion),
    placa = NULLIF(trim(p_placa), ''),
    marca = NULLIF(trim(p_marca), ''),
    modelo = NULLIF(trim(p_modelo), ''),
    numero_serie = NULLIF(trim(p_numero_serie), ''),
    anio_fabricacion = p_anio_fabricacion,
    costo_adquisicion = p_costo_adquisicion,
    tiempo_vida_meses = p_tiempo_vida_meses,
    depreciacion_mensual = p_depreciacion_mensual,
    importe_base_recuperable = p_importe_base_recuperable,
    fecha_inicio_depreciacion = p_fecha_inicio_depreciacion,
    fecha_fin_depreciacion = p_fecha_fin_depreciacion,
    actualizado_en = now(),
    actualizado_por_usuario_id = p_id_usuario_accion
  WHERE id = p_id_activo AND id_empresa = p_id_empresa;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'ACTIVO_ACTUALIZADO',
    'mensaje', 'El activo fue actualizado correctamente',
    'datos', jsonb_build_object('id_activo', p_id_activo)
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'ACTIVO_ACTUALIZACION_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al actualizar el activo');
END;
$$;

CREATE OR REPLACE FUNCTION fn_reactivar_activo(
  p_id_empresa UUID,
  p_id_usuario_accion UUID,
  p_id_activo UUID
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_estado STRING;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  SELECT estado INTO v_estado
  FROM activo
  WHERE id = p_id_activo AND id_empresa = p_id_empresa AND eliminado_en IS NULL;

  IF v_estado IS NULL THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'ACTIVO_NO_ENCONTRADO', 'mensaje', 'El activo no existe o no pertenece a la empresa');
  END IF;

  IF v_estado <> 'BAJA' THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'ACTIVO_NO_ESTA_DADO_DE_BAJA', 'mensaje', 'El activo no esta dado de baja, no se puede reactivar');
  END IF;

  UPDATE activo
  SET estado = 'ACTIVO', actualizado_en = now(), actualizado_por_usuario_id = p_id_usuario_accion
  WHERE id = p_id_activo AND id_empresa = p_id_empresa;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'ACTIVO_REACTIVADO',
    'mensaje', 'El activo fue reactivado correctamente',
    'datos', jsonb_build_object('id_activo', p_id_activo, 'estado', 'ACTIVO')
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'ACTIVO_REACTIVACION_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al reactivar el activo');
END;
$$;

CREATE OR REPLACE FUNCTION fn_actualizar_herramienta(
  p_id_empresa UUID,
  p_id_usuario_accion UUID,
  p_id_herramienta UUID,
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
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM herramienta WHERE id = p_id_herramienta AND id_empresa = p_id_empresa AND eliminado_en IS NULL
  ) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'HERRAMIENTA_NO_ENCONTRADA', 'mensaje', 'La herramienta no existe o no pertenece a la empresa');
  END IF;

  IF EXISTS (
    SELECT 1 FROM herramienta WHERE id = p_id_herramienta AND id_empresa = p_id_empresa AND eliminado_en IS NULL AND estado = 'BAJA'
  ) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'HERRAMIENTA_DADA_DE_BAJA', 'mensaje', 'La herramienta esta dada de baja, no se puede editar');
  END IF;

  IF p_id_tipo_herramienta IS NOT NULL AND NOT EXISTS (
    SELECT 1 FROM tipo_herramienta
    WHERE id = p_id_tipo_herramienta AND id_empresa = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL
  ) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'TIPO_HERRAMIENTA_NO_VALIDO', 'mensaje', 'El tipo de herramienta no existe o no pertenece a la empresa');
  END IF;

  UPDATE herramienta SET
    id_tipo_herramienta = p_id_tipo_herramienta,
    codigo = NULLIF(trim(p_codigo), ''),
    descripcion = NULLIF(trim(p_descripcion), ''),
    marca = NULLIF(trim(p_marca), ''),
    modelo = NULLIF(trim(p_modelo), ''),
    numero_serie = NULLIF(trim(p_numero_serie), ''),
    costo_adquisicion = p_costo_adquisicion,
    tiempo_vida_meses = p_tiempo_vida_meses,
    fecha_inicio_depreciacion = p_fecha_inicio_depreciacion,
    fecha_fin_depreciacion = p_fecha_fin_depreciacion,
    actualizado_en = now(),
    actualizado_por_usuario_id = p_id_usuario_accion
  WHERE id = p_id_herramienta AND id_empresa = p_id_empresa;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'HERRAMIENTA_ACTUALIZADA',
    'mensaje', 'La herramienta fue actualizada correctamente',
    'datos', jsonb_build_object('id_herramienta', p_id_herramienta)
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'HERRAMIENTA_ACTUALIZACION_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al actualizar la herramienta');
END;
$$;

CREATE OR REPLACE FUNCTION fn_finalizar_asignacion_activo(
  p_id_empresa UUID,
  p_id_usuario_accion UUID,
  p_id_asignacion UUID,
  p_fecha_fin DATE
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_estado STRING;
  v_fecha_inicio DATE;
  v_fecha_fin DATE;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  SELECT estado, fecha_inicio INTO v_estado, v_fecha_inicio
  FROM activo_asignacion_contrato
  WHERE id = p_id_asignacion AND id_empresa = p_id_empresa AND eliminado_en IS NULL;

  IF v_estado IS NULL THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'ASIGNACION_NO_ENCONTRADA', 'mensaje', 'La asignacion no existe o no pertenece a la empresa');
  END IF;

  IF v_estado <> 'ACTIVO' THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'ASIGNACION_NO_ACTIVA', 'mensaje', 'La asignacion no esta activa, no se puede finalizar');
  END IF;

  v_fecha_fin := COALESCE(p_fecha_fin, current_date);

  IF v_fecha_fin < v_fecha_inicio THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'FECHA_FIN_INVALIDA', 'mensaje', 'La fecha de fin no puede ser anterior a la fecha de inicio de la asignacion');
  END IF;

  UPDATE activo_asignacion_contrato SET
    estado = 'CERRADO',
    fecha_fin = v_fecha_fin,
    actualizado_en = now(),
    actualizado_por_usuario_id = p_id_usuario_accion
  WHERE id = p_id_asignacion AND id_empresa = p_id_empresa;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'ASIGNACION_FINALIZADA',
    'mensaje', 'La asignacion del activo fue finalizada correctamente',
    'datos', jsonb_build_object('id_asignacion', p_id_asignacion, 'estado', 'CERRADO', 'fecha_fin', v_fecha_fin)
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'ASIGNACION_FINALIZACION_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al finalizar la asignacion');
END;
$$;


-- ====================================================================
-- Tablero Resumen de activos e inversion (procedimientos agregados 2026-06-26)
-- ====================================================================

DROP FUNCTION IF EXISTS fn_obtener_resumen_activos_inversion(UUID, UUID);

CREATE OR REPLACE FUNCTION fn_obtener_resumen_activos_inversion(
  p_id_empresa UUID,
  p_id_periodo UUID DEFAULT NULL,
  p_estado STRING DEFAULT NULL,
  p_id_clasificacion_activo UUID DEFAULT NULL
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_inversion_colocada DECIMAL(18,2);
  v_saldo_por_recuperar DECIMAL(18,2);
  v_recuperacion_periodo DECIMAL(18,2);
  v_totales JSONB;
  v_por_estado JSONB;
  v_por_clasificacion JSONB;
  v_recuperacion_por_periodo JSONB;
  v_alertas_vida_util JSONB;
  v_alertas_sin_recuperar JSONB;
  v_herramientas_totales JSONB;
  v_herramientas_por_estado JSONB;
  v_herramientas_por_tipo JSONB;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  SELECT COALESCE(SUM(aac.inversion_asignada), 0), COALESCE(SUM(aac.saldo_inversion_pendiente), 0)
  INTO v_inversion_colocada, v_saldo_por_recuperar
  FROM activo_asignacion_contrato aac
  JOIN activo a ON a.id = aac.id_activo
  WHERE aac.id_empresa = p_id_empresa
    AND aac.eliminado_en IS NULL
    AND a.eliminado_en IS NULL
    AND a.estado <> 'BAJA'
    AND (p_estado IS NULL OR a.estado = p_estado)
    AND (p_id_clasificacion_activo IS NULL OR a.id_clasificacion_activo = p_id_clasificacion_activo);

  SELECT COALESCE(SUM(rim.importe_recuperado), 0)
  INTO v_recuperacion_periodo
  FROM recuperacion_inversion_mensual rim
  JOIN activo a ON a.id = rim.id_activo
  WHERE rim.id_empresa = p_id_empresa
    AND a.eliminado_en IS NULL
    AND (p_id_periodo IS NULL OR rim.id_periodo = p_id_periodo)
    AND (p_estado IS NULL OR a.estado = p_estado)
    AND (p_id_clasificacion_activo IS NULL OR a.id_clasificacion_activo = p_id_clasificacion_activo);

  SELECT jsonb_build_object(
    'activos_registrados', count(*),
    'operativos', count(*) FILTER (WHERE a.estado = 'ACTIVO'),
    'parados', count(*) FILTER (WHERE a.estado = 'PARADO'),
    'en_traslado', count(*) FILTER (WHERE a.estado = 'EN_TRASLADO'),
    'dados_de_baja', count(*) FILTER (WHERE a.estado = 'BAJA'),
    'inversion_total', COALESCE(SUM(a.costo_adquisicion) FILTER (WHERE a.estado <> 'BAJA'), 0),
    'inversion_capitalizable', COALESCE(SUM(a.costo_adquisicion) FILTER (WHERE c.es_capitalizable AND a.estado <> 'BAJA'), 0),
    'inversion_no_capitalizable', COALESCE(SUM(a.costo_adquisicion) FILTER (WHERE c.es_capitalizable IS NOT TRUE AND a.estado <> 'BAJA'), 0),
    'inversion_colocada_contratos', v_inversion_colocada,
    'saldo_por_recuperar', v_saldo_por_recuperar,
    'recuperacion_periodo', v_recuperacion_periodo
  )
  INTO v_totales
  FROM activo a
  LEFT JOIN clasificacion_activo c ON c.id = a.id_clasificacion_activo
  WHERE a.id_empresa = p_id_empresa
    AND a.eliminado_en IS NULL
    AND (p_estado IS NULL OR a.estado = p_estado)
    AND (p_id_clasificacion_activo IS NULL OR a.id_clasificacion_activo = p_id_clasificacion_activo);

  SELECT COALESCE(jsonb_agg(jsonb_build_object('estado', t.estado, 'cantidad', t.cantidad) ORDER BY t.cantidad DESC), '[]'::jsonb)
  INTO v_por_estado
  FROM (
    SELECT a.estado AS estado, count(*) AS cantidad
    FROM activo a
    WHERE a.id_empresa = p_id_empresa
      AND a.eliminado_en IS NULL
      AND (p_estado IS NULL OR a.estado = p_estado)
      AND (p_id_clasificacion_activo IS NULL OR a.id_clasificacion_activo = p_id_clasificacion_activo)
    GROUP BY a.estado
  ) t;

  SELECT COALESCE(jsonb_agg(jsonb_build_object(
    'clasificacion', t.clasificacion,
    'es_capitalizable', t.es_capitalizable,
    'cantidad', t.cantidad,
    'inversion', t.inversion
  ) ORDER BY t.inversion DESC), '[]'::jsonb)
  INTO v_por_clasificacion
  FROM (
    SELECT COALESCE(c.descripcion, 'Sin clasificar') AS clasificacion,
           COALESCE(c.es_capitalizable, false) AS es_capitalizable,
           count(*) AS cantidad,
           COALESCE(SUM(a.costo_adquisicion) FILTER (WHERE a.estado <> 'BAJA'), 0) AS inversion
    FROM activo a
    LEFT JOIN clasificacion_activo c ON c.id = a.id_clasificacion_activo
    WHERE a.id_empresa = p_id_empresa
      AND a.eliminado_en IS NULL
      AND (p_estado IS NULL OR a.estado = p_estado)
      AND (p_id_clasificacion_activo IS NULL OR a.id_clasificacion_activo = p_id_clasificacion_activo)
    GROUP BY c.descripcion, c.es_capitalizable
  ) t;

  SELECT COALESCE(jsonb_agg(jsonb_build_object(
    'id_periodo', t.id_periodo,
    'periodo', t.etiqueta,
    'anio', t.anio,
    'mes', t.mes,
    'importe', t.importe
  ) ORDER BY t.anio, t.mes), '[]'::jsonb)
  INTO v_recuperacion_por_periodo
  FROM (
    SELECT p.id AS id_periodo,
           p.anio AS anio,
           p.mes AS mes,
           lpad(p.mes::STRING, 2, '0') || '/' || p.anio::STRING AS etiqueta,
           SUM(rim.importe_recuperado) AS importe
    FROM recuperacion_inversion_mensual rim
    JOIN periodo p ON p.id = rim.id_periodo
    JOIN activo a ON a.id = rim.id_activo
    WHERE rim.id_empresa = p_id_empresa
      AND a.eliminado_en IS NULL
      AND (p_estado IS NULL OR a.estado = p_estado)
      AND (p_id_clasificacion_activo IS NULL OR a.id_clasificacion_activo = p_id_clasificacion_activo)
    GROUP BY p.id, p.anio, p.mes
  ) t;

  SELECT COALESCE(jsonb_agg(jsonb_build_object(
    'codigo', t.codigo,
    'descripcion', t.descripcion,
    'fecha_fin_depreciacion', t.fecha_fin_depreciacion,
    'dias_restantes', t.dias_restantes
  ) ORDER BY t.dias_restantes), '[]'::jsonb)
  INTO v_alertas_vida_util
  FROM (
    SELECT a.codigo AS codigo,
           a.descripcion AS descripcion,
           a.fecha_fin_depreciacion AS fecha_fin_depreciacion,
           (a.fecha_fin_depreciacion - current_date) AS dias_restantes
    FROM activo a
    WHERE a.id_empresa = p_id_empresa
      AND a.eliminado_en IS NULL
      AND a.estado <> 'BAJA'
      AND a.fecha_fin_depreciacion IS NOT NULL
      AND a.fecha_fin_depreciacion <= current_date + INTERVAL '180 days'
      AND (p_estado IS NULL OR a.estado = p_estado)
      AND (p_id_clasificacion_activo IS NULL OR a.id_clasificacion_activo = p_id_clasificacion_activo)
    ORDER BY a.fecha_fin_depreciacion
    LIMIT 6
  ) t;

  SELECT COALESCE(jsonb_agg(jsonb_build_object(
    'codigo', t.codigo,
    'descripcion', t.descripcion,
    'saldo_pendiente', t.saldo_pendiente
  ) ORDER BY t.saldo_pendiente DESC), '[]'::jsonb)
  INTO v_alertas_sin_recuperar
  FROM (
    SELECT a.codigo AS codigo,
           a.descripcion AS descripcion,
           SUM(aac.saldo_inversion_pendiente) AS saldo_pendiente
    FROM activo_asignacion_contrato aac
    JOIN activo a ON a.id = aac.id_activo
    WHERE aac.id_empresa = p_id_empresa
      AND aac.eliminado_en IS NULL
      AND a.eliminado_en IS NULL
      AND aac.saldo_inversion_pendiente > 0
      AND (p_estado IS NULL OR a.estado = p_estado)
      AND (p_id_clasificacion_activo IS NULL OR a.id_clasificacion_activo = p_id_clasificacion_activo)
    GROUP BY a.codigo, a.descripcion
    ORDER BY SUM(aac.saldo_inversion_pendiente) DESC
    LIMIT 6
  ) t;

  SELECT jsonb_build_object(
    'registradas', count(*),
    'operativas', count(*) FILTER (WHERE h.estado = 'ACTIVO'),
    'paradas', count(*) FILTER (WHERE h.estado = 'PARADO'),
    'en_traslado', count(*) FILTER (WHERE h.estado = 'EN_TRASLADO'),
    'dadas_de_baja', count(*) FILTER (WHERE h.estado = 'BAJA'),
    'inversion_total', COALESCE(SUM(h.costo_adquisicion), 0),
    'inversion_vigente', COALESCE(SUM(h.costo_adquisicion) FILTER (WHERE h.estado <> 'BAJA'), 0)
  )
  INTO v_herramientas_totales
  FROM herramienta h
  WHERE h.id_empresa = p_id_empresa
    AND h.eliminado_en IS NULL;

  SELECT COALESCE(jsonb_agg(jsonb_build_object('estado', t.estado, 'cantidad', t.cantidad) ORDER BY t.cantidad DESC), '[]'::jsonb)
  INTO v_herramientas_por_estado
  FROM (
    SELECT h.estado AS estado, count(*) AS cantidad
    FROM herramienta h
    WHERE h.id_empresa = p_id_empresa
      AND h.eliminado_en IS NULL
    GROUP BY h.estado
  ) t;

  SELECT COALESCE(jsonb_agg(jsonb_build_object(
    'tipo', t.tipo,
    'cantidad', t.cantidad,
    'inversion', t.inversion
  ) ORDER BY t.cantidad DESC), '[]'::jsonb)
  INTO v_herramientas_por_tipo
  FROM (
    SELECT COALESCE(th.descripcion, 'Sin tipo') AS tipo,
           count(*) AS cantidad,
           COALESCE(SUM(h.costo_adquisicion) FILTER (WHERE h.estado <> 'BAJA'), 0) AS inversion
    FROM herramienta h
    LEFT JOIN tipo_herramienta th ON th.id = h.id_tipo_herramienta
    WHERE h.id_empresa = p_id_empresa
      AND h.eliminado_en IS NULL
    GROUP BY th.descripcion
  ) t;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'RESUMEN_ACTIVOS_INVERSION_OBTENIDO',
    'mensaje', 'Resumen de activos e inversion obtenido',
    'datos', jsonb_build_object(
      'totales', v_totales,
      'por_estado', v_por_estado,
      'por_clasificacion', v_por_clasificacion,
      'recuperacion_por_periodo', v_recuperacion_por_periodo,
      'alertas', jsonb_build_object(
        'vida_util_por_vencer', v_alertas_vida_util,
        'inversion_sin_recuperar', v_alertas_sin_recuperar
      ),
      'herramientas', jsonb_build_object(
        'totales', v_herramientas_totales,
        'por_estado', v_herramientas_por_estado,
        'por_tipo', v_herramientas_por_tipo
      )
    )
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'RESUMEN_ACTIVOS_INVERSION_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al obtener el resumen de activos e inversion');
END;
$$;

CREATE OR REPLACE FUNCTION fn_listar_alertas_activos(
  p_id_empresa UUID,
  p_tipo STRING,
  p_busqueda STRING DEFAULT NULL,
  p_limite INT DEFAULT NULL,
  p_desplazamiento INT DEFAULT NULL
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_limite INT;
  v_desplazamiento INT;
  v_items JSONB;
  v_total INT;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  IF p_tipo NOT IN ('VIDA_UTIL', 'SIN_RECUPERAR') THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'TIPO_ALERTA_NO_VALIDO', 'mensaje', 'El tipo de alerta no es valido');
  END IF;

  v_limite := LEAST(GREATEST(COALESCE(p_limite, 20), 1), 100);
  v_desplazamiento := GREATEST(COALESCE(p_desplazamiento, 0), 0);

  IF p_tipo = 'VIDA_UTIL' THEN
    SELECT count(*) INTO v_total
    FROM activo a
    WHERE a.id_empresa = p_id_empresa
      AND a.eliminado_en IS NULL
      AND a.estado <> 'BAJA'
      AND a.fecha_fin_depreciacion IS NOT NULL
      AND a.fecha_fin_depreciacion <= current_date + INTERVAL '180 days'
      AND (p_busqueda IS NULL OR a.codigo ILIKE '%' || p_busqueda || '%' OR a.descripcion ILIKE '%' || p_busqueda || '%');

    SELECT COALESCE(jsonb_agg(sub.fila ORDER BY sub.fila_fecha, sub.fila_id), '[]'::jsonb)
    INTO v_items
    FROM (
      SELECT jsonb_build_object(
               'id', a.id,
               'codigo', a.codigo,
               'descripcion', a.descripcion,
               'estado', a.estado,
               'clasificacion', COALESCE(c.descripcion, 'Sin clasificar'),
               'fecha_fin_depreciacion', a.fecha_fin_depreciacion,
               'dias_restantes', (a.fecha_fin_depreciacion - current_date)
             ) AS fila,
             a.fecha_fin_depreciacion AS fila_fecha,
             a.id AS fila_id
      FROM activo a
      LEFT JOIN clasificacion_activo c ON c.id = a.id_clasificacion_activo
      WHERE a.id_empresa = p_id_empresa
        AND a.eliminado_en IS NULL
        AND a.estado <> 'BAJA'
        AND a.fecha_fin_depreciacion IS NOT NULL
        AND a.fecha_fin_depreciacion <= current_date + INTERVAL '180 days'
        AND (p_busqueda IS NULL OR a.codigo ILIKE '%' || p_busqueda || '%' OR a.descripcion ILIKE '%' || p_busqueda || '%')
      ORDER BY a.fecha_fin_depreciacion, a.id
      LIMIT v_limite OFFSET v_desplazamiento
    ) sub;
  ELSE
    SELECT count(*) INTO v_total
    FROM (
      SELECT a.id
      FROM activo_asignacion_contrato aac
      JOIN activo a ON a.id = aac.id_activo
      WHERE aac.id_empresa = p_id_empresa
        AND aac.eliminado_en IS NULL
        AND a.eliminado_en IS NULL
        AND aac.saldo_inversion_pendiente > 0
        AND (p_busqueda IS NULL OR a.codigo ILIKE '%' || p_busqueda || '%' OR a.descripcion ILIKE '%' || p_busqueda || '%')
      GROUP BY a.id
    ) conteo;

    SELECT COALESCE(jsonb_agg(sub.fila ORDER BY sub.fila_saldo DESC, sub.fila_id), '[]'::jsonb)
    INTO v_items
    FROM (
      SELECT jsonb_build_object(
               'id', a.id,
               'codigo', a.codigo,
               'descripcion', a.descripcion,
               'estado', a.estado,
               'inversion_asignada', SUM(aac.inversion_asignada),
               'saldo_pendiente', SUM(aac.saldo_inversion_pendiente)
             ) AS fila,
             SUM(aac.saldo_inversion_pendiente) AS fila_saldo,
             a.id AS fila_id
      FROM activo_asignacion_contrato aac
      JOIN activo a ON a.id = aac.id_activo
      WHERE aac.id_empresa = p_id_empresa
        AND aac.eliminado_en IS NULL
        AND a.eliminado_en IS NULL
        AND aac.saldo_inversion_pendiente > 0
        AND (p_busqueda IS NULL OR a.codigo ILIKE '%' || p_busqueda || '%' OR a.descripcion ILIKE '%' || p_busqueda || '%')
      GROUP BY a.id, a.codigo, a.descripcion, a.estado
      ORDER BY SUM(aac.saldo_inversion_pendiente) DESC, a.id
      LIMIT v_limite OFFSET v_desplazamiento
    ) sub;
  END IF;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'ALERTAS_ACTIVOS_LISTADAS',
    'mensaje', 'Listado de alertas de activos obtenido',
    'datos', jsonb_build_object(
      'items', v_items,
      'paginacion', jsonb_build_object(
        'total', v_total,
        'limite', v_limite,
        'desplazamiento', v_desplazamiento,
        'hay_mas', (v_desplazamiento + v_limite) < v_total
      )
    )
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'ALERTAS_ACTIVOS_LISTADO_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al listar las alertas de activos');
END;
$$;

CREATE OR REPLACE FUNCTION fn_listar_periodos_disponibles(
  p_id_empresa UUID
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_items JSONB;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  SELECT COALESCE(jsonb_agg(jsonb_build_object(
    'id', t.id,
    'anio', t.anio,
    'mes', t.mes,
    'etiqueta', lpad(t.mes::STRING, 2, '0') || '/' || t.anio::STRING
  ) ORDER BY t.anio DESC, t.mes DESC), '[]'::jsonb)
  INTO v_items
  FROM (
    SELECT p.id AS id, p.anio AS anio, p.mes AS mes
    FROM periodo p
    WHERE p.id_empresa = p_id_empresa
      AND p.eliminado_en IS NULL
  ) t;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'PERIODOS_DISPONIBLES_LISTADOS',
    'mensaje', 'Periodos disponibles obtenidos',
    'datos', jsonb_build_object('items', v_items)
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'PERIODOS_DISPONIBLES_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al listar los periodos disponibles');
END;
$$;

CREATE OR REPLACE FUNCTION fn_listar_activos_detalle(
  p_id_empresa UUID,
  p_estado STRING DEFAULT NULL,
  p_id_clasificacion_activo UUID DEFAULT NULL,
  p_busqueda STRING DEFAULT NULL,
  p_limite INT DEFAULT NULL,
  p_cursor_creado_en TIMESTAMPTZ DEFAULT NULL,
  p_cursor_id UUID DEFAULT NULL
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_limite_pagina INT;
  v_filas_pagina JSONB;
  v_existen_mas BOOL;
  v_cantidad_pagina INT;
  v_cursor_siguiente JSONB;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  v_limite_pagina := LEAST(GREATEST(COALESCE(p_limite, 200), 1), 500);

  WITH detalle_ordenado AS (
    SELECT a.codigo,
           a.descripcion,
           a.estado,
           COALESCE(c.descripcion, 'Sin clasificar') AS clasificacion,
           CASE WHEN COALESCE(c.es_capitalizable, false) THEN 'Si' ELSE 'No' END AS capitalizable,
           COALESCE(ta.descripcion, '') AS tipo_adquisicion,
           a.marca,
           a.modelo,
           a.placa,
           a.numero_serie,
           a.anio_fabricacion,
           a.costo_adquisicion,
           a.tiempo_vida_meses,
           a.depreciacion_mensual,
           a.importe_base_recuperable,
           a.fecha_inicio_depreciacion,
           a.fecha_fin_depreciacion,
           a.creado_en,
           a.id,
           row_number() OVER (ORDER BY a.creado_en DESC, a.id DESC) AS orden_en_pagina
    FROM activo a
    LEFT JOIN clasificacion_activo c ON c.id = a.id_clasificacion_activo
    LEFT JOIN tipo_adquisicion_activo ta ON ta.id = a.id_tipo_adquisicion_activo
    WHERE a.id_empresa = p_id_empresa
      AND a.eliminado_en IS NULL
      AND (p_estado IS NULL OR a.estado = p_estado)
      AND (p_id_clasificacion_activo IS NULL OR a.id_clasificacion_activo = p_id_clasificacion_activo)
      AND (p_busqueda IS NULL OR a.codigo ILIKE '%' || p_busqueda || '%' OR a.descripcion ILIKE '%' || p_busqueda || '%' OR a.placa ILIKE '%' || p_busqueda || '%')
      AND (p_cursor_creado_en IS NULL OR (a.creado_en, a.id) < (p_cursor_creado_en, p_cursor_id))
    ORDER BY a.creado_en DESC, a.id DESC
    LIMIT v_limite_pagina + 1
  )
  SELECT
    COALESCE(
      jsonb_agg(to_jsonb(detalle_ordenado) - 'orden_en_pagina' ORDER BY detalle_ordenado.orden_en_pagina)
      FILTER (WHERE detalle_ordenado.orden_en_pagina <= v_limite_pagina),
      '[]'::jsonb
    ),
    count(*) > v_limite_pagina
  INTO v_filas_pagina, v_existen_mas
  FROM detalle_ordenado;

  v_cantidad_pagina := jsonb_array_length(v_filas_pagina);
  IF v_existen_mas AND v_cantidad_pagina > 0 THEN
    v_cursor_siguiente := jsonb_build_object(
      'creado_en', v_filas_pagina -> (v_cantidad_pagina - 1) -> 'creado_en',
      'id', v_filas_pagina -> (v_cantidad_pagina - 1) -> 'id'
    );
  ELSE
    v_cursor_siguiente := NULL;
  END IF;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'ACTIVOS_DETALLE_LISTADO',
    'mensaje', 'Detalle de activos obtenido',
    'datos', jsonb_build_object(
      'items', v_filas_pagina,
      'paginacion', jsonb_build_object(
        'limite', v_limite_pagina,
        'hay_mas', v_existen_mas,
        'cursor_siguiente', v_cursor_siguiente
      )
    )
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'ACTIVOS_DETALLE_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al obtener el detalle de activos');
END;
$$;
-- ====================================================================
-- MODULOS NUEVOS (2026-07-01): mantenimiento, incidencias, intervenciones,
-- ajustes de recuperacion, parametros + variantes de catalogo.
-- 5 tablas + indices + 41 procedimientos. Mismo molde del grupo.
-- ====================================================================

-- ---- TABLAS NUEVAS (5) ----
-- >>> entidad_parametro_activos_inversion.sql
CREATE TABLE parametro_activos_inversion (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_empresa UUID NOT NULL,
  categoria STRING NOT NULL,
  clave STRING NOT NULL,
  valor STRING NOT NULL,
  descripcion STRING,
  estado STRING NOT NULL DEFAULT 'ACTIVO',
  creado_en TIMESTAMPTZ NOT NULL DEFAULT now(),
  creado_por_usuario_id UUID,
  actualizado_en TIMESTAMPTZ NOT NULL DEFAULT now(),
  actualizado_por_usuario_id UUID,
  eliminado_en TIMESTAMPTZ,
  eliminado_por_usuario_id UUID,
  CONSTRAINT ck_parametro_activos_inversion_categoria CHECK (categoria IN ('PARAMETRO_ACTIVO', 'REGLA_RECUPERACION', 'REGLA_MAESTRA', 'BASE_RECUPERACION', 'DISTRIBUCION')),
  CONSTRAINT ck_parametro_activos_inversion_estado CHECK (estado IN ('ACTIVO', 'INACTIVO'))
);

ALTER TABLE parametro_activos_inversion ADD CONSTRAINT fk_parametro_activos_inversion_empresa FOREIGN KEY (id_empresa) REFERENCES empresa (id) ON DELETE RESTRICT;
ALTER TABLE parametro_activos_inversion ADD CONSTRAINT fk_parametro_activos_inversion_creado_por FOREIGN KEY (creado_por_usuario_id) REFERENCES usuario (id) ON DELETE RESTRICT;
ALTER TABLE parametro_activos_inversion ADD CONSTRAINT fk_parametro_activos_inversion_actualizado_por FOREIGN KEY (actualizado_por_usuario_id) REFERENCES usuario (id) ON DELETE RESTRICT;
ALTER TABLE parametro_activos_inversion ADD CONSTRAINT fk_parametro_activos_inversion_eliminado_por FOREIGN KEY (eliminado_por_usuario_id) REFERENCES usuario (id) ON DELETE RESTRICT;

-- >>> entidad_recuperacion_ajuste.sql
CREATE TABLE recuperacion_ajuste (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_empresa UUID NOT NULL,
  id_activo UUID NOT NULL,
  id_contrato UUID,
  id_periodo UUID,
  fecha DATE NOT NULL,
  monto_ajuste DECIMAL(18,2) NOT NULL,
  motivo STRING NOT NULL,
  estado STRING NOT NULL DEFAULT 'PENDIENTE',
  fecha_resolucion DATE,
  creado_en TIMESTAMPTZ NOT NULL DEFAULT now(),
  creado_por_usuario_id UUID,
  actualizado_en TIMESTAMPTZ NOT NULL DEFAULT now(),
  actualizado_por_usuario_id UUID,
  eliminado_en TIMESTAMPTZ,
  eliminado_por_usuario_id UUID,
  CONSTRAINT ck_recuperacion_ajuste_estado CHECK (estado IN ('PENDIENTE', 'APROBADO', 'RECHAZADO'))
);

ALTER TABLE recuperacion_ajuste ADD CONSTRAINT fk_recuperacion_ajuste_empresa FOREIGN KEY (id_empresa) REFERENCES empresa (id) ON DELETE RESTRICT;
ALTER TABLE recuperacion_ajuste ADD CONSTRAINT fk_recuperacion_ajuste_activo FOREIGN KEY (id_activo) REFERENCES activo (id) ON DELETE RESTRICT;
ALTER TABLE recuperacion_ajuste ADD CONSTRAINT fk_recuperacion_ajuste_contrato FOREIGN KEY (id_contrato) REFERENCES contrato (id) ON DELETE RESTRICT;
ALTER TABLE recuperacion_ajuste ADD CONSTRAINT fk_recuperacion_ajuste_periodo FOREIGN KEY (id_periodo) REFERENCES periodo (id) ON DELETE RESTRICT;
ALTER TABLE recuperacion_ajuste ADD CONSTRAINT fk_recuperacion_ajuste_creado_por FOREIGN KEY (creado_por_usuario_id) REFERENCES usuario (id) ON DELETE RESTRICT;
ALTER TABLE recuperacion_ajuste ADD CONSTRAINT fk_recuperacion_ajuste_actualizado_por FOREIGN KEY (actualizado_por_usuario_id) REFERENCES usuario (id) ON DELETE RESTRICT;
ALTER TABLE recuperacion_ajuste ADD CONSTRAINT fk_recuperacion_ajuste_eliminado_por FOREIGN KEY (eliminado_por_usuario_id) REFERENCES usuario (id) ON DELETE RESTRICT;

-- >>> entidad_activo_incidencia.sql
CREATE TABLE activo_incidencia (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_empresa UUID NOT NULL,
  id_activo UUID NOT NULL,
  fecha_reporte DATE NOT NULL,
  titulo STRING NOT NULL,
  descripcion STRING,
  severidad STRING NOT NULL DEFAULT 'MEDIA',
  estado STRING NOT NULL DEFAULT 'ABIERTA',
  fecha_resolucion DATE,
  solucion STRING,
  creado_en TIMESTAMPTZ NOT NULL DEFAULT now(),
  creado_por_usuario_id UUID,
  actualizado_en TIMESTAMPTZ NOT NULL DEFAULT now(),
  actualizado_por_usuario_id UUID,
  eliminado_en TIMESTAMPTZ,
  eliminado_por_usuario_id UUID,
  CONSTRAINT ck_activo_incidencia_severidad CHECK (severidad IN ('BAJA', 'MEDIA', 'ALTA', 'CRITICA')),
  CONSTRAINT ck_activo_incidencia_estado CHECK (estado IN ('ABIERTA', 'EN_PROCESO', 'RESUELTA', 'ANULADA'))
);

ALTER TABLE activo_incidencia ADD CONSTRAINT fk_activo_incidencia_empresa FOREIGN KEY (id_empresa) REFERENCES empresa (id) ON DELETE RESTRICT;
ALTER TABLE activo_incidencia ADD CONSTRAINT fk_activo_incidencia_activo FOREIGN KEY (id_activo) REFERENCES activo (id) ON DELETE RESTRICT;
ALTER TABLE activo_incidencia ADD CONSTRAINT fk_activo_incidencia_creado_por FOREIGN KEY (creado_por_usuario_id) REFERENCES usuario (id) ON DELETE RESTRICT;
ALTER TABLE activo_incidencia ADD CONSTRAINT fk_activo_incidencia_actualizado_por FOREIGN KEY (actualizado_por_usuario_id) REFERENCES usuario (id) ON DELETE RESTRICT;
ALTER TABLE activo_incidencia ADD CONSTRAINT fk_activo_incidencia_eliminado_por FOREIGN KEY (eliminado_por_usuario_id) REFERENCES usuario (id) ON DELETE RESTRICT;

-- >>> entidad_activo_mantenimiento.sql
CREATE TABLE activo_mantenimiento (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_empresa UUID NOT NULL,
  id_activo UUID NOT NULL,
  tipo STRING NOT NULL,
  fecha_programada DATE NOT NULL,
  fecha_ejecucion DATE,
  descripcion STRING NOT NULL,
  costo DECIMAL(18,2),
  id_responsable UUID,
  estado STRING NOT NULL DEFAULT 'PROGRAMADO',
  creado_en TIMESTAMPTZ NOT NULL DEFAULT now(),
  creado_por_usuario_id UUID,
  actualizado_en TIMESTAMPTZ NOT NULL DEFAULT now(),
  actualizado_por_usuario_id UUID,
  eliminado_en TIMESTAMPTZ,
  eliminado_por_usuario_id UUID,
  CONSTRAINT ck_activo_mantenimiento_tipo CHECK (tipo IN ('PREVENTIVO', 'CORRECTIVO')),
  CONSTRAINT ck_activo_mantenimiento_estado CHECK (estado IN ('PROGRAMADO', 'EJECUTADO', 'ANULADO')),
  CONSTRAINT ck_activo_mantenimiento_costo CHECK (costo >= 0)
);

ALTER TABLE activo_mantenimiento ADD CONSTRAINT fk_activo_mantenimiento_empresa FOREIGN KEY (id_empresa) REFERENCES empresa (id) ON DELETE RESTRICT;
ALTER TABLE activo_mantenimiento ADD CONSTRAINT fk_activo_mantenimiento_activo FOREIGN KEY (id_activo) REFERENCES activo (id) ON DELETE RESTRICT;
ALTER TABLE activo_mantenimiento ADD CONSTRAINT fk_activo_mantenimiento_responsable FOREIGN KEY (id_responsable) REFERENCES usuario (id) ON DELETE RESTRICT;
ALTER TABLE activo_mantenimiento ADD CONSTRAINT fk_activo_mantenimiento_creado_por FOREIGN KEY (creado_por_usuario_id) REFERENCES usuario (id) ON DELETE RESTRICT;
ALTER TABLE activo_mantenimiento ADD CONSTRAINT fk_activo_mantenimiento_actualizado_por FOREIGN KEY (actualizado_por_usuario_id) REFERENCES usuario (id) ON DELETE RESTRICT;
ALTER TABLE activo_mantenimiento ADD CONSTRAINT fk_activo_mantenimiento_eliminado_por FOREIGN KEY (eliminado_por_usuario_id) REFERENCES usuario (id) ON DELETE RESTRICT;

-- >>> entidad_herramienta_intervencion.sql
CREATE TABLE herramienta_intervencion (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_empresa UUID NOT NULL,
  id_herramienta UUID NOT NULL,
  tipo STRING NOT NULL,
  fecha DATE NOT NULL,
  descripcion STRING,
  costo DECIMAL(18,2),
  id_responsable UUID,
  estado STRING NOT NULL DEFAULT 'REGISTRADA',
  creado_en TIMESTAMPTZ NOT NULL DEFAULT now(),
  creado_por_usuario_id UUID,
  actualizado_en TIMESTAMPTZ NOT NULL DEFAULT now(),
  actualizado_por_usuario_id UUID,
  eliminado_en TIMESTAMPTZ,
  eliminado_por_usuario_id UUID,
  CONSTRAINT ck_herramienta_intervencion_tipo CHECK (tipo IN ('REPARACION', 'CALIBRACION', 'REVISION')),
  CONSTRAINT ck_herramienta_intervencion_estado CHECK (estado IN ('REGISTRADA', 'EN_PROCESO', 'FINALIZADA', 'ANULADA')),
  CONSTRAINT ck_herramienta_intervencion_costo CHECK (costo >= 0)
);

ALTER TABLE herramienta_intervencion ADD CONSTRAINT fk_herramienta_intervencion_empresa FOREIGN KEY (id_empresa) REFERENCES empresa (id) ON DELETE RESTRICT;
ALTER TABLE herramienta_intervencion ADD CONSTRAINT fk_herramienta_intervencion_herramienta FOREIGN KEY (id_herramienta) REFERENCES herramienta (id) ON DELETE RESTRICT;
ALTER TABLE herramienta_intervencion ADD CONSTRAINT fk_herramienta_intervencion_responsable FOREIGN KEY (id_responsable) REFERENCES usuario (id) ON DELETE RESTRICT;
ALTER TABLE herramienta_intervencion ADD CONSTRAINT fk_herramienta_intervencion_creado_por FOREIGN KEY (creado_por_usuario_id) REFERENCES usuario (id) ON DELETE RESTRICT;
ALTER TABLE herramienta_intervencion ADD CONSTRAINT fk_herramienta_intervencion_actualizado_por FOREIGN KEY (actualizado_por_usuario_id) REFERENCES usuario (id) ON DELETE RESTRICT;
ALTER TABLE herramienta_intervencion ADD CONSTRAINT fk_herramienta_intervencion_eliminado_por FOREIGN KEY (eliminado_por_usuario_id) REFERENCES usuario (id) ON DELETE RESTRICT;

-- ---- INDICES NUEVOS ----
-- >>> idx_parametro_activos_inversion.sql
CREATE UNIQUE INDEX uq_parametro_activos_inversion_clave ON parametro_activos_inversion (id_empresa, categoria, clave) WHERE eliminado_en IS NULL;
CREATE INDEX idx_parametro_activos_inversion_categoria ON parametro_activos_inversion (id_empresa, categoria) WHERE eliminado_en IS NULL;
CREATE INDEX idx_star_parametro_activos_inversion_listado ON parametro_activos_inversion (id_empresa, creado_en DESC, id DESC) STORING (categoria, clave, valor, descripcion, estado) WHERE eliminado_en IS NULL;

-- >>> idx_recuperacion_ajuste.sql
CREATE INDEX idx_recuperacion_ajuste_activo ON recuperacion_ajuste (id_activo) WHERE eliminado_en IS NULL;
CREATE INDEX idx_recuperacion_ajuste_contrato ON recuperacion_ajuste (id_contrato) WHERE eliminado_en IS NULL;
CREATE INDEX idx_star_recuperacion_ajuste_listado ON recuperacion_ajuste (id_empresa, creado_en DESC, id DESC) STORING (id_activo, id_contrato, id_periodo, fecha, monto_ajuste, motivo, estado, fecha_resolucion) WHERE eliminado_en IS NULL;

-- >>> idx_activo_incidencia.sql
CREATE INDEX idx_activo_incidencia_activo ON activo_incidencia (id_activo) WHERE eliminado_en IS NULL;
CREATE INDEX idx_star_activo_incidencia_listado ON activo_incidencia (id_empresa, creado_en DESC, id DESC) STORING (id_activo, fecha_reporte, titulo, descripcion, severidad, estado, fecha_resolucion, solucion) WHERE eliminado_en IS NULL;

-- >>> idx_activo_mantenimiento.sql
CREATE INDEX idx_activo_mantenimiento_activo ON activo_mantenimiento (id_activo) WHERE eliminado_en IS NULL;
CREATE INDEX idx_star_activo_mantenimiento_listado ON activo_mantenimiento (id_empresa, creado_en DESC, id DESC) STORING (id_activo, tipo, fecha_programada, fecha_ejecucion, descripcion, costo, id_responsable, estado) WHERE eliminado_en IS NULL;

-- >>> idx_herramienta_intervencion.sql
CREATE INDEX idx_herramienta_intervencion_herramienta ON herramienta_intervencion (id_herramienta) WHERE eliminado_en IS NULL;
CREATE INDEX idx_star_herramienta_intervencion_listado ON herramienta_intervencion (id_empresa, creado_en DESC, id DESC) STORING (id_herramienta, tipo, fecha, descripcion, costo, id_responsable, estado) WHERE eliminado_en IS NULL;

-- ---- PROCEDIMIENTOS NUEVOS (41) ----
-- >>> fn_actualizar_ajuste_recuperacion.sql
CREATE OR REPLACE FUNCTION fn_actualizar_ajuste_recuperacion(
  p_id_empresa UUID,
  p_id_usuario_accion UUID,
  p_id_ajuste UUID,
  p_fecha DATE,
  p_monto_ajuste DECIMAL,
  p_motivo STRING
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_estado STRING;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  SELECT estado INTO v_estado
  FROM recuperacion_ajuste
  WHERE id = p_id_ajuste AND id_empresa = p_id_empresa AND eliminado_en IS NULL;

  IF v_estado IS NULL THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'AJUSTE_RECUPERACION_NO_ENCONTRADO', 'mensaje', 'El ajuste no existe o no pertenece a la empresa');
  END IF;

  IF v_estado <> 'PENDIENTE' THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'AJUSTE_RECUPERACION_NO_PENDIENTE', 'mensaje', 'Solo se puede editar un ajuste pendiente');
  END IF;

  IF p_fecha IS NULL THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'FECHA_OBLIGATORIA', 'mensaje', 'La fecha del ajuste es obligatoria');
  END IF;

  IF p_monto_ajuste IS NULL OR p_monto_ajuste = 0 THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'MONTO_INVALIDO', 'mensaje', 'El monto del ajuste debe ser distinto de cero');
  END IF;

  IF p_motivo IS NULL OR char_length(trim(p_motivo)) = 0 THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'MOTIVO_OBLIGATORIO', 'mensaje', 'El motivo del ajuste es obligatorio');
  END IF;

  UPDATE recuperacion_ajuste SET
    fecha = p_fecha,
    monto_ajuste = p_monto_ajuste,
    motivo = trim(p_motivo),
    actualizado_en = now(),
    actualizado_por_usuario_id = p_id_usuario_accion
  WHERE id = p_id_ajuste AND id_empresa = p_id_empresa;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'AJUSTE_RECUPERACION_ACTUALIZADO',
    'mensaje', 'El ajuste fue actualizado correctamente',
    'datos', jsonb_build_object('id_ajuste', p_id_ajuste)
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'AJUSTE_RECUPERACION_ACTUALIZACION_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al actualizar el ajuste');
END;
$$;

-- >>> fn_actualizar_clasificacion_activo.sql
CREATE OR REPLACE FUNCTION fn_actualizar_clasificacion_activo(
  p_id_empresa UUID,
  p_id_usuario_accion UUID,
  p_id_clasificacion_activo UUID,
  p_codigo STRING,
  p_descripcion STRING,
  p_es_capitalizable BOOL DEFAULT true
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  IF p_codigo IS NULL OR char_length(trim(p_codigo)) = 0 THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'CODIGO_OBLIGATORIO', 'mensaje', 'El codigo de la clasificacion es obligatorio');
  END IF;

  IF p_descripcion IS NULL OR char_length(trim(p_descripcion)) = 0 THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'DESCRIPCION_OBLIGATORIA', 'mensaje', 'La descripcion de la clasificacion es obligatoria');
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM clasificacion_activo
    WHERE id = p_id_clasificacion_activo AND id_empresa = p_id_empresa AND eliminado_en IS NULL
  ) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'CLASIFICACION_ACTIVO_NO_ENCONTRADA', 'mensaje', 'La clasificacion de activo no existe o no pertenece a la empresa');
  END IF;

  IF EXISTS (
    SELECT 1 FROM clasificacion_activo
    WHERE id_empresa = p_id_empresa AND codigo = trim(p_codigo) AND eliminado_en IS NULL AND id <> p_id_clasificacion_activo
  ) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'CLASIFICACION_ACTIVO_CODIGO_DUPLICADO', 'mensaje', 'Ya existe una clasificacion de activo con ese codigo en la empresa');
  END IF;

  UPDATE clasificacion_activo SET
    codigo = trim(p_codigo),
    descripcion = trim(p_descripcion),
    es_capitalizable = COALESCE(p_es_capitalizable, true),
    actualizado_en = now(),
    actualizado_por_usuario_id = p_id_usuario_accion
  WHERE id = p_id_clasificacion_activo AND id_empresa = p_id_empresa;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'CLASIFICACION_ACTIVO_ACTUALIZADA',
    'mensaje', 'La clasificacion de activo fue actualizada correctamente',
    'datos', jsonb_build_object('id_clasificacion_activo', p_id_clasificacion_activo)
  );
EXCEPTION
  WHEN unique_violation THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'CLASIFICACION_ACTIVO_CODIGO_DUPLICADO', 'mensaje', 'Ya existe una clasificacion de activo con ese codigo en la empresa');
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'CLASIFICACION_ACTIVO_ACTUALIZACION_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al actualizar la clasificacion de activo');
END;
$$;

-- >>> fn_actualizar_incidencia_activo.sql
CREATE OR REPLACE FUNCTION fn_actualizar_incidencia_activo(
  p_id_empresa UUID,
  p_id_usuario_accion UUID,
  p_id_incidencia UUID,
  p_titulo STRING,
  p_descripcion STRING DEFAULT NULL,
  p_severidad STRING DEFAULT 'MEDIA'
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_estado STRING;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  SELECT estado INTO v_estado
  FROM activo_incidencia
  WHERE id = p_id_incidencia AND id_empresa = p_id_empresa AND eliminado_en IS NULL;

  IF v_estado IS NULL THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'INCIDENCIA_ACTIVO_NO_ENCONTRADA', 'mensaje', 'La incidencia no existe o no pertenece a la empresa');
  END IF;

  IF v_estado IN ('RESUELTA', 'ANULADA') THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'INCIDENCIA_ACTIVO_CERRADA', 'mensaje', 'La incidencia esta resuelta o anulada, no se puede editar');
  END IF;

  IF p_titulo IS NULL OR char_length(trim(p_titulo)) = 0 THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'TITULO_OBLIGATORIO', 'mensaje', 'El titulo de la incidencia es obligatorio');
  END IF;

  IF COALESCE(p_severidad, 'MEDIA') NOT IN ('BAJA', 'MEDIA', 'ALTA', 'CRITICA') THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'SEVERIDAD_NO_VALIDA', 'mensaje', 'La severidad no es valida');
  END IF;

  UPDATE activo_incidencia SET
    titulo = trim(p_titulo),
    descripcion = NULLIF(trim(p_descripcion), ''),
    severidad = COALESCE(p_severidad, 'MEDIA'),
    actualizado_en = now(),
    actualizado_por_usuario_id = p_id_usuario_accion
  WHERE id = p_id_incidencia AND id_empresa = p_id_empresa;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'INCIDENCIA_ACTIVO_ACTUALIZADA',
    'mensaje', 'La incidencia fue actualizada correctamente',
    'datos', jsonb_build_object('id_incidencia', p_id_incidencia)
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'INCIDENCIA_ACTIVO_ACTUALIZACION_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al actualizar la incidencia');
END;
$$;

-- >>> fn_actualizar_intervencion_herramienta.sql
CREATE OR REPLACE FUNCTION fn_actualizar_intervencion_herramienta(
  p_id_empresa UUID,
  p_id_usuario_accion UUID,
  p_id_intervencion UUID,
  p_tipo STRING,
  p_fecha DATE,
  p_descripcion STRING DEFAULT NULL,
  p_costo DECIMAL DEFAULT NULL
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_estado STRING;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  SELECT estado INTO v_estado
  FROM herramienta_intervencion
  WHERE id = p_id_intervencion AND id_empresa = p_id_empresa AND eliminado_en IS NULL;

  IF v_estado IS NULL THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'INTERVENCION_HERRAMIENTA_NO_ENCONTRADA', 'mensaje', 'La intervencion no existe o no pertenece a la empresa');
  END IF;

  IF v_estado IN ('FINALIZADA', 'ANULADA') THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'INTERVENCION_HERRAMIENTA_CERRADA', 'mensaje', 'La intervencion esta finalizada o anulada, no se puede editar');
  END IF;

  IF p_tipo IS NULL OR p_tipo NOT IN ('REPARACION', 'CALIBRACION', 'REVISION') THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'TIPO_INTERVENCION_NO_VALIDO', 'mensaje', 'El tipo de intervencion no es valido');
  END IF;

  IF p_fecha IS NULL THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'FECHA_OBLIGATORIA', 'mensaje', 'La fecha de la intervencion es obligatoria');
  END IF;

  IF COALESCE(p_costo, 0) < 0 THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'COSTO_INVALIDO', 'mensaje', 'El costo no puede ser negativo');
  END IF;

  UPDATE herramienta_intervencion SET
    tipo = p_tipo,
    fecha = p_fecha,
    descripcion = NULLIF(trim(p_descripcion), ''),
    costo = p_costo,
    actualizado_en = now(),
    actualizado_por_usuario_id = p_id_usuario_accion
  WHERE id = p_id_intervencion AND id_empresa = p_id_empresa;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'INTERVENCION_HERRAMIENTA_ACTUALIZADA',
    'mensaje', 'La intervencion fue actualizada correctamente',
    'datos', jsonb_build_object('id_intervencion', p_id_intervencion)
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'INTERVENCION_HERRAMIENTA_ACTUALIZACION_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al actualizar la intervencion');
END;
$$;

-- >>> fn_actualizar_mantenimiento_activo.sql
CREATE OR REPLACE FUNCTION fn_actualizar_mantenimiento_activo(
  p_id_empresa UUID,
  p_id_usuario_accion UUID,
  p_id_mantenimiento UUID,
  p_tipo STRING,
  p_fecha_programada DATE,
  p_descripcion STRING,
  p_costo DECIMAL DEFAULT NULL,
  p_id_responsable UUID DEFAULT NULL
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_estado STRING;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  SELECT estado INTO v_estado
  FROM activo_mantenimiento
  WHERE id = p_id_mantenimiento AND id_empresa = p_id_empresa AND eliminado_en IS NULL;

  IF v_estado IS NULL THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'MANTENIMIENTO_ACTIVO_NO_ENCONTRADO', 'mensaje', 'El mantenimiento no existe o no pertenece a la empresa');
  END IF;

  IF v_estado = 'ANULADO' THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'MANTENIMIENTO_ACTIVO_ANULADO', 'mensaje', 'El mantenimiento esta anulado, no se puede editar');
  END IF;

  IF p_tipo IS NULL OR p_tipo NOT IN ('PREVENTIVO', 'CORRECTIVO') THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'TIPO_MANTENIMIENTO_NO_VALIDO', 'mensaje', 'El tipo de mantenimiento debe ser PREVENTIVO o CORRECTIVO');
  END IF;

  IF p_fecha_programada IS NULL THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'FECHA_OBLIGATORIA', 'mensaje', 'La fecha programada del mantenimiento es obligatoria');
  END IF;

  IF p_descripcion IS NULL OR char_length(trim(p_descripcion)) = 0 THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'DESCRIPCION_OBLIGATORIA', 'mensaje', 'La descripcion del mantenimiento es obligatoria');
  END IF;

  IF COALESCE(p_costo, 0) < 0 THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'COSTO_INVALIDO', 'mensaje', 'El costo no puede ser negativo');
  END IF;

  IF p_id_responsable IS NOT NULL AND NOT EXISTS (SELECT 1 FROM usuario WHERE id = p_id_responsable) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'RESPONSABLE_NO_VALIDO', 'mensaje', 'El responsable no existe');
  END IF;

  UPDATE activo_mantenimiento SET
    tipo = p_tipo,
    fecha_programada = p_fecha_programada,
    descripcion = trim(p_descripcion),
    costo = p_costo,
    id_responsable = p_id_responsable,
    actualizado_en = now(),
    actualizado_por_usuario_id = p_id_usuario_accion
  WHERE id = p_id_mantenimiento AND id_empresa = p_id_empresa;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'MANTENIMIENTO_ACTIVO_ACTUALIZADO',
    'mensaje', 'El mantenimiento fue actualizado correctamente',
    'datos', jsonb_build_object('id_mantenimiento', p_id_mantenimiento)
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'MANTENIMIENTO_ACTIVO_ACTUALIZACION_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al actualizar el mantenimiento');
END;
$$;

-- >>> fn_actualizar_parametro_activos_inversion.sql
CREATE OR REPLACE FUNCTION fn_actualizar_parametro_activos_inversion(
  p_id_empresa UUID,
  p_id_usuario_accion UUID,
  p_id_parametro UUID,
  p_valor STRING,
  p_descripcion STRING DEFAULT NULL
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  IF NOT EXISTS (SELECT 1 FROM parametro_activos_inversion WHERE id = p_id_parametro AND id_empresa = p_id_empresa AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'PARAMETRO_NO_ENCONTRADO', 'mensaje', 'El parametro no existe o no pertenece a la empresa');
  END IF;

  IF p_valor IS NULL OR char_length(trim(p_valor)) = 0 THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'VALOR_OBLIGATORIO', 'mensaje', 'El valor del parametro es obligatorio');
  END IF;

  UPDATE parametro_activos_inversion SET
    valor = trim(p_valor),
    descripcion = NULLIF(trim(p_descripcion), ''),
    actualizado_en = now(),
    actualizado_por_usuario_id = p_id_usuario_accion
  WHERE id = p_id_parametro AND id_empresa = p_id_empresa;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'PARAMETRO_ACTUALIZADO',
    'mensaje', 'El parametro fue actualizado correctamente',
    'datos', jsonb_build_object('id_parametro', p_id_parametro)
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'PARAMETRO_ACTUALIZACION_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al actualizar el parametro');
END;
$$;

-- >>> fn_actualizar_tipo_adquisicion_activo.sql
CREATE OR REPLACE FUNCTION fn_actualizar_tipo_adquisicion_activo(
  p_id_empresa UUID,
  p_id_usuario_accion UUID,
  p_id_tipo_adquisicion_activo UUID,
  p_codigo STRING,
  p_descripcion STRING
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  IF p_codigo IS NULL OR char_length(trim(p_codigo)) = 0 THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'CODIGO_OBLIGATORIO', 'mensaje', 'El codigo del tipo de adquisicion es obligatorio');
  END IF;

  IF p_descripcion IS NULL OR char_length(trim(p_descripcion)) = 0 THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'DESCRIPCION_OBLIGATORIA', 'mensaje', 'La descripcion del tipo de adquisicion es obligatoria');
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM tipo_adquisicion_activo
    WHERE id = p_id_tipo_adquisicion_activo AND id_empresa = p_id_empresa AND eliminado_en IS NULL
  ) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'TIPO_ADQUISICION_ACTIVO_NO_ENCONTRADO', 'mensaje', 'El tipo de adquisicion de activo no existe o no pertenece a la empresa');
  END IF;

  IF EXISTS (
    SELECT 1 FROM tipo_adquisicion_activo
    WHERE id_empresa = p_id_empresa AND codigo = trim(p_codigo) AND eliminado_en IS NULL AND id <> p_id_tipo_adquisicion_activo
  ) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'TIPO_ADQUISICION_ACTIVO_CODIGO_DUPLICADO', 'mensaje', 'Ya existe un tipo de adquisicion con ese codigo en la empresa');
  END IF;

  UPDATE tipo_adquisicion_activo SET
    codigo = trim(p_codigo),
    descripcion = trim(p_descripcion),
    actualizado_en = now(),
    actualizado_por_usuario_id = p_id_usuario_accion
  WHERE id = p_id_tipo_adquisicion_activo AND id_empresa = p_id_empresa;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'TIPO_ADQUISICION_ACTIVO_ACTUALIZADO',
    'mensaje', 'El tipo de adquisicion de activo fue actualizado correctamente',
    'datos', jsonb_build_object('id_tipo_adquisicion_activo', p_id_tipo_adquisicion_activo)
  );
EXCEPTION
  WHEN unique_violation THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'TIPO_ADQUISICION_ACTIVO_CODIGO_DUPLICADO', 'mensaje', 'Ya existe un tipo de adquisicion con ese codigo en la empresa');
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'TIPO_ADQUISICION_ACTIVO_ACTUALIZACION_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al actualizar el tipo de adquisicion de activo');
END;
$$;

-- >>> fn_actualizar_tipo_herramienta.sql
CREATE OR REPLACE FUNCTION fn_actualizar_tipo_herramienta(
  p_id_empresa UUID,
  p_id_usuario_accion UUID,
  p_id_tipo_herramienta UUID,
  p_codigo STRING,
  p_descripcion STRING
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  IF p_codigo IS NULL OR char_length(trim(p_codigo)) = 0 THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'CODIGO_OBLIGATORIO', 'mensaje', 'El codigo del tipo de herramienta es obligatorio');
  END IF;

  IF p_descripcion IS NULL OR char_length(trim(p_descripcion)) = 0 THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'DESCRIPCION_OBLIGATORIA', 'mensaje', 'La descripcion del tipo de herramienta es obligatoria');
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM tipo_herramienta
    WHERE id = p_id_tipo_herramienta AND id_empresa = p_id_empresa AND eliminado_en IS NULL
  ) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'TIPO_HERRAMIENTA_NO_ENCONTRADO', 'mensaje', 'El tipo de herramienta no existe o no pertenece a la empresa');
  END IF;

  IF EXISTS (
    SELECT 1 FROM tipo_herramienta
    WHERE id_empresa = p_id_empresa AND codigo = trim(p_codigo) AND eliminado_en IS NULL AND id <> p_id_tipo_herramienta
  ) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'TIPO_HERRAMIENTA_CODIGO_DUPLICADO', 'mensaje', 'Ya existe un tipo de herramienta con ese codigo en la empresa');
  END IF;

  UPDATE tipo_herramienta SET
    codigo = trim(p_codigo),
    descripcion = trim(p_descripcion),
    actualizado_en = now(),
    actualizado_por_usuario_id = p_id_usuario_accion
  WHERE id = p_id_tipo_herramienta AND id_empresa = p_id_empresa;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'TIPO_HERRAMIENTA_ACTUALIZADO',
    'mensaje', 'El tipo de herramienta fue actualizado correctamente',
    'datos', jsonb_build_object('id_tipo_herramienta', p_id_tipo_herramienta)
  );
EXCEPTION
  WHEN unique_violation THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'TIPO_HERRAMIENTA_CODIGO_DUPLICADO', 'mensaje', 'Ya existe un tipo de herramienta con ese codigo en la empresa');
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'TIPO_HERRAMIENTA_ACTUALIZACION_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al actualizar el tipo de herramienta');
END;
$$;

-- >>> fn_anular_incidencia_activo.sql
CREATE OR REPLACE FUNCTION fn_anular_incidencia_activo(
  p_id_empresa UUID,
  p_id_usuario_accion UUID,
  p_id_incidencia UUID
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_estado STRING;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  SELECT estado INTO v_estado
  FROM activo_incidencia
  WHERE id = p_id_incidencia AND id_empresa = p_id_empresa AND eliminado_en IS NULL;

  IF v_estado IS NULL THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'INCIDENCIA_ACTIVO_NO_ENCONTRADA', 'mensaje', 'La incidencia no existe o no pertenece a la empresa');
  END IF;

  IF v_estado = 'ANULADA' THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'INCIDENCIA_ACTIVO_YA_ANULADA', 'mensaje', 'La incidencia ya se encuentra anulada');
  END IF;

  UPDATE activo_incidencia
  SET estado = 'ANULADA', actualizado_en = now(), actualizado_por_usuario_id = p_id_usuario_accion
  WHERE id = p_id_incidencia AND id_empresa = p_id_empresa;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'INCIDENCIA_ACTIVO_ANULADA',
    'mensaje', 'La incidencia fue anulada correctamente',
    'datos', jsonb_build_object('id_incidencia', p_id_incidencia, 'estado', 'ANULADA')
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'INCIDENCIA_ACTIVO_ANULACION_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al anular la incidencia');
END;
$$;

-- >>> fn_anular_intervencion_herramienta.sql
CREATE OR REPLACE FUNCTION fn_anular_intervencion_herramienta(
  p_id_empresa UUID,
  p_id_usuario_accion UUID,
  p_id_intervencion UUID
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_estado STRING;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  SELECT estado INTO v_estado
  FROM herramienta_intervencion
  WHERE id = p_id_intervencion AND id_empresa = p_id_empresa AND eliminado_en IS NULL;

  IF v_estado IS NULL THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'INTERVENCION_HERRAMIENTA_NO_ENCONTRADA', 'mensaje', 'La intervencion no existe o no pertenece a la empresa');
  END IF;

  IF v_estado = 'ANULADA' THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'INTERVENCION_HERRAMIENTA_YA_ANULADA', 'mensaje', 'La intervencion ya se encuentra anulada');
  END IF;

  UPDATE herramienta_intervencion
  SET estado = 'ANULADA', actualizado_en = now(), actualizado_por_usuario_id = p_id_usuario_accion
  WHERE id = p_id_intervencion AND id_empresa = p_id_empresa;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'INTERVENCION_HERRAMIENTA_ANULADA',
    'mensaje', 'La intervencion fue anulada correctamente',
    'datos', jsonb_build_object('id_intervencion', p_id_intervencion, 'estado', 'ANULADA')
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'INTERVENCION_HERRAMIENTA_ANULACION_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al anular la intervencion');
END;
$$;

-- >>> fn_anular_mantenimiento_activo.sql
CREATE OR REPLACE FUNCTION fn_anular_mantenimiento_activo(
  p_id_empresa UUID,
  p_id_usuario_accion UUID,
  p_id_mantenimiento UUID
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_estado STRING;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  SELECT estado INTO v_estado
  FROM activo_mantenimiento
  WHERE id = p_id_mantenimiento AND id_empresa = p_id_empresa AND eliminado_en IS NULL;

  IF v_estado IS NULL THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'MANTENIMIENTO_ACTIVO_NO_ENCONTRADO', 'mensaje', 'El mantenimiento no existe o no pertenece a la empresa');
  END IF;

  IF v_estado = 'ANULADO' THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'MANTENIMIENTO_ACTIVO_YA_ANULADO', 'mensaje', 'El mantenimiento ya se encuentra anulado');
  END IF;

  UPDATE activo_mantenimiento
  SET estado = 'ANULADO', actualizado_en = now(), actualizado_por_usuario_id = p_id_usuario_accion
  WHERE id = p_id_mantenimiento AND id_empresa = p_id_empresa;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'MANTENIMIENTO_ACTIVO_ANULADO',
    'mensaje', 'El mantenimiento fue anulado correctamente',
    'datos', jsonb_build_object('id_mantenimiento', p_id_mantenimiento, 'estado', 'ANULADO')
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'MANTENIMIENTO_ACTIVO_ANULACION_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al anular el mantenimiento');
END;
$$;

-- >>> fn_aprobar_ajuste_recuperacion.sql
CREATE OR REPLACE FUNCTION fn_aprobar_ajuste_recuperacion(
  p_id_empresa UUID,
  p_id_usuario_accion UUID,
  p_id_ajuste UUID
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_estado STRING;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  SELECT estado INTO v_estado
  FROM recuperacion_ajuste
  WHERE id = p_id_ajuste AND id_empresa = p_id_empresa AND eliminado_en IS NULL;

  IF v_estado IS NULL THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'AJUSTE_RECUPERACION_NO_ENCONTRADO', 'mensaje', 'El ajuste no existe o no pertenece a la empresa');
  END IF;

  IF v_estado <> 'PENDIENTE' THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'AJUSTE_RECUPERACION_NO_PENDIENTE', 'mensaje', 'Solo se puede aprobar un ajuste pendiente');
  END IF;

  UPDATE recuperacion_ajuste
  SET estado = 'APROBADO', fecha_resolucion = current_date, actualizado_en = now(), actualizado_por_usuario_id = p_id_usuario_accion
  WHERE id = p_id_ajuste AND id_empresa = p_id_empresa;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'AJUSTE_RECUPERACION_APROBADO',
    'mensaje', 'El ajuste fue aprobado correctamente',
    'datos', jsonb_build_object('id_ajuste', p_id_ajuste, 'estado', 'APROBADO')
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'AJUSTE_RECUPERACION_APROBACION_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al aprobar el ajuste');
END;
$$;

-- >>> fn_dar_de_baja_clasificacion_activo.sql
CREATE OR REPLACE FUNCTION fn_dar_de_baja_clasificacion_activo(
  p_id_empresa UUID,
  p_id_usuario_accion UUID,
  p_id_clasificacion_activo UUID
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_estado STRING;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  SELECT estado INTO v_estado
  FROM clasificacion_activo
  WHERE id = p_id_clasificacion_activo AND id_empresa = p_id_empresa AND eliminado_en IS NULL;

  IF v_estado IS NULL THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'CLASIFICACION_ACTIVO_NO_ENCONTRADA', 'mensaje', 'La clasificacion de activo no existe o no pertenece a la empresa');
  END IF;

  IF v_estado = 'INACTIVO' THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'CLASIFICACION_ACTIVO_YA_INACTIVA', 'mensaje', 'La clasificacion de activo ya se encuentra inactiva');
  END IF;

  UPDATE clasificacion_activo
  SET estado = 'INACTIVO', actualizado_en = now(), actualizado_por_usuario_id = p_id_usuario_accion
  WHERE id = p_id_clasificacion_activo AND id_empresa = p_id_empresa;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'CLASIFICACION_ACTIVO_INACTIVADA',
    'mensaje', 'La clasificacion de activo fue inactivada correctamente',
    'datos', jsonb_build_object('id_clasificacion_activo', p_id_clasificacion_activo, 'estado', 'INACTIVO')
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'CLASIFICACION_ACTIVO_BAJA_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al inactivar la clasificacion de activo');
END;
$$;

-- >>> fn_dar_de_baja_herramienta.sql
CREATE OR REPLACE FUNCTION fn_dar_de_baja_herramienta(
  p_id_empresa UUID,
  p_id_usuario_accion UUID,
  p_id_herramienta UUID
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_estado STRING;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  SELECT estado INTO v_estado
  FROM herramienta
  WHERE id = p_id_herramienta AND id_empresa = p_id_empresa AND eliminado_en IS NULL;

  IF v_estado IS NULL THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'HERRAMIENTA_NO_ENCONTRADA', 'mensaje', 'La herramienta no existe o no pertenece a la empresa');
  END IF;

  IF v_estado = 'BAJA' THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'HERRAMIENTA_YA_DADA_DE_BAJA', 'mensaje', 'La herramienta ya se encuentra dada de baja');
  END IF;

  UPDATE herramienta
  SET estado = 'BAJA', actualizado_en = now(), actualizado_por_usuario_id = p_id_usuario_accion
  WHERE id = p_id_herramienta AND id_empresa = p_id_empresa;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'HERRAMIENTA_DADA_DE_BAJA',
    'mensaje', 'La herramienta fue dada de baja correctamente',
    'datos', jsonb_build_object('id_herramienta', p_id_herramienta, 'estado', 'BAJA')
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'HERRAMIENTA_BAJA_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al dar de baja la herramienta');
END;
$$;

-- >>> fn_dar_de_baja_parametro_activos_inversion.sql
CREATE OR REPLACE FUNCTION fn_dar_de_baja_parametro_activos_inversion(
  p_id_empresa UUID,
  p_id_usuario_accion UUID,
  p_id_parametro UUID
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_estado STRING;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  SELECT estado INTO v_estado
  FROM parametro_activos_inversion
  WHERE id = p_id_parametro AND id_empresa = p_id_empresa AND eliminado_en IS NULL;

  IF v_estado IS NULL THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'PARAMETRO_NO_ENCONTRADO', 'mensaje', 'El parametro no existe o no pertenece a la empresa');
  END IF;

  IF v_estado = 'INACTIVO' THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'PARAMETRO_YA_INACTIVO', 'mensaje', 'El parametro ya se encuentra inactivo');
  END IF;

  UPDATE parametro_activos_inversion
  SET estado = 'INACTIVO', actualizado_en = now(), actualizado_por_usuario_id = p_id_usuario_accion
  WHERE id = p_id_parametro AND id_empresa = p_id_empresa;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'PARAMETRO_INACTIVADO',
    'mensaje', 'El parametro fue inactivado correctamente',
    'datos', jsonb_build_object('id_parametro', p_id_parametro, 'estado', 'INACTIVO')
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'PARAMETRO_BAJA_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al inactivar el parametro');
END;
$$;

-- >>> fn_dar_de_baja_tipo_adquisicion_activo.sql
CREATE OR REPLACE FUNCTION fn_dar_de_baja_tipo_adquisicion_activo(
  p_id_empresa UUID,
  p_id_usuario_accion UUID,
  p_id_tipo_adquisicion_activo UUID
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_estado STRING;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  SELECT estado INTO v_estado
  FROM tipo_adquisicion_activo
  WHERE id = p_id_tipo_adquisicion_activo AND id_empresa = p_id_empresa AND eliminado_en IS NULL;

  IF v_estado IS NULL THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'TIPO_ADQUISICION_ACTIVO_NO_ENCONTRADO', 'mensaje', 'El tipo de adquisicion de activo no existe o no pertenece a la empresa');
  END IF;

  IF v_estado = 'INACTIVO' THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'TIPO_ADQUISICION_ACTIVO_YA_INACTIVO', 'mensaje', 'El tipo de adquisicion de activo ya se encuentra inactivo');
  END IF;

  UPDATE tipo_adquisicion_activo
  SET estado = 'INACTIVO', actualizado_en = now(), actualizado_por_usuario_id = p_id_usuario_accion
  WHERE id = p_id_tipo_adquisicion_activo AND id_empresa = p_id_empresa;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'TIPO_ADQUISICION_ACTIVO_INACTIVADO',
    'mensaje', 'El tipo de adquisicion de activo fue inactivado correctamente',
    'datos', jsonb_build_object('id_tipo_adquisicion_activo', p_id_tipo_adquisicion_activo, 'estado', 'INACTIVO')
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'TIPO_ADQUISICION_ACTIVO_BAJA_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al inactivar el tipo de adquisicion de activo');
END;
$$;

-- >>> fn_dar_de_baja_tipo_herramienta.sql
CREATE OR REPLACE FUNCTION fn_dar_de_baja_tipo_herramienta(
  p_id_empresa UUID,
  p_id_usuario_accion UUID,
  p_id_tipo_herramienta UUID
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_estado STRING;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  SELECT estado INTO v_estado
  FROM tipo_herramienta
  WHERE id = p_id_tipo_herramienta AND id_empresa = p_id_empresa AND eliminado_en IS NULL;

  IF v_estado IS NULL THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'TIPO_HERRAMIENTA_NO_ENCONTRADO', 'mensaje', 'El tipo de herramienta no existe o no pertenece a la empresa');
  END IF;

  IF v_estado = 'INACTIVO' THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'TIPO_HERRAMIENTA_YA_INACTIVO', 'mensaje', 'El tipo de herramienta ya se encuentra inactivo');
  END IF;

  UPDATE tipo_herramienta
  SET estado = 'INACTIVO', actualizado_en = now(), actualizado_por_usuario_id = p_id_usuario_accion
  WHERE id = p_id_tipo_herramienta AND id_empresa = p_id_empresa;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'TIPO_HERRAMIENTA_INACTIVADO',
    'mensaje', 'El tipo de herramienta fue inactivado correctamente',
    'datos', jsonb_build_object('id_tipo_herramienta', p_id_tipo_herramienta, 'estado', 'INACTIVO')
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'TIPO_HERRAMIENTA_BAJA_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al inactivar el tipo de herramienta');
END;
$$;

-- >>> fn_ejecutar_mantenimiento_activo.sql
CREATE OR REPLACE FUNCTION fn_ejecutar_mantenimiento_activo(
  p_id_empresa UUID,
  p_id_usuario_accion UUID,
  p_id_mantenimiento UUID,
  p_fecha_ejecucion DATE DEFAULT NULL
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_estado STRING;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  SELECT estado INTO v_estado
  FROM activo_mantenimiento
  WHERE id = p_id_mantenimiento AND id_empresa = p_id_empresa AND eliminado_en IS NULL;

  IF v_estado IS NULL THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'MANTENIMIENTO_ACTIVO_NO_ENCONTRADO', 'mensaje', 'El mantenimiento no existe o no pertenece a la empresa');
  END IF;

  IF v_estado <> 'PROGRAMADO' THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'MANTENIMIENTO_ACTIVO_NO_PROGRAMADO', 'mensaje', 'Solo se puede ejecutar un mantenimiento en estado PROGRAMADO');
  END IF;

  UPDATE activo_mantenimiento
  SET estado = 'EJECUTADO', fecha_ejecucion = COALESCE(p_fecha_ejecucion, current_date), actualizado_en = now(), actualizado_por_usuario_id = p_id_usuario_accion
  WHERE id = p_id_mantenimiento AND id_empresa = p_id_empresa;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'MANTENIMIENTO_ACTIVO_EJECUTADO',
    'mensaje', 'El mantenimiento fue marcado como ejecutado',
    'datos', jsonb_build_object('id_mantenimiento', p_id_mantenimiento, 'estado', 'EJECUTADO')
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'MANTENIMIENTO_ACTIVO_EJECUCION_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al ejecutar el mantenimiento');
END;
$$;

-- >>> fn_finalizar_intervencion_herramienta.sql
CREATE OR REPLACE FUNCTION fn_finalizar_intervencion_herramienta(
  p_id_empresa UUID,
  p_id_usuario_accion UUID,
  p_id_intervencion UUID
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_estado STRING;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  SELECT estado INTO v_estado
  FROM herramienta_intervencion
  WHERE id = p_id_intervencion AND id_empresa = p_id_empresa AND eliminado_en IS NULL;

  IF v_estado IS NULL THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'INTERVENCION_HERRAMIENTA_NO_ENCONTRADA', 'mensaje', 'La intervencion no existe o no pertenece a la empresa');
  END IF;

  IF v_estado NOT IN ('REGISTRADA', 'EN_PROCESO') THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'INTERVENCION_HERRAMIENTA_NO_FINALIZABLE', 'mensaje', 'Solo se puede finalizar una intervencion registrada o en proceso');
  END IF;

  UPDATE herramienta_intervencion
  SET estado = 'FINALIZADA', actualizado_en = now(), actualizado_por_usuario_id = p_id_usuario_accion
  WHERE id = p_id_intervencion AND id_empresa = p_id_empresa;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'INTERVENCION_HERRAMIENTA_FINALIZADA',
    'mensaje', 'La intervencion fue finalizada correctamente',
    'datos', jsonb_build_object('id_intervencion', p_id_intervencion, 'estado', 'FINALIZADA')
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'INTERVENCION_HERRAMIENTA_FINALIZACION_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al finalizar la intervencion');
END;
$$;

-- >>> fn_listar_ajustes_recuperacion.sql
CREATE OR REPLACE FUNCTION fn_listar_ajustes_recuperacion(
  p_id_empresa UUID,
  p_id_activo UUID DEFAULT NULL,
  p_estado STRING DEFAULT NULL,
  p_texto_busqueda STRING DEFAULT NULL,
  p_limite INT DEFAULT NULL,
  p_cursor_creado_en TIMESTAMPTZ DEFAULT NULL,
  p_cursor_id UUID DEFAULT NULL
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_limite_pagina INT;
  v_pagina JSONB;
  v_hay_mas BOOL;
  v_cantidad INT;
  v_cursor_siguiente JSONB;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  IF p_id_activo IS NOT NULL AND NOT EXISTS (SELECT 1 FROM activo WHERE id = p_id_activo AND id_empresa = p_id_empresa AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'ACTIVO_NO_VALIDO', 'mensaje', 'El activo no existe o no pertenece a la empresa');
  END IF;

  v_limite_pagina := LEAST(GREATEST(COALESCE(p_limite, 20), 1), 100);

  WITH ajustes_ordenados AS (
    SELECT aj.id, aj.id_activo, a.codigo AS activo_codigo, a.descripcion AS activo_descripcion,
           aj.id_contrato, aj.id_periodo, aj.fecha, aj.monto_ajuste, aj.motivo, aj.estado, aj.fecha_resolucion, aj.creado_en,
           row_number() OVER (ORDER BY aj.creado_en DESC, aj.id DESC) AS orden_en_pagina
    FROM recuperacion_ajuste aj
    JOIN activo a ON a.id = aj.id_activo
    WHERE aj.id_empresa = p_id_empresa
      AND aj.eliminado_en IS NULL
      AND (p_id_activo IS NULL OR aj.id_activo = p_id_activo)
      AND (p_estado IS NULL OR aj.estado = p_estado)
      AND (p_texto_busqueda IS NULL OR aj.motivo ILIKE '%' || p_texto_busqueda || '%' OR a.codigo ILIKE '%' || p_texto_busqueda || '%' OR a.descripcion ILIKE '%' || p_texto_busqueda || '%')
      AND (p_cursor_creado_en IS NULL OR (aj.creado_en, aj.id) < (p_cursor_creado_en, p_cursor_id))
    ORDER BY aj.creado_en DESC, aj.id DESC
    LIMIT v_limite_pagina + 1
  )
  SELECT
    COALESCE(
      jsonb_agg(to_jsonb(ajustes_ordenados) - 'orden_en_pagina' ORDER BY ajustes_ordenados.orden_en_pagina)
      FILTER (WHERE ajustes_ordenados.orden_en_pagina <= v_limite_pagina),
      '[]'::jsonb
    ),
    count(*) > v_limite_pagina
  INTO v_pagina, v_hay_mas
  FROM ajustes_ordenados;

  v_cantidad := jsonb_array_length(v_pagina);
  IF v_hay_mas AND v_cantidad > 0 THEN
    v_cursor_siguiente := jsonb_build_object(
      'creado_en', v_pagina -> (v_cantidad - 1) -> 'creado_en',
      'id', v_pagina -> (v_cantidad - 1) -> 'id'
    );
  ELSE
    v_cursor_siguiente := NULL;
  END IF;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'AJUSTES_RECUPERACION_LISTADOS',
    'mensaje', 'Listado de ajustes de recuperacion obtenido',
    'datos', jsonb_build_object(
      'items', v_pagina,
      'paginacion', jsonb_build_object('limite', v_limite_pagina, 'hay_mas', v_hay_mas, 'cursor_siguiente', v_cursor_siguiente)
    )
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'AJUSTES_RECUPERACION_LISTADO_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al listar los ajustes de recuperacion');
END;
$$;

-- >>> fn_listar_incidencias_activo.sql
CREATE OR REPLACE FUNCTION fn_listar_incidencias_activo(
  p_id_empresa UUID,
  p_id_activo UUID DEFAULT NULL,
  p_estado STRING DEFAULT NULL,
  p_severidad STRING DEFAULT NULL,
  p_texto_busqueda STRING DEFAULT NULL,
  p_limite INT DEFAULT NULL,
  p_cursor_creado_en TIMESTAMPTZ DEFAULT NULL,
  p_cursor_id UUID DEFAULT NULL
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_limite_pagina INT;
  v_pagina JSONB;
  v_hay_mas BOOL;
  v_cantidad INT;
  v_cursor_siguiente JSONB;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  IF p_id_activo IS NOT NULL AND NOT EXISTS (SELECT 1 FROM activo WHERE id = p_id_activo AND id_empresa = p_id_empresa AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'ACTIVO_NO_VALIDO', 'mensaje', 'El activo no existe o no pertenece a la empresa');
  END IF;

  v_limite_pagina := LEAST(GREATEST(COALESCE(p_limite, 20), 1), 100);

  WITH incidencias_ordenadas AS (
    SELECT i.id, i.id_activo, a.codigo AS activo_codigo, a.descripcion AS activo_descripcion,
           i.fecha_reporte, i.titulo, i.descripcion, i.severidad, i.estado, i.fecha_resolucion, i.solucion, i.creado_en,
           row_number() OVER (ORDER BY i.creado_en DESC, i.id DESC) AS orden_en_pagina
    FROM activo_incidencia i
    JOIN activo a ON a.id = i.id_activo
    WHERE i.id_empresa = p_id_empresa
      AND i.eliminado_en IS NULL
      AND (p_id_activo IS NULL OR i.id_activo = p_id_activo)
      AND (p_estado IS NULL OR i.estado = p_estado)
      AND (p_severidad IS NULL OR i.severidad = p_severidad)
      AND (p_texto_busqueda IS NULL OR i.titulo ILIKE '%' || p_texto_busqueda || '%' OR i.descripcion ILIKE '%' || p_texto_busqueda || '%' OR a.codigo ILIKE '%' || p_texto_busqueda || '%' OR a.descripcion ILIKE '%' || p_texto_busqueda || '%')
      AND (p_cursor_creado_en IS NULL OR (i.creado_en, i.id) < (p_cursor_creado_en, p_cursor_id))
    ORDER BY i.creado_en DESC, i.id DESC
    LIMIT v_limite_pagina + 1
  )
  SELECT
    COALESCE(
      jsonb_agg(to_jsonb(incidencias_ordenadas) - 'orden_en_pagina' ORDER BY incidencias_ordenadas.orden_en_pagina)
      FILTER (WHERE incidencias_ordenadas.orden_en_pagina <= v_limite_pagina),
      '[]'::jsonb
    ),
    count(*) > v_limite_pagina
  INTO v_pagina, v_hay_mas
  FROM incidencias_ordenadas;

  v_cantidad := jsonb_array_length(v_pagina);
  IF v_hay_mas AND v_cantidad > 0 THEN
    v_cursor_siguiente := jsonb_build_object(
      'creado_en', v_pagina -> (v_cantidad - 1) -> 'creado_en',
      'id', v_pagina -> (v_cantidad - 1) -> 'id'
    );
  ELSE
    v_cursor_siguiente := NULL;
  END IF;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'INCIDENCIAS_ACTIVO_LISTADAS',
    'mensaje', 'Listado de incidencias obtenido',
    'datos', jsonb_build_object(
      'items', v_pagina,
      'paginacion', jsonb_build_object('limite', v_limite_pagina, 'hay_mas', v_hay_mas, 'cursor_siguiente', v_cursor_siguiente)
    )
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'INCIDENCIAS_ACTIVO_LISTADO_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al listar las incidencias');
END;
$$;

-- >>> fn_listar_intervenciones_herramienta.sql
CREATE OR REPLACE FUNCTION fn_listar_intervenciones_herramienta(
  p_id_empresa UUID,
  p_id_herramienta UUID DEFAULT NULL,
  p_estado STRING DEFAULT NULL,
  p_tipo STRING DEFAULT NULL,
  p_texto_busqueda STRING DEFAULT NULL,
  p_limite INT DEFAULT NULL,
  p_cursor_creado_en TIMESTAMPTZ DEFAULT NULL,
  p_cursor_id UUID DEFAULT NULL
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_limite_pagina INT;
  v_pagina JSONB;
  v_hay_mas BOOL;
  v_cantidad INT;
  v_cursor_siguiente JSONB;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  IF p_id_herramienta IS NOT NULL AND NOT EXISTS (SELECT 1 FROM herramienta WHERE id = p_id_herramienta AND id_empresa = p_id_empresa AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'HERRAMIENTA_NO_VALIDA', 'mensaje', 'La herramienta no existe o no pertenece a la empresa');
  END IF;

  v_limite_pagina := LEAST(GREATEST(COALESCE(p_limite, 20), 1), 100);

  WITH intervenciones_ordenadas AS (
    SELECT iv.id, iv.id_herramienta, h.codigo AS herramienta_codigo, h.descripcion AS herramienta_descripcion,
           iv.tipo, iv.fecha, iv.descripcion, iv.costo, iv.id_responsable, iv.estado, iv.creado_en,
           row_number() OVER (ORDER BY iv.creado_en DESC, iv.id DESC) AS orden_en_pagina
    FROM herramienta_intervencion iv
    JOIN herramienta h ON h.id = iv.id_herramienta
    WHERE iv.id_empresa = p_id_empresa
      AND iv.eliminado_en IS NULL
      AND (p_id_herramienta IS NULL OR iv.id_herramienta = p_id_herramienta)
      AND (p_estado IS NULL OR iv.estado = p_estado)
      AND (p_tipo IS NULL OR iv.tipo = p_tipo)
      AND (p_texto_busqueda IS NULL OR iv.descripcion ILIKE '%' || p_texto_busqueda || '%' OR h.codigo ILIKE '%' || p_texto_busqueda || '%' OR h.descripcion ILIKE '%' || p_texto_busqueda || '%')
      AND (p_cursor_creado_en IS NULL OR (iv.creado_en, iv.id) < (p_cursor_creado_en, p_cursor_id))
    ORDER BY iv.creado_en DESC, iv.id DESC
    LIMIT v_limite_pagina + 1
  )
  SELECT
    COALESCE(
      jsonb_agg(to_jsonb(intervenciones_ordenadas) - 'orden_en_pagina' ORDER BY intervenciones_ordenadas.orden_en_pagina)
      FILTER (WHERE intervenciones_ordenadas.orden_en_pagina <= v_limite_pagina),
      '[]'::jsonb
    ),
    count(*) > v_limite_pagina
  INTO v_pagina, v_hay_mas
  FROM intervenciones_ordenadas;

  v_cantidad := jsonb_array_length(v_pagina);
  IF v_hay_mas AND v_cantidad > 0 THEN
    v_cursor_siguiente := jsonb_build_object(
      'creado_en', v_pagina -> (v_cantidad - 1) -> 'creado_en',
      'id', v_pagina -> (v_cantidad - 1) -> 'id'
    );
  ELSE
    v_cursor_siguiente := NULL;
  END IF;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'INTERVENCIONES_HERRAMIENTA_LISTADAS',
    'mensaje', 'Listado de intervenciones obtenido',
    'datos', jsonb_build_object(
      'items', v_pagina,
      'paginacion', jsonb_build_object('limite', v_limite_pagina, 'hay_mas', v_hay_mas, 'cursor_siguiente', v_cursor_siguiente)
    )
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'INTERVENCIONES_HERRAMIENTA_LISTADO_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al listar las intervenciones');
END;
$$;

-- >>> fn_listar_mantenimientos_activo.sql
CREATE OR REPLACE FUNCTION fn_listar_mantenimientos_activo(
  p_id_empresa UUID,
  p_id_activo UUID DEFAULT NULL,
  p_estado STRING DEFAULT NULL,
  p_tipo STRING DEFAULT NULL,
  p_texto_busqueda STRING DEFAULT NULL,
  p_limite INT DEFAULT NULL,
  p_cursor_creado_en TIMESTAMPTZ DEFAULT NULL,
  p_cursor_id UUID DEFAULT NULL
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_limite_pagina INT;
  v_pagina JSONB;
  v_hay_mas BOOL;
  v_cantidad INT;
  v_cursor_siguiente JSONB;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  IF p_id_activo IS NOT NULL AND NOT EXISTS (SELECT 1 FROM activo WHERE id = p_id_activo AND id_empresa = p_id_empresa AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'ACTIVO_NO_VALIDO', 'mensaje', 'El activo no existe o no pertenece a la empresa');
  END IF;

  v_limite_pagina := LEAST(GREATEST(COALESCE(p_limite, 20), 1), 100);

  WITH mantenimientos_ordenados AS (
    SELECT m.id, m.id_activo, a.codigo AS activo_codigo, a.descripcion AS activo_descripcion,
           m.tipo, m.fecha_programada, m.fecha_ejecucion, m.descripcion, m.costo, m.id_responsable, m.estado, m.creado_en,
           row_number() OVER (ORDER BY m.creado_en DESC, m.id DESC) AS orden_en_pagina
    FROM activo_mantenimiento m
    JOIN activo a ON a.id = m.id_activo
    WHERE m.id_empresa = p_id_empresa
      AND m.eliminado_en IS NULL
      AND (p_id_activo IS NULL OR m.id_activo = p_id_activo)
      AND (p_estado IS NULL OR m.estado = p_estado)
      AND (p_tipo IS NULL OR m.tipo = p_tipo)
      AND (p_texto_busqueda IS NULL OR m.descripcion ILIKE '%' || p_texto_busqueda || '%' OR a.codigo ILIKE '%' || p_texto_busqueda || '%' OR a.descripcion ILIKE '%' || p_texto_busqueda || '%')
      AND (p_cursor_creado_en IS NULL OR (m.creado_en, m.id) < (p_cursor_creado_en, p_cursor_id))
    ORDER BY m.creado_en DESC, m.id DESC
    LIMIT v_limite_pagina + 1
  )
  SELECT
    COALESCE(
      jsonb_agg(to_jsonb(mantenimientos_ordenados) - 'orden_en_pagina' ORDER BY mantenimientos_ordenados.orden_en_pagina)
      FILTER (WHERE mantenimientos_ordenados.orden_en_pagina <= v_limite_pagina),
      '[]'::jsonb
    ),
    count(*) > v_limite_pagina
  INTO v_pagina, v_hay_mas
  FROM mantenimientos_ordenados;

  v_cantidad := jsonb_array_length(v_pagina);
  IF v_hay_mas AND v_cantidad > 0 THEN
    v_cursor_siguiente := jsonb_build_object(
      'creado_en', v_pagina -> (v_cantidad - 1) -> 'creado_en',
      'id', v_pagina -> (v_cantidad - 1) -> 'id'
    );
  ELSE
    v_cursor_siguiente := NULL;
  END IF;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'MANTENIMIENTOS_ACTIVO_LISTADOS',
    'mensaje', 'Listado de mantenimientos obtenido',
    'datos', jsonb_build_object(
      'items', v_pagina,
      'paginacion', jsonb_build_object('limite', v_limite_pagina, 'hay_mas', v_hay_mas, 'cursor_siguiente', v_cursor_siguiente)
    )
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'MANTENIMIENTOS_ACTIVO_LISTADO_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al listar los mantenimientos');
END;
$$;

-- >>> fn_listar_parametros_activos_inversion.sql
CREATE OR REPLACE FUNCTION fn_listar_parametros_activos_inversion(
  p_id_empresa UUID,
  p_categoria STRING DEFAULT NULL,
  p_estado STRING DEFAULT NULL,
  p_texto_busqueda STRING DEFAULT NULL,
  p_limite INT DEFAULT NULL,
  p_cursor_creado_en TIMESTAMPTZ DEFAULT NULL,
  p_cursor_id UUID DEFAULT NULL
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_limite_pagina INT;
  v_pagina JSONB;
  v_hay_mas BOOL;
  v_cantidad INT;
  v_cursor_siguiente JSONB;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  v_limite_pagina := LEAST(GREATEST(COALESCE(p_limite, 50), 1), 200);

  WITH parametros_ordenados AS (
    SELECT p.id, p.categoria, p.clave, p.valor, p.descripcion, p.estado, p.creado_en,
           row_number() OVER (ORDER BY p.creado_en DESC, p.id DESC) AS orden_en_pagina
    FROM parametro_activos_inversion p
    WHERE p.id_empresa = p_id_empresa
      AND p.eliminado_en IS NULL
      AND (p_categoria IS NULL OR p.categoria = p_categoria)
      AND (p_estado IS NULL OR p.estado = p_estado)
      AND (p_texto_busqueda IS NULL OR p.clave ILIKE '%' || p_texto_busqueda || '%' OR p.valor ILIKE '%' || p_texto_busqueda || '%' OR p.descripcion ILIKE '%' || p_texto_busqueda || '%')
      AND (p_cursor_creado_en IS NULL OR (p.creado_en, p.id) < (p_cursor_creado_en, p_cursor_id))
    ORDER BY p.creado_en DESC, p.id DESC
    LIMIT v_limite_pagina + 1
  )
  SELECT
    COALESCE(
      jsonb_agg(to_jsonb(parametros_ordenados) - 'orden_en_pagina' ORDER BY parametros_ordenados.orden_en_pagina)
      FILTER (WHERE parametros_ordenados.orden_en_pagina <= v_limite_pagina),
      '[]'::jsonb
    ),
    count(*) > v_limite_pagina
  INTO v_pagina, v_hay_mas
  FROM parametros_ordenados;

  v_cantidad := jsonb_array_length(v_pagina);
  IF v_hay_mas AND v_cantidad > 0 THEN
    v_cursor_siguiente := jsonb_build_object(
      'creado_en', v_pagina -> (v_cantidad - 1) -> 'creado_en',
      'id', v_pagina -> (v_cantidad - 1) -> 'id'
    );
  ELSE
    v_cursor_siguiente := NULL;
  END IF;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'PARAMETROS_LISTADOS',
    'mensaje', 'Listado de parametros obtenido',
    'datos', jsonb_build_object(
      'items', v_pagina,
      'paginacion', jsonb_build_object('limite', v_limite_pagina, 'hay_mas', v_hay_mas, 'cursor_siguiente', v_cursor_siguiente)
    )
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'PARAMETROS_LISTADO_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al listar los parametros');
END;
$$;

-- >>> fn_obtener_detalle_ajuste_recuperacion.sql
CREATE OR REPLACE FUNCTION fn_obtener_detalle_ajuste_recuperacion(
  p_id_empresa UUID,
  p_id_ajuste UUID
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_detalle JSONB;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  SELECT to_jsonb(d) INTO v_detalle
  FROM (
    SELECT aj.id, aj.id_activo, a.codigo AS activo_codigo, a.descripcion AS activo_descripcion,
           aj.id_contrato, aj.id_periodo, aj.fecha, aj.monto_ajuste, aj.motivo, aj.estado, aj.fecha_resolucion,
           aj.creado_en, aj.creado_por_usuario_id, aj.actualizado_en, aj.actualizado_por_usuario_id
    FROM recuperacion_ajuste aj
    JOIN activo a ON a.id = aj.id_activo
    WHERE aj.id = p_id_ajuste AND aj.id_empresa = p_id_empresa AND aj.eliminado_en IS NULL
  ) d;

  IF v_detalle IS NULL THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'AJUSTE_RECUPERACION_NO_ENCONTRADO', 'mensaje', 'El ajuste no existe o no pertenece a la empresa');
  END IF;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'AJUSTE_RECUPERACION_DETALLE',
    'mensaje', 'Detalle del ajuste obtenido',
    'datos', v_detalle
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'AJUSTE_RECUPERACION_DETALLE_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al obtener el detalle del ajuste');
END;
$$;

-- >>> fn_obtener_detalle_incidencia_activo.sql
CREATE OR REPLACE FUNCTION fn_obtener_detalle_incidencia_activo(
  p_id_empresa UUID,
  p_id_incidencia UUID
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_detalle JSONB;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  SELECT to_jsonb(d) INTO v_detalle
  FROM (
    SELECT i.id, i.id_activo, a.codigo AS activo_codigo, a.descripcion AS activo_descripcion,
           i.fecha_reporte, i.titulo, i.descripcion, i.severidad, i.estado, i.fecha_resolucion, i.solucion,
           i.creado_en, i.creado_por_usuario_id, i.actualizado_en, i.actualizado_por_usuario_id
    FROM activo_incidencia i
    JOIN activo a ON a.id = i.id_activo
    WHERE i.id = p_id_incidencia AND i.id_empresa = p_id_empresa AND i.eliminado_en IS NULL
  ) d;

  IF v_detalle IS NULL THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'INCIDENCIA_ACTIVO_NO_ENCONTRADA', 'mensaje', 'La incidencia no existe o no pertenece a la empresa');
  END IF;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'INCIDENCIA_ACTIVO_DETALLE',
    'mensaje', 'Detalle de la incidencia obtenido',
    'datos', v_detalle
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'INCIDENCIA_ACTIVO_DETALLE_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al obtener el detalle de la incidencia');
END;
$$;

-- >>> fn_obtener_detalle_intervencion_herramienta.sql
CREATE OR REPLACE FUNCTION fn_obtener_detalle_intervencion_herramienta(
  p_id_empresa UUID,
  p_id_intervencion UUID
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_detalle JSONB;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  SELECT to_jsonb(d) INTO v_detalle
  FROM (
    SELECT iv.id, iv.id_herramienta, h.codigo AS herramienta_codigo, h.descripcion AS herramienta_descripcion,
           iv.tipo, iv.fecha, iv.descripcion, iv.costo, iv.id_responsable, iv.estado,
           iv.creado_en, iv.creado_por_usuario_id, iv.actualizado_en, iv.actualizado_por_usuario_id
    FROM herramienta_intervencion iv
    JOIN herramienta h ON h.id = iv.id_herramienta
    WHERE iv.id = p_id_intervencion AND iv.id_empresa = p_id_empresa AND iv.eliminado_en IS NULL
  ) d;

  IF v_detalle IS NULL THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'INTERVENCION_HERRAMIENTA_NO_ENCONTRADA', 'mensaje', 'La intervencion no existe o no pertenece a la empresa');
  END IF;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'INTERVENCION_HERRAMIENTA_DETALLE',
    'mensaje', 'Detalle de la intervencion obtenido',
    'datos', v_detalle
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'INTERVENCION_HERRAMIENTA_DETALLE_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al obtener el detalle de la intervencion');
END;
$$;

-- >>> fn_obtener_detalle_mantenimiento_activo.sql
CREATE OR REPLACE FUNCTION fn_obtener_detalle_mantenimiento_activo(
  p_id_empresa UUID,
  p_id_mantenimiento UUID
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_detalle JSONB;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  SELECT to_jsonb(d) INTO v_detalle
  FROM (
    SELECT m.id, m.id_activo, a.codigo AS activo_codigo, a.descripcion AS activo_descripcion,
           m.tipo, m.fecha_programada, m.fecha_ejecucion, m.descripcion, m.costo, m.id_responsable, m.estado,
           m.creado_en, m.creado_por_usuario_id, m.actualizado_en, m.actualizado_por_usuario_id
    FROM activo_mantenimiento m
    JOIN activo a ON a.id = m.id_activo
    WHERE m.id = p_id_mantenimiento AND m.id_empresa = p_id_empresa AND m.eliminado_en IS NULL
  ) d;

  IF v_detalle IS NULL THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'MANTENIMIENTO_ACTIVO_NO_ENCONTRADO', 'mensaje', 'El mantenimiento no existe o no pertenece a la empresa');
  END IF;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'MANTENIMIENTO_ACTIVO_DETALLE',
    'mensaje', 'Detalle del mantenimiento obtenido',
    'datos', v_detalle
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'MANTENIMIENTO_ACTIVO_DETALLE_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al obtener el detalle del mantenimiento');
END;
$$;

-- >>> fn_obtener_detalle_parametro_activos_inversion.sql
CREATE OR REPLACE FUNCTION fn_obtener_detalle_parametro_activos_inversion(
  p_id_empresa UUID,
  p_id_parametro UUID
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_detalle JSONB;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  SELECT to_jsonb(d) INTO v_detalle
  FROM (
    SELECT p.id, p.categoria, p.clave, p.valor, p.descripcion, p.estado,
           p.creado_en, p.creado_por_usuario_id, p.actualizado_en, p.actualizado_por_usuario_id
    FROM parametro_activos_inversion p
    WHERE p.id = p_id_parametro AND p.id_empresa = p_id_empresa AND p.eliminado_en IS NULL
  ) d;

  IF v_detalle IS NULL THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'PARAMETRO_NO_ENCONTRADO', 'mensaje', 'El parametro no existe o no pertenece a la empresa');
  END IF;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'PARAMETRO_DETALLE',
    'mensaje', 'Detalle del parametro obtenido',
    'datos', v_detalle
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'PARAMETRO_DETALLE_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al obtener el detalle del parametro');
END;
$$;

-- >>> fn_reactivar_clasificacion_activo.sql
CREATE OR REPLACE FUNCTION fn_reactivar_clasificacion_activo(
  p_id_empresa UUID,
  p_id_usuario_accion UUID,
  p_id_clasificacion_activo UUID
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_estado STRING;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  SELECT estado INTO v_estado
  FROM clasificacion_activo
  WHERE id = p_id_clasificacion_activo AND id_empresa = p_id_empresa AND eliminado_en IS NULL;

  IF v_estado IS NULL THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'CLASIFICACION_ACTIVO_NO_ENCONTRADA', 'mensaje', 'La clasificacion de activo no existe o no pertenece a la empresa');
  END IF;

  IF v_estado <> 'INACTIVO' THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'CLASIFICACION_ACTIVO_NO_ESTA_INACTIVA', 'mensaje', 'La clasificacion de activo no esta inactiva, no se puede reactivar');
  END IF;

  UPDATE clasificacion_activo
  SET estado = 'ACTIVO', actualizado_en = now(), actualizado_por_usuario_id = p_id_usuario_accion
  WHERE id = p_id_clasificacion_activo AND id_empresa = p_id_empresa;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'CLASIFICACION_ACTIVO_REACTIVADA',
    'mensaje', 'La clasificacion de activo fue reactivada correctamente',
    'datos', jsonb_build_object('id_clasificacion_activo', p_id_clasificacion_activo, 'estado', 'ACTIVO')
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'CLASIFICACION_ACTIVO_REACTIVACION_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al reactivar la clasificacion de activo');
END;
$$;

-- >>> fn_reactivar_herramienta.sql
CREATE OR REPLACE FUNCTION fn_reactivar_herramienta(
  p_id_empresa UUID,
  p_id_usuario_accion UUID,
  p_id_herramienta UUID
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_estado STRING;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  SELECT estado INTO v_estado
  FROM herramienta
  WHERE id = p_id_herramienta AND id_empresa = p_id_empresa AND eliminado_en IS NULL;

  IF v_estado IS NULL THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'HERRAMIENTA_NO_ENCONTRADA', 'mensaje', 'La herramienta no existe o no pertenece a la empresa');
  END IF;

  IF v_estado <> 'BAJA' THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'HERRAMIENTA_NO_ESTA_DADA_DE_BAJA', 'mensaje', 'La herramienta no esta dada de baja, no se puede reactivar');
  END IF;

  UPDATE herramienta
  SET estado = 'ACTIVO', actualizado_en = now(), actualizado_por_usuario_id = p_id_usuario_accion
  WHERE id = p_id_herramienta AND id_empresa = p_id_empresa;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'HERRAMIENTA_REACTIVADA',
    'mensaje', 'La herramienta fue reactivada correctamente',
    'datos', jsonb_build_object('id_herramienta', p_id_herramienta, 'estado', 'ACTIVO')
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'HERRAMIENTA_REACTIVACION_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al reactivar la herramienta');
END;
$$;

-- >>> fn_reactivar_parametro_activos_inversion.sql
CREATE OR REPLACE FUNCTION fn_reactivar_parametro_activos_inversion(
  p_id_empresa UUID,
  p_id_usuario_accion UUID,
  p_id_parametro UUID
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_estado STRING;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  SELECT estado INTO v_estado
  FROM parametro_activos_inversion
  WHERE id = p_id_parametro AND id_empresa = p_id_empresa AND eliminado_en IS NULL;

  IF v_estado IS NULL THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'PARAMETRO_NO_ENCONTRADO', 'mensaje', 'El parametro no existe o no pertenece a la empresa');
  END IF;

  IF v_estado <> 'INACTIVO' THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'PARAMETRO_NO_ESTA_INACTIVO', 'mensaje', 'El parametro no esta inactivo, no se puede reactivar');
  END IF;

  UPDATE parametro_activos_inversion
  SET estado = 'ACTIVO', actualizado_en = now(), actualizado_por_usuario_id = p_id_usuario_accion
  WHERE id = p_id_parametro AND id_empresa = p_id_empresa;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'PARAMETRO_REACTIVADO',
    'mensaje', 'El parametro fue reactivado correctamente',
    'datos', jsonb_build_object('id_parametro', p_id_parametro, 'estado', 'ACTIVO')
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'PARAMETRO_REACTIVACION_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al reactivar el parametro');
END;
$$;

-- >>> fn_reactivar_tipo_adquisicion_activo.sql
CREATE OR REPLACE FUNCTION fn_reactivar_tipo_adquisicion_activo(
  p_id_empresa UUID,
  p_id_usuario_accion UUID,
  p_id_tipo_adquisicion_activo UUID
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_estado STRING;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  SELECT estado INTO v_estado
  FROM tipo_adquisicion_activo
  WHERE id = p_id_tipo_adquisicion_activo AND id_empresa = p_id_empresa AND eliminado_en IS NULL;

  IF v_estado IS NULL THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'TIPO_ADQUISICION_ACTIVO_NO_ENCONTRADO', 'mensaje', 'El tipo de adquisicion de activo no existe o no pertenece a la empresa');
  END IF;

  IF v_estado <> 'INACTIVO' THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'TIPO_ADQUISICION_ACTIVO_NO_ESTA_INACTIVO', 'mensaje', 'El tipo de adquisicion de activo no esta inactivo, no se puede reactivar');
  END IF;

  UPDATE tipo_adquisicion_activo
  SET estado = 'ACTIVO', actualizado_en = now(), actualizado_por_usuario_id = p_id_usuario_accion
  WHERE id = p_id_tipo_adquisicion_activo AND id_empresa = p_id_empresa;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'TIPO_ADQUISICION_ACTIVO_REACTIVADO',
    'mensaje', 'El tipo de adquisicion de activo fue reactivado correctamente',
    'datos', jsonb_build_object('id_tipo_adquisicion_activo', p_id_tipo_adquisicion_activo, 'estado', 'ACTIVO')
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'TIPO_ADQUISICION_ACTIVO_REACTIVACION_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al reactivar el tipo de adquisicion de activo');
END;
$$;

-- >>> fn_reactivar_tipo_herramienta.sql
CREATE OR REPLACE FUNCTION fn_reactivar_tipo_herramienta(
  p_id_empresa UUID,
  p_id_usuario_accion UUID,
  p_id_tipo_herramienta UUID
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_estado STRING;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  SELECT estado INTO v_estado
  FROM tipo_herramienta
  WHERE id = p_id_tipo_herramienta AND id_empresa = p_id_empresa AND eliminado_en IS NULL;

  IF v_estado IS NULL THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'TIPO_HERRAMIENTA_NO_ENCONTRADO', 'mensaje', 'El tipo de herramienta no existe o no pertenece a la empresa');
  END IF;

  IF v_estado <> 'INACTIVO' THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'TIPO_HERRAMIENTA_NO_ESTA_INACTIVO', 'mensaje', 'El tipo de herramienta no esta inactivo, no se puede reactivar');
  END IF;

  UPDATE tipo_herramienta
  SET estado = 'ACTIVO', actualizado_en = now(), actualizado_por_usuario_id = p_id_usuario_accion
  WHERE id = p_id_tipo_herramienta AND id_empresa = p_id_empresa;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'TIPO_HERRAMIENTA_REACTIVADO',
    'mensaje', 'El tipo de herramienta fue reactivado correctamente',
    'datos', jsonb_build_object('id_tipo_herramienta', p_id_tipo_herramienta, 'estado', 'ACTIVO')
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'TIPO_HERRAMIENTA_REACTIVACION_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al reactivar el tipo de herramienta');
END;
$$;

-- >>> fn_rechazar_ajuste_recuperacion.sql
CREATE OR REPLACE FUNCTION fn_rechazar_ajuste_recuperacion(
  p_id_empresa UUID,
  p_id_usuario_accion UUID,
  p_id_ajuste UUID
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_estado STRING;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  SELECT estado INTO v_estado
  FROM recuperacion_ajuste
  WHERE id = p_id_ajuste AND id_empresa = p_id_empresa AND eliminado_en IS NULL;

  IF v_estado IS NULL THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'AJUSTE_RECUPERACION_NO_ENCONTRADO', 'mensaje', 'El ajuste no existe o no pertenece a la empresa');
  END IF;

  IF v_estado <> 'PENDIENTE' THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'AJUSTE_RECUPERACION_NO_PENDIENTE', 'mensaje', 'Solo se puede rechazar un ajuste pendiente');
  END IF;

  UPDATE recuperacion_ajuste
  SET estado = 'RECHAZADO', fecha_resolucion = current_date, actualizado_en = now(), actualizado_por_usuario_id = p_id_usuario_accion
  WHERE id = p_id_ajuste AND id_empresa = p_id_empresa;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'AJUSTE_RECUPERACION_RECHAZADO',
    'mensaje', 'El ajuste fue rechazado correctamente',
    'datos', jsonb_build_object('id_ajuste', p_id_ajuste, 'estado', 'RECHAZADO')
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'AJUSTE_RECUPERACION_RECHAZO_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al rechazar el ajuste');
END;
$$;

-- >>> fn_registrar_ajuste_recuperacion.sql
CREATE OR REPLACE FUNCTION fn_registrar_ajuste_recuperacion(
  p_id_empresa UUID,
  p_id_usuario_accion UUID,
  p_id_activo UUID,
  p_fecha DATE,
  p_monto_ajuste DECIMAL,
  p_motivo STRING,
  p_id_contrato UUID DEFAULT NULL,
  p_id_periodo UUID DEFAULT NULL
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_id_ajuste UUID;
  v_periodo_anio INT2;
  v_periodo_mes INT2;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  IF NOT EXISTS (SELECT 1 FROM activo WHERE id = p_id_activo AND id_empresa = p_id_empresa AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'ACTIVO_NO_VALIDO', 'mensaje', 'El activo no existe o no pertenece a la empresa');
  END IF;

  IF p_id_contrato IS NOT NULL AND NOT EXISTS (SELECT 1 FROM contrato WHERE id = p_id_contrato AND id_empresa = p_id_empresa AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'CONTRATO_NO_VALIDO', 'mensaje', 'El contrato no existe o no pertenece a la empresa');
  END IF;

  IF p_id_periodo IS NOT NULL AND NOT EXISTS (SELECT 1 FROM periodo WHERE id = p_id_periodo AND id_empresa = p_id_empresa AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'PERIODO_NO_VALIDO', 'mensaje', 'El periodo no existe o no pertenece a la empresa');
  END IF;

  IF p_fecha IS NULL THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'FECHA_OBLIGATORIA', 'mensaje', 'La fecha del ajuste es obligatoria');
  END IF;

  IF p_id_periodo IS NOT NULL THEN
    SELECT anio, mes INTO v_periodo_anio, v_periodo_mes
    FROM periodo
    WHERE id = p_id_periodo AND id_empresa = p_id_empresa AND eliminado_en IS NULL;

    IF EXTRACT(YEAR FROM p_fecha)::INT <> v_periodo_anio OR EXTRACT(MONTH FROM p_fecha)::INT <> v_periodo_mes THEN
      RETURN jsonb_build_object('exito', false, 'codigo_error', 'PERIODO_FECHA_INCOHERENTE', 'mensaje', 'La fecha del ajuste no corresponde al periodo seleccionado (deben ser del mismo mes y anio)');
    END IF;
  END IF;

  IF p_monto_ajuste IS NULL OR p_monto_ajuste = 0 THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'MONTO_INVALIDO', 'mensaje', 'El monto del ajuste debe ser distinto de cero');
  END IF;

  IF p_motivo IS NULL OR char_length(trim(p_motivo)) = 0 THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'MOTIVO_OBLIGATORIO', 'mensaje', 'El motivo del ajuste es obligatorio');
  END IF;

  INSERT INTO recuperacion_ajuste (
    id_empresa, id_activo, id_contrato, id_periodo, fecha, monto_ajuste, motivo, estado, creado_por_usuario_id
  ) VALUES (
    p_id_empresa, p_id_activo, p_id_contrato, p_id_periodo, p_fecha, p_monto_ajuste, trim(p_motivo), 'PENDIENTE', p_id_usuario_accion
  ) RETURNING id INTO v_id_ajuste;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'AJUSTE_RECUPERACION_REGISTRADO',
    'mensaje', 'El ajuste de recuperacion fue registrado correctamente',
    'datos', jsonb_build_object('id_ajuste', v_id_ajuste)
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'AJUSTE_RECUPERACION_REGISTRO_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al registrar el ajuste de recuperacion');
END;
$$;

-- >>> fn_registrar_incidencia_activo.sql
CREATE OR REPLACE FUNCTION fn_registrar_incidencia_activo(
  p_id_empresa UUID,
  p_id_usuario_accion UUID,
  p_id_activo UUID,
  p_fecha_reporte DATE,
  p_titulo STRING,
  p_descripcion STRING DEFAULT NULL,
  p_severidad STRING DEFAULT 'MEDIA'
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_id_incidencia UUID;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  IF NOT EXISTS (SELECT 1 FROM activo WHERE id = p_id_activo AND id_empresa = p_id_empresa AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'ACTIVO_NO_VALIDO', 'mensaje', 'El activo no existe o no pertenece a la empresa');
  END IF;

  IF p_fecha_reporte IS NULL THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'FECHA_OBLIGATORIA', 'mensaje', 'La fecha de reporte es obligatoria');
  END IF;

  IF p_titulo IS NULL OR char_length(trim(p_titulo)) = 0 THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'TITULO_OBLIGATORIO', 'mensaje', 'El titulo de la incidencia es obligatorio');
  END IF;

  IF COALESCE(p_severidad, 'MEDIA') NOT IN ('BAJA', 'MEDIA', 'ALTA', 'CRITICA') THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'SEVERIDAD_NO_VALIDA', 'mensaje', 'La severidad no es valida');
  END IF;

  INSERT INTO activo_incidencia (
    id_empresa, id_activo, fecha_reporte, titulo, descripcion, severidad, estado, creado_por_usuario_id
  ) VALUES (
    p_id_empresa, p_id_activo, p_fecha_reporte, trim(p_titulo), NULLIF(trim(p_descripcion), ''), COALESCE(p_severidad, 'MEDIA'), 'ABIERTA', p_id_usuario_accion
  ) RETURNING id INTO v_id_incidencia;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'INCIDENCIA_ACTIVO_REGISTRADA',
    'mensaje', 'La incidencia fue registrada correctamente',
    'datos', jsonb_build_object('id_incidencia', v_id_incidencia)
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'INCIDENCIA_ACTIVO_REGISTRO_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al registrar la incidencia');
END;
$$;

-- >>> fn_registrar_intervencion_herramienta.sql
CREATE OR REPLACE FUNCTION fn_registrar_intervencion_herramienta(
  p_id_empresa UUID,
  p_id_usuario_accion UUID,
  p_id_herramienta UUID,
  p_tipo STRING,
  p_fecha DATE,
  p_descripcion STRING DEFAULT NULL,
  p_costo DECIMAL DEFAULT NULL
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_id_intervencion UUID;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  IF NOT EXISTS (SELECT 1 FROM herramienta WHERE id = p_id_herramienta AND id_empresa = p_id_empresa AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'HERRAMIENTA_NO_VALIDA', 'mensaje', 'La herramienta no existe o no pertenece a la empresa');
  END IF;

  IF p_tipo IS NULL OR p_tipo NOT IN ('REPARACION', 'CALIBRACION', 'REVISION') THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'TIPO_INTERVENCION_NO_VALIDO', 'mensaje', 'El tipo de intervencion no es valido');
  END IF;

  IF p_fecha IS NULL THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'FECHA_OBLIGATORIA', 'mensaje', 'La fecha de la intervencion es obligatoria');
  END IF;

  IF COALESCE(p_costo, 0) < 0 THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'COSTO_INVALIDO', 'mensaje', 'El costo no puede ser negativo');
  END IF;

  INSERT INTO herramienta_intervencion (
    id_empresa, id_herramienta, tipo, fecha, descripcion, costo, estado, creado_por_usuario_id
  ) VALUES (
    p_id_empresa, p_id_herramienta, p_tipo, p_fecha, NULLIF(trim(p_descripcion), ''), p_costo, 'REGISTRADA', p_id_usuario_accion
  ) RETURNING id INTO v_id_intervencion;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'INTERVENCION_HERRAMIENTA_REGISTRADA',
    'mensaje', 'La intervencion fue registrada correctamente',
    'datos', jsonb_build_object('id_intervencion', v_id_intervencion)
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'INTERVENCION_HERRAMIENTA_REGISTRO_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al registrar la intervencion');
END;
$$;

-- >>> fn_registrar_mantenimiento_activo.sql
CREATE OR REPLACE FUNCTION fn_registrar_mantenimiento_activo(
  p_id_empresa UUID,
  p_id_usuario_accion UUID,
  p_id_activo UUID,
  p_tipo STRING,
  p_fecha_programada DATE,
  p_descripcion STRING,
  p_costo DECIMAL DEFAULT NULL,
  p_id_responsable UUID DEFAULT NULL
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_id_mantenimiento UUID;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  IF NOT EXISTS (SELECT 1 FROM activo WHERE id = p_id_activo AND id_empresa = p_id_empresa AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'ACTIVO_NO_VALIDO', 'mensaje', 'El activo no existe o no pertenece a la empresa');
  END IF;

  IF p_tipo IS NULL OR p_tipo NOT IN ('PREVENTIVO', 'CORRECTIVO') THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'TIPO_MANTENIMIENTO_NO_VALIDO', 'mensaje', 'El tipo de mantenimiento debe ser PREVENTIVO o CORRECTIVO');
  END IF;

  IF p_fecha_programada IS NULL THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'FECHA_OBLIGATORIA', 'mensaje', 'La fecha programada del mantenimiento es obligatoria');
  END IF;

  IF p_descripcion IS NULL OR char_length(trim(p_descripcion)) = 0 THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'DESCRIPCION_OBLIGATORIA', 'mensaje', 'La descripcion del mantenimiento es obligatoria');
  END IF;

  IF COALESCE(p_costo, 0) < 0 THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'COSTO_INVALIDO', 'mensaje', 'El costo no puede ser negativo');
  END IF;

  IF p_id_responsable IS NOT NULL AND NOT EXISTS (SELECT 1 FROM usuario WHERE id = p_id_responsable) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'RESPONSABLE_NO_VALIDO', 'mensaje', 'El responsable no existe');
  END IF;

  INSERT INTO activo_mantenimiento (
    id_empresa, id_activo, tipo, fecha_programada, descripcion, costo, id_responsable, estado, creado_por_usuario_id
  ) VALUES (
    p_id_empresa, p_id_activo, p_tipo, p_fecha_programada, trim(p_descripcion), p_costo, p_id_responsable, 'PROGRAMADO', p_id_usuario_accion
  ) RETURNING id INTO v_id_mantenimiento;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'MANTENIMIENTO_ACTIVO_REGISTRADO',
    'mensaje', 'El mantenimiento fue registrado correctamente',
    'datos', jsonb_build_object('id_mantenimiento', v_id_mantenimiento)
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'MANTENIMIENTO_ACTIVO_REGISTRO_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al registrar el mantenimiento');
END;
$$;

-- >>> fn_registrar_parametro_activos_inversion.sql
CREATE OR REPLACE FUNCTION fn_registrar_parametro_activos_inversion(
  p_id_empresa UUID,
  p_id_usuario_accion UUID,
  p_categoria STRING,
  p_clave STRING,
  p_valor STRING,
  p_descripcion STRING DEFAULT NULL
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_id_parametro UUID;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  IF p_categoria IS NULL OR p_categoria NOT IN ('PARAMETRO_ACTIVO', 'REGLA_RECUPERACION', 'REGLA_MAESTRA', 'BASE_RECUPERACION', 'DISTRIBUCION') THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'CATEGORIA_NO_VALIDA', 'mensaje', 'La categoria del parametro no es valida');
  END IF;

  IF p_clave IS NULL OR char_length(trim(p_clave)) = 0 THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'CLAVE_OBLIGATORIA', 'mensaje', 'La clave del parametro es obligatoria');
  END IF;

  IF p_valor IS NULL OR char_length(trim(p_valor)) = 0 THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'VALOR_OBLIGATORIO', 'mensaje', 'El valor del parametro es obligatorio');
  END IF;

  IF EXISTS (SELECT 1 FROM parametro_activos_inversion WHERE id_empresa = p_id_empresa AND categoria = p_categoria AND clave = trim(p_clave) AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'PARAMETRO_CLAVE_DUPLICADA', 'mensaje', 'Ya existe un parametro con esa clave en la categoria');
  END IF;

  INSERT INTO parametro_activos_inversion (
    id_empresa, categoria, clave, valor, descripcion, estado, creado_por_usuario_id
  ) VALUES (
    p_id_empresa, p_categoria, trim(p_clave), trim(p_valor), NULLIF(trim(p_descripcion), ''), 'ACTIVO', p_id_usuario_accion
  ) RETURNING id INTO v_id_parametro;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'PARAMETRO_REGISTRADO',
    'mensaje', 'El parametro fue registrado correctamente',
    'datos', jsonb_build_object('id_parametro', v_id_parametro)
  );
EXCEPTION
  WHEN unique_violation THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'PARAMETRO_CLAVE_DUPLICADA', 'mensaje', 'Ya existe un parametro con esa clave en la categoria');
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'PARAMETRO_REGISTRO_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al registrar el parametro');
END;
$$;

-- >>> fn_resolver_incidencia_activo.sql
CREATE OR REPLACE FUNCTION fn_resolver_incidencia_activo(
  p_id_empresa UUID,
  p_id_usuario_accion UUID,
  p_id_incidencia UUID,
  p_solucion STRING,
  p_fecha_resolucion DATE DEFAULT NULL
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_estado STRING;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  SELECT estado INTO v_estado
  FROM activo_incidencia
  WHERE id = p_id_incidencia AND id_empresa = p_id_empresa AND eliminado_en IS NULL;

  IF v_estado IS NULL THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'INCIDENCIA_ACTIVO_NO_ENCONTRADA', 'mensaje', 'La incidencia no existe o no pertenece a la empresa');
  END IF;

  IF v_estado NOT IN ('ABIERTA', 'EN_PROCESO') THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'INCIDENCIA_ACTIVO_NO_RESOLUBLE', 'mensaje', 'Solo se puede resolver una incidencia abierta o en proceso');
  END IF;

  IF p_solucion IS NULL OR char_length(trim(p_solucion)) = 0 THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'SOLUCION_OBLIGATORIA', 'mensaje', 'La solucion es obligatoria para resolver la incidencia');
  END IF;

  UPDATE activo_incidencia
  SET estado = 'RESUELTA', solucion = trim(p_solucion), fecha_resolucion = COALESCE(p_fecha_resolucion, current_date),
      actualizado_en = now(), actualizado_por_usuario_id = p_id_usuario_accion
  WHERE id = p_id_incidencia AND id_empresa = p_id_empresa;

  RETURN jsonb_build_object(
    'exito', true,
    'codigo', 'INCIDENCIA_ACTIVO_RESUELTA',
    'mensaje', 'La incidencia fue resuelta correctamente',
    'datos', jsonb_build_object('id_incidencia', p_id_incidencia, 'estado', 'RESUELTA')
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'INCIDENCIA_ACTIVO_RESOLUCION_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al resolver la incidencia');
END;
$$;

