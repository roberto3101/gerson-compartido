-- ====================================================================
-- sesga_global_completo.sql  -  BD GLOBAL: todas las capacidades de todos los grupos
-- Generada desde codeplexMaster para pruebas locales (CockroachDB v26).
-- Contenido: 47 tablas + 1 stub + todos los indices + 37 funciones que compilan
--            + SEMILLAS DEMO al final que pueblan las 48 tablas (TODAS las entidades):
--              empresa vigente, usuario, usuario_empresa, 2 periodos, roles/permisos;
--              catalogos completos (estado/tipo de contrato, grupo de actividad, zona,
--              cliente, contrato, tipo/clasificacion de gasto, linea de servicio,
--              clasificaciones/tipos de activo y herramienta); y datos transaccionales
--              demo de cada capacidad: proveedor, gasto directo, ERP importacion y detalle,
--              contrato_zona, porcentaje de distribucion, gasto fijo, gasto inicial,
--              operario, rubro, produccion mensual y detalle, facturacion contractual y
--              detalle, valorizacion mensual y complementaria con sus detalles, 2 activos,
--              herramienta, asignacion, trabajo, traslado, movimiento de herramienta,
--              recuperacion de inversion, penalidad, provision, cierre mensual y usuario_rol.
--              Verificado: las 48 tablas quedan pobladas y el script carga sin errores en v26.
--
-- USO (Gerson): ejecutar UNA sola vez en CockroachDB v26 y queda lista para usar:
--   cockroach sql --insecure --host=localhost:26260 --file sesga_global_completo.sql
--   (el script hace DROP/CREATE de la base sesga_global al inicio; no hay que pararse en ninguna BD)
--
-- FIXES LOCALES aplicados a SQL ajeno que no compilaba (avisar a sus autores):
--   gobierno_central/entidad_empresa.sql        llaves { } en vez de ( ), CONTRAINT x3
--   gobierno_central/entidad_periodo.sql        comas faltantes entre columnas y constraints
--   gobierno_central/entidad_permiso.sql        id sin tipo UUID, ON DELETE incompleto, coma sobrante
--   gobierno_central/entidad_usuario_empresa.sql coma sobrante antes del cierre
--   contratos/entidad_zona.sql                  indice duplicado uq_zona_empresa_codigo
--   contratos/entidad_grupo_actividad.sql       indice duplicado uq_grupo_actividad_empresa_codigo
--   contratos/entidad_contrato_gasto_fijo.sql   coma faltante entre checks
--   facturacion/entidad_valorizacion_*.sql      comas faltantes entre constraints
--   stub local: zona_contratada (facturacion_contractual la referencia y no existe en master)
--
-- FUNCIONES AJENAS EXCLUIDAS (no compilan en CockroachDB v26):
--   contratos/fn_crear_contrato.sql            -> usa "return" en vez de RETURNS
--   contratos/fn_actualizar_contrato.sql       -> usa "return" en vez de RETURNS
--   costeo_directo/fn_listar_clasificaciones_gasto.sql -> usa SQLERRM (no existe en CockroachDB)
--   costeo_directo/fn_listar_gastos_directos.sql       -> usa SQLERRM
--   costeo_directo/fn_listar_proveedores.sql           -> usa SQLERRM
--   costeo_directo/fn_registrar_gasto_directo.sql      -> EXCEPTION de retry no soportada
--   gobierno_central/fn_crear_empresa.sql      -> error de sintaxis
--   gobierno_central/fn_actualizar_empresa.sql -> error de sintaxis
--   gobierno_central/fn_dar_de_baja_empresa.sql -> usa SQLERRM
--   gobierno_central/fn_reactivar_empresa.sql  -> usa SQLERRM
--   gobierno_central/fn_listar_empresas.sql    -> usa SQLERRM
--   gobierno_central/fn_crear_usuario.sql      -> parametros con default mal ordenados
--   gobierno_central/fn_actualizar_usuario.sql -> parametros con default mal ordenados
--   gobierno_central/fn_dar_de_baja_usuario.sql -> usa SQLERRM
--   gobierno_central/fn_reactivar_usuario.sql  -> usa SQLERRM
--   gobierno_central/fn_listar_usuarios.sql    -> error de sintaxis
--   gobierno_central/fn_listar_roles.sql       -> usa SQLERRM
--   gobierno_central/fn_reactivar_rol.sql      -> apunta a base db_sesga_reyser inexistente
--   gobierno_central/fn_agregar_rol_a_usuario.sql -> error de sintaxis
-- ====================================================================
DROP DATABASE IF EXISTS sesga_global CASCADE;
CREATE DATABASE sesga_global;
SET database = sesga_global;

CREATE TABLE zona_contratada (id UUID PRIMARY KEY DEFAULT gen_random_uuid());

-- ==================== TABLAS (orden de dependencias) ====================
-- >>> esquema/gobierno_central/entidad_usuario.sql
CREATE TABLE usuario (
  id                          UUID        PRIMARY KEY NOT NULL DEFAULT gen_random_uuid(),
  correo_electronico          STRING      NOT NULL UNIQUE,
  clave_hash                  STRING      NOT NULL,
  nombres                     STRING      NOT NULL,
  apellidos                   STRING      NOT NULL,
  telefono                    STRING,
  estado                      STRING      NOT NULL DEFAULT 'ACTIVO',
  creado_en                   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  actualizado_en              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  eliminado_en                TIMESTAMPTZ NULL,
  creado_por_usuario_id       UUID,
  actualizado_por_usuario_id  UUID,
  eliminado_por_usuario_id    UUID,

  CONSTRAINT ck_usuario_estado
    CHECK (estado IN ('ACTIVO', 'SUSPENDIDO')),
  
  CONSTRAINT ck_usuario_correo_formato
    CHECK (correo_electronico SIMILAR TO '_%@_%._%')
);

ALTER TABLE usuario
ADD CONSTRAINT fk_usuario_creado_por_usuario
FOREIGN KEY (creado_por_usuario_id) REFERENCES usuario(id) ON DELETE RESTRICT;

ALTER TABLE usuario
ADD CONSTRAINT fk_usuario_actualizado_por_usuario
FOREIGN KEY (actualizado_por_usuario_id) REFERENCES usuario(id) ON DELETE RESTRICT;

ALTER TABLE usuario
ADD CONSTRAINT fk_usuario_eliminado_por_usuario
FOREIGN KEY (eliminado_por_usuario_id) REFERENCES usuario(id) ON DELETE RESTRICT;

-- >>> esquema/gobierno_central/entidad_empresa.sql
CREATE TABLE empresa (

	id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  ruc STRING NOT NULL UNIQUE,
  razon_social STRING NOT NULL,
  nombre_comercial STRING,
  direccion STRING,
  telefono STRING,
  correo_electronico STRING,
  estado STRING NOT NULL DEFAULT 'ACTIVO',
  creado_en TIMESTAMPTZ NOT NULL DEFAULT now(),
  actualizado_en TIMESTAMPTZ NOT NULL DEFAULT now(),
  eliminado_en TIMESTAMPTZ NULL,
  creado_por_usuario_id UUID,
  actualizado_por_usuario_id UUID,
  eliminado_por_usuario_id UUID,
  
  CONSTRAINT ck_empresa_estado
    CHECK (estado IN ('ACTIVO', 'SUSPENDIDO')),
    
  CONSTRAINT ck_empresa_ruc_longitud
    CHECK (char_length(ruc) = 11)  
); 
ALTER TABLE empresa
ADD CONSTRAINT fk_empresa_creado_por_usuario
FOREIGN KEY (creado_por_usuario_id) REFERENCES usuario(id) ON DELETE RESTRICT;

ALTER TABLE empresa
ADD CONSTRAINT fk_empresa_actualizado_por_usuario
FOREIGN KEY (actualizado_por_usuario_id) REFERENCES usuario(id) ON DELETE RESTRICT;

ALTER TABLE empresa
ADD CONSTRAINT fk_empresa_eliminado_por_usuario
FOREIGN KEY (eliminado_por_usuario_id) REFERENCES usuario(id) ON DELETE RESTRICT;

-- >>> esquema/activos_e_inversion/entidad_clasificacion_activo.sql
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

-- >>> esquema/activos_e_inversion/entidad_tipo_adquisicion_activo.sql
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

-- >>> esquema/activos_e_inversion/entidad_activo.sql
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

-- >>> esquema/contratos/entidad_cliente.sql
CREATE TABLE cliente (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  id_empresa UUID NOT NULL,
  ruc STRING,
  razon_social STRING NOT NULL,
  nombre_comercial STRING,
  direccion STRING,
  telefono STRING,
  correo_electronico STRING,
  contacto STRING,
  estado STRING NOT NULL DEFAULT 'ACTIVO',
  creado_en TIMESTAMPTZ NOT NULL DEFAULT now(),
  actualizado_en TIMESTAMPTZ NOT NULL DEFAULT now(),
  eliminado_en TIMESTAMPTZ NULL,
  creado_por_usuario_id UUID,
  actualizado_por_usuario_id UUID,
  eliminado_por_usuario_id UUID,

  CONSTRAINT uq_cliente_ruc_unico
    UNIQUE (id_empresa, ruc),
 
  CONSTRAINT ck_cliente_estado
    CHECK (estado IN ('ACTIVO', 'INACTIVO')),

  CONSTRAINT ck_cliente_ruc_longitud
    CHECK (ruc IS NULL OR char_length(ruc) = 11),
    
  CONSTRAINT ck_cliente_razon_social_longitud
    CHECK (char_length(razon_social) <= 120),

  CONSTRAINT ck_cliente_nombre_comercial_longitud
    CHECK (nombre_comercial IS NULL OR char_length(nombre_comercial) <= 80),

  CONSTRAINT ck_cliente_direccion_longitud
    CHECK (direccion IS NULL OR char_length(direccion) <= 200),

  CONSTRAINT ck_cliente_telefono_longitud
    CHECK (telefono IS NULL OR char_length(telefono) <= 20),

  CONSTRAINT ck_cliente_correo_electronico_longitud
    CHECK (correo_electronico IS NULL OR char_length(correo_electronico) <= 80),

  CONSTRAINT ck_cliente_contacto_longitud
    CHECK (contacto IS NULL OR char_length(contacto) <= 80)

);

ALTER TABLE cliente
  ADD CONSTRAINT fk_cliente_empresa
  FOREIGN KEY (id_empresa) REFERENCES empresa(id) ON DELETE RESTRICT;
ALTER TABLE cliente
  ADD CONSTRAINT fk_cliente_creado_por_usuario
  FOREIGN KEY (creado_por_usuario_id) REFERENCES usuario(id) ON DELETE RESTRICT;
ALTER TABLE cliente
  ADD CONSTRAINT fk_cliente_actualizado_por_usuario
  FOREIGN KEY (actualizado_por_usuario_id) REFERENCES usuario(id) ON DELETE RESTRICT;
ALTER TABLE cliente
  ADD CONSTRAINT fk_cliente_eliminado_por_usuario
  FOREIGN KEY (eliminado_por_usuario_id) REFERENCES usuario(id) ON DELETE RESTRICT;

CREATE UNIQUE INDEX uq_cliente_empresa_ruc ON cliente (id_empresa, ruc)
  WHERE eliminado_en IS NULL AND ruc IS NOT NULL;

CREATE UNIQUE INDEX uq_cliente_empresa_correo ON cliente (id_empresa, correo_electronico)
  WHERE correo_electronico IS NOT NULL;

CREATE INDEX idx_cliente_empresa ON cliente (id_empresa);

-- >>> esquema/contratos/entidad_estado_contrato.sql
CREATE TABLE estado_contrato (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  id_empresa UUID NOT NULL,
  codigo STRING NOT NULL,
  descripcion STRING NOT NULL,
  es_vigente BOOL NOT NULL DEFAULT false,
  estado STRING NOT NULL DEFAULT 'ACTIVO',
  creado_en TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  actualizado_en TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  eliminado_en TIMESTAMPTZ NULL,
  creado_por_usuario_id UUID,
  actualizado_por_usuario_id UUID,
  eliminado_por_usuario_id UUID,

  CONSTRAINT uq_estado_contrato_empresa_codigo
    UNIQUE (id_empresa, codigo),
 
  CONSTRAINT ck_estado_contrato_estado
    CHECK (estado IN ('ACTIVO', 'INACTIVO')),

  CONSTRAINT ck_estado_contrato_codigo_longitud
    CHECK (char_length(codigo) >=2 AND char_length(codigo) <= 20),

  CONSTRAINT ck_estado_contrato_codigo
    CHECK (codigo = upper(codigo)),

  CONSTRAINT ck_estado_contrato_descripcion_longitud
    CHECK (char_length(descripcion) <= 60)
);

ALTER TABLE estado_contrato
  ADD CONSTRAINT fk_estado_contrato_empresa
  FOREIGN KEY (id_empresa) REFERENCES empresa(id) ON DELETE RESTRICT;
ALTER TABLE estado_contrato
  ADD CONSTRAINT fk_estado_contrato_creado_por_usuario
  FOREIGN KEY (creado_por_usuario_id) REFERENCES usuario(id) ON DELETE RESTRICT;
ALTER TABLE estado_contrato
  ADD CONSTRAINT fk_estado_contrato_actualizado_por_usuario
  FOREIGN KEY (actualizado_por_usuario_id) REFERENCES usuario(id) ON DELETE RESTRICT;
ALTER TABLE estado_contrato
  ADD CONSTRAINT fk_estado_contrato_eliminado_por_usuario
  FOREIGN KEY (eliminado_por_usuario_id) REFERENCES usuario(id) ON DELETE RESTRICT;

CREATE INDEX idx_estado_contrato_empresa ON estado_contrato (id_empresa);

CREATE UNIQUE INDEX uq_estado_contrato_vigente_unico ON estado_contrato (id_empresa)
  WHERE es_vigente = true AND eliminado_en IS NULL;

-- >>> esquema/contratos/entidad_tipo_contrato.sql
CREATE TABLE tipo_contrato (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  id_empresa UUID NOT NULL,
  codigo STRING NOT NULL,
  descripcion STRING NOT NULL,
  estado STRING NOT NULL DEFAULT 'ACTIVO',
  creado_en TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  actualizado_en TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  eliminado_en TIMESTAMPTZ NULL,
  creado_por_usuario_id UUID,
  actualizado_por_usuario_id UUID,
  eliminado_por_usuario_id UUID,

  CONSTRAINT uq_tipo_contrato_empresa_codigo
    UNIQUE (id_empresa, codigo),
 
  CONSTRAINT ck_tipo_contrato_estado
    CHECK (estado IN ('ACTIVO', 'INACTIVO')),

  CONSTRAINT ck_tipo_contrato_codigo_longitud
    CHECK (char_length(codigo) >=2 AND char_length(codigo) <= 20),

  CONSTRAINT ck_tipo_contrato_descripcion_longitud
    CHECK (char_length(descripcion) <= 80)
);

ALTER TABLE tipo_contrato
  ADD CONSTRAINT fk_tipo_contrato_empresa
  FOREIGN KEY (id_empresa) REFERENCES empresa(id) ON DELETE RESTRICT;
ALTER TABLE tipo_contrato
  ADD CONSTRAINT fk_tipo_contrato_creado_por_usuario
  FOREIGN KEY (creado_por_usuario_id) REFERENCES usuario(id) ON DELETE RESTRICT;
ALTER TABLE tipo_contrato
  ADD CONSTRAINT fk_tipo_contrato_actualizado_por_usuario
  FOREIGN KEY (actualizado_por_usuario_id) REFERENCES usuario(id) ON DELETE RESTRICT;
ALTER TABLE tipo_contrato
  ADD CONSTRAINT fk_tipo_contrato_eliminado_por_usuario
  FOREIGN KEY (eliminado_por_usuario_id) REFERENCES usuario(id) ON DELETE RESTRICT;

CREATE INDEX idx_tipo_contrato_empresa ON tipo_contrato (id_empresa);

-- >>> esquema/contratos/entidad_contrato.sql
CREATE TABLE contrato (
  id                             UUID        	DEFAULT gen_random_uuid() PRIMARY KEY,
  id_empresa                     UUID        	NOT NULL,
  id_tipo_contrato               UUID        	NOT NULL,
  id_estado_contrato             UUID        	NOT NULL,
  id_cliente                     UUID         	NOT NULL,
  codigo                         VARCHAR(30)	NOT NULL,
  nombre                         VARCHAR(120)   NOT NULL,
  monto_contractual              NUMERIC(18,2),
  presupuesto_mensual_proyectado NUMERIC(18,2),
  fecha_inicio                   DATE,
  fecha_fin_contrato             DATE,
  fecha_fin_real                 DATE,
  estado                         VARCHAR(15)    NOT NULL DEFAULT 'ACTIVO',
  creado_en                      TIMESTAMPTZ    NOT null DEFAULT NOW(),
  actualizado_en                 TIMESTAMPTZ    NOT null DEFAULT NOW(),
  eliminado_en                   TIMESTAMPTZ,
  creado_por_usuario_id          UUID,
  actualizado_por_usuario_id     UUID,
  eliminado_por_usuario_id       UUID,
  
  	constraint uk_contrato_empresa_codigo
  		unique (id_empresa, codigo),
  	
  	constraint ck_contrato_estado
  		check (estado in ('ACTIVO', 'SUSPENDIDO', 'FINALIZADO')),
  	
	CONSTRAINT ck_contrato_fecha_contrato_mayor
	    CHECK (fecha_fin_contrato >= fecha_inicio),  	
	    
	CONSTRAINT ck_contrato_fecha_real_mayor
	    CHECK (fecha_fin_real IS NULL OR fecha_fin_real >= fecha_inicio),	    
  
	CONSTRAINT ck_contrato_monto_contractual_positivo
	    CHECK (monto_contractual >= 0),	    
	    
	CONSTRAINT ck_contrato_presupuesto_mensual_proyectado_positivo
	    CHECK (presupuesto_mensual_proyectado >= 0)	    
	    
);

CREATE INDEX idx_contrato_empresa        ON contrato(id_empresa);
CREATE INDEX idx_contrato_tipo           ON contrato(id_tipo_contrato);
CREATE INDEX idx_contrato_estado         ON contrato(id_estado_contrato);
CREATE INDEX idx_contrato_cliente        ON contrato(id_cliente);
CREATE INDEX idx_contrato_vigentes       ON contrato(id_empresa) WHERE estado = 'ACTIVO';

ALTER TABLE contrato 
  ADD CONSTRAINT fk_contrato_empresa
  FOREIGN KEY (id_empresa) REFERENCES empresa(id);
 
ALTER TABLE contrato 
  ADD CONSTRAINT fk_contrato_tipo_contrato
  FOREIGN KEY (id_tipo_contrato) REFERENCES tipo_contrato(id); 
 
ALTER TABLE contrato 
  ADD CONSTRAINT fk_contrato_estado_contrato
  FOREIGN KEY (id_estado_contrato) REFERENCES estado_contrato(id); 
 
ALTER TABLE contrato 
  ADD CONSTRAINT fk_contrato_cliente
  FOREIGN KEY (id_cliente) REFERENCES cliente(id);

-- >>> esquema/contratos/entidad_zona.sql
CREATE TABLE zona (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  id_empresa UUID NOT NULL,
  codigo STRING NOT NULL,
  descripcion STRING NOT NULL,
  estado STRING NOT NULL DEFAULT 'ACTIVO',
  creado_en TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  actualizado_en TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  eliminado_en TIMESTAMPTZ NULL,
  creado_por_usuario_id UUID,
  actualizado_por_usuario_id UUID,
  eliminado_por_usuario_id UUID,

  CONSTRAINT uq_zona_empresa_codigo
    UNIQUE (id_empresa, codigo),
 
  CONSTRAINT ck_zona_estado
    CHECK (estado IN ('ACTIVO', 'INACTIVO')),

  CONSTRAINT ck_zona_codigo_longitud
    CHECK (char_length(codigo) >=2 AND char_length(codigo) <= 20),

  CONSTRAINT ck_zona_codigo
    CHECK (codigo = upper(codigo)),

   CONSTRAINT ck_zona_descripcion_longitud
    CHECK (char_length(descripcion) <= 80)
);

ALTER TABLE zona
  ADD CONSTRAINT fk_zona_empresa
  FOREIGN KEY (id_empresa) REFERENCES empresa(id) ON DELETE RESTRICT;
ALTER TABLE zona
  ADD CONSTRAINT fk_zona_creado_por_usuario
  FOREIGN KEY (creado_por_usuario_id) REFERENCES usuario(id) ON DELETE RESTRICT;
ALTER TABLE zona
  ADD CONSTRAINT fk_zona_actualizado_por_usuario
  FOREIGN KEY (actualizado_por_usuario_id) REFERENCES usuario(id) ON DELETE RESTRICT;
ALTER TABLE zona
  ADD CONSTRAINT fk_zona_eliminado_por_usuario
  FOREIGN KEY (eliminado_por_usuario_id) REFERENCES usuario(id) ON DELETE RESTRICT;

CREATE UNIQUE INDEX uq_zona_empresa_codigo_vigente
  ON zona (id_empresa, codigo)
  WHERE eliminado_en IS NULL;

CREATE INDEX idx_zona_empresa ON zona (id_empresa);

-- >>> esquema/gobierno_central/entidad_periodo.sql
CREATE TABLE periodo (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_empresa UUID NOT NULL,
  anio SMALLINT NOT NULL,
  mes SMALLINT NOT NULL,
  codigo_periodo STRING NOT NULL,
  fecha_inicio DATE NOT NULL,
  fecha_fin DATE NOT NULL,
  estado STRING NOT NULL DEFAULT  'ABIERTO',
  creado_en TIMESTAMPTZ NOT NULL DEFAULT now(),
  actualizado_en TIMESTAMPTZ NOT NULL DEFAULT now(),
  eliminado_en TIMESTAMPTZ NULL,
  creado_por_usuario_id UUID,
  actualizado_por_usuario_id UUID,
  eliminado_por_usuario_id UUID,

  CONSTRAINT uq_periodo_empresa_anio_mes
    UNIQUE (id_empresa, anio, mes),

  CONSTRAINT uq_periodo_empresa_codigo
    UNIQUE (id_empresa, codigo_periodo),

  CONSTRAINT ck_periodo_anio_valido
    CHECK (anio BETWEEN 2000 AND 2100),

  CONSTRAINT ck_periodo_mes_valido
    CHECK (mes BETWEEN 1 AND 12),

  CONSTRAINT ck_periodo_estado
    CHECK (estado IN ('ABIERTO', 'CERRADO'))
);

ALTER TABLE periodo
ADD CONSTRAINT fk_periodo_empresa
FOREIGN KEY (id_empresa) REFERENCES empresa(id) ON DELETE RESTRICT;

ALTER TABLE periodo
ADD CONSTRAINT fk_periodo_creado_por_usuario
FOREIGN KEY (creado_por_usuario_id) REFERENCES usuario(id) ON DELETE RESTRICT;

ALTER TABLE periodo
ADD CONSTRAINT fk_periodo_actualizado_por_usuario
FOREIGN KEY (actualizado_por_usuario_id) REFERENCES usuario(id) ON DELETE RESTRICT;

ALTER TABLE periodo
ADD CONSTRAINT fk_periodo_eliminado_por_usuario
FOREIGN KEY (eliminado_por_usuario_id) REFERENCES usuario(id) ON DELETE RESTRICT;

-- >>> esquema/activos_e_inversion/entidad_activo_registro_trabajo.sql
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

-- >>> esquema/activos_e_inversion/entidad_activo_traslado.sql
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

-- >>> esquema/activos_e_inversion/entidad_tipo_herramienta.sql
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

-- >>> esquema/activos_e_inversion/entidad_herramienta.sql
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

-- >>> esquema/activos_e_inversion/entidad_herramienta_movimiento.sql
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

-- >>> esquema/activos_e_inversion/entidad_recuperacion_inversion_mensual.sql
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

-- >>> esquema/activos_e_inversion/entidad_relacion_activo_asignacion_contrato.sql
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

-- >>> esquema/cierre_mensual/entidad_cierre_mensual.sql
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

-- >>> esquema/cierre_mensual/entidad_penalidad.sql
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

-- >>> esquema/cierre_mensual/entidad_provision.sql
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

-- >>> esquema/costeo_directo/entidad_tipo_clasificacion_gasto.sql
CREATE TABLE tipo_clasificacion_gasto (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
    id_empresa UUID NOT NULL,
    codigo STRING NOT NULL,
    descripcion STRING NOT NULL,
    estado STRING NOT NULL DEFAULT 'ACTIVO',
    creado_en TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    actualizado_en TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    eliminado_en TIMESTAMPTZ NULL,
    creado_por_usuario_id UUID,
    actualizado_por_usuario_id UUID,
    eliminado_por_usuario_id UUID,
    CONSTRAINT uq_tipo_clasificacion_gasto_empresa_codigo UNIQUE (id_empresa, codigo),
    CONSTRAINT ck_tipo_clasificacion_gasto_estado CHECK (
        estado IN ('ACTIVO', 'INACTIVO')
    ),
    CONSTRAINT ck_tipo_clasificacion_gasto_codigo_longitud CHECK (
        char_length(codigo) BETWEEN 1 AND 20
    ),
    CONSTRAINT ck_tipo_clasificacion_gasto_descripcion_longitud CHECK (
        char_length(descripcion) BETWEEN 1 AND 80
    )
);

ALTER TABLE tipo_clasificacion_gasto
ADD CONSTRAINT fk_tipo_clasificacion_gasto_empresa FOREIGN KEY (id_empresa) REFERENCES empresa (id) ON DELETE RESTRICT;

ALTER TABLE tipo_clasificacion_gasto
ADD CONSTRAINT fk_tipo_clasificacion_gasto_creado_por FOREIGN KEY (creado_por_usuario_id) REFERENCES usuario (id) ON DELETE RESTRICT;

ALTER TABLE tipo_clasificacion_gasto
ADD CONSTRAINT fk_tipo_clasificacion_gasto_actualizado_por FOREIGN KEY (actualizado_por_usuario_id) REFERENCES usuario (id) ON DELETE RESTRICT;

ALTER TABLE tipo_clasificacion_gasto
ADD CONSTRAINT fk_tipo_clasificacion_gasto_eliminado_por FOREIGN KEY (eliminado_por_usuario_id) REFERENCES usuario (id) ON DELETE RESTRICT;

-- >>> esquema/costeo_directo/entidad_clasificacion_gasto.sql
CREATE TABLE clasificacion_gasto (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
    id_empresa UUID NOT NULL,
    id_tipo_clasificacion_gasto UUID NOT NULL,
    codigo STRING NOT NULL,
    descripcion STRING NOT NULL,
    estado STRING NOT NULL DEFAULT 'ACTIVO',
    creado_en TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    actualizado_en TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    eliminado_en TIMESTAMPTZ NULL,
    creado_por_usuario_id UUID,
    actualizado_por_usuario_id UUID,
    eliminado_por_usuario_id UUID,
    CONSTRAINT uq_clasificacion_gasto_empresa_codigo UNIQUE (id_empresa, codigo),
    CONSTRAINT ck_clasificacion_gasto_estado CHECK (
        estado IN ('ACTIVO', 'INACTIVO')
    ),
    CONSTRAINT ck_clasificacion_gasto_codigo_longitud CHECK (
        char_length(codigo) BETWEEN 1 AND 20
    ),
    CONSTRAINT ck_clasificacion_gasto_descripcion_longitud CHECK (
        char_length(descripcion) BETWEEN 1 AND 100
    )
);

ALTER TABLE clasificacion_gasto
ADD CONSTRAINT fk_clasificacion_gasto_empresa FOREIGN KEY (id_empresa) REFERENCES empresa (id) ON DELETE RESTRICT;

ALTER TABLE clasificacion_gasto
ADD CONSTRAINT fk_clasificacion_gasto_tipo FOREIGN KEY (id_tipo_clasificacion_gasto) REFERENCES tipo_clasificacion_gasto (id) ON DELETE RESTRICT;

ALTER TABLE clasificacion_gasto
ADD CONSTRAINT fk_clasificacion_gasto_creado_por FOREIGN KEY (creado_por_usuario_id) REFERENCES usuario (id) ON DELETE RESTRICT;

ALTER TABLE clasificacion_gasto
ADD CONSTRAINT fk_clasificacion_gasto_actualizado_por FOREIGN KEY (actualizado_por_usuario_id) REFERENCES usuario (id) ON DELETE RESTRICT;

ALTER TABLE clasificacion_gasto
ADD CONSTRAINT fk_clasificacion_gasto_eliminado_por FOREIGN KEY (eliminado_por_usuario_id) REFERENCES usuario (id) ON DELETE RESTRICT;

-- >>> esquema/costeo_directo/entidad_proveedor.sql
CREATE TABLE proveedor (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
    id_empresa UUID NOT NULL,
    tipo_documento_identidad STRING NOT NULL,
    nro_documento STRING NOT NULL,
    razon_social STRING NOT NULL,
    nombre_comercial STRING,
    direccion STRING,
    telefono STRING,
    correo_electronico STRING,
    contacto STRING,
    estado STRING NOT NULL DEFAULT 'ACTIVO',
    creado_en TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    actualizado_en TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    eliminado_en TIMESTAMPTZ NULL,
    creado_por_usuario_id UUID,
    actualizado_por_usuario_id UUID,
    eliminado_por_usuario_id UUID,
    CONSTRAINT uq_proveedor_empresa_nro_documento UNIQUE (id_empresa, nro_documento),
    CONSTRAINT ck_proveedor_estado CHECK (
        estado IN ('ACTIVO', 'INACTIVO')
    ),
    CONSTRAINT ck_proveedor_tipo_documento CHECK (
        tipo_documento_identidad IN (
            'DNI',
            'RUC',
            'CE',
            'PAS',
            'OTRO'
        )
    ),
    CONSTRAINT ck_proveedor_razon_social_longitud CHECK (
        char_length(razon_social) BETWEEN 1 AND 120
    )
);

ALTER TABLE proveedor
ADD CONSTRAINT fk_proveedor_empresa FOREIGN KEY (id_empresa) REFERENCES empresa (id) ON DELETE RESTRICT;

ALTER TABLE proveedor
ADD CONSTRAINT fk_proveedor_creado_por FOREIGN KEY (creado_por_usuario_id) REFERENCES usuario (id) ON DELETE RESTRICT;

ALTER TABLE proveedor
ADD CONSTRAINT fk_proveedor_actualizado_por FOREIGN KEY (actualizado_por_usuario_id) REFERENCES usuario (id) ON DELETE RESTRICT;

ALTER TABLE proveedor
ADD CONSTRAINT fk_proveedor_eliminado_por FOREIGN KEY (eliminado_por_usuario_id) REFERENCES usuario (id) ON DELETE RESTRICT;

-- >>> esquema/contratos/entidad_contrato_gasto_fijo.sql
CREATE TABLE contrato_gasto_fijo (
  id               				 UUID         DEFAULT gen_random_uuid() PRIMARY KEY,
  id_empresa       				 UUID         NOT NULL,
  id_contrato      				 UUID         NOT NULL,
  id_zona          				 UUID         ,
  id_clasificacion  			 UUID         NOT NULL,
  id_proveedor     				 UUID         ,
  descripcion       			 VARCHAR(120),
  importe          				 NUMERIC(18,2) NOT NULL,
  fecha_inicio     				 DATE,
  fecha_fin        				 DATE,
  
  estado                         VARCHAR(15)    NOT NULL DEFAULT 'ACTIVO',
  creado_en                      TIMESTAMPTZ    NOT null DEFAULT NOW(),
  actualizado_en                 TIMESTAMPTZ    NOT null DEFAULT NOW(),
  eliminado_en                   TIMESTAMPTZ,
  creado_por_usuario_id          UUID,
  actualizado_por_usuario_id     UUID,
  eliminado_por_usuario_id       UUID,
  
  	constraint ck_contrato_gasto_fijo_importe_positivo
  		check (importe > 0),
	  	
	CONSTRAINT ck_contrato_gasto_fijo_orden_fechas
	    CHECK (fecha_fin IS NULL OR fecha_fin >= fecha_inicio)  	
  
);

CREATE INDEX idx_contrato_gasto_fijo_empresa       ON contrato_gasto_fijo(id_empresa);
CREATE INDEX idx_contrato_gasto_fijo_contrato      ON contrato_gasto_fijo(id_contrato);
CREATE INDEX idx_contrato_gasto_fijo_clasificacion ON contrato_gasto_fijo(id_clasificacion);

CREATE INDEX idx_contrato_gasto_fijo_zona          ON contrato_gasto_fijo(id_zona) WHERE id_zona IS NOT NULL;
CREATE INDEX idx_contrato_gasto_fijo_proveedor     ON contrato_gasto_fijo(id_proveedor) WHERE id_proveedor IS NOT NULL;

CREATE INDEX idx_contrato_gasto_fijo_vigentes      ON contrato_gasto_fijo(id_contrato, fecha_inicio, fecha_fin) WHERE estado = 'ACTIVO';

ALTER TABLE contrato_gasto_fijo 
  ADD CONSTRAINT fk_contrato_gasto_fijo_empresa
  FOREIGN KEY (id_empresa) REFERENCES empresa(id);
 
ALTER TABLE contrato_gasto_fijo 
  ADD CONSTRAINT fk_contrato_gasto_fijo_contrato
  FOREIGN KEY (id_contrato) REFERENCES contrato(id);
 
ALTER TABLE contrato_gasto_fijo 
  ADD CONSTRAINT fk_contrato_gasto_fijo_zona
  FOREIGN KEY (id_zona) REFERENCES zona(id)
  ON DELETE SET NULL;
 
ALTER TABLE contrato_gasto_fijo 
  ADD CONSTRAINT fk_contrato_gasto_fijo_clasificacion
  FOREIGN KEY (id_clasificacion) REFERENCES clasificacion_gasto(id); 
 
ALTER TABLE contrato_gasto_fijo 
  ADD CONSTRAINT fk_contrato_gasto_fijo_proveedor
  FOREIGN KEY (id_proveedor) REFERENCES proveedor(id)
  ON DELETE SET NULL;

-- >>> esquema/contratos/entidad_contrato_porcentaje_distribucion.sql
CREATE TABLE contrato_porcentaje_distribucion (
  id           					 UUID         	DEFAULT gen_random_uuid() PRIMARY KEY,
  id_empresa        			 UUID         	NOT NULL,
  id_contrato  					 UUID         	NOT NULL,
  id_periodo   					 UUID         	NOT NULL,
  porcentaje   					 NUMERIC(7,4) 	NOT NULL,   -- 0.1500 = 15.00%
  estado                         VARCHAR(15)    NOT NULL DEFAULT 'ACTIVO',
  creado_en                      TIMESTAMPTZ    NOT null DEFAULT NOW(),
  actualizado_en                 TIMESTAMPTZ    NOT null DEFAULT NOW(),
  eliminado_en                   TIMESTAMPTZ,
  creado_por_usuario_id          UUID,
  actualizado_por_usuario_id     UUID,
  eliminado_por_usuario_id       UUID,
  
	CONSTRAINT uk_contrato_porcentaje_contrato_periodo 
    	UNIQUE (id_contrato, id_periodo),
	    	
	CONSTRAINT ck_contrato_porcentaje_rango
	    CHECK (porcentaje >= 0.0000 AND porcentaje <= 1.0000)    	
  
);

CREATE INDEX idx_contrato_porcentaje_empresa   ON contrato_porcentaje_distribucion(id_empresa);
CREATE INDEX idx_contrato_porcentaje_periodo   ON contrato_porcentaje_distribucion(id_periodo);

ALTER TABLE contrato_porcentaje_distribucion 
  ADD CONSTRAINT fk_contratos_porcentaje_empresa
  FOREIGN KEY (id_empresa) REFERENCES empresa(id) 
  ON DELETE CASCADE;
 
 ALTER TABLE contrato_porcentaje_distribucion 
  ADD CONSTRAINT fk_contratos_porcentaje_contrato
  FOREIGN KEY (id_contrato) REFERENCES contrato(id) 
  ON DELETE CASCADE;
 
 ALTER TABLE contrato_porcentaje_distribucion 
  ADD CONSTRAINT fk_contratos_porcentaje_periodo
  FOREIGN KEY (id_periodo) REFERENCES periodo(id);

-- >>> esquema/contratos/entidad_contrato_zona.sql
CREATE TABLE contrato_zona (
  id           					 UUID      		DEFAULT gen_random_uuid() PRIMARY KEY,
  id_empresa   					 UUID      		NOT NULL,
  id_contrato  					 UUID      		NOT NULL,
  id_zona      					 UUID     	 	NOT NULL,
  estado                         VARCHAR(15)    NOT NULL DEFAULT 'ACTIVO',
  creado_en                      TIMESTAMPTZ    NOT null DEFAULT NOW(),
  actualizado_en                 TIMESTAMPTZ    NOT null DEFAULT NOW(),
  eliminado_en                   TIMESTAMPTZ,
  creado_por_usuario_id          UUID,
  actualizado_por_usuario_id     UUID,
  eliminado_por_usuario_id       UUID,
	
	CONSTRAINT uk_contrato_zona_contrato_zona 
	    UNIQUE (id_contrato, id_zona)
  
);

CREATE INDEX idx_contrato_zona_empresa       ON contrato_zona(id_empresa);
CREATE INDEX idx_contrato_zona_contrato      ON contrato_zona(id_contrato);
CREATE INDEX idx_contrato_zona_zona          ON contrato_zona(id_zona);
CREATE INDEX idx_contrato_zona_vigentes      ON contrato_zona(id_empresa) WHERE estado = 'ACTIVO';

ALTER TABLE contrato_zona 
  ADD CONSTRAINT fk_contrato_zona_empresa
  FOREIGN KEY (id_empresa) REFERENCES empresa(id);
 
ALTER TABLE contrato_zona 
  ADD CONSTRAINT fk_contrato_zona_contrato
  FOREIGN KEY (id_contrato) REFERENCES contrato(id);

ALTER TABLE contrato_zona 
  ADD CONSTRAINT fk_contrato_zona_zona
  FOREIGN KEY (id_zona) REFERENCES zona(id);

-- >>> esquema/contratos/entidad_gasto_inicial.sql
CREATE TABLE gasto_inicial (
  id               				 UUID         	DEFAULT gen_random_uuid() PRIMARY KEY,
  id_empresa         			 UUID         	NOT NULL,
  id_contrato      				 UUID         	NOT NULL,
  id_zona          				 UUID         	,
  descripcion      				 VARCHAR(120) 	NOT NULL,
  importe_total    				 NUMERIC(18,2) 	NOT NULL,
  importe_mensual  				 NUMERIC(18,2),
  tiempo_en_meses  				 INT,
  fecha_inicio     				 DATE,
  fecha_fin        				 DATE,
  estado                         VARCHAR(15)    NOT NULL DEFAULT 'ACTIVO',
  creado_en                      TIMESTAMPTZ    NOT null DEFAULT NOW(),
  actualizado_en                 TIMESTAMPTZ    NOT null DEFAULT NOW(),
  eliminado_en                   TIMESTAMPTZ,
  creado_por_usuario_id          UUID,
  actualizado_por_usuario_id     UUID,
  eliminado_por_usuario_id       UUID,
  
	CONSTRAINT ck_gasto_inicial_estado
	    CHECK (estado IN ('ACTIVO', 'SUSPENDIDO', 'FINALIZADO')),
		    
	CONSTRAINT ck_gasto_inicial_importe_total_positivo
	    CHECK (importe_total > 0),
		
	CONSTRAINT ck_gasto_inicial_importe_mensual_positivo
	    CHECK (importe_mensual IS null or importe_mensual > 0),
	
	CONSTRAINT ck_gasto_inicial_duracion_valida
	    CHECK (tiempo_en_meses IS NULL OR tiempo_en_meses > 0),	
	    
	CONSTRAINT ck_gasto_inicial_orden_fechas
	    CHECK (fecha_fin IS NULL OR fecha_fin >= fecha_inicio)	    
    
);

CREATE INDEX idx_gasto_inicial_empresa             ON gasto_inicial(id_empresa);
CREATE INDEX idx_gasto_inicial_contrato            ON gasto_inicial(id_contrato);
CREATE INDEX idx_gasto_inicial_zona                ON gasto_inicial(id_zona) where id_zona is not NULL;
CREATE INDEX idx_gasto_inicial_vigentes            ON gasto_inicial(id_contrato, fecha_inicio, fecha_fin) WHERE estado = 'ACTIVO';

ALTER TABLE gasto_inicial 
  ADD CONSTRAINT fk_gasto_inicial_empresa
  FOREIGN KEY (id_empresa) REFERENCES empresa(id);
 
ALTER TABLE gasto_inicial 
  ADD CONSTRAINT fk_gasto_inicial_contrato
  FOREIGN KEY (id_contrato) REFERENCES contrato(id);

ALTER TABLE gasto_inicial 
  ADD CONSTRAINT fk_gasto_inicial_zona
  FOREIGN KEY (id_zona) REFERENCES zona(id)
  ON DELETE SET NULL;

-- >>> esquema/contratos/entidad_grupo_actividad.sql
CREATE TABLE grupo_actividad (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  id_empresa UUID NOT NULL,
  codigo STRING NOT NULL,
  descripcion STRING NOT NULL,
  estado STRING NOT NULL DEFAULT 'ACTIVO',
  creado_en TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  actualizado_en TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  eliminado_en TIMESTAMPTZ NULL,
  creado_por_usuario_id UUID,
  actualizado_por_usuario_id UUID,
  eliminado_por_usuario_id UUID,

  CONSTRAINT uq_grupo_actividad_empresa_codigo
    UNIQUE (id_empresa, codigo),
 
  CONSTRAINT ck_grupo_actividad_estado
    CHECK (estado IN ('ACTIVO', 'INACTIVO')),

  CONSTRAINT ck_grupo_actividad_codigo_longitud
    CHECK (char_length(codigo) >=2 AND char_length(codigo) <= 20),

  CONSTRAINT ck_grupo_actividad_codigo
    CHECK (codigo = upper(codigo)),

  CONSTRAINT ck_grupo_actividad_descripcion_longitud
    CHECK (char_length(descripcion) <= 80)
);

ALTER TABLE grupo_actividad
  ADD CONSTRAINT fk_grupo_actividad_empresa
  FOREIGN KEY (id_empresa) REFERENCES empresa(id) ON DELETE RESTRICT;
ALTER TABLE grupo_actividad
  ADD CONSTRAINT fk_grupo_actividad_creado_por_usuario
  FOREIGN KEY (creado_por_usuario_id) REFERENCES usuario(id) ON DELETE RESTRICT;
ALTER TABLE grupo_actividad
  ADD CONSTRAINT fk_grupo_actividad_actualizado_por_usuario
  FOREIGN KEY (actualizado_por_usuario_id) REFERENCES usuario(id) ON DELETE RESTRICT;
ALTER TABLE grupo_actividad
  ADD CONSTRAINT fk_grupo_actividad_eliminado_por_usuario
  FOREIGN KEY (eliminado_por_usuario_id) REFERENCES usuario(id) ON DELETE RESTRICT;

CREATE UNIQUE INDEX uq_grupo_actividad_empresa_codigo_vigente
  ON grupo_actividad (id_empresa, codigo)
  WHERE eliminado_en IS NULL;

CREATE INDEX idx_grupo_actividad_empresa ON grupo_actividad (id_empresa);

-- >>> esquema/costeo_directo/entidad_erp_importacion.sql
CREATE TABLE erp_importacion (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
    id_empresa UUID NOT NULL,
    id_periodo UUID,
    id_clasificacion_gasto UUID,
    fecha_importacion TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    tipo_datos STRING,
    archivo_origen STRING,
    total_registros INT NOT NULL DEFAULT 0,
    registros_ok INT NOT NULL DEFAULT 0,
    registros_error INT NOT NULL DEFAULT 0,
    estado STRING NOT NULL DEFAULT 'PENDIENTE',
    detalle_error STRING,
    creado_en TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    creado_por_usuario_id UUID,
    CONSTRAINT ck_erp_importacion_estado CHECK (
        estado IN (
            'PENDIENTE',
            'PROCESADO',
            'ERROR',
            'REPROCESAR'
        )
    ),
    CONSTRAINT ck_erp_importacion_tipo_datos_longitud CHECK (
        tipo_datos IS NULL
        OR char_length(tipo_datos) <= 60
    ),
    CONSTRAINT ck_erp_importacion_registros_no_negativos CHECK (
        total_registros >= 0
        AND registros_ok >= 0
        AND registros_error >= 0
    )
);

ALTER TABLE erp_importacion
ADD CONSTRAINT fk_erp_importacion_empresa FOREIGN KEY (id_empresa) REFERENCES empresa (id) ON DELETE RESTRICT;

ALTER TABLE erp_importacion
ADD CONSTRAINT fk_erp_importacion_periodo FOREIGN KEY (id_periodo) REFERENCES periodo (id) ON DELETE RESTRICT;

ALTER TABLE erp_importacion
ADD CONSTRAINT fk_erp_importacion_clasificacion_gasto FOREIGN KEY (id_clasificacion_gasto) REFERENCES clasificacion_gasto (id) ON DELETE RESTRICT;

ALTER TABLE erp_importacion
ADD CONSTRAINT fk_erp_importacion_creado_por FOREIGN KEY (creado_por_usuario_id) REFERENCES usuario (id) ON DELETE RESTRICT;

CREATE INDEX idx_erp_importacion_empresa_periodo ON erp_importacion (id_empresa, id_periodo);

CREATE INDEX idx_erp_importacion_estado ON erp_importacion (estado);

-- >>> esquema/costeo_directo/entidad_gasto_directo.sql
CREATE TABLE gasto_directo (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
    id_empresa UUID NOT NULL,
    id_contrato UUID NOT NULL,
    id_zona UUID,
    id_periodo UUID NOT NULL,
    id_clasificacion_gasto UUID NOT NULL,
    id_proveedor UUID,
    origen STRING NOT NULL DEFAULT 'MANUAL',
    tipo_documento STRING,
    erp_serie STRING (10),
    erp_numero STRING (20),
    erp_fecha DATE,
    descripcion STRING (200),
    importe NUMERIC(18, 2) NOT NULL,
    estado STRING NOT NULL DEFAULT 'ACTIVO',
    creado_en TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    actualizado_en TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    eliminado_en TIMESTAMPTZ NULL,
    creado_por_usuario_id UUID,
    actualizado_por_usuario_id UUID,
    eliminado_por_usuario_id UUID,
    CONSTRAINT ck_gasto_directo_origen CHECK (origen IN ('MANUAL', 'ERP')),
    CONSTRAINT ck_gasto_directo_estado CHECK (
        estado IN ('ACTIVO', 'ANULADO')
    ),
    CONSTRAINT ck_gasto_directo_importe_positivo CHECK (importe > 0),
    CONSTRAINT ck_gasto_directo_tipo_documento CHECK (
        tipo_documento IS NULL
        OR tipo_documento IN (
            'FACT',
            'BOL',
            'NC',
            'ND',
            'RXH',
            'LIQ',
            'OC',
            'OTRO'
        )
    ),
    CONSTRAINT ck_gasto_directo_erp_coherente CHECK (
        origen = 'MANUAL'
        OR (
            origen = 'ERP'
            AND erp_serie IS NOT NULL
            AND erp_numero IS NOT NULL
        )
    )
);

ALTER TABLE gasto_directo
ADD CONSTRAINT fk_gasto_directo_empresa FOREIGN KEY (id_empresa) REFERENCES empresa (id) ON DELETE RESTRICT;

ALTER TABLE gasto_directo
ADD CONSTRAINT fk_gasto_directo_contrato FOREIGN KEY (id_contrato) REFERENCES contrato (id) ON DELETE RESTRICT;

ALTER TABLE gasto_directo
ADD CONSTRAINT fk_gasto_directo_zona FOREIGN KEY (id_zona) REFERENCES zona (id) ON DELETE RESTRICT;

ALTER TABLE gasto_directo
ADD CONSTRAINT fk_gasto_directo_periodo FOREIGN KEY (id_periodo) REFERENCES periodo (id) ON DELETE RESTRICT;

ALTER TABLE gasto_directo
ADD CONSTRAINT fk_gasto_directo_clasificacion_gasto FOREIGN KEY (id_clasificacion_gasto) REFERENCES clasificacion_gasto (id) ON DELETE RESTRICT;

ALTER TABLE gasto_directo
ADD CONSTRAINT fk_gasto_directo_proveedor FOREIGN KEY (id_proveedor) REFERENCES proveedor (id) ON DELETE RESTRICT;

ALTER TABLE gasto_directo
ADD CONSTRAINT fk_gasto_directo_creado_por FOREIGN KEY (creado_por_usuario_id) REFERENCES usuario (id) ON DELETE RESTRICT;

ALTER TABLE gasto_directo
ADD CONSTRAINT fk_gasto_directo_actualizado_por FOREIGN KEY (actualizado_por_usuario_id) REFERENCES usuario (id) ON DELETE RESTRICT;

ALTER TABLE gasto_directo
ADD CONSTRAINT fk_gasto_directo_eliminado_por FOREIGN KEY (eliminado_por_usuario_id) REFERENCES usuario (id) ON DELETE RESTRICT;

CREATE INDEX idx_gasto_directo_empresa_periodo ON gasto_directo (id_empresa, id_periodo)
WHERE
    eliminado_en IS NULL;

CREATE INDEX idx_gasto_directo_contrato_periodo ON gasto_directo (id_contrato, id_periodo)
WHERE
    eliminado_en IS NULL;

CREATE INDEX idx_gasto_directo_zona_periodo ON gasto_directo (id_zona, id_periodo)
WHERE
    eliminado_en IS NULL
    AND id_zona IS NOT NULL;

CREATE INDEX idx_gasto_directo_origen ON gasto_directo (origen);

CREATE INDEX idx_gasto_directo_erp_doc ON gasto_directo (erp_serie, erp_numero)
WHERE
    origen = 'ERP';

-- >>> esquema/costeo_directo/entidad_erp_importacion_detalle.sql
CREATE TABLE erp_importacion_detalle (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
    id_empresa UUID NOT NULL,
    id_erp_importacion UUID NOT NULL,
    datos_raw JSONB NOT NULL,
    id_gasto_directo UUID,
    estado STRING NOT NULL DEFAULT 'PENDIENTE',
    error_mensaje STRING,
    creado_en TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT ck_erp_importacion_detalle_estado CHECK (
        estado IN (
            'PENDIENTE',
            'PROCESADO',
            'ERROR'
        )
    )
);

ALTER TABLE erp_importacion_detalle
ADD CONSTRAINT fk_erp_importacion_detalle_empresa FOREIGN KEY (id_empresa) REFERENCES empresa (id) ON DELETE RESTRICT;

ALTER TABLE erp_importacion_detalle
ADD CONSTRAINT fk_erp_importacion_detalle_importacion FOREIGN KEY (id_erp_importacion) REFERENCES erp_importacion (id) ON DELETE RESTRICT;

ALTER TABLE erp_importacion_detalle
ADD CONSTRAINT fk_erp_importacion_detalle_gasto_directo FOREIGN KEY (id_gasto_directo) REFERENCES gasto_directo (id) ON DELETE RESTRICT;

-- >>> esquema/facturacion_y_valorizacion/entidad_facturacion_contractual.sql
CREATE TABLE facturacion_contractual (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_empresa UUID NOT NULL,
  id_contrato UUID NOT NULL,
  id_zona_contratada UUID NOT NULL,
  id_periodo UUID NOT NULL,
  numero_documento STRING NOT NULL,
  fecha_emision DATE NOT NULL,
  total_facturado DECIMAL(18,2) NOT NULL DEFAULT 0,
  observacion STRING,
  estado STRING NOT NULL DEFAULT 'ACTIVO',
  creado_en TIMESTAMPTZ NOT NULL DEFAULT now(),
  actualizado_en TIMESTAMPTZ NOT NULL DEFAULT now(),
  eliminado_en TIMESTAMPTZ NULL,
  creado_por_usuario_id UUID,
  actualizado_por_usuario_id UUID,
  eliminado_por_usuario_id UUID,
  CONSTRAINT ck_fc_estado
    CHECK (estado IN ('ACTIVO','ANULADO','ELIMINADO')),
  CONSTRAINT ck_fc_numero_doc_longitud
    CHECK (char_length(numero_documento) <= 40),
  CONSTRAINT ck_fc_total CHECK (total_facturado >= 0)
);

ALTER TABLE facturacion_contractual ADD CONSTRAINT fk_fc_contrato
  FOREIGN KEY (id_contrato) REFERENCES contrato(id) ON DELETE RESTRICT;
ALTER TABLE facturacion_contractual ADD CONSTRAINT fk_fc_zona_contratada
  FOREIGN KEY (id_zona_contratada) REFERENCES zona_contratada(id) ON DELETE RESTRICT;
ALTER TABLE facturacion_contractual ADD CONSTRAINT fk_fc_periodo
  FOREIGN KEY (id_periodo) REFERENCES periodo(id) ON DELETE RESTRICT;

CREATE UNIQUE INDEX uq_facturacion_contractual_documento
  ON facturacion_contractual (id_empresa, id_contrato, id_periodo, numero_documento)
  WHERE estado != 'ELIMINADO';
CREATE INDEX idx_facturacion_contractual_periodo
  ON facturacion_contractual (id_empresa, id_periodo);

-- >>> esquema/facturacion_y_valorizacion/entidad_facturacion_contractual_detalle.sql
CREATE TABLE facturacion_contractual_detalle (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_empresa UUID NOT NULL,
  id_facturacion_contractual UUID NOT NULL,
  concepto STRING NOT NULL,
  importe DECIMAL(18,2) NOT NULL,
  estado STRING NOT NULL DEFAULT 'ACTIVO',
  creado_en TIMESTAMPTZ NOT NULL DEFAULT now(),
  actualizado_en TIMESTAMPTZ NOT NULL DEFAULT now(),
  eliminado_en TIMESTAMPTZ NULL,
  creado_por_usuario_id UUID,
  actualizado_por_usuario_id UUID,
  eliminado_por_usuario_id UUID,
  CONSTRAINT ck_fcd_estado
    CHECK (estado IN ('ACTIVO','ANULADO','ELIMINADO')),
  CONSTRAINT ck_fcd_concepto_longitud
    CHECK (char_length(concepto) <= 200),
  CONSTRAINT ck_fcd_importe CHECK (importe >= 0)
);

ALTER TABLE facturacion_contractual_detalle ADD CONSTRAINT fk_fcd_facturacion
  FOREIGN KEY (id_facturacion_contractual) REFERENCES facturacion_contractual(id) ON DELETE RESTRICT;

CREATE INDEX idx_facturacion_contractual_detalle_cabecera
  ON facturacion_contractual_detalle (id_facturacion_contractual);

-- >>> esquema/facturacion_y_valorizacion/entidad_valorizacion_complementaria.sql
CREATE TABLE valorizacion_complementaria(
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_empresa UUID NOT NULL,
  id_contrato UUID NOT NULL,
  id_contrato_zona UUID NOT NULL,
  id_periodo UUID NOT NULL,
  tipo_ajuste STRING NOT NULL,
  motivo STRING NOT NULL,
  fecha_registro DATE NOT NULL DEFAULT current_date(),
  total_valorizacion_complementaria DECIMAL(18,2) NOT NULL DEFAULT 0,
  estado STRING NOT NULL DEFAULT 'BORRADOR',
  creado_en TIMESTAMPTZ NOT NULL DEFAULT now(),
  actualizado_en TIMESTAMPTZ NOT NULL DEFAULT now(),
  eliminado_en TIMESTAMPTZ NULL,
  creado_por_usuario_id UUID NOT NULL,
  actualizado_por_usuario_id UUID,
  eliminado_por_usuario_id UUID,

  CONSTRAINT fk_valorizacion_complementaria_empresa
    FOREIGN KEY (id_empresa) REFERENCES empresa(id) ON DELETE RESTRICT,

  CONSTRAINT fk_valorizacion_complementaria_contrato
    FOREIGN KEY (id_contrato) REFERENCES contrato(id) ON DELETE RESTRICT,

  CONSTRAINT fk_valorizacion_complementaria_contrato_zona
    FOREIGN KEY (id_contrato_zona) REFERENCES contrato_zona(id) ON DELETE RESTRICT,

  CONSTRAINT fk_valorizacion_complementaria_periodo
    FOREIGN KEY (id_periodo) REFERENCES periodo(id) ON DELETE RESTRICT,

  CONSTRAINT fk_valorizacion_complementaria_creado_por_usuario
    FOREIGN KEY (creado_por_usuario_id) REFERENCES usuario(id) ON DELETE RESTRICT,

  CONSTRAINT fk_valorizacion_complementaria_actualizado_por_usuario
    FOREIGN KEY (actualizado_por_usuario_id) REFERENCES usuario(id) ON DELETE RESTRICT,

  CONSTRAINT fk_valorizacion_complementaria_eliminado_por_usuario
    FOREIGN KEY (eliminado_por_usuario_id) REFERENCES usuario(id) ON DELETE RESTRICT,

  CONSTRAINT ck_valorizacion_complementaria_estado
    CHECK (estado IN ('BORRADOR','VALIDADO','APROBADO','ANULADO')),

  CONSTRAINT ck_valorizacion_complementaria_tipo_ajuste
    CHECK (tipo_ajuste IN ('REGULARIZACION','CORRECCION', 'RECONOCIMIENTO_EXTRAORDINARIO', 'AJUSTE_MANUAL')),
  
  CONSTRAINT ck_valorizacion_complementaria_motivo
    CHECK (char_length(motivo) >= 5 AND char_length(motivo) <= 250),
  
  CONSTRAINT ck_valorizacion_complementaria_total
    CHECK (total_valorizacion_complementaria >= 0)
    
);

CREATE INDEX idx_valorizacion_complementaria_contexto
  ON valorizacion_complementaria (id_empresa, id_contrato, id_contrato_zona, id_periodo);


-- CREATE TABLE valorizacion_complementaria (
--   id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
--   id_empresa UUID NOT NULL,
--   id_contrato UUID NOT NULL,
--   id_zona_contratada UUID NOT NULL,
--   id_periodo UUID NOT NULL,
--   motivo STRING NOT NULL,
--   fecha_registro DATE NOT NULL DEFAULT current_date(),
--   total_valorizacion_complementaria DECIMAL(18,2) NOT NULL DEFAULT 0,
--   estado STRING NOT NULL DEFAULT 'ACTIVO',
--   creado_en TIMESTAMPTZ NOT NULL DEFAULT now(),
--   actualizado_en TIMESTAMPTZ NOT NULL DEFAULT now(),
--   eliminado_en TIMESTAMPTZ NULL,
--   creado_por_usuario_id UUID,
--   actualizado_por_usuario_id UUID,
--   eliminado_por_usuario_id UUID,
--   CONSTRAINT ck_vc_estado
--     CHECK (estado IN ('ACTIVO','CORREGIDO','ANULADO','ELIMINADO')),
--   CONSTRAINT ck_vc_motivo CHECK (char_length(motivo) <= 250),
--   CONSTRAINT ck_vc_total CHECK (total_valorizacion_complementaria >= 0)
-- );

-- CREATE INDEX idx_valorizacion_complementaria_contexto
--   ON valorizacion_complementaria (id_empresa, id_contrato, id_zona_contratada, id_periodo);

-- >>> esquema/produccion/entidad_rubro.sql

CREATE TABLE rubro (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_empresa UUID NOT NULL,

    codigo STRING NOT NULL,
    nombre STRING NOT NULL,
    descripcion STRING,
    estado STRING NOT NULL DEFAULT 'ACTIVO',

    creado_en TIMESTAMPTZ NOT NULL DEFAULT now(),
    actualizado_en TIMESTAMPTZ NOT NULL DEFAULT now(),
    eliminado_en TIMESTAMPTZ NULL,

    creado_por_usuario_id UUID,
    actualizado_por_usuario_id UUID,
    eliminado_por_usuario_id UUID,

    CONSTRAINT uq_rubro_empresa_codigo
        UNIQUE (id_empresa, codigo),

    CONSTRAINT uq_rubro_empresa_nombre
        UNIQUE (id_empresa, nombre),

    CONSTRAINT ck_rubro_estado
        CHECK (estado IN ('ACTIVO', 'SUSPENDIDO', 'ELIMINADO')),

    CONSTRAINT ck_rubro_codigo_longitud
        CHECK (char_length(codigo) <= 30),

    CONSTRAINT ck_rubro_nombre_longitud
        CHECK (char_length(nombre) <= 80),

    CONSTRAINT ck_rubro_descripcion_longitud
        CHECK (descripcion IS NULL OR char_length(descripcion) <= 200)
);
ALTER TABLE rubro
ADD CONSTRAINT fk_rubro_empresa
FOREIGN KEY (id_empresa)
REFERENCES empresa(id)
ON DELETE RESTRICT;

ALTER TABLE rubro
ADD CONSTRAINT fk_rubro_creado_por_usuario
FOREIGN KEY (creado_por_usuario_id)
REFERENCES usuario(id)
ON DELETE RESTRICT;

ALTER TABLE rubro
ADD CONSTRAINT fk_rubro_actualizado_por_usuario
FOREIGN KEY (actualizado_por_usuario_id)
REFERENCES usuario(id)
ON DELETE RESTRICT;

ALTER TABLE rubro
ADD CONSTRAINT fk_rubro_eliminado_por_usuario
FOREIGN KEY (eliminado_por_usuario_id)
REFERENCES usuario(id)
ON DELETE RESTRICT;

-- >>> esquema/facturacion_y_valorizacion/entidad_valorizacion_complementaria_detalle.sql
CREATE TABLE valorizacion_complementaria_detalle (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_empresa UUID NOT NULL,
  id_valorizacion_complementaria UUID NOT NULL,
  id_rubro UUID NOT NULL,
  concepto STRING NOT NULL,
  cantidad DECIMAL(18,4) NOT NULL DEFAULT 1,
  precio_unitario DECIMAL(18,4) NOT NULL,
  importe DECIMAL(18,2) NOT NULL,
  observacion STRING,
  estado STRING NOT NULL DEFAULT 'ACTIVO',
  creado_en TIMESTAMPTZ NOT NULL DEFAULT now(),
  actualizado_en TIMESTAMPTZ NOT NULL DEFAULT now(),
  eliminado_en TIMESTAMPTZ NULL,
  creado_por_usuario_id UUID NOT NULL,
  actualizado_por_usuario_id UUID,
  eliminado_por_usuario_id UUID,

  CONSTRAINT fk_valorizacion_complementaria_detalle_empresa
    FOREIGN KEY (id_empresa) REFERENCES empresa(id) ON DELETE RESTRICT,
  
  CONSTRAINT fk_valorizacion_complementaria_detalle_cabecera
    FOREIGN KEY (id_valorizacion_complementaria) REFERENCES valorizacion_complementaria(id) ON DELETE CASCADE,
  
  CONSTRAINT fk_valorizacion_complementaria_detalle_rubro
    FOREIGN KEY (id_rubro) REFERENCES rubro(id) ON DELETE RESTRICT,
  
  CONSTRAINT fk_valorizacion_complementaria_detalle_creado_por_usuario
    FOREIGN KEY (creado_por_usuario_id) REFERENCES usuario(id) ON DELETE RESTRICT,
  
  CONSTRAINT fk_valorizacion_complementaria_detalle_actualizado_por_usuario
    FOREIGN KEY (actualizado_por_usuario_id) REFERENCES usuario(id) ON DELETE RESTRICT,
  
  CONSTRAINT fk_valorizacion_complementaria_detalle_eliminado_por_usuario
    FOREIGN KEY (eliminado_por_usuario_id) REFERENCES usuario(id) ON DELETE RESTRICT,
  
  CONSTRAINT ck_valorizacion_complementaria_detalle_estado
    CHECK (estado IN ('ACTIVO','ANULADO')),

  CONSTRAINT ck_valorizacion_complementaria_detalle_cantidad 
    CHECK (cantidad > 0),
  
  CONSTRAINT ck_valorizacion_complementaria_detalle_precio 
    CHECK (precio_unitario >= 0),
  
  CONSTRAINT ck_valorizacion_complementaria_detalle_importe 
    CHECK (importe >= 0),
  
  CONSTRAINT ck_valorizacion_complementaria_detalle_concepto
    CHECK (char_length(concepto) >= 3 AND char_length(concepto) <= 150)
);

CREATE INDEX idx_valorizacion_complementaria_detalle_cabecera
  ON valorizacion_complementaria_detalle (id_valorizacion_complementaria);

CREATE INDEX idx_valorizacion_complementaria_detalle_rubro
  ON valorizacion_complementaria_detalle (id_empresa, id_rubro);
  








-- CREATE TABLE valorizacion_complementaria_detalle (
--   id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
--   id_empresa UUID NOT NULL,
--   id_valorizacion_complementaria UUID NOT NULL,
--   descripcion STRING NOT NULL,
--   cantidad DECIMAL(18,4) NOT NULL DEFAULT 1,
--   precio_unitario DECIMAL(18,4) NOT NULL,
--   importe DECIMAL(18,2) NOT NULL,
--   estado STRING NOT NULL DEFAULT 'ACTIVO',
--   creado_en TIMESTAMPTZ NOT NULL DEFAULT now(),
--   actualizado_en TIMESTAMPTZ NOT NULL DEFAULT now(),
--   eliminado_en TIMESTAMPTZ NULL,
--   creado_por_usuario_id UUID,
--   actualizado_por_usuario_id UUID,
--   eliminado_por_usuario_id UUID,
--   CONSTRAINT ck_vcd_estado
--     CHECK (estado IN ('ACTIVO','CORREGIDO','ANULADO','ELIMINADO')),
--   CONSTRAINT ck_vcd_cantidad CHECK (cantidad > 0),
--   CONSTRAINT ck_vcd_precio CHECK (precio_unitario >= 0),
--   CONSTRAINT ck_vcd_importe CHECK (importe >= 0)
-- );

-- >>> esquema/produccion/entidad_produccion_mensual.sql
CREATE TABLE produccion_mensual (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_empresa UUID NOT NULL,
    id_contrato UUID NOT NULL,
    id_contrato_zona UUID NOT NULL,
    id_periodo UUID NOT NULL,
    total_valorizado NUMERIC(18, 2) NOT NULL DEFAULT 0,
    fecha_registro DATE NOT NULL DEFAULT current_date(),
    observacion STRING(300),
    estado STRING NOT NULL DEFAULT 'ACTIVO',
    creado_en TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    actualizado_en TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    eliminado_en TIMESTAMPTZ NULL,
    creado_por_usuario_id UUID,
    actualizado_por_usuario_id UUID,
    eliminado_por_usuario_id UUID,
    CONSTRAINT uq_produccion_mensual UNIQUE (
        id_empresa,
        id_contrato,
        id_contrato_zona,
        id_periodo
    ),
    CONSTRAINT ck_produccion_mensual_estado CHECK (
        estado IN ('ACTIVO', 'CORREGIDO', 'ANULADO')
    ),
    CONSTRAINT ck_produccion_mensual_total_valorizado CHECK (total_valorizado >= 0)
);

ALTER TABLE produccion_mensual
ADD CONSTRAINT fk_produccion_mensual_empresa FOREIGN KEY (id_empresa) REFERENCES empresa (id) ON DELETE RESTRICT;

ALTER TABLE produccion_mensual
ADD CONSTRAINT fk_produccion_mensual_contrato FOREIGN KEY (id_contrato) REFERENCES contrato (id) ON DELETE RESTRICT;

ALTER TABLE produccion_mensual
ADD CONSTRAINT fk_produccion_mensual_contrato_zona FOREIGN KEY (id_contrato_zona) REFERENCES contrato_zona (id) ON DELETE RESTRICT;

ALTER TABLE produccion_mensual
ADD CONSTRAINT fk_produccion_mensual_periodo FOREIGN KEY (id_periodo) REFERENCES periodo (id) ON DELETE RESTRICT;

ALTER TABLE produccion_mensual
ADD CONSTRAINT fk_produccion_mensual_creado_por FOREIGN KEY (creado_por_usuario_id) REFERENCES usuario (id) ON DELETE RESTRICT;

ALTER TABLE produccion_mensual
ADD CONSTRAINT fk_produccion_mensual_actualizado_por FOREIGN KEY (actualizado_por_usuario_id) REFERENCES usuario (id) ON DELETE RESTRICT;

ALTER TABLE produccion_mensual
ADD CONSTRAINT fk_produccion_mensual_eliminado_por FOREIGN KEY (eliminado_por_usuario_id) REFERENCES usuario (id) ON DELETE RESTRICT;

CREATE INDEX idx_produccion_mensual_empresa_periodo ON produccion_mensual (id_empresa, id_periodo)
WHERE
    eliminado_en IS NULL;

CREATE INDEX idx_produccion_mensual_contrato_periodo ON produccion_mensual (id_contrato, id_periodo)
WHERE
    eliminado_en IS NULL;

-- >>> esquema/facturacion_y_valorizacion/entidad_valorizacion_mensual.sql
CREATE TABLE valorizacion_mensual (

  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_empresa UUID NOT NULL,
  id_contrato UUID NOT NULL,
  id_contrato_zona UUID NOT NULL,
  id_periodo UUID NOT NULL,
  id_produccion_mensual UUID NOT NULL,
  fecha_valorizacion DATE NOT NULL DEFAULT current_date(),
  observacion STRING,
  total_valorizacion_mensual DECIMAL(18,2) NOT NULL DEFAULT 0,
  estado STRING NOT NULL DEFAULT 'BORRADOR',
  creado_en TIMESTAMPTZ NOT NULL DEFAULT now(),
  actualizado_en TIMESTAMPTZ NOT NULL DEFAULT now(),
  eliminado_en TIMESTAMPTZ NULL,
  creado_por_usuario_id UUID NOT NULL,
  actualizado_por_usuario_id UUID,
  eliminado_por_usuario_id UUID,

  CONSTRAINT fk_valorizacion_mensual_empresa
    FOREIGN KEY (id_empresa) REFERENCES empresa(id) ON DELETE RESTRICT,

  CONSTRAINT fk_valorizacion_mensual_contrato
    FOREIGN KEY (id_contrato) REFERENCES contrato(id) ON DELETE RESTRICT,
  
  CONSTRAINT fk_valorizacion_mensual_contrato_zona
    FOREIGN KEY (id_contrato_zona) REFERENCES contrato_zona(id) ON DELETE RESTRICT,
  
  CONSTRAINT fk_valorizacion_mensual_periodo
    FOREIGN KEY (id_periodo) REFERENCES periodo(id) ON DELETE RESTRICT,
  
  CONSTRAINT fk_valorizacion_mensual_produccion
    FOREIGN KEY (id_produccion_mensual) REFERENCES produccion_mensual(id) ON DELETE RESTRICT,
  
  CONSTRAINT fk_valorizacion_mensual_creado_por_usuario
    FOREIGN KEY (creado_por_usuario_id) REFERENCES usuario(id) ON DELETE RESTRICT,
  
  CONSTRAINT fk_valorizacion_mensual_actualizado_por_usuario
    FOREIGN KEY (actualizado_por_usuario_id) REFERENCES usuario(id) ON DELETE RESTRICT,

  CONSTRAINT fk_valorizacion_mensual_eliminado_por_usuario
    FOREIGN KEY (eliminado_por_usuario_id) REFERENCES usuario(id) ON DELETE RESTRICT,
  
  CONSTRAINT ck_valorizacion_mensual_estado
    CHECK (estado IN ('BORRADOR','VALIDADO','APROBADO','ANULADO')),

  CONSTRAINT ck_valorizacion_mensual_total 
    CHECK (total_valorizacion_mensual >= 0),

  CONSTRAINT uq_valorizacion_mensual_contexto
    UNIQUE (id_empresa, id_contrato, id_contrato_zona, id_periodo)

);

CREATE INDEX idx_valorizacion_mensual_periodo
  ON valorizacion_mensual (id_empresa, id_periodo);

CREATE INDEX idx_valorizacion_mensual_contrato
  ON valorizacion_mensual (id_empresa, id_contrato, id_contrato_zona);

-- CREATE TABLE valorizacion_mensual (
--   id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
--   id_empresa UUID NOT NULL,
--   id_contrato UUID NOT NULL,
--   id_zona_contratada UUID NOT NULL,
--   id_periodo UUID NOT NULL,
--   id_produccion_mensual UUID NOT NULL,
--   fecha_valorizacion DATE NOT NULL DEFAULT current_date(),
--   total_valorizacion_mensual DECIMAL(18,2) NOT NULL DEFAULT 0,
--   observacion STRING,
--   estado STRING NOT NULL DEFAULT 'ACTIVO',
--   creado_en TIMESTAMPTZ NOT NULL DEFAULT now(),
--   actualizado_en TIMESTAMPTZ NOT NULL DEFAULT now(),
--   eliminado_en TIMESTAMPTZ NULL,
--   creado_por_usuario_id UUID,
--   actualizado_por_usuario_id UUID,
--   eliminado_por_usuario_id UUID,
--   CONSTRAINT ck_vm_estado
--     CHECK (estado IN ('ACTIVO','CORREGIDO','ANULADO','ELIMINADO')),
--   CONSTRAINT ck_vm_total CHECK (total_valorizacion_mensual >= 0)
-- );

-- ALTER TABLE valorizacion_mensual ADD CONSTRAINT fk_vm_produccion
--   FOREIGN KEY (id_produccion_mensual) REFERENCES produccion_mensual(id) ON DELETE RESTRICT;

-- CREATE UNIQUE INDEX uq_valorizacion_mensual_produccion
--   ON valorizacion_mensual (id_empresa, id_produccion_mensual)
--   WHERE estado != 'ELIMINADO';
-- CREATE INDEX idx_valorizacion_mensual_periodo
--   ON valorizacion_mensual (id_empresa, id_periodo);

-- >>> esquema/facturacion_y_valorizacion/entidad_valorizacion_mensual_detalle.sql
CREATE TABLE valorizacion_mensual_detalle (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_empresa UUID NOT NULL,
  id_valorizacion_mensual UUID NOT NULL,
  id_rubro UUID NOT NULL,
  concepto STRING NOT NULL,
  cantidad_valorizada DECIMAL(18,4) NOT NULL,
  precio_unitario DECIMAL(18,4) NOT NULL,
  importe_valorizado DECIMAL(18,2) NOT NULL,
  observacion STRING,
  estado STRING NOT NULL DEFAULT 'ACTIVO',
  creado_en TIMESTAMPTZ NOT NULL DEFAULT now(),
  actualizado_en TIMESTAMPTZ NOT NULL DEFAULT now(),
  eliminado_en TIMESTAMPTZ NULL,
  creado_por_usuario_id UUID NOT NULL,
  actualizado_por_usuario_id UUID,
  eliminado_por_usuario_id UUID,


  CONSTRAINT fk_valorizacion_mensual_detalle_empresa
    FOREIGN KEY (id_empresa) REFERENCES empresa(id) ON DELETE RESTRICT,

  CONSTRAINT fk_valorizacion_mensual_detalle_cabecera
    FOREIGN KEY (id_valorizacion_mensual) REFERENCES valorizacion_mensual(id) ON DELETE CASCADE,

  CONSTRAINT fk_valorizacion_mensual_detalle_rubro
    FOREIGN KEY (id_rubro) REFERENCES rubro(id) ON DELETE RESTRICT,
  
  CONSTRAINT fk_valorizacion_mensual_detalle_creado_por_usuario
    FOREIGN KEY (creado_por_usuario_id) REFERENCES usuario(id) ON DELETE RESTRICT,
  
  CONSTRAINT fk_valorizacion_mensual_detalle_actualizado_por_usuario
    FOREIGN KEY (actualizado_por_usuario_id) REFERENCES usuario(id) ON DELETE RESTRICT,

  CONSTRAINT fk_valorizacion_mensual_detalle_eliminado_por_usuario  
    FOREIGN KEY (eliminado_por_usuario_id) REFERENCES usuario(id) ON DELETE RESTRICT,

  CONSTRAINT ck_valoracion_mensual_detalle_estado
    CHECK (estado IN ('ACTIVO','ANULADO')),

  CONSTRAINT ck_valorizacion_mensual_detalle_cantidad 
    CHECK (cantidad_valorizada > 0),

  CONSTRAINT ck_valorizacion_mensual_detalle_precio 
    CHECK (precio_unitario >= 0),

  CONSTRAINT ck_valorizacion_mensual_detalle_importe 
    CHECK (importe_valorizado >= 0),

  CONSTRAINT ck_valorizacion_mensual_detalle_concepto
    CHECK (char_length(concepto) >= 3 AND char_length(concepto) <= 150)
);

CREATE INDEX idx_valorizacion_mensual_detalle_cabecera
  ON valorizacion_mensual_detalle (id_valorizacion_mensual);

CREATE INDEX idx_valorizacion_mensual_detalle_rubro
  ON valorizacion_mensual_detalle (id_empresa, id_rubro);


-- CREATE TABLE valorizacion_mensual_detalle (
--   id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
--   id_empresa UUID NOT NULL,
--   id_valorizacion_mensual UUID NOT NULL,
--   id_grupo_actividad UUID NOT NULL,
--   cantidad_valorizada DECIMAL(18,4) NOT NULL,
--   precio_unitario DECIMAL(18,4) NOT NULL,
--   importe_valorizado DECIMAL(18,2) NOT NULL,
--   estado STRING NOT NULL DEFAULT 'ACTIVO',
--   creado_en TIMESTAMPTZ NOT NULL DEFAULT now(),
--   actualizado_en TIMESTAMPTZ NOT NULL DEFAULT now(),
--   eliminado_en TIMESTAMPTZ NULL,
--   creado_por_usuario_id UUID,
--   actualizado_por_usuario_id UUID,
--   eliminado_por_usuario_id UUID,
--   CONSTRAINT ck_vmd_estado
--     CHECK (estado IN ('ACTIVO','CORREGIDO','ANULADO','ELIMINADO')),
--   CONSTRAINT ck_vmd_cantidad CHECK (cantidad_valorizada > 0),
--   CONSTRAINT ck_vmd_precio CHECK (precio_unitario >= 0),
--   CONSTRAINT ck_vmd_importe CHECK (importe_valorizado >= 0)
-- );

-- >>> esquema/gobierno_central/entidad_rol.sql
CREATE TABLE rol (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_empresa UUID NOT NULL,
    nombre STRING NOT NULL,
    descripcion STRING,
    estado STRING NOT NULL DEFAULT 'ACTIVO',
    creado_en TIMESTAMPTZ NOT NULL DEFAULT now(),
    actualizado_en TIMESTAMPTZ NOT NULL DEFAULT now(),
    eliminado_en TIMESTAMPTZ NULL,
    creado_por_usuario_id UUID,
    actualizado_por_usuario_id UUID,
    eliminado_por_usuario_id UUID,
    
    CONSTRAINT fk_rol_empresa
        FOREIGN KEY (id_empresa) REFERENCES empresa(id) ON DELETE RESTRICT,
        
    CONSTRAINT ck_rol_estado
         CHECK (estado IN ('ACTIVO', 'SUSPENDIDO')),
    
    CONSTRAINT ck_rol_nombre_longitud
         CHECK (char_length(nombre) <= 60),
         
    CONSTRAINT ck_rol_descripcion_longitud
         CHECK (descripcion IS NULL OR char_length(descripcion) <= 200),
    
    CONSTRAINT uk_rol_empresa_nombre
          UNIQUE (id_empresa, nombre)

);


ALTER TABLE rol
ADD CONSTRAINT fk_rol_creado_por_usuario 
FOREIGN KEY (creado_por_usuario_id) REFERENCES usuario(id) ON DELETE RESTRICT;

ALTER TABLE rol
ADD CONSTRAINT fk_rol_actualizado_por_usuario 
FOREIGN KEY (actualizado_por_usuario_id) REFERENCES usuario(id) ON DELETE RESTRICT;

ALTER TABLE rol
ADD CONSTRAINT fk_rol_eliminado_por_usuario 
FOREIGN KEY (eliminado_por_usuario_id) REFERENCES usuario(id) ON DELETE RESTRICT;

-- >>> esquema/gobierno_central/entidad_permiso.sql
CREATE TABLE permiso (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_empresa UUID        NOT NULL,
  id_rol     UUID        NOT NULL ,
  modulo     STRING NOT NULL ,
  accion     STRING NOT NULL ,
  estado     STRING NOT NULL DEFAULT 'ACTIVO',
  creado_en  TIMESTAMPTZ DEFAULT NOW(),
  actualizado_en  TIMESTAMPTZ DEFAULT NOW(),
  creado_por_usuario_id UUID,
  actualizado_por_usuario_id UUID,

  CONSTRAINT uk_permiso_rol_modulo_accion
    UNIQUE (id_rol, modulo, accion)
);

ALTER TABLE permiso
ADD CONSTRAINT fk_permiso_empresa
FOREIGN KEY (id_empresa) REFERENCES empresa(id) ON DELETE RESTRICT;

ALTER TABLE permiso
ADD CONSTRAINT fk_permiso_rol
FOREIGN KEY (id_rol) REFERENCES rol(id) ON DELETE RESTRICT;

ALTER TABLE permiso
ADD CONSTRAINT fk_permiso_creado_por
FOREIGN KEY (creado_por_usuario_id) REFERENCES usuario(id) ON DELETE RESTRICT;

ALTER TABLE permiso
ADD CONSTRAINT fk_permiso_actualizado_por
FOREIGN KEY (actualizado_por_usuario_id) REFERENCES usuario(id) ON DELETE RESTRICT;

-- >>> esquema/gobierno_central/entidad_usuario_empresa.sql
CREATE TABLE usuario_empresa (
  id                          UUID        PRIMARY KEY NOT NULL DEFAULT gen_random_uuid(),
  id_empresa                  UUID        NOT NULL,
  id_usuario                  UUID        NOT NULL,
  estado                      STRING      NOT NULL DEFAULT 'ACTIVO',
  creado_en                   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  actualizado_en              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  eliminado_en                TIMESTAMPTZ NULL,
  creado_por_usuario_id       UUID,
  actualizado_por_usuario_id  UUID,
  eliminado_por_usuario_id    UUID,

  CONSTRAINT uq_usuario_empresa
    UNIQUE (id_empresa, id_usuario),

  CONSTRAINT ck_usuario_empresa_estado
    CHECK (estado IN ('ACTIVO', 'SUSPENDIDO'))
);

ALTER TABLE usuario_empresa
ADD CONSTRAINT fk_usuario_empresa
FOREIGN KEY (id_empresa) REFERENCES empresa(id) ON DELETE RESTRICT;

ALTER TABLE usuario_empresa
ADD CONSTRAINT fk_usuario_empresa_usuario
FOREIGN KEY (id_usuario) REFERENCES usuario(id) ON DELETE RESTRICT;

ALTER TABLE usuario_empresa
ADD CONSTRAINT fk_usuario_empresa_creado_por_usuario
FOREIGN KEY (creado_por_usuario_id) REFERENCES usuario(id) ON DELETE RESTRICT;

ALTER TABLE usuario_empresa
ADD CONSTRAINT fk_usuario_empresa_actualizado_por_usuario
FOREIGN KEY (actualizado_por_usuario_id) REFERENCES usuario(id) ON DELETE RESTRICT;

ALTER TABLE usuario_empresa
ADD CONSTRAINT fk_usuario_empresa_eliminado_por_usuario
FOREIGN KEY (eliminado_por_usuario_id) REFERENCES usuario(id) ON DELETE RESTRICT;

-- >>> esquema/gobierno_central/entidad_usuario_rol.sql
CREATE TABLE usuario_rol (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_usuario_empresa UUID NOT NULL,
    id_rol UUID NOT NULL,
    estado STRING NOT NULL DEFAULT 'ACTIVO',
    creado_en TIMESTAMPTZ NOT NULL DEFAULT now(),
    actualizado_en TIMESTAMPTZ NOT NULL DEFAULT now(),
    eliminado_en TIMESTAMPTZ NULL,
    creado_por_usuario_id UUID,
    actualizado_por_usuario_id UUID,
    eliminado_por_usuario_id UUID,

    CONSTRAINT uq_usuario_rol
        UNIQUE (id_usuario_empresa, id_rol),

    CONSTRAINT ck_usuario_rol_estado
        CHECK (estado IN ('ACTIVO', 'SUSPENDIDO'))
);

ALTER TABLE usuario_rol
ADD CONSTRAINT fk_usuario_rol_usuario_empresa
FOREIGN KEY (id_usuario_empresa) REFERENCES usuario_empresa(id) ON DELETE RESTRICT;

ALTER TABLE usuario_rol
ADD CONSTRAINT fk_usuario_rol_rol
FOREIGN KEY (id_rol) REFERENCES rol(id) ON DELETE RESTRICT;

ALTER TABLE usuario_rol
ADD CONSTRAINT fk_usuario_rol_creado_por_usuario
FOREIGN KEY (creado_por_usuario_id) REFERENCES usuario(id) ON DELETE RESTRICT;

ALTER TABLE usuario_rol
ADD CONSTRAINT fk_usuario_rol_actualizado_por_usuario
FOREIGN KEY (actualizado_por_usuario_id) REFERENCES usuario(id) ON DELETE RESTRICT;

ALTER TABLE usuario_rol
ADD CONSTRAINT fk_usuario_rol_eliminado_por_usuario
FOREIGN KEY (eliminado_por_usuario_id) REFERENCES usuario(id) ON DELETE RESTRICT;

-- >>> esquema/produccion/entidad_linea_servicio.sql

CREATE TABLE linea_servicio (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_empresa UUID NOT NULL,
    id_grupo_actividad UUID NOT NULL,
    codigo STRING(30) NOT NULL,
    nombre STRING(80) NOT NULL,
    descripcion STRING(200),
    estado STRING NOT NULL DEFAULT 'ACTIVO',
    creado_en TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    actualizado_en TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    eliminado_en TIMESTAMPTZ NULL,
    creado_por_usuario_id UUID,
    actualizado_por_usuario_id UUID,
    eliminado_por_usuario_id UUID,

    CONSTRAINT ck_linea_servicio_estado CHECK (
        estado IN ('ACTIVO', 'SUSPENDIDO')
    ),

    CONSTRAINT ck_linea_servicio_codigo_mayuscula CHECK (
        codigo = upper(codigo)
    )
);

ALTER TABLE linea_servicio
ADD CONSTRAINT fk_linea_servicio_empresa
FOREIGN KEY (id_empresa) REFERENCES empresa(id) ON DELETE RESTRICT;

ALTER TABLE linea_servicio
ADD CONSTRAINT fk_linea_servicio_grupo_actividad
FOREIGN KEY (id_grupo_actividad) REFERENCES grupo_actividad(id) ON DELETE RESTRICT;

ALTER TABLE linea_servicio
ADD CONSTRAINT fk_linea_servicio_creado_por
FOREIGN KEY (creado_por_usuario_id) REFERENCES usuario(id) ON DELETE RESTRICT;

ALTER TABLE linea_servicio
ADD CONSTRAINT fk_linea_servicio_actualizado_por
FOREIGN KEY (actualizado_por_usuario_id) REFERENCES usuario(id) ON DELETE RESTRICT;

ALTER TABLE linea_servicio
ADD CONSTRAINT fk_linea_servicio_eliminado_por
FOREIGN KEY (eliminado_por_usuario_id) REFERENCES usuario(id) ON DELETE RESTRICT;

-- >>> esquema/produccion/entidad_operario.sql
CREATE TABLE operario (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_empresa UUID NOT NULL,
    tipo_documento STRING(20) NOT NULL,
    numero_documento STRING(20) NOT NULL,
    nombres STRING(120) NOT NULL,
    apellidos STRING(120) NOT NULL,
    cargo STRING(120),
    licencia STRING(60),
    estado STRING NOT NULL DEFAULT 'ACTIVO',
    creado_en TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    actualizado_en TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    eliminado_en TIMESTAMPTZ NULL,
    creado_por_usuario_id UUID,
    actualizado_por_usuario_id UUID,
    eliminado_por_usuario_id UUID,
    CONSTRAINT uq_operario_empresa_documento UNIQUE (id_empresa, tipo_documento, numero_documento),
    CONSTRAINT ck_operario_estado CHECK (
        estado IN ('ACTIVO', 'SUSPENDIDO', 'ELIMINADO')
    ),
    CONSTRAINT ck_operario_tipo_documento CHECK (
        tipo_documento IN ('DNI', 'CE', 'PASAPORTE', 'OTRO')
    )
);

ALTER TABLE operario
ADD CONSTRAINT fk_operario_empresa FOREIGN KEY (id_empresa) REFERENCES empresa (id) ON DELETE RESTRICT;

ALTER TABLE operario
ADD CONSTRAINT fk_operario_creado_por FOREIGN KEY (creado_por_usuario_id) REFERENCES usuario (id) ON DELETE RESTRICT;

ALTER TABLE operario
ADD CONSTRAINT fk_operario_actualizado_por FOREIGN KEY (actualizado_por_usuario_id) REFERENCES usuario (id) ON DELETE RESTRICT;

ALTER TABLE operario
ADD CONSTRAINT fk_operario_eliminado_por FOREIGN KEY (eliminado_por_usuario_id) REFERENCES usuario (id) ON DELETE RESTRICT;

CREATE INDEX idx_operario_empresa ON operario (id_empresa)
WHERE
    eliminado_en IS NULL;

-- >>> esquema/produccion/entidad_produccion_mensual_detalle.sql
CREATE TABLE produccion_mensual_detalle (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_empresa UUID NOT NULL,
    id_produccion_mensual UUID NOT NULL,
    id_linea_servicio UUID NOT NULL,
    id_operario UUID,
    descripcion STRING(300) NOT NULL,
    cantidad_producida NUMERIC(18, 4) NOT NULL,
    precio_unitario NUMERIC(18, 4) NOT NULL,
    valor_produccion_detalle NUMERIC(18, 2) NOT NULL,
    estado STRING NOT NULL DEFAULT 'ACTIVO',
    creado_en TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    actualizado_en TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    eliminado_en TIMESTAMPTZ NULL,
    creado_por_usuario_id UUID,
    actualizado_por_usuario_id UUID,
    eliminado_por_usuario_id UUID,
    CONSTRAINT ck_produccion_mensual_detalle_estado CHECK (
        estado IN ('ACTIVO', 'CORREGIDO', 'ANULADO')
    ),
    CONSTRAINT ck_produccion_mensual_detalle_cantidad CHECK (cantidad_producida > 0),
    CONSTRAINT ck_produccion_mensual_detalle_precio CHECK (precio_unitario >= 0),
    CONSTRAINT ck_produccion_mensual_detalle_valor CHECK (valor_produccion_detalle >= 0)
);

ALTER TABLE produccion_mensual_detalle
ADD CONSTRAINT fk_produccion_mensual_detalle_empresa FOREIGN KEY (id_empresa) REFERENCES empresa (id) ON DELETE RESTRICT;

ALTER TABLE produccion_mensual_detalle
ADD CONSTRAINT fk_produccion_mensual_detalle_produccion FOREIGN KEY (id_produccion_mensual) REFERENCES produccion_mensual (id) ON DELETE RESTRICT;

ALTER TABLE produccion_mensual_detalle
ADD CONSTRAINT fk_produccion_mensual_detalle_linea_servicio FOREIGN KEY (id_linea_servicio) REFERENCES linea_servicio (id) ON DELETE RESTRICT;

ALTER TABLE produccion_mensual_detalle
ADD CONSTRAINT fk_produccion_mensual_detalle_operario FOREIGN KEY (id_operario) REFERENCES operario (id) ON DELETE RESTRICT;

ALTER TABLE produccion_mensual_detalle
ADD CONSTRAINT fk_produccion_mensual_detalle_creado_por FOREIGN KEY (creado_por_usuario_id) REFERENCES usuario (id) ON DELETE RESTRICT;

ALTER TABLE produccion_mensual_detalle
ADD CONSTRAINT fk_produccion_mensual_detalle_actualizado_por FOREIGN KEY (actualizado_por_usuario_id) REFERENCES usuario (id) ON DELETE RESTRICT;

ALTER TABLE produccion_mensual_detalle
ADD CONSTRAINT fk_produccion_mensual_detalle_eliminado_por FOREIGN KEY (eliminado_por_usuario_id) REFERENCES usuario (id) ON DELETE RESTRICT;

CREATE INDEX idx_produccion_mensual_detalle_produccion ON produccion_mensual_detalle (id_produccion_mensual)
WHERE
    eliminado_en IS NULL;

CREATE INDEX idx_produccion_mensual_detalle_linea_servicio ON produccion_mensual_detalle (id_linea_servicio)
WHERE
    eliminado_en IS NULL;

-- ==================== INDICES ====================
-- >>> indices/activos-e-inversion/idx_activo.sql
CREATE INDEX idx_activo_estado ON activo (id_empresa, estado) WHERE eliminado_en IS NULL;
CREATE INDEX idx_star_activo_listado ON activo (id_empresa, creado_en DESC, id DESC) STORING (codigo, descripcion, estado, placa, marca, modelo, anio_fabricacion, costo_adquisicion, id_clasificacion_activo, id_tipo_adquisicion_activo) WHERE eliminado_en IS NULL;

-- >>> indices/activos-e-inversion/idx_activo_asignacion_contrato.sql
CREATE INDEX idx_activo_asignacion_contrato_activo ON activo_asignacion_contrato (id_activo, id_contrato);
CREATE INDEX idx_activo_asignacion_contrato_empresa ON activo_asignacion_contrato (id_empresa);
CREATE INDEX idx_activo_asignacion_contrato_estado ON activo_asignacion_contrato (id_activo, id_contrato) WHERE estado = 'ACTIVO';
CREATE INDEX idx_star_activo_asignacion_contrato_listado ON activo_asignacion_contrato (id_empresa, id_activo, creado_en DESC, id DESC) STORING (id_contrato, id_zona, inversion_asignada, saldo_inversion_pendiente, cuota_recuperacion_mensual, fecha_inicio, fecha_fin, estado) WHERE eliminado_en IS NULL;

-- >>> indices/activos-e-inversion/idx_activo_registro_trabajo.sql
CREATE INDEX idx_activo_registro_trabajo_activo ON activo_registro_trabajo (id_activo, id_periodo);
CREATE INDEX idx_activo_registro_trabajo_contrato ON activo_registro_trabajo (id_contrato, id_periodo);
CREATE INDEX idx_star_activo_registro_trabajo_listado ON activo_registro_trabajo (id_empresa, id_activo, creado_en DESC, id DESC) STORING (id_contrato, id_zona, id_operario, id_periodo, fecha, horas_trabajadas, descripcion_trabajo, valorizacion_trabajo, dias_depreciados, kilometraje_inicio, kilometraje_fin) WHERE eliminado_en IS NULL;

-- >>> indices/activos-e-inversion/idx_activo_traslado.sql
CREATE INDEX idx_activo_traslado_activo ON activo_traslado (id_activo);
CREATE INDEX idx_star_activo_traslado_listado ON activo_traslado (id_empresa, id_activo, creado_en DESC, id DESC) STORING (id_contrato_origen, id_zona_origen, id_contrato_destino, id_zona_destino, fecha_traslado, saldo_trasladado, motivo);

-- >>> indices/activos-e-inversion/idx_clasificacion_activo.sql
CREATE UNIQUE INDEX idx_unico_clasificacion_activo_codigo ON clasificacion_activo (id_empresa, codigo) WHERE eliminado_en IS NULL;

-- >>> indices/activos-e-inversion/idx_herramienta.sql
CREATE INDEX idx_star_herramienta_listado ON herramienta (id_empresa, creado_en DESC, id DESC) STORING (codigo, descripcion, marca, modelo, numero_serie, estado, costo_adquisicion, id_tipo_herramienta) WHERE eliminado_en IS NULL;

-- >>> indices/activos-e-inversion/idx_herramienta_movimiento.sql
CREATE INDEX idx_herramienta_movimiento_periodo ON herramienta_movimiento (id_empresa, id_periodo);
CREATE INDEX idx_herramienta_movimiento_origen ON herramienta_movimiento (id_contrato_origen);
CREATE INDEX idx_herramienta_movimiento_destino ON herramienta_movimiento (id_contrato_destino);
CREATE INDEX idx_star_herramienta_movimiento_listado ON herramienta_movimiento (id_empresa, id_herramienta, creado_en DESC, id DESC) STORING (tipo_movimiento, fecha, id_periodo, id_contrato_origen, id_zona_origen, id_contrato_destino, id_zona_destino, cantidad, costo, valorizacion, motivo);

-- >>> indices/activos-e-inversion/idx_recuperacion_inversion_mensual.sql
CREATE INDEX idx_recuperacion_inversion_mensual_contrato ON recuperacion_inversion_mensual (id_contrato, id_periodo);
CREATE INDEX idx_recuperacion_inversion_mensual_activo ON recuperacion_inversion_mensual (id_activo);
CREATE INDEX idx_star_recuperacion_inversion_mensual_listado ON recuperacion_inversion_mensual (id_empresa, creado_en DESC, id DESC) STORING (id_activo, id_contrato, id_periodo, importe_recuperado, saldo_antes, saldo_despues, parado);

-- >>> indices/activos-e-inversion/idx_tipo_adquisicion_activo.sql
CREATE UNIQUE INDEX idx_unico_tipo_adquisicion_activo_codigo ON tipo_adquisicion_activo (id_empresa, codigo) WHERE eliminado_en IS NULL;

-- >>> indices/activos-e-inversion/idx_tipo_herramienta.sql
CREATE UNIQUE INDEX idx_unico_tipo_herramienta_codigo ON tipo_herramienta (id_empresa, codigo) WHERE eliminado_en IS NULL;

-- >>> indices/cierre-mensual/idx_cierre_mensual.sql
CREATE INDEX idx_cierre_mensual_estado ON cierre_mensual (id_empresa, estado);
CREATE INDEX idx_star_cierre_mensual_listado ON cierre_mensual (id_empresa, creado_en DESC, id DESC) STORING (id_contrato, id_periodo, total_facturado, total_gastos, utilidad_bruta, utilidad_neta, utilidad_final, estado, fecha_cierre) WHERE eliminado_en IS NULL;

-- >>> indices/cierre-mensual/idx_penalidad.sql
CREATE INDEX idx_penalidad_contrato_periodo ON penalidad (id_contrato, id_periodo);
CREATE INDEX idx_star_penalidad_listado ON penalidad (id_empresa, creado_en DESC, id DESC) STORING (id_contrato, id_periodo, descripcion, importe) WHERE eliminado_en IS NULL;

-- >>> indices/cierre-mensual/idx_provision.sql
CREATE INDEX idx_provision_contrato_periodo ON provision (id_contrato, id_periodo);
CREATE INDEX idx_star_provision_listado ON provision (id_empresa, creado_en DESC, id DESC) STORING (id_contrato, id_periodo, descripcion, importe, aplicado) WHERE eliminado_en IS NULL;

-- >>> indices/costeo_directo/indice_erp_importacion_detalle.sql
CREATE INDEX idx_erp_importacion_detalle_importacion ON erp_importacion_detalle (id_erp_importacion);

CREATE INDEX idx_erp_importacion_detalle_pendientes ON erp_importacion_detalle (estado)
WHERE
    estado = 'PENDIENTE';

-- >>> indices/produccion/indice_linea_servicio_empresa.sql
CREATE INDEX idx_linea_servicio_empresa
ON linea_servicio (id_empresa)
WHERE eliminado_en IS NULL;

-- >>> indices/produccion/indice_linea_servicio_grupo_actividad.sql
CREATE INDEX idx_linea_servicio_grupo_actividad
ON linea_servicio (id_grupo_actividad)
WHERE eliminado_en IS NULL;

-- >>> indices/produccion/indice_unique_linea_servicio_empresa_codigo.sql
CREATE UNIQUE INDEX idx_linea_servicio_empresa_codigo
ON linea_servicio (id_empresa, codigo)
WHERE eliminado_en IS NULL;

-- >>> indices/produccion/indice_unique_linea_servicio_grupo_nombre.sql
CREATE UNIQUE INDEX idx_linea_servicio_grupo_nombre
ON linea_servicio (
    id_empresa,
    id_grupo_actividad,
    nombre
)
WHERE eliminado_en IS NULL;

-- ==================== FUNCIONES (30: 17 base + 13 de lectura del Grupo 5) ====================
-- >>> procedimientos/gobierno_central/fn_crear_rol.sql
CREATE OR REPLACE FUNCTION fn_crear_rol(
    p_id_empresa UUID,
    p_nombre STRING,
    p_descripcion STRING,
    p_creado_por_usuario_id UUID
)
RETURNS JSONB
LANGUAGE plpgsql
VOLATILE
AS $$
DECLARE
    v_id_rol_creado UUID;
BEGIN
    
    IF p_id_empresa IS NULL THEN
        RETURN jsonb_build_object(
			'exito', false, 
			'codigo_error', 'EMPRESA_OBLIGATORIA', 
			'mensaje', 'La empresa es obligatoria para crear un rol'
		);
    END IF;

    IF p_nombre IS NULL OR char_length(trim(p_nombre)) = 0 THEN
        RETURN jsonb_build_object(
			'exito', false, 
			'codigo_error', 'NOMBRE_ROL_OBLIGATORIO', 
			'mensaje', 'El nombre del rol es obligatorio y no puede estar vacío'
		);
    END IF;

    IF p_creado_por_usuario_id IS NULL THEN
        RETURN jsonb_build_object(
			'exito', false, 
			'codigo_error', 'USUARIO_CREADOR_OBLIGATORIO', 
			'mensaje', 'El usuario creador es obligatorio para efectos de auditoría'
		);
    END IF;

    IF p_nombre IS NOT NULL AND char_length(p_nombre) > 60 THEN
        RETURN jsonb_build_object(
			'exito', false, 
			'codigo_error', 'LONGITUD_NOMBRE_EXCEDIDA', 
			'mensaje', 'El nombre del rol no puede superar los 60 caracteres'
		);
    END IF;

    IF p_descripcion IS NOT NULL AND char_length(p_descripcion) > 200 THEN
        RETURN jsonb_build_object(
			'exito', false, 
			'codigo_error', 'LONGITUD_DESCRIPCION_EXCEDIDA', 
			'mensaje', 'La descripción no puede superar los 200 caracteres'
		);
    END IF;
	
	
    IF NOT EXISTS (
		SELECT 1 FROM usuario 
		WHERE id = p_creado_por_usuario_id 
			  AND eliminado_en IS NULL
	) THEN
        RETURN jsonb_build_object(
			'exito', false, 
			'codigo_error', 'USUARIO_CREADOR_NO_VALIDO', 
			'mensaje', 'El usuario que intenta crear el rol no existe o fue eliminado'
		);
    END IF;

    
    IF NOT EXISTS (
		SELECT 1 FROM empresa 
		WHERE id = p_id_empresa AND eliminado_en IS NULL
	) THEN
        RETURN jsonb_build_object(
			'exito', false,
			'codigo_error', 'EMPRESA_NO_EXISTE', 
			'mensaje', 'La empresa asignada no existe o fue eliminada'
		);
    END IF;

    IF EXISTS (
			SELECT 1 FROM empresa 
			WHERE id = p_id_empresa AND eliminado_en IS NULL AND estado = 'SUSPENDIDO'
	) THEN
        RETURN jsonb_build_object(
			'exito', false, 
			'codigo_error', 'EMPRESA_SUSPENDIDA', 
			'mensaje', 'No se pueden crear roles en una empresa que se encuentra suspendida'
		);
    END IF;
	
    IF EXISTS (
		SELECT 1 FROM rol 
		WHERE id_empresa = p_id_empresa 
			AND lower(trim(nombre)) = lower(trim(p_nombre)) 
			AND eliminado_en IS NULL
	) THEN
        RETURN jsonb_build_object(
				'exito', false, 
				'codigo_error', 'ROL_DUPLICADO', 
				'mensaje', 'Ya existe un rol activo con ese mismo nombre en esta empresa'
		);
    END IF;

    INSERT INTO rol (id_empresa,nombre,descripcion,estado,creado_en,actualizado_en,eliminado_en,
					 creado_por_usuario_id,actualizado_por_usuario_id,eliminado_por_usuario_id) 
	VALUES (p_id_empresa,trim(p_nombre),trim(p_descripcion),'ACTIVO',now(),now(),NULL,
        	p_creado_por_usuario_id,p_creado_por_usuario_id,NULL
    )
    RETURNING id INTO v_id_rol_creado;

    RETURN jsonb_build_object(
        'exito', true,
        'codigo', 'ROL_CREADO_EXITOSAMENTE',
        'mensaje', 'El rol de dominio fue creado correctamente',
        'datos', jsonb_build_object(
            'id_rol', v_id_rol_creado,
            'id_empresa', p_id_empresa,
            'nombre', trim(p_nombre),
            'estado', 'ACTIVO'
        )
    );

EXCEPTION
    WHEN unique_violation THEN
        RETURN jsonb_build_object(
			'exito', false, 
			'codigo_error', 'LLAVE_UNICA_DUPLICADA', 
			'mensaje', 'Ya existe un registro duplicado'
		);
    WHEN foreign_key_violation THEN
        RETURN jsonb_build_object(
			'exito', false, 
			'codigo_error', 'RELACION_INVALIDA', 
			'mensaje', 'Ya existe una relacion invalida entre usuario ó empresa'
		);
    WHEN others THEN
        RETURN jsonb_build_object(
			'exito', false, 'codigo_error', 
			'CREAR_ROL_ERROR_NO_CONTROLADO', 
			'mensaje', 'Ocurrió un error no controlado al crear el rol corporativo'
		);
END;
$$;

-- >>> procedimientos/gobierno_central/fn_actualizar_rol.sql
CREATE OR REPLACE FUNCTION fn_actualizar_rol(
    p_id_empresa UUID,
    p_id_rol UUID,
    p_nombre STRING,
    p_descripcion STRING,
    p_actualizado_por_usuario_id UUID
)
RETURNS JSONB
LANGUAGE plpgsql
VOLATILE
AS $$
DECLARE
    v_nombre_actual STRING;
    v_descripcion_actual STRING;
BEGIN
   
    IF p_id_empresa IS NULL THEN
        RETURN jsonb_build_object(
			'exito', false, 
			'codigo_error', 'EMPRESA_OBLIGATORIA', 
			'mensaje', 'La empresa es obligatoria para actualizar el rol'
		);
    END IF;

    IF p_id_rol IS NULL THEN
        RETURN jsonb_build_object(
			'exito', false, 
			'codigo_error', 'ROL_OBLIGATORIO', 
			'mensaje', 'El identificador del rol es obligatorio para la actualización'
		);
    END IF;

    IF p_actualizado_por_usuario_id IS NULL THEN
        RETURN jsonb_build_object(
			'exito', false, 
			'codigo_error', 'USUARIO_AUTOR_OBLIGATORIO', 
			'mensaje', 'El usuario auditor es obligatorio para registrar la modificación'
		);
    END IF;

    IF NOT EXISTS (
		SELECT 1 FROM empresa 
		WHERE id = p_id_empresa 
			AND eliminado_en IS NULL
	) THEN
        RETURN jsonb_build_object(
			'exito', false, 
			'codigo_error', 'EMPRESA_NO_EXISTE', 
			'mensaje', 'La empresa asignada no existe o fue eliminada'
		);
    END IF;

    IF EXISTS (
		SELECT 1 FROM empresa 
		WHERE id = p_id_empresa 
			AND eliminado_en IS NULL 
			AND estado = 'SUSPENDIDO'
	) THEN
        RETURN jsonb_build_object(
			'exito', false, 
			'codigo_error', 'EMPRESA_SUSPENDIDA', 
			'mensaje', 'No se pueden modificar recursos de una empresa suspendida'
		);
    END IF;

    IF NOT EXISTS (
		SELECT 1 FROM usuario 
		WHERE id = p_actualizado_por_usuario_id 
			AND eliminado_en IS NULL
	) THEN
        RETURN jsonb_build_object(
			'exito', false, 
			'codigo_error', 'USUARIO_ACTUALIZADOR_NO_VALIDO', 
			'mensaje', 'El usuario que intenta modificar el rol no existe o fue eliminado'
		);
    END IF;

   
    SELECT nombre, descripcion 
    FROM rol 
    WHERE id = p_id_rol 
		AND id_empresa = p_id_empresa 
		AND eliminado_en IS NULL
    INTO v_nombre_actual, v_descripcion_actual;

    IF v_nombre_actual IS NULL THEN
        RETURN jsonb_build_object(
			'exito', false, 
			'codigo_error', 'ROL_NO_ENCONTRADO', 
			'mensaje', 'El rol especificado no existe en la empresa o ha sido eliminado'
		);
    END IF;

    IF p_nombre IS NOT NULL AND trim(p_nombre) <> '' AND upper(trim(p_nombre)) <> upper(v_nombre_actual) THEN
       
        IF char_length(p_nombre) > 60 THEN
            RETURN jsonb_build_object(
				'exito', false, 
				'codigo_error', 'LONGITUD_NOMBRE_EXCEDIDA', 
				'mensaje', 'El nombre del rol no puede superar los 60 caracteres'
			);
        END IF;

        IF EXISTS (
			SELECT 1 FROM rol 
			WHERE id_empresa = p_id_empresa 
				AND upper(trim(nombre)) = upper(trim(p_nombre)) 
				AND id <> p_id_rol 
				AND eliminado_en IS NULL
		) THEN
            RETURN jsonb_build_object(
				'exito', false,
				'codigo_error', 'ROL_DUPLICADO', 
				'mensaje', 'Ya existe otro rol activo con ese mismo nombre en esta empresa'
			);
        END IF;
        
        v_nombre_actual := trim(p_nombre);
    END IF;

    IF p_descripcion IS NOT NULL THEN
        IF char_length(p_descripcion) > 200 THEN
            RETURN jsonb_build_object(
				'exito', false, 
				'codigo_error', 'LONGITUD_DESCRIPCION_EXCEDIDA', 
				'mensaje', 'La descripción no puede superar los 200 caracteres'
			);
        END IF;
        v_descripcion_actual := trim(p_descripcion);
    END IF;

    UPDATE rol
    SET 
        nombre = v_nombre_actual,
        descripcion = v_descripcion_actual,
        actualizado_en = now(),
        actualizado_por_usuario_id = p_actualizado_por_usuario_id
    WHERE id = p_id_rol 
      AND id_empresa = p_id_empresa
      AND eliminado_en IS NULL;

    RETURN jsonb_build_object(
        'exito', true,
        'codigo', 'ROL_ACTUALIZADO_EXITOSAMENTE',
        'mensaje', 'El rol de dominio fue modificado correctamente',
        'datos', jsonb_build_object(
            'id_rol', p_id_rol,
            'id_empresa', p_id_empresa,
            'nombre', v_nombre_actual,
            'descripcion', v_descripcion_actual
        )
    );

EXCEPTION
    WHEN unique_violation THEN
        RETURN jsonb_build_object(
			'exito', false, 
			'codigo_error', 'LLAVE_UNICA_DUPLICADA', 
			'mensaje', 'Ya existe un registro duplicado'
		);
    WHEN foreign_key_violation THEN
        RETURN jsonb_build_object(
			'exito', false, 
			'codigo_error', 'RELACION_INVALIDA', 
			'mensaje', 'Ya existe una relacion invalida entre usuario ó empresa'
		);
    WHEN others THEN
        RETURN jsonb_build_object(
			'exito', false, 
			'codigo_error', 'ACTUALIZAR_ROL_ERROR_NO_CONTROLADO', 
			'mensaje', 'Ocurrió un error no controlado al actualizar el rol corporativo');
END;
$$;

-- >>> procedimientos/gobierno_central/fn_suspender_rol.sql
CREATE OR REPLACE FUNCTION fn_suspender_rol(
    p_id_empresa UUID,
    p_id_rol UUID,
    p_actualizado_por_usuario_id UUID
)
RETURNS JSONB
LANGUAGE plpgsql
VOLATILE
AS $$
DECLARE
    v_nombre_rol STRING;
    v_estado_actual STRING;
BEGIN
    
    IF p_id_empresa IS NULL THEN
        RETURN jsonb_build_object(
			'exito', false, 
			'codigo_error', 'EMPRESA_OBLIGATORIA', 
			'mensaje', 'La empresa es obligatoria para suspender el rol'
		);
    END IF;

    IF p_id_rol IS NULL THEN
        RETURN jsonb_build_object(
			'exito', false, 
			'codigo_error', 'ROL_OBLIGATORIO', 
			'mensaje', 'El identificador del rol es obligatorio'
		);
    END IF;

    IF p_actualizado_por_usuario_id IS NULL THEN
        RETURN jsonb_build_object(
			'exito', false, 
			'codigo_error', 'USUARIO_AUTOR_OBLIGATORIO', 
			'mensaje', 'El usuario auditor es obligatorio para registrar la suspensión'
		);
    END IF;

    IF NOT EXISTS (
		SELECT 1 FROM empresa 
		WHERE id = p_id_empresa 
			AND eliminado_en IS NULL
	) THEN
        RETURN jsonb_build_object(
			'exito', false, 
			'codigo_error', 'EMPRESA_NO_EXISTE', 
			'mensaje', 'La empresa asignada no existe o fue eliminada'
		);
    END IF;

    IF EXISTS (
		SELECT 1 FROM empresa 
		WHERE id = p_id_empresa 
			AND eliminado_en IS NULL 
			AND estado = 'SUSPENDIDO'
	) THEN
        RETURN jsonb_build_object(
			'exito', false, 
			'codigo_error', 'EMPRESA_SUSPENDIDA', 
			'mensaje', 'No se pueden realizar acciones en una empresa que ya está suspendida'
		);
    END IF;

    IF NOT EXISTS (
		SELECT 1 FROM usuario 
		WHERE id = p_actualizado_por_usuario_id 
			AND eliminado_en IS NULL
	) THEN
        RETURN jsonb_build_object(
			'exito', false, 
			'codigo_error', 'USUARIO_OPERADOR_NO_VALIDO', 
			'mensaje', 'El usuario que ejecuta la acción no existe o fue eliminado'
		);
    END IF;

    SELECT nombre, estado 
    FROM rol 
    WHERE id = p_id_rol 
		AND id_empresa = p_id_empresa 
		AND eliminado_en IS NULL
    INTO v_nombre_rol, v_estado_actual;

    IF v_nombre_rol IS NULL THEN
        RETURN jsonb_build_object(
			'exito', false, 
			'codigo_error', 'ROL_NO_ENCONTRADO', 
			'mensaje', 'El rol especificado no existe o ha sido eliminado lógicamente'
		);
    END IF;

    IF v_estado_actual = 'SUSPENDIDO' THEN
        RETURN jsonb_build_object(
			'exito', false, 
			'codigo_error', 'ROL_YA_SUSPENDIDO', 
			'mensaje', 'El rol ya se encuentra en estado suspendido'
		);
    END IF;

    UPDATE rol SET 
        estado = 'SUSPENDIDO',
        actualizado_en = now(),
        actualizado_por_usuario_id = p_actualizado_por_usuario_id
    WHERE id = p_id_rol 
      AND id_empresa = p_id_empresa;

    RETURN jsonb_build_object(
        'exito', true,
        'codigo', 'ROL_SUSPENDIDO_EXITOSAMENTE',
        'mensaje', 'El rol fue suspendido correctamente',
        'datos', jsonb_build_object(
            'id_rol', p_id_rol,
            'id_empresa', p_id_empresa,
            'nombre', v_nombre_rol,
            'estado', 'SUSPENDIDO'
        )
    );

EXCEPTION
    WHEN foreign_key_violation THEN
        RETURN jsonb_build_object(
			'exito', false, 
			'codigo_error', 'RELACION_INVALIDA', 
			'mensaje', 'Ya existe una relacion invalida entre usuario, empresa o rol'
		);
    WHEN others THEN
        RETURN jsonb_build_object(
			'exito', false, 
			'codigo_error', 'SUSPENDER_ROL_ERROR_NO_CONTROLADO', 
			'mensaje', 'Ocurrió un error no controlado al suspender el rol corporativo'
		);
END;
$$;

-- >>> procedimientos/gobierno_central/fn_dar_de_baja_rol.sql
CREATE OR REPLACE FUNCTION fn_dar_de_baja_rol(
    p_id_empresa UUID,
    p_id_rol UUID,
    p_eliminado_por_usuario_id UUID
)
RETURNS JSONB
LANGUAGE plpgsql
VOLATILE
AS $$
DECLARE
    v_nombre_rol STRING;
BEGIN
    
    IF p_id_empresa IS NULL THEN
        RETURN jsonb_build_object(
			'exito', false, 
			'codigo_error', 'EMPRESA_OBLIGATORIA', 
			'mensaje', 'La empresa es obligatoria para dar de baja el rol'
		);
    END IF;

    IF p_id_rol IS NULL THEN
        RETURN jsonb_build_object(
			'exito', false, 
			'codigo_error', 'ROL_OBLIGATORIO', 
			'mensaje', 'El identificador del rol es obligatorio'
		);
    END IF;

    IF p_eliminado_por_usuario_id IS NULL THEN
        RETURN jsonb_build_object(
			'exito', false, 
			'codigo_error', 'USUARIO_AUTOR_OBLIGATORIO', 
			'mensaje', 'El usuario auditor es obligatorio para registrar la baja'
		);
    END IF;

    IF NOT EXISTS (
		SELECT 1 FROM empresa 
		WHERE id = p_id_empresa 
			AND eliminado_en IS NULL
	) THEN
        RETURN jsonb_build_object(
			'exito', false, 
			'codigo_error', 'EMPRESA_NO_EXISTE', 
			'mensaje', 'La empresa asignada no existe o fue eliminada'
		);
    END IF;

    IF EXISTS (
		SELECT 1 FROM empresa 
		WHERE id = p_id_empresa 
			AND eliminado_en IS NULL 
			AND estado = 'SUSPENDIDO'
	) THEN
        RETURN jsonb_build_object(
			'exito', false, 
			'codigo_error', 'EMPRESA_SUSPENDIDA', 
			'mensaje', 'No se pueden realizar acciones de baja en una empresa suspendida'
		);
    END IF;

    IF NOT EXISTS (
		SELECT 1 FROM usuario 
		WHERE id = p_eliminado_por_usuario_id 
			AND eliminado_en IS NULL
	) THEN
        RETURN jsonb_build_object(
			'exito', false, 
			'codigo_error', 'USUARIO_OPERADOR_NO_VALIDO', 
			'mensaje', 'El usuario que ejecuta la baja no existe o fue eliminado'
		);
    END IF;

    SELECT nombre 
    FROM rol 
    WHERE id = p_id_rol 
		AND id_empresa = p_id_empresa 
		AND eliminado_en IS NULL
    INTO v_nombre_rol;

    IF v_nombre_rol IS NULL THEN
        RETURN jsonb_build_object(
			'exito', false, 
			'codigo_error', 'ROL_NO_ENCONTRADO', 
			'mensaje', 'El rol especificado no existe o ya ha sido dado de baja previamente'
		);
    END IF;

    UPDATE rol
    SET 
        eliminado_en = now(),
        eliminado_por_usuario_id = p_eliminado_por_usuario_id
    WHERE id = p_id_rol 
      AND id_empresa = p_id_empresa;

    RETURN jsonb_build_object(
        'exito', true,
        'codigo', 'ROL_DADO_DE_BAJA',
        'mensaje', 'El rol fue dado de baja exitosamente',
        'datos', jsonb_build_object(
            'id_rol', p_id_rol,
            'id_empresa', p_id_empresa,
            'nombre', v_nombre_rol,
            'fecha_baja', now()
        )
    );

EXCEPTION
    WHEN foreign_key_violation THEN
        RETURN jsonb_build_object(
			'exito', false, 
			'codigo_error', 'RELACION_INVALIDA', 
			'mensaje', 'Ya existe una relacion invalida entre usuario, empresa o rol'
		);
    WHEN others THEN
        RETURN jsonb_build_object(
			'exito', false, 
			'codigo_error', 'DAR_BAJA_ROL_ERROR_NO_CONTROLADO', 
			'mensaje', 'Ocurrió un error no controlado al dar de baja el rol corporativo'
		);
END;
$$;

-- >>> procedimientos/activos-e-inversion/fn_registrar_activo.sql
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

-- >>> procedimientos/activos-e-inversion/fn_asignar_activo_a_contrato.sql
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

-- >>> procedimientos/activos-e-inversion/fn_registrar_trabajo_activo.sql
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

-- >>> procedimientos/activos-e-inversion/fn_ejecutar_recuperacion_mensual.sql
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

-- >>> procedimientos/activos-e-inversion/fn_registrar_traslado_activo.sql
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

-- >>> procedimientos/activos-e-inversion/fn_registrar_herramienta.sql
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

-- >>> procedimientos/activos-e-inversion/fn_mover_herramienta.sql
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

-- >>> procedimientos/cierre-mensual/fn_registrar_penalidad.sql
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

-- >>> procedimientos/cierre-mensual/fn_registrar_provision.sql
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

-- >>> procedimientos/cierre-mensual/fn_ejecutar_cierre_mensual.sql
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

-- >>> procedimientos/cierre-mensual/fn_recalcular_cierre_mensual.sql
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

-- >>> procedimientos/cierre-mensual/fn_cerrar_cierre_mensual.sql
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

-- >>> procedimientos/cierre-mensual/fn_consultar_resultado_contrato.sql
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

-- ==================== ACTUALIZACION GRUPO 5: indices estrella + procedimientos de lectura ====================
-- (lectura con lenguaje ubicuo de Gerson; traslados corregido a una sola funcion)

CREATE INDEX idx_activo_listado ON activo (id_empresa, creado_en DESC, id DESC) STORING (codigo, descripcion, estado, placa, marca, modelo, anio_fabricacion, costo_adquisicion, id_clasificacion_activo, id_tipo_adquisicion_activo) WHERE eliminado_en IS NULL;
CREATE INDEX idx_activo_asignacion_contrato_listado ON activo_asignacion_contrato (id_empresa, id_activo, creado_en DESC, id DESC) STORING (id_contrato, id_zona, inversion_asignada, saldo_inversion_pendiente, cuota_recuperacion_mensual, fecha_inicio, fecha_fin, estado) WHERE eliminado_en IS NULL;
CREATE INDEX idx_activo_registro_trabajo_listado ON activo_registro_trabajo (id_empresa, id_activo, creado_en DESC, id DESC) STORING (id_contrato, id_zona, id_operario, id_periodo, fecha, horas_trabajadas, descripcion_trabajo, valorizacion_trabajo, dias_depreciados, kilometraje_inicio, kilometraje_fin) WHERE eliminado_en IS NULL;
CREATE INDEX idx_activo_traslado_listado ON activo_traslado (id_empresa, id_activo, creado_en DESC, id DESC) STORING (id_contrato_origen, id_zona_origen, id_contrato_destino, id_zona_destino, fecha_traslado, saldo_trasladado, motivo);
CREATE INDEX idx_herramienta_listado ON herramienta (id_empresa, creado_en DESC, id DESC) STORING (codigo, descripcion, marca, modelo, numero_serie, estado, costo_adquisicion, id_tipo_herramienta) WHERE eliminado_en IS NULL;
CREATE INDEX idx_herramienta_movimiento_listado ON herramienta_movimiento (id_empresa, id_herramienta, creado_en DESC, id DESC) STORING (tipo_movimiento, fecha, id_periodo, id_contrato_origen, id_zona_origen, id_contrato_destino, id_zona_destino, cantidad, costo, valorizacion, motivo);
CREATE INDEX idx_recuperacion_inversion_mensual_listado ON recuperacion_inversion_mensual (id_empresa, creado_en DESC, id DESC) STORING (id_activo, id_contrato, id_periodo, importe_recuperado, saldo_antes, saldo_despues, parado);
CREATE INDEX idx_cierre_mensual_listado ON cierre_mensual (id_empresa, creado_en DESC, id DESC) STORING (id_contrato, id_periodo, total_facturado, total_gastos, utilidad_bruta, utilidad_neta, utilidad_final, estado, fecha_cierre) WHERE eliminado_en IS NULL;
CREATE INDEX idx_penalidad_listado ON penalidad (id_empresa, creado_en DESC, id DESC) STORING (id_contrato, id_periodo, descripcion, importe) WHERE eliminado_en IS NULL;
CREATE INDEX idx_provision_listado ON provision (id_empresa, creado_en DESC, id DESC) STORING (id_contrato, id_periodo, descripcion, importe, aplicado) WHERE eliminado_en IS NULL;

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
  v_limite_pagina INT;
  v_activos_pagina JSONB;
  v_existen_mas_activos BOOL;
  v_cantidad_activos_pagina INT;
  v_cursor_siguiente JSONB;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  v_limite_pagina := LEAST(GREATEST(COALESCE(p_limite, 20), 1), 100);

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
      AND (p_busqueda IS NULL OR a.codigo ILIKE '%' || p_busqueda || '%' OR a.descripcion ILIKE '%' || p_busqueda || '%')
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
        'cursor_siguiente', v_cursor_siguiente
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
  p_estado STRING,
  p_id_tipo_herramienta UUID,
  p_texto_busqueda  STRING,
  p_limite_pagina  INT,
  p_cursor_creado_en TIMESTAMPTZ,
  p_cursor_id UUID
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  v_limite_pagina INT;
  v_herramientas_pagina JSONB;
  v_existen_mas_herramientas BOOL;
  v_cantidad_herramientas_pagina INT;
  v_cursor_siguiente JSONB;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  v_limite_pagina := LEAST(GREATEST(COALESCE(p_limite_pagina , 20), 1), 100);

  WITH herramientas_ordenadas_para_listado AS (
    SELECT h.id, h.codigo, h.descripcion, h.marca, h.modelo, h.numero_serie,
           h.estado, h.costo_adquisicion, h.id_tipo_herramienta, h.creado_en,
           row_number() OVER (ORDER BY h.creado_en DESC, h.id DESC) AS orden_en_pagina
    FROM herramienta h
    WHERE h.id_empresa = p_id_empresa
      AND h.eliminado_en IS NULL
      AND (p_estado IS NULL OR h.estado = p_estado)
      AND (p_id_tipo_herramienta IS NULL OR h.id_tipo_herramienta = p_id_tipo_herramienta)
      AND (p_texto_busqueda  IS NULL OR h.codigo ILIKE '%' || p_texto_busqueda  || '%' OR h.descripcion ILIKE '%' || p_texto_busqueda  || '%')
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
      'paginacion', jsonb_build_object('limite', v_limite_pagina, 'hay_mas', v_existen_mas_herramientas, 'cursor_siguiente', v_cursor_siguiente)
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
  v_limite_pagina INT;
  v_movimientos_herramienta_pagina JSONB;
  v_existen_mas_movimientos BOOL;
  v_cantidad_movimientos_pagina INT;
  v_cursor_siguiente JSONB;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  IF NOT EXISTS (SELECT 1 FROM herramienta WHERE id = p_id_herramienta AND id_empresa = p_id_empresa AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'HERRAMIENTA_NO_VALIDA', 'mensaje', 'La herramienta no existe o no pertenece a la empresa');
  END IF;

  v_limite_pagina := LEAST(GREATEST(COALESCE(p_limite, 20), 1), 100);

  WITH movimientos_herramienta_ordenados_para_listado AS (
    SELECT m.id, m.tipo_movimiento, m.fecha, m.id_periodo,
           m.id_contrato_origen, m.id_zona_origen, m.id_contrato_destino, m.id_zona_destino,
           m.cantidad, m.costo, m.valorizacion, m.motivo, m.creado_en,
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
      'paginacion', jsonb_build_object('limite', v_limite_pagina, 'hay_mas', v_existen_mas_movimientos, 'cursor_siguiente', v_cursor_siguiente)
    )
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'MOVIMIENTOS_HERRAMIENTA_LISTADO_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al listar los movimientos');
END;
$$;
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
  v_limite_pagina INT;
  v_asignaciones_activo_pagina JSONB;
  v_existen_mas_asignaciones BOOL;
  v_cantidad_asignaciones_pagina INT;
  v_cursor_siguiente JSONB;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  IF NOT EXISTS (SELECT 1 FROM activo WHERE id = p_id_activo AND id_empresa = p_id_empresa AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'ACTIVO_NO_VALIDO', 'mensaje', 'El activo no existe o no pertenece a la empresa');
  END IF;

  v_limite_pagina := LEAST(GREATEST(COALESCE(p_limite, 20), 1), 100);

  WITH asignaciones_activo_ordenadas_para_listado AS (
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
      'paginacion', jsonb_build_object('limite', v_limite_pagina, 'hay_mas', v_existen_mas_asignaciones, 'cursor_siguiente', v_cursor_siguiente)
    )
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'ASIGNACIONES_ACTIVO_LISTADO_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al listar las asignaciones');
END;
$$;

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
  v_limite_pagina INT;
  v_trabajos_activo_pagina JSONB;
  v_existen_mas_trabajos BOOL;
  v_cantidad_trabajos_pagina INT;
  v_cursor_siguiente JSONB;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  IF NOT EXISTS (SELECT 1 FROM activo WHERE id = p_id_activo AND id_empresa = p_id_empresa AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'ACTIVO_NO_VALIDO', 'mensaje', 'El activo no existe o no pertenece a la empresa');
  END IF;

  v_limite_pagina := LEAST(GREATEST(COALESCE(p_limite, 20), 1), 100);

  WITH trabajos_activo_ordenados_para_listado AS (
    SELECT t.id, t.id_contrato, t.id_zona, t.id_operario, t.id_periodo, t.fecha,
           t.horas_trabajadas, t.descripcion_trabajo, t.valorizacion_trabajo, t.dias_depreciados,
           t.kilometraje_inicio, t.kilometraje_fin, t.creado_en,
           row_number() OVER (ORDER BY t.creado_en DESC, t.id DESC) AS orden_en_pagina
    FROM activo_registro_trabajo t
    WHERE t.id_empresa = p_id_empresa
      AND t.id_activo = p_id_activo
      AND t.eliminado_en IS NULL
      AND (p_id_contrato IS NULL OR t.id_contrato = p_id_contrato)
      AND (p_id_periodo IS NULL OR t.id_periodo = p_id_periodo)
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
      'paginacion', jsonb_build_object('limite', v_limite_pagina, 'hay_mas', v_existen_mas_trabajos, 'cursor_siguiente', v_cursor_siguiente)
    )
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'TRABAJOS_ACTIVO_LISTADO_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al listar los trabajos');
END;
$$;

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
  v_limite_pagina INT;
  v_traslados_activo_pagina JSONB;
  v_existen_mas_traslados BOOL;
  v_cantidad_traslados_pagina INT;
  v_cursor_siguiente JSONB;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa WHERE id = p_id_empresa AND estado = 'ACTIVO' AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'EMPRESA_NO_VIGENTE', 'mensaje', 'La empresa no existe o no esta vigente');
  END IF;

  IF NOT EXISTS (SELECT 1 FROM activo WHERE id = p_id_activo AND id_empresa = p_id_empresa AND eliminado_en IS NULL) THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'ACTIVO_NO_VALIDO', 'mensaje', 'El activo no existe o no pertenece a la empresa');
  END IF;

  v_limite_pagina := LEAST(GREATEST(COALESCE(p_limite, 20), 1), 100);

  WITH traslados_activo_ordenados_para_listado AS (
    SELECT t.id, t.id_contrato_origen, t.id_zona_origen, t.id_contrato_destino, t.id_zona_destino,
           t.fecha_traslado, t.saldo_trasladado, t.motivo, t.creado_en,
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
      'paginacion', jsonb_build_object('limite', v_limite_pagina, 'hay_mas', v_existen_mas_traslados, 'cursor_siguiente', v_cursor_siguiente)
    )
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('exito', false, 'codigo_error', 'TRASLADOS_ACTIVO_LISTADO_ERROR_NO_CONTROLADO', 'mensaje', 'Ocurrio un error no controlado al listar los traslados');
END;
$$;


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
    SELECT r.id, r.id_activo, r.id_contrato, r.id_periodo, r.importe_recuperado,
           r.saldo_antes, r.saldo_despues, r.parado, r.creado_en,
           row_number() OVER (ORDER BY r.creado_en DESC, r.id DESC) AS orden_en_pagina
    FROM recuperacion_inversion_mensual r
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
  p_id_contrato UUID,
  p_id_periodo UUID,
  p_limite INT,
  p_cursor_creado_en TIMESTAMPTZ,
  p_cursor_id UUID
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
  p_id_contrato UUID,
  p_id_periodo UUID,
  p_limite INT,
  p_cursor_creado_en TIMESTAMPTZ,
  p_cursor_id UUID
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


-- ====================================================================
-- SEMILLAS DEMO GLOBAL  -  datos de arranque para TODAS las capacidades
-- UUIDs fijos (anclas) para FK consistentes. Orden por dependencias FK.
-- ====================================================================

-- ===== NUCLEO: empresa, usuario, periodos =====
INSERT INTO empresa (id, ruc, razon_social, nombre_comercial, direccion, telefono, correo_electronico, estado)
VALUES ('11111111-1111-1111-1111-111111111111', '20100010001', 'SESGA REYSER DEMO S.A.C.', 'SESGA REYSER', 'Av. Operativa 100, Lima', '014440000', 'contacto@sesgareyser.com', 'ACTIVO');

INSERT INTO usuario (id, correo_electronico, clave_hash, nombres, apellidos, estado)
VALUES ('22222222-2222-2222-2222-222222222222', 'admin@sesgareyser.com', 'demo-no-usar-en-produccion', 'Administrador', 'Demo', 'ACTIVO');

INSERT INTO usuario_empresa (id_empresa, id_usuario, estado)
VALUES ('11111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-222222222222', 'ACTIVO');

INSERT INTO periodo (id, id_empresa, anio, mes, codigo_periodo, fecha_inicio, fecha_fin, estado) VALUES
('33333333-3333-3333-3333-333333330001', '11111111-1111-1111-1111-111111111111', 2026, 1, '2026-01', '2026-01-01', '2026-01-31', 'ABIERTO'),
('33333333-3333-3333-3333-333333330002', '11111111-1111-1111-1111-111111111111', 2026, 2, '2026-02', '2026-02-01', '2026-02-28', 'ABIERTO');

-- ===== GOBIERNO: roles + permisos =====
INSERT INTO rol (id, id_empresa, nombre, descripcion, estado) VALUES
('aa000000-0000-0000-0000-000000000001', '11111111-1111-1111-1111-111111111111', 'ADMINISTRADOR', 'Acceso total a la plataforma operativa', 'ACTIVO'),
(gen_random_uuid(), '11111111-1111-1111-1111-111111111111', 'SUPERVISOR', 'Supervision y aprobacion operativa', 'ACTIVO'),
(gen_random_uuid(), '11111111-1111-1111-1111-111111111111', 'OPERADOR', 'Operacion diaria de las capacidades asignadas', 'ACTIVO'),
(gen_random_uuid(), '11111111-1111-1111-1111-111111111111', 'CONSULTA', 'Consulta de datos sin cambios operativos', 'ACTIVO');

INSERT INTO permiso (id_empresa, id_rol, modulo, accion) VALUES
('11111111-1111-1111-1111-111111111111', 'aa000000-0000-0000-0000-000000000001', 'ACTIVOS', 'CREAR'),
('11111111-1111-1111-1111-111111111111', 'aa000000-0000-0000-0000-000000000001', 'ACTIVOS', 'LISTAR'),
('11111111-1111-1111-1111-111111111111', 'aa000000-0000-0000-0000-000000000001', 'CIERRE', 'EJECUTAR');

-- ===== CONTRATOS: catalogos base =====
INSERT INTO estado_contrato (id, id_empresa, codigo, descripcion, es_vigente, estado) VALUES
(gen_random_uuid(), '11111111-1111-1111-1111-111111111111', 'BORRADOR', 'Contrato en preparacion', false, 'ACTIVO'),
('ec000000-0000-0000-0000-000000000002', '11111111-1111-1111-1111-111111111111', 'VIGENTE', 'Contrato vigente y operativo', true, 'ACTIVO'),
(gen_random_uuid(), '11111111-1111-1111-1111-111111111111', 'SUSPENDIDO', 'Contrato suspendido temporalmente', false, 'ACTIVO'),
(gen_random_uuid(), '11111111-1111-1111-1111-111111111111', 'FINALIZADO', 'Contrato finalizado', false, 'ACTIVO'),
(gen_random_uuid(), '11111111-1111-1111-1111-111111111111', 'LIQUIDADO', 'Contrato liquidado y cerrado', false, 'ACTIVO');

INSERT INTO tipo_contrato (id, id_empresa, codigo, descripcion, estado) VALUES
('7c000000-0000-0000-0000-000000000001', '11111111-1111-1111-1111-111111111111', 'SERVICIO', 'Contrato de servicio operativo', 'ACTIVO'),
(gen_random_uuid(), '11111111-1111-1111-1111-111111111111', 'OBRA', 'Contrato de obra o ejecucion', 'ACTIVO'),
(gen_random_uuid(), '11111111-1111-1111-1111-111111111111', 'ORDEN_SERV', 'Orden de servicio formalizada', 'ACTIVO'),
(gen_random_uuid(), '11111111-1111-1111-1111-111111111111', 'COMPLEMENT', 'Contrato complementario', 'ACTIVO');

INSERT INTO grupo_actividad (id, id_empresa, codigo, descripcion) VALUES
('6a000000-0000-0000-0000-000000000001', '11111111-1111-1111-1111-111111111111', 'GA-OPER', 'Operaciones generales');

INSERT INTO zona (id, id_empresa, codigo, descripcion, estado) VALUES
('44444444-4444-4444-4444-444444444444', '11111111-1111-1111-1111-111111111111', 'ZN-LIMA', 'Zona Lima Metropolitana', 'ACTIVO');

INSERT INTO cliente (id, id_empresa, ruc, razon_social, estado) VALUES
('55555555-5555-5555-5555-555555555555', '11111111-1111-1111-1111-111111111111', '20600060006', 'CLIENTE OPERATIVO S.A.C.', 'ACTIVO');

INSERT INTO contrato (id, id_empresa, id_tipo_contrato, id_estado_contrato, id_cliente, codigo, nombre) VALUES
('cc000000-0000-0000-0000-000000000001', '11111111-1111-1111-1111-111111111111', '7c000000-0000-0000-0000-000000000001', 'ec000000-0000-0000-0000-000000000002', '55555555-5555-5555-5555-555555555555', 'CT-2026-001', 'Servicio operativo zona Lima 2026');

-- ===== COSTEO: catalogos =====
INSERT INTO tipo_clasificacion_gasto (id, id_empresa, codigo, descripcion) VALUES
('7d000000-0000-0000-0000-000000000001', '11111111-1111-1111-1111-111111111111', 'DIRECTO', 'Gasto directo de operacion');

INSERT INTO clasificacion_gasto (id, id_empresa, id_tipo_clasificacion_gasto, codigo, descripcion) VALUES
('7d000000-0000-0000-0000-000000000011', '11111111-1111-1111-1111-111111111111', '7d000000-0000-0000-0000-000000000001', 'COMBUSTIBLE', 'Combustible y lubricantes');

-- ===== PRODUCCION: catalogo linea_servicio =====
INSERT INTO linea_servicio (id, id_empresa, id_grupo_actividad, codigo, nombre) VALUES
('1c000000-0000-0000-0000-000000000001', '11111111-1111-1111-1111-111111111111', '6a000000-0000-0000-0000-000000000001', 'LS-001', 'Linea de servicio operativa');

-- ===== ACTIVOS: catalogos + demo =====
INSERT INTO clasificacion_activo (id, id_empresa, codigo, descripcion, es_capitalizable, estado) VALUES
('a1a1a1a1-a1a1-a1a1-a1a1-a1a1a1a1a1a1', '11111111-1111-1111-1111-111111111111', 'VEHICULO', 'Vehiculo operativo', true, 'ACTIVO'),
(gen_random_uuid(), '11111111-1111-1111-1111-111111111111', 'MAQUINARIA', 'Maquinaria y equipo mayor', true, 'ACTIVO'),
(gen_random_uuid(), '11111111-1111-1111-1111-111111111111', 'MOBILIARIO', 'Mobiliario y adecuacion', true, 'ACTIVO'),
(gen_random_uuid(), '11111111-1111-1111-1111-111111111111', 'EQUIPO_MENOR', 'Equipo menor no capitalizable', false, 'ACTIVO');

INSERT INTO tipo_adquisicion_activo (id, id_empresa, codigo, descripcion, estado) VALUES
('a2a2a2a2-a2a2-a2a2-a2a2-a2a2a2a2a2a2', '11111111-1111-1111-1111-111111111111', 'COMPRA', 'Compra directa', 'ACTIVO'),
(gen_random_uuid(), '11111111-1111-1111-1111-111111111111', 'LEASING', 'Adquisicion por leasing', 'ACTIVO'),
(gen_random_uuid(), '11111111-1111-1111-1111-111111111111', 'ALQUILER', 'Activo alquilado o rentado', 'ACTIVO'),
(gen_random_uuid(), '11111111-1111-1111-1111-111111111111', 'TRANSFER', 'Transferencia interna', 'ACTIVO');

INSERT INTO tipo_herramienta (id, id_empresa, codigo, descripcion, estado) VALUES
(gen_random_uuid(), '11111111-1111-1111-1111-111111111111', 'MANUAL', 'Herramienta manual', 'ACTIVO'),
('a3a3a3a3-a3a3-a3a3-a3a3-a3a3a3a3a3a3', '11111111-1111-1111-1111-111111111111', 'ELECTRICA', 'Herramienta electrica', 'ACTIVO'),
(gen_random_uuid(), '11111111-1111-1111-1111-111111111111', 'MEDICION', 'Herramienta de medicion', 'ACTIVO'),
(gen_random_uuid(), '11111111-1111-1111-1111-111111111111', 'SEGURIDAD', 'Herramienta o kit de seguridad', 'ACTIVO');

INSERT INTO activo (id, id_empresa, id_clasificacion_activo, id_tipo_adquisicion_activo, codigo, descripcion, placa, marca, modelo, anio_fabricacion, costo_adquisicion, tiempo_vida_meses, depreciacion_mensual, importe_base_recuperable, fecha_inicio_depreciacion, fecha_fin_depreciacion, estado) VALUES
('b1b1b1b1-b1b1-b1b1-b1b1-b1b1b1b1b1b1', '11111111-1111-1111-1111-111111111111', 'a1a1a1a1-a1a1-a1a1-a1a1-a1a1a1a1a1a1', 'a2a2a2a2-a2a2-a2a2-a2a2-a2a2a2a2a2a2', 'ACT-001', 'Camioneta Toyota Hilux', 'ABC-123', 'Toyota', 'Hilux 4x4', 2024, 120000.00, 60, 2000.00, 120000.00, '2026-01-01', '2030-12-31', 'ACTIVO'),
('b1b1b1b1-b1b1-b1b1-b1b1-b1b1b1b1b1b2', '11111111-1111-1111-1111-111111111111', 'a1a1a1a1-a1a1-a1a1-a1a1-a1a1a1a1a1a1', 'a2a2a2a2-a2a2-a2a2-a2a2-a2a2a2a2a2a2', 'ACT-002', 'Volquete Volvo FMX', 'XYZ-789', 'Volvo', 'FMX', 2023, 300000.00, 120, 2500.00, 300000.00, '2026-01-01', '2035-12-31', 'ACTIVO');

INSERT INTO herramienta (id, id_empresa, id_tipo_herramienta, codigo, descripcion, marca, modelo, costo_adquisicion, tiempo_vida_meses, fecha_inicio_depreciacion, fecha_fin_depreciacion, estado) VALUES
('b2b2b2b2-b2b2-b2b2-b2b2-b2b2b2b2b2b2', '11111111-1111-1111-1111-111111111111', 'a3a3a3a3-a3a3-a3a3-a3a3-a3a3a3a3a3a3', 'HER-001', 'Taladro percutor', 'Bosch', 'GSB-550', 450.00, 36, '2026-01-01', '2028-12-31', 'ACTIVO');

INSERT INTO activo_asignacion_contrato (id, id_empresa, id_activo, id_contrato, id_zona, inversion_asignada, saldo_inversion_pendiente, cuota_recuperacion_mensual, fecha_inicio, estado) VALUES
('d1d1d1d1-d1d1-d1d1-d1d1-d1d1d1d1d1d1', '11111111-1111-1111-1111-111111111111', 'b1b1b1b1-b1b1-b1b1-b1b1-b1b1b1b1b1b1', 'cc000000-0000-0000-0000-000000000001', '44444444-4444-4444-4444-444444444444', 120000.00, 100000.00, 10000.00, '2026-01-01', 'ACTIVO');

-- ===== COSTEO: proveedor + transaccional =====
INSERT INTO proveedor (id, id_empresa, tipo_documento_identidad, nro_documento, razon_social, nombre_comercial, direccion, telefono, correo_electronico, contacto, estado, creado_por_usuario_id) VALUES ('e0000000-0000-0000-0000-000000000001', '11111111-1111-1111-1111-111111111111', 'RUC', '20512345678', 'PROVEEDOR DEMO SAC', 'Proveedor Demo', 'Av. Industrial 123, Lima', '014567890', 'contacto@proveedordemo.pe', 'Juan Perez', 'ACTIVO', '22222222-2222-2222-2222-222222222222');
INSERT INTO erp_importacion (id, id_empresa, id_periodo, id_clasificacion_gasto, fecha_importacion, tipo_datos, archivo_origen, total_registros, registros_ok, registros_error, estado, creado_por_usuario_id) VALUES ('e5000000-0000-0000-0000-000000000001', '11111111-1111-1111-1111-111111111111', '33333333-3333-3333-3333-333333330001', '7d000000-0000-0000-0000-000000000011', '2026-01-15 10:00:00+00', 'GASTOS', 'gastos_enero_2026.csv', 1, 1, 0, 'PROCESADO', '22222222-2222-2222-2222-222222222222');
INSERT INTO gasto_directo (id, id_empresa, id_contrato, id_zona, id_periodo, id_clasificacion_gasto, id_proveedor, origen, tipo_documento, erp_serie, erp_numero, erp_fecha, descripcion, importe, estado, creado_por_usuario_id) VALUES ('e4000000-0000-0000-0000-000000000001', '11111111-1111-1111-1111-111111111111', 'cc000000-0000-0000-0000-000000000001', '44444444-4444-4444-4444-444444444444', '33333333-3333-3333-3333-333333330001', '7d000000-0000-0000-0000-000000000011', 'e0000000-0000-0000-0000-000000000001', 'ERP', 'FACT', 'F001', '00012345', '2026-01-10', 'Compra de combustible enero 2026', 1500.00, 'ACTIVO', '22222222-2222-2222-2222-222222222222');
INSERT INTO erp_importacion_detalle (id, id_empresa, id_erp_importacion, datos_raw, id_gasto_directo, estado, error_mensaje) VALUES (gen_random_uuid(), '11111111-1111-1111-1111-111111111111', 'e5000000-0000-0000-0000-000000000001', '{"serie": "F001", "numero": "00012345", "fecha": "2026-01-10", "ruc": "20512345678", "importe": 1500.00, "descripcion": "Compra de combustible enero 2026"}', 'e4000000-0000-0000-0000-000000000001', 'PROCESADO', NULL);

-- ===== CONTRATOS: relaciones (contrato_gasto_fijo usa proveedor) =====
INSERT INTO contrato_zona (id, id_empresa, id_contrato, id_zona, estado, creado_por_usuario_id) VALUES ('c0000000-0000-0000-0000-000000000001','11111111-1111-1111-1111-111111111111','cc000000-0000-0000-0000-000000000001','44444444-4444-4444-4444-444444444444','ACTIVO','22222222-2222-2222-2222-222222222222');
INSERT INTO contrato_porcentaje_distribucion (id, id_empresa, id_contrato, id_periodo, porcentaje, estado, creado_por_usuario_id) VALUES ('cf000000-0000-0000-0000-000000000001','11111111-1111-1111-1111-111111111111','cc000000-0000-0000-0000-000000000001','33333333-3333-3333-3333-333333330001',1.0000,'ACTIVO','22222222-2222-2222-2222-222222222222');
INSERT INTO contrato_gasto_fijo (id, id_empresa, id_contrato, id_zona, id_clasificacion, id_proveedor, descripcion, importe, fecha_inicio, fecha_fin, estado, creado_por_usuario_id) VALUES ('ca000000-0000-0000-0000-000000000001','11111111-1111-1111-1111-111111111111','cc000000-0000-0000-0000-000000000001','44444444-4444-4444-4444-444444444444','7d000000-0000-0000-0000-000000000011','e0000000-0000-0000-0000-000000000001','Alquiler de oficina central',3500.00,'2026-01-01','2026-01-31','ACTIVO','22222222-2222-2222-2222-222222222222');
INSERT INTO gasto_inicial (id, id_empresa, id_contrato, id_zona, descripcion, importe_total, importe_mensual, tiempo_en_meses, fecha_inicio, fecha_fin, estado, creado_por_usuario_id) VALUES ('cb000000-0000-0000-0000-000000000001','11111111-1111-1111-1111-111111111111','cc000000-0000-0000-0000-000000000001','44444444-4444-4444-4444-444444444444','Implementacion inicial de equipamiento',12000.00,1000.00,12,'2026-01-01','2026-01-31','ACTIVO','22222222-2222-2222-2222-222222222222');

-- ===== PRODUCCION: transaccional (usa contrato_zona) =====
INSERT INTO operario (id, id_empresa, tipo_documento, numero_documento, nombres, apellidos, cargo, licencia, estado, creado_por_usuario_id) VALUES ('e1000000-0000-0000-0000-000000000001', '11111111-1111-1111-1111-111111111111', 'DNI', '40123456', 'Carlos Alberto', 'Quispe Mamani', 'OPERARIO DE LIMPIEZA', 'A-IIB-40123456', 'ACTIVO', '22222222-2222-2222-2222-222222222222');
INSERT INTO rubro (id, id_empresa, codigo, nombre, descripcion, estado, creado_por_usuario_id) VALUES ('e2000000-0000-0000-0000-000000000001', '11111111-1111-1111-1111-111111111111', 'RUB-001', 'LIMPIEZA Y MANTENIMIENTO', 'Rubro demo de servicios de limpieza y mantenimiento de areas', 'ACTIVO', '22222222-2222-2222-2222-222222222222');
INSERT INTO produccion_mensual (id, id_empresa, id_contrato, id_contrato_zona, id_periodo, total_valorizado, fecha_registro, observacion, estado, creado_por_usuario_id) VALUES ('e3000000-0000-0000-0000-000000000001', '11111111-1111-1111-1111-111111111111', 'cc000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000001', '33333333-3333-3333-3333-333333330001', 12260.00, '2026-01-31', 'Produccion mensual demo enero 2026', 'ACTIVO', '22222222-2222-2222-2222-222222222222');
INSERT INTO produccion_mensual_detalle (id, id_empresa, id_produccion_mensual, id_linea_servicio, id_operario, descripcion, cantidad_producida, precio_unitario, valor_produccion_detalle, estado, creado_por_usuario_id) VALUES (gen_random_uuid(), '11111111-1111-1111-1111-111111111111', 'e3000000-0000-0000-0000-000000000001', '1c000000-0000-0000-0000-000000000001', 'e1000000-0000-0000-0000-000000000001', 'Limpieza de areas comunes m2', 120.0000, 85.5000, 10260.00, 'ACTIVO', '22222222-2222-2222-2222-222222222222');
INSERT INTO produccion_mensual_detalle (id, id_empresa, id_produccion_mensual, id_linea_servicio, id_operario, descripcion, cantidad_producida, precio_unitario, valor_produccion_detalle, estado, creado_por_usuario_id) VALUES (gen_random_uuid(), '11111111-1111-1111-1111-111111111111', 'e3000000-0000-0000-0000-000000000001', '1c000000-0000-0000-0000-000000000001', 'e1000000-0000-0000-0000-000000000001', 'Recojo de residuos solidos viajes', 40.0000, 50.0000, 2000.00, 'ACTIVO', '22222222-2222-2222-2222-222222222222');

-- ===== FACTURACION + VALORIZACION (usa contrato_zona, produccion_mensual, rubro) =====
INSERT INTO zona_contratada (id) VALUES ('e6000000-0000-0000-0000-000000000001');
INSERT INTO facturacion_contractual (id, id_empresa, id_contrato, id_zona_contratada, id_periodo, numero_documento, fecha_emision, total_facturado, observacion, estado, creado_por_usuario_id) VALUES ('e7000000-0000-0000-0000-000000000001', '11111111-1111-1111-1111-111111111111', 'cc000000-0000-0000-0000-000000000001', 'e6000000-0000-0000-0000-000000000001', '33333333-3333-3333-3333-333333330001', 'F001-00000001', '2026-01-31', 15000.00, 'Facturacion contractual demo enero 2026', 'ACTIVO', '22222222-2222-2222-2222-222222222222');
INSERT INTO facturacion_contractual_detalle (id, id_empresa, id_facturacion_contractual, concepto, importe, estado, creado_por_usuario_id) VALUES (gen_random_uuid(), '11111111-1111-1111-1111-111111111111', 'e7000000-0000-0000-0000-000000000001', 'Servicio mensual contractual zona demo', 15000.00, 'ACTIVO', '22222222-2222-2222-2222-222222222222');
INSERT INTO valorizacion_mensual (id, id_empresa, id_contrato, id_contrato_zona, id_periodo, id_produccion_mensual, fecha_valorizacion, observacion, total_valorizacion_mensual, estado, creado_por_usuario_id) VALUES ('e8000000-0000-0000-0000-000000000001', '11111111-1111-1111-1111-111111111111', 'cc000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000001', '33333333-3333-3333-3333-333333330001', 'e3000000-0000-0000-0000-000000000001', '2026-01-31', 'Valorizacion mensual demo enero 2026', 12000.00, 'BORRADOR', '22222222-2222-2222-2222-222222222222');
INSERT INTO valorizacion_mensual_detalle (id, id_empresa, id_valorizacion_mensual, id_rubro, concepto, cantidad_valorizada, precio_unitario, importe_valorizado, observacion, estado, creado_por_usuario_id) VALUES (gen_random_uuid(), '11111111-1111-1111-1111-111111111111', 'e8000000-0000-0000-0000-000000000001', 'e2000000-0000-0000-0000-000000000001', 'Avance valorizado rubro demo', 100.0000, 120.0000, 12000.00, 'Detalle valorizacion mensual demo', 'ACTIVO', '22222222-2222-2222-2222-222222222222');
INSERT INTO valorizacion_complementaria (id, id_empresa, id_contrato, id_contrato_zona, id_periodo, tipo_ajuste, motivo, fecha_registro, total_valorizacion_complementaria, estado, creado_por_usuario_id) VALUES ('e9000000-0000-0000-0000-000000000001', '11111111-1111-1111-1111-111111111111', 'cc000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000001', '33333333-3333-3333-3333-333333330001', 'REGULARIZACION', 'Regularizacion de avance no valorizado en periodo demo', '2026-01-31', 2500.00, 'BORRADOR', '22222222-2222-2222-2222-222222222222');
INSERT INTO valorizacion_complementaria_detalle (id, id_empresa, id_valorizacion_complementaria, id_rubro, concepto, cantidad, precio_unitario, importe, observacion, estado, creado_por_usuario_id) VALUES (gen_random_uuid(), '11111111-1111-1111-1111-111111111111', 'e9000000-0000-0000-0000-000000000001', 'e2000000-0000-0000-0000-000000000001', 'Ajuste complementario rubro demo', 25.0000, 100.0000, 2500.00, 'Detalle complementario demo', 'ACTIVO', '22222222-2222-2222-2222-222222222222');

-- ===== ACTIVOS / CIERRE / GOBIERNO: transaccional (hojas) =====
INSERT INTO activo_registro_trabajo (id, id_empresa, id_activo, id_contrato, id_zona, id_periodo, fecha, fecha_hora_inicio, fecha_hora_fin, horas_trabajadas, descripcion_trabajo, valorizacion_trabajo, dias_depreciados, kilometraje_inicio, kilometraje_fin, creado_por_usuario_id) VALUES (gen_random_uuid(), '11111111-1111-1111-1111-111111111111', 'b1b1b1b1-b1b1-b1b1-b1b1-b1b1b1b1b1b1', 'cc000000-0000-0000-0000-000000000001', '44444444-4444-4444-4444-444444444444', '33333333-3333-3333-3333-333333330001', '2026-01-15', '2026-01-15T08:00:00Z', '2026-01-15T16:00:00Z', 8.00, 'Operacion de vehiculo en ruta demo', 1200.00, 1.00, 10000, 10120, '22222222-2222-2222-2222-222222222222');
INSERT INTO activo_traslado (id, id_empresa, id_activo, id_contrato_origen, id_zona_origen, id_contrato_destino, id_zona_destino, fecha_traslado, saldo_trasladado, motivo, creado_por_usuario_id) VALUES (gen_random_uuid(), '11111111-1111-1111-1111-111111111111', 'b1b1b1b1-b1b1-b1b1-b1b1-b1b1b1b1b1b1', 'cc000000-0000-0000-0000-000000000001', '44444444-4444-4444-4444-444444444444', 'cc000000-0000-0000-0000-000000000001', '44444444-4444-4444-4444-444444444444', '2026-01-20', 5000.00, 'Reasignacion interna demo', '22222222-2222-2222-2222-222222222222');
INSERT INTO herramienta_movimiento (id, id_empresa, id_herramienta, id_periodo, tipo_movimiento, fecha, id_contrato_origen, id_zona_origen, id_contrato_destino, id_zona_destino, cantidad, costo, valorizacion, motivo, creado_por_usuario_id) VALUES (gen_random_uuid(), '11111111-1111-1111-1111-111111111111', 'b2b2b2b2-b2b2-b2b2-b2b2-b2b2b2b2b2b2', '33333333-3333-3333-3333-333333330001', 'ENTRADA', '2026-01-10', NULL, NULL, 'cc000000-0000-0000-0000-000000000001', '44444444-4444-4444-4444-444444444444', 2.00, 350.00, 700.00, 'Ingreso inicial de herramienta demo', '22222222-2222-2222-2222-222222222222');
INSERT INTO recuperacion_inversion_mensual (id, id_empresa, id_activo, id_contrato, id_periodo, importe_recuperado, saldo_antes, saldo_despues, parado, creado_por_usuario_id) VALUES (gen_random_uuid(), '11111111-1111-1111-1111-111111111111', 'b1b1b1b1-b1b1-b1b1-b1b1-b1b1b1b1b1b1', 'cc000000-0000-0000-0000-000000000001', '33333333-3333-3333-3333-333333330001', 1500.00, 30000.00, 28500.00, false, '22222222-2222-2222-2222-222222222222');
INSERT INTO penalidad (id, id_empresa, id_contrato, id_periodo, descripcion, importe, creado_por_usuario_id) VALUES (gen_random_uuid(), '11111111-1111-1111-1111-111111111111', 'cc000000-0000-0000-0000-000000000001', '33333333-3333-3333-3333-333333330001', 'Penalidad por incumplimiento de SLA demo', 800.00, '22222222-2222-2222-2222-222222222222');
INSERT INTO provision (id, id_empresa, id_contrato, id_periodo, descripcion, importe, aplicado, creado_por_usuario_id) VALUES (gen_random_uuid(), '11111111-1111-1111-1111-111111111111', 'cc000000-0000-0000-0000-000000000001', '33333333-3333-3333-3333-333333330001', 'Provision de gastos varios demo', 1200.00, false, '22222222-2222-2222-2222-222222222222');
INSERT INTO cierre_mensual (id, id_empresa, id_contrato, id_periodo, total_facturado, total_produccion, gastos_directos, gastos_varios_fijos, gastos_iniciales_periodo, recuperacion_inversion, gastos_administrativos, gastos_indirectos, gastos_financieros, gastos_sig, total_gastos, utilidad_bruta, impuesto_renta, renta_adicional, reparto_utilidades, penalidades, utilidad_neta, utilidad_final, estado, creado_por_usuario_id) VALUES (gen_random_uuid(), '11111111-1111-1111-1111-111111111111', 'cc000000-0000-0000-0000-000000000001', '33333333-3333-3333-3333-333333330001', 50000.00, 50000.00, 20000.00, 3000.00, 1000.00, 1500.00, 4000.00, 2000.00, 500.00, 800.00, 31300.00, 18700.00, 5610.00, 0.00, 1870.00, 800.00, 12290.00, 11420.00, 'BORRADOR', '22222222-2222-2222-2222-222222222222');
INSERT INTO usuario_rol (id, id_usuario_empresa, id_rol, estado, creado_por_usuario_id) VALUES (gen_random_uuid(), (SELECT id FROM usuario_empresa WHERE id_empresa='11111111-1111-1111-1111-111111111111' LIMIT 1), 'aa000000-0000-0000-0000-000000000001', 'ACTIVO', '22222222-2222-2222-2222-222222222222');
