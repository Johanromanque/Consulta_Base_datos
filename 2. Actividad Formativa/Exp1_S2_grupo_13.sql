/* ---- DEFINIR FORMATO FECHA DD/MM/YYYY ---- */
ALTER SESSION SET NLS_DATE_FORMAT='DD/MM/YYYY';


/* ---- BORRADO DE OBJETOS ---- */

DROP TABLE detalle_factura CASCADE CONSTRAINTS;
DROP TABLE factura CASCADE CONSTRAINTS;
DROP TABLE detalle_boleta CASCADE CONSTRAINTS;
DROP TABLE boleta CASCADE CONSTRAINTS;
DROP TABLE producto CASCADE CONSTRAINTS;
DROP TABLE unidad_medida CASCADE CONSTRAINTS;
DROP TABLE pais CASCADE CONSTRAINTS;
DROP TABLE cliente CASCADE CONSTRAINTS;
DROP TABLE vendedor CASCADE CONSTRAINTS;
DROP TABLE forma_pago CASCADE CONSTRAINTS;
DROP TABLE banco CASCADE CONSTRAINTS;
DROP TABLE comuna CASCADE CONSTRAINTS;
DROP TABLE ciudad CASCADE CONSTRAINTS;
DROP TABLE tramo_antiguedad CASCADE CONSTRAINTS;
DROP TABLE tramo_escolaridad CASCADE CONSTRAINTS;
DROP TABLE remun_mensual_vendedor CASCADE CONSTRAINTS;
DROP TABLE escolaridad CASCADE CONSTRAINTS;


/* ---- CREACIÓN DE OBJETOS ---- */

CREATE TABLE remun_mensual_vendedor (
  rutvendedor       VARCHAR2(10),
  nomvendedor       VARCHAR2(30),
  fecha_remun       NUMBER(6),
  sueldo_base       NUMBER(8),
  colacion          NUMBER(8),
  movilizacion      NUMBER(8),
  prevision         NUMBER(8),
  salud             NUMBER(8),
  comision_normal   NUMBER(8),
  comsion_por_venta NUMBER(8),
  total_bonos       NUMBER(8),
  total_haberes     NUMBER(8),
  total_desctos     NUMBER(8),
  total_pagar       NUMBER(8)
);

ALTER TABLE remun_mensual_vendedor ADD CONSTRAINT pk_remun_mensual_vendedor PRIMARY KEY ( rutvendedor,
                                                                                          fecha_remun );

CREATE TABLE tramo_antiguedad (
  sec_annos_contratado NUMBER(2),
  fec_ini_vig          DATE,
  fec_ter_vig          DATE,
  annos_cont_inf       NUMBER(2),
  annos_cont_sup       NUMBER(2),
  porcentaje           NUMBER(2)
);

ALTER TABLE tramo_antiguedad ADD CONSTRAINT pk_tramo_antiguedad PRIMARY KEY ( sec_annos_contratado,
                                                                              fec_ini_vig );

CREATE TABLE escolaridad (
  id_escolaridad    NUMBER(2),
  sigla_escolaridad VARCHAR2(5),
  desc_escolaridad  VARCHAR2(50)
);

ALTER TABLE escolaridad ADD CONSTRAINT pk_escolaridad PRIMARY KEY ( id_escolaridad );

CREATE TABLE tramo_escolaridad (
  id_escolaridad        NUMBER(2),
  fecha_vigencia        NUMBER(4),
  porc_asig_escolaridad NUMBER(2)
);

ALTER TABLE tramo_escolaridad ADD CONSTRAINT pk_tramo_escolaridad PRIMARY KEY ( id_escolaridad,
                                                                                fecha_vigencia );

CREATE TABLE ciudad (
  codciudad   NUMBER(2),
  descripcion VARCHAR2(30)
);

ALTER TABLE ciudad ADD CONSTRAINT pk_cod_ciudad PRIMARY KEY ( codciudad );

CREATE TABLE comuna (
  codcomuna   NUMBER(2),
  descripcion VARCHAR2(30),
  codciudad   NUMBER(2)
);

ALTER TABLE comuna ADD CONSTRAINT pk_cod_comuna PRIMARY KEY ( codcomuna );

CREATE TABLE cliente (
  rutcliente VARCHAR2(10),
  nombre     VARCHAR2(30),
  direccion  VARCHAR2(30),
  codcomuna  NUMBER(2),
  telefono   NUMBER(10),
  estado     VARCHAR2(1),
  mail       VARCHAR2(50),
  credito    NUMBER(7),
  saldo      NUMBER(7)
);

ALTER TABLE cliente ADD CONSTRAINT pk_rut_cliente PRIMARY KEY ( rutcliente );

ALTER TABLE cliente
  ADD CONSTRAINT estado_cliente_ck CHECK ( estado IN ( 'A', 'B' ) );

CREATE TABLE vendedor (
  rutvendedor    VARCHAR2(10),
  id             NUMBER(2),
  nombre         VARCHAR2(30),
  direccion      VARCHAR2(30),
  codcomuna      NUMBER(2),
  telefono       NUMBER(10),
  mail           VARCHAR2(50),
  sueldo_base    NUMBER(8),
  comision       NUMBER(2, 2),
  fecha_contrato DATE,
  id_escolaridad NUMBER(2)
);

ALTER TABLE vendedor ADD CONSTRAINT pk_rut_vendedor PRIMARY KEY ( rutvendedor );

CREATE TABLE unidad_medida (
  codunidad   VARCHAR2(2),
  descripcion VARCHAR2(30)
);

ALTER TABLE unidad_medida ADD CONSTRAINT pk_cod_unidad PRIMARY KEY ( codunidad );

CREATE TABLE pais (
  codpais NUMBER(2),
  nompais VARCHAR2(30)
);

ALTER TABLE pais ADD CONSTRAINT pk_pais PRIMARY KEY ( codpais );

CREATE TABLE producto (
  codproducto      NUMBER(3),
  descripcion      VARCHAR2(40),
  codunidad        VARCHAR2(2),
  codcategoria     VARCHAR2(1),
  vunitario        NUMBER(8),
  valorcomprapeso  NUMBER(8),
  valorcompradolar NUMBER(8, 2),
  totalstock       NUMBER(5),
  stkseguridad     NUMBER(5),
  procedencia      VARCHAR2(1),
  codpais          NUMBER(2),
  codproducto_rel  NUMBER(3)
);

ALTER TABLE producto ADD CONSTRAINT pk_cod_prod PRIMARY KEY ( codproducto );

CREATE TABLE forma_pago (
  codpago     NUMBER(2),
  descripcion VARCHAR2(30)
);

ALTER TABLE forma_pago ADD CONSTRAINT pk_codpago PRIMARY KEY ( codpago );

CREATE TABLE banco (
  codbanco    NUMBER(2),
  descripcion VARCHAR2(30)
);

ALTER TABLE banco ADD CONSTRAINT pk_codbanco PRIMARY KEY ( codbanco );

CREATE TABLE factura (
  numfactura     NUMBER(7),
  rutcliente     VARCHAR2(10),
  rutvendedor    VARCHAR2(10),
  fecha          DATE,
  f_vencimiento  DATE,
  neto           NUMBER(7),
  iva            NUMBER(7),
  total          NUMBER(7),
  codbanco       NUMBER(2),
  codpago        NUMBER(2),
  num_docto_pago VARCHAR2(30),
  estado         VARCHAR2(2)
);

ALTER TABLE factura ADD CONSTRAINT pk_numfactur PRIMARY KEY ( numfactura );

CREATE TABLE detalle_factura (
  numfactura   NUMBER(7),
  codproducto  NUMBER(3),
  vunitario    NUMBER(8),
  codpromocion NUMBER(4),
  descri_prom  VARCHAR2(60),
  descuento    NUMBER(8),
  cantidad     NUMBER(5),
  totallinea   NUMBER(8)
);

ALTER TABLE detalle_factura ADD CONSTRAINT pk_det_fact PRIMARY KEY ( numfactura,
                                                                     codproducto );

CREATE TABLE boleta (
  numboleta      NUMBER(7),
  rutcliente     VARCHAR2(10),
  rutvendedor    VARCHAR2(10),
  fecha          DATE,
  total          NUMBER(7),
  codpago        NUMBER(2),
  codbanco       NUMBER(2),
  num_docto_pago VARCHAR2(30),
  estado         VARCHAR2(2)
);

ALTER TABLE boleta ADD CONSTRAINT pk_numboleta PRIMARY KEY ( numboleta );

CREATE TABLE detalle_boleta (
  numboleta    NUMBER(7),
  codproducto  NUMBER(3),
  vunitario    NUMBER(8),
  codpromocion NUMBER(4),
  descri_prom  VARCHAR2(60),
  descuento    NUMBER(8),
  cantidad     NUMBER(5),
  totallinea   NUMBER(8)
);

ALTER TABLE detalle_boleta ADD CONSTRAINT pk_det_boleta PRIMARY KEY ( numboleta,
                                                                      codproducto );

ALTER TABLE detalle_boleta
  ADD CONSTRAINT det_bol_codproducto_fk FOREIGN KEY ( codproducto )
    REFERENCES producto ( codproducto );

ALTER TABLE detalle_boleta
  ADD CONSTRAINT det_bol_num_boleta_fk FOREIGN KEY ( numboleta )
    REFERENCES boleta ( numboleta );

ALTER TABLE detalle_factura
  ADD CONSTRAINT cod_prod_fk FOREIGN KEY ( codproducto )
    REFERENCES producto ( codproducto );

ALTER TABLE detalle_factura
  ADD CONSTRAINT num_fact_fk FOREIGN KEY ( numfactura )
    REFERENCES factura ( numfactura );

ALTER TABLE factura
  ADD CONSTRAINT rutcliente_fk FOREIGN KEY ( rutcliente )
    REFERENCES cliente ( rutcliente );

ALTER TABLE factura
  ADD CONSTRAINT rutvendedor_fk FOREIGN KEY ( rutvendedor )
    REFERENCES vendedor ( rutvendedor );

ALTER TABLE factura
  ADD CONSTRAINT codpago_fk FOREIGN KEY ( codpago )
    REFERENCES forma_pago ( codpago );

ALTER TABLE factura
  ADD CONSTRAINT codbanco_fk FOREIGN KEY ( codbanco )
    REFERENCES banco ( codbanco );

ALTER TABLE factura
  ADD CONSTRAINT estado_factura_ck CHECK ( estado IN ( 'EM', 'PA', 'NC' ) );

ALTER TABLE producto
  ADD CONSTRAINT cod_unidad_fk FOREIGN KEY ( codunidad )
    REFERENCES unidad_medida ( codunidad );

ALTER TABLE producto
  ADD CONSTRAINT cod_pais_fk FOREIGN KEY ( codpais )
    REFERENCES pais ( codpais );

ALTER TABLE producto
  ADD CONSTRAINT codproducto_rel_fk FOREIGN KEY ( codproducto_rel )
    REFERENCES producto ( codproducto );

ALTER TABLE vendedor
  ADD CONSTRAINT vendedor_cod_comuna_fk FOREIGN KEY ( codcomuna )
    REFERENCES comuna ( codcomuna );

ALTER TABLE comuna
  ADD CONSTRAINT cod_ciudad_fk FOREIGN KEY ( codciudad )
    REFERENCES ciudad ( codciudad );

ALTER TABLE cliente
  ADD CONSTRAINT cod_comuna_fk FOREIGN KEY ( codcomuna )
    REFERENCES comuna ( codcomuna );

ALTER TABLE boleta
  ADD CONSTRAINT bol_rutcliente_fk FOREIGN KEY ( rutcliente )
    REFERENCES cliente ( rutcliente );

ALTER TABLE boleta
  ADD CONSTRAINT bol_rutvendedor_fk FOREIGN KEY ( rutvendedor )
    REFERENCES vendedor ( rutvendedor );

ALTER TABLE boleta
  ADD CONSTRAINT bol_codpago_fk FOREIGN KEY ( codpago )
    REFERENCES forma_pago ( codpago );

ALTER TABLE boleta
  ADD CONSTRAINT bol_codbanco_fk FOREIGN KEY ( codbanco )
    REFERENCES banco ( codbanco );

ALTER TABLE boleta
  ADD CONSTRAINT bol_estado_boleta_ck CHECK ( estado IN ( 'EM', 'PA', 'NC' ) );

ALTER TABLE remun_mensual_vendedor
  ADD CONSTRAINT fk_remun_mensual_vendedor FOREIGN KEY ( rutvendedor )
    REFERENCES vendedor ( rutvendedor );

ALTER TABLE tramo_escolaridad
  ADD CONSTRAINT fk_tramo_escolaridad FOREIGN KEY ( id_escolaridad )
    REFERENCES escolaridad ( id_escolaridad );

ALTER TABLE vendedor
  ADD CONSTRAINT fk_esc_vendedor FOREIGN KEY ( id_escolaridad )
    REFERENCES escolaridad ( id_escolaridad );



/* ---- POBLAMIENTO ---- */

INSERT INTO tramo_antiguedad VALUES (
  1,
  TO_DATE('01/01/' || TO_CHAR(EXTRACT(YEAR FROM SYSDATE)-2)),
  TO_DATE('31/12/' || TO_CHAR(EXTRACT(YEAR FROM SYSDATE)-2)),
  1,
  9,
  4
);

INSERT INTO tramo_antiguedad VALUES (
  2,
  TO_DATE('01/01/' || TO_CHAR(EXTRACT(YEAR FROM SYSDATE)-2)),
  TO_DATE('31/12/' || TO_CHAR(EXTRACT(YEAR FROM SYSDATE)-2)),
  10,
  12,
  6
);

INSERT INTO tramo_antiguedad VALUES (
  3,
  TO_DATE('01/01/' || TO_CHAR(EXTRACT(YEAR FROM SYSDATE)-2)),
  TO_DATE('31/12/' || TO_CHAR(EXTRACT(YEAR FROM SYSDATE)-2)),
  13,
  16,
  7
);

INSERT INTO tramo_antiguedad VALUES (
  4,
  TO_DATE('01/01/' || TO_CHAR(EXTRACT(YEAR FROM SYSDATE)-2)),
  TO_DATE('31/12/' || TO_CHAR(EXTRACT(YEAR FROM SYSDATE)-2)),
  16,
  30,
  10
);

INSERT INTO tramo_antiguedad VALUES (
  1,
  TO_DATE('01/01/' || TO_CHAR(EXTRACT(YEAR FROM SYSDATE)-1)),
  TO_DATE('31/12/' || TO_CHAR(EXTRACT(YEAR FROM SYSDATE)-1)),
  1,
  9,
  5
);

INSERT INTO tramo_antiguedad VALUES (
  2,
  TO_DATE('01/01/' || TO_CHAR(EXTRACT(YEAR FROM SYSDATE)-1)),
  TO_DATE('31/12/' || TO_CHAR(EXTRACT(YEAR FROM SYSDATE)-1)),
  10,
  12,
  7
);

INSERT INTO tramo_antiguedad VALUES (
  3,
  TO_DATE('01/01/' || TO_CHAR(EXTRACT(YEAR FROM SYSDATE)-1)),
  TO_DATE('31/12/' || TO_CHAR(EXTRACT(YEAR FROM SYSDATE)-1)),
  13,
  16,
  8
);

INSERT INTO tramo_antiguedad VALUES (
  4,
  TO_DATE('01/01/' || TO_CHAR(EXTRACT(YEAR FROM SYSDATE)-1)),
  TO_DATE('31/12/' || TO_CHAR(EXTRACT(YEAR FROM SYSDATE)-1)),
  16,
  30,
  11
);

INSERT INTO escolaridad VALUES (
  10,
  'BA',
  'BASICA'
);

INSERT INTO escolaridad VALUES (
  20,
  'MCH',
  'MEDIA CIENTIFICA HUMANISTA'
);

INSERT INTO escolaridad VALUES (
  30,
  'MTP',
  'MEDIA TECNICO PROFESIONAL'
);

INSERT INTO escolaridad VALUES (
  40,
  'SCFT',
  'SUPERIOR CENTRO DE FORMACION TECNICA'
);

INSERT INTO escolaridad VALUES (
  50,
  'SIP',
  'SUPERIOR INSTITUTO PROFESIONAL'
);

INSERT INTO escolaridad VALUES (
  60,
  'SU',
  'SUPERIOR UNIVERSIDAD'
);

INSERT INTO tramo_escolaridad VALUES (
  10,
  EXTRACT(YEAR FROM SYSDATE)-2,
  1
);

INSERT INTO tramo_escolaridad VALUES (
  20,
  EXTRACT(YEAR FROM SYSDATE)-2,
  2
);

INSERT INTO tramo_escolaridad VALUES (
  30,
  EXTRACT(YEAR FROM SYSDATE)-2,
  3
);

INSERT INTO tramo_escolaridad VALUES (
  40,
  EXTRACT(YEAR FROM SYSDATE)-2,
  4
);

INSERT INTO tramo_escolaridad VALUES (
  50,
  EXTRACT(YEAR FROM SYSDATE)-2,
  5
);

INSERT INTO tramo_escolaridad VALUES (
  60,
  EXTRACT(YEAR FROM SYSDATE)-2,
  6
);

INSERT INTO tramo_escolaridad VALUES (
  10,
  EXTRACT(YEAR FROM SYSDATE)-1,
  4
);

INSERT INTO tramo_escolaridad VALUES (
  20,
  EXTRACT(YEAR FROM SYSDATE)-1,
  5
);

INSERT INTO tramo_escolaridad VALUES (
  30,
  EXTRACT(YEAR FROM SYSDATE)-1,
  6
);

INSERT INTO tramo_escolaridad VALUES (
  40,
  EXTRACT(YEAR FROM SYSDATE)-1,
  7
);

INSERT INTO tramo_escolaridad VALUES (
  50,
  EXTRACT(YEAR FROM SYSDATE)-1,
  8
);

INSERT INTO tramo_escolaridad VALUES (
  60,
  EXTRACT(YEAR FROM SYSDATE)-1,
  9
);

INSERT INTO ciudad VALUES (
  1,
  'ARICA'
);

INSERT INTO ciudad VALUES (
  2,
  'IQUIQUE'
);

INSERT INTO ciudad VALUES (
  3,
  'CALAMA'
);

INSERT INTO ciudad VALUES (
  4,
  'ANTOFAGASTA'
);

INSERT INTO ciudad VALUES (
  5,
  'COPIAPO'
);

INSERT INTO ciudad VALUES (
  6,
  'LA SERENA'
);

INSERT INTO ciudad VALUES (
  7,
  'VALPARAISO'
);

INSERT INTO ciudad VALUES (
  8,
  'SANTIAGO'
);

INSERT INTO ciudad VALUES (
  9,
  'RANCAGUA'
);

INSERT INTO ciudad VALUES (
  10,
  'TALCA'
);

INSERT INTO ciudad VALUES (
  11,
  'CONCEPCION'
);

INSERT INTO ciudad VALUES (
  12,
  'TEMUCO'
);

INSERT INTO ciudad VALUES (
  13,
  'VALDIVIA'
);

INSERT INTO ciudad VALUES (
  14,
  'OSORNO'
);

INSERT INTO ciudad VALUES (
  15,
  'PTO. MONTT'
);

INSERT INTO ciudad VALUES (
  16,
  'COYHAIQUE'
);

INSERT INTO ciudad VALUES (
  17,
  'PTA. ARENAS'
);

INSERT INTO comuna VALUES (
  1,
  'VITACURA',
  8
);

INSERT INTO comuna VALUES (
  2,
  'NUNOA',
  8
);

INSERT INTO comuna VALUES (
  3,
  'PENALOLEN',
  8
);

INSERT INTO comuna VALUES (
  4,
  'SANTIAGO',
  8
);

INSERT INTO comuna VALUES (
  5,
  'VALDIVIA',
  13
);

INSERT INTO comuna VALUES (
  6,
  'EL LOA',
  3
);

INSERT INTO comuna VALUES (
  7,
  'CHILLAN',
  11
);

INSERT INTO comuna VALUES (
  8,
  'PROVIDENCIA',
  8
);

INSERT INTO comuna VALUES (
  9,
  'PTO.SAAVEDRA',
  14
);

INSERT INTO forma_pago VALUES (
  1,
  'EFECTIVO'
);

INSERT INTO forma_pago VALUES (
  2,
  'TARJETA DEBITO'
);

INSERT INTO forma_pago VALUES (
  3,
  'TARJETA CREDITO'
);

INSERT INTO forma_pago VALUES (
  4,
  'CHEQUE'
);

INSERT INTO banco VALUES (
  1,
  'CHILE'
);

INSERT INTO banco VALUES (
  2,
  'SANTANDER'
);

INSERT INTO banco VALUES (
  3,
  'BCI'
);

INSERT INTO banco VALUES (
  4,
  'CORP BANCA'
);

INSERT INTO banco VALUES (
  5,
  'BBVA'
);

INSERT INTO banco VALUES (
  6,
  'SCOTIBANK'
);

INSERT INTO banco VALUES (
  7,
  'SECURITY'
);

INSERT INTO unidad_medida VALUES (
  'UN',
  'UNITARIO'
);

INSERT INTO unidad_medida VALUES (
  'LQ',
  'LIQUIDO'
);

INSERT INTO pais VALUES (
  1,
  'CHILE'
);

INSERT INTO pais VALUES (
  2,
  'EEUU'
);

INSERT INTO pais VALUES (
  3,
  'INGLATERRA'
);

INSERT INTO pais VALUES (
  4,
  'ALEMANIA'
);

INSERT INTO pais VALUES (
  5,
  'FRANCIA'
);

INSERT INTO pais VALUES (
  6,
  'CANADA'
);

INSERT INTO pais VALUES (
  7,
  'ARGENTINA'
);

INSERT INTO pais VALUES (
  8,
  'BRASIL'
);

INSERT INTO cliente VALUES (
  '6245678-1',
  'JUAN LOPEZ',
  'ALAMEDA 6152',
  8,
  96644123,
  'A',
  'JLOPEZ@GMAIL.COM',
  1000000,
  696550
);

INSERT INTO cliente VALUES (
  '7812354-2',
  'MARIA SANTANDER',
  'APOQUINDO 9093',
  8,
  961682456,
  'A',
  'MSANTANDER@HOTMAIL.COM',
  1000000,
  819120
);

INSERT INTO cliente VALUES (
  '9912478-3',
  'SIGIFRIDO SILVA',
  'BILBAO 6200',
  8,
  55877315,
  'B',
  'SSILVA@GMAIL.COM',
  1500000,
  0
);

INSERT INTO cliente VALUES (
  '14456789-4',
  'OSCAR LARA',
  'ALAMEDA 960',
  NULL,
  79888222,
  'A',
  'OLARA@GMAIL.COM',
  2500000,
  2000000
);

INSERT INTO cliente VALUES (
  '11245678-5',
  'MARCO ITURRA',
  'ALAMEDA 1056',
  8,
  94577804,
  'A',
  NULL,
  3000000,
  2332410
);

INSERT INTO cliente VALUES (
  '6467708-6',
  'MARIBEL SOTO',
  'VICUNA MACKENNA 4555',
  4,
  95514545,
  'A',
  'MSOTO@GMAIL.COM',
  1800000,
  1200000
);

INSERT INTO cliente VALUES (
  '10125945-7',
  'SABINA VERGARA',
  'AV. LA FLORIDA 15554 ',
  4,
  88656285,
  'A',
  NULL,
  500000,
  150000
);

INSERT INTO cliente VALUES (
  '8125781-8',
  'PATRICIA FUENTES',
  'IRARRAZABAL 5452',
  2,
  NULL,
  'A',
  'PFUENTES@HOTMAIL.COM',
  450000,
  50000
);

INSERT INTO cliente VALUES (
  '13746912-9',
  'ABRAHAM IGLESIAS',
  'ALAMEDA 454',
  4,
  91452303,
  'A',
  'AIGLESIAS@YAHOO.COM',
  100000,
  90000
);

INSERT INTO cliente VALUES (
  '5446780-0',
  'CARLOS MENDOZA',
  'PANAMERICANA 152',
  1,
  NULL,
  'A',
  NULL,
  800000,
  550000
);

INSERT INTO cliente VALUES (
  '10812874-0',
  'LIDIA FUENZALIDA',
  'PROVIDENCIA 4587 ',
  NULL,
  78544452,
  'A',
  'LFUENZALIDA@GMAIL.COM',
  1900000,
  790000
);

INSERT INTO cliente VALUES (
  '15123587-1',
  'BRAULIO GUTIERREZ',
  'PROVIDENCIA 5400',
  NULL,
  NULL,
  'B',
  'BGUTIERREZ@HOTMAIL.COM',
  2500000,
  0
);

INSERT INTO cliente VALUES (
  '12444650-7',
  'RUBEN PANTOJA',
  'AV. GRECIA 152',
  4,
  NULL,
  'B',
  'RPANTOJA@YAHOO.COM',
  100000,
  0
);

INSERT INTO cliente VALUES (
  '13685017-1',
  'JOHNNY YANEZ',
  'PROVIDENCIA 2900',
  NULL,
  78598619,
  'A',
  'JYANEZ@GMAIL.COM',
  1200000,
  200000
);

INSERT INTO cliente VALUES (
  '10675908-1',
  'JAIME SALAMANCA',
  'FREIRE 2900',
  NULL,
  78598555,
  'A',
  'JSALAMANCA@GMAIL.COM',
  1000000,
  1000000
);

INSERT INTO cliente VALUES (
  '11755017-K',
  'ANDREA LARA',
  'PROVIDENCIA 12763',
  NULL,
  85448619,
  'A',
  'ALARA@GMAIL.COM',
  1200000,
  1200000
);

INSERT INTO vendedor VALUES (
  '12456778-1',
  1,
  'LEOPOLDO ROJAS',
  'ALAMEDA 6152',
  1,
  44644123,
  'LROJAS@GMAIL.COM',
  240000,
  0.1,
  TO_DATE('01-08-' || TO_CHAR(EXTRACT(YEAR FROM SYSDATE)-24)),
  20
);

INSERT INTO vendedor VALUES (
  '10712354-2',
  2,
  'MARIO SOTO ',
  'APOQUINDO 9093',
  2,
  651682456,
  'MSOTO@HOTMAIL.COM',
  265000,
  0.2,
  TO_DATE('18-07-' || TO_CHAR(EXTRACT(YEAR FROM SYSDATE)-20)),
  30
);

INSERT INTO vendedor VALUES (
  '11124678-3',
  3,
  'SALVADOR ALVARADO',
  'BILBAO 6200',
  3,
  65877315,
  'SALVARADO@GMAIL.COM',
  250000,
  0.3,
  TO_DATE('22-03-' || TO_CHAR(EXTRACT(YEAR FROM SYSDATE)-17)),
  40
);

INSERT INTO vendedor VALUES (
  '10456789-4',
  4,
  'LUIS MUNOZ',
  'ALAMEDA 960',
  4,
  96888222,
  'LMUNOZ@GMAIL.COM',
  270000,
  0.4,
  TO_DATE('07-09-' || TO_CHAR(EXTRACT(YEAR FROM SYSDATE)-14)),
  50
);

INSERT INTO producto VALUES (
  1,
  'ZAPATO HOMBRE MODELO ALL BLACK-0-11',
  'UN',
  'P',
  25000,
  4000,
  7.42,
  100,
  10,
  'I',
  2,
  NULL
);

INSERT INTO producto VALUES (
  2,
  'ZAPATO HOMBRE MODELO LAGO 6-05',
  'UN',
  'P',
  28000,
  8890,
  8.87,
  90,
  10,
  'I',
  2,
  NULL
);

INSERT INTO producto VALUES (
  3,
  'ZAPATO HOMBRE MODELO PADUA 6-43',
  'UN',
  'P',
  55000,
  7990,
  7.09,
  54,
  5,
  'I',
  2,
  NULL
);

INSERT INTO producto VALUES (
  4,
  'ZAPATO HOMBRE MODELO DOZZA 0-03',
  'UN',
  'P',
  35000,
  6770.5,
  07,
  40,
  4,
  'I',
  2,
  NULL
);

INSERT INTO producto VALUES (
  5,
  'ZAPATO HOMBRE MODELO VALIER 3-18',
  'UN',
  'P',
  49000,
  3950,
  4.03,
  40,
  4,
  'I',
  2,
  NULL
);

INSERT INTO producto VALUES (
  6,
  'ZAPATO HOMBRE MODELO MURCIA 0-003',
  'UN',
  'P',
  27850,
  5679,
  7.98,
  60,
  6,
  'I',
  4,
  NULL
);

INSERT INTO producto VALUES (
  7,
  'ZAPATO HOMBRE MODELO SIENA 0-01',
  'UN',
  'P',
  41990,
  9500,
  9.77,
  87,
  10,
  'I',
  4,
  NULL
);

INSERT INTO producto VALUES (
  8,
  'ZAPATO HOMBRE MODELO TAGO 0-87',
  'UN',
  'P',
  42500,
  10890,
  NULL,
  60,
  6,
  'I',
  8,
  NULL
);

INSERT INTO producto VALUES (
  9,
  'ZAPATO HOMBRE MODELO INDIE 0-16',
  'UN',
  'P',
  38990,
  15000,
  17.85,
  18,
  5,
  'I',
  8,
  NULL
);

INSERT INTO producto VALUES (
  10,
  'ZAPATO HOMBRE MODELO NAPOLES 0-17',
  'UN',
  'P',
  27500,
  1500,
  2.01,
  100,
  10,
  'I',
  8,
  NULL
);

INSERT INTO producto VALUES (
  11,
  'RENOVADOR LIQUIDO NEUTRO ALTO BRILLO',
  'LQ',
  'A',
  2850,
  1200,
  1.6,
  150,
  15,
  'I',
  7,
  NULL
);

INSERT INTO producto VALUES (
  12,
  'ZAPATO MUJER MODELO BOSSA 0-18',
  'UN',
  'P',
  35000,
  11000,
  15.64,
  70,
  7,
  'I',
  7,
  NULL
);

INSERT INTO producto VALUES (
  13,
  'ZAPATO MUJER MODELO BRISTOL 1-19',
  'UN',
  'P',
  29000,
  6400,
  NULL,
  69,
  10,
  'I',
  2,
  NULL
);

INSERT INTO producto VALUES (
  14,
  'ZAPATO MUJER MODELO RAMBLAS 2-20',
  'UN',
  'P',
  37980,
  13980,
  15.85,
  35,
  10,
  'I',
  2,
  NULL
);

INSERT INTO producto VALUES (
  15,
  'ZAPATO MUJER MODELO MONTREAL 3-201',
  'UN',
  'P',
  42990,
  9000,
  8.77,
  20,
  2,
  'I',
  4,
  NULL
);

INSERT INTO producto VALUES (
  16,
  'ZAPATO MUJER MODELO MONTECARLO 4-10',
  'UN',
  'P',
  56990,
  5000,
  5.50,
  54,
  10,
  'I',
  4,
  NULL
);

INSERT INTO producto VALUES (
  17,
  'ZAPATO MUJER MODELO LOMBARDO 11-5',
  'UN',
  'P',
  35990,
  3800,
  NULL,
  34,
  7,
  'I',
  4,
  NULL
);

INSERT INTO producto VALUES (
  18,
  'ZAPATO MUJER MODELO SYDNEY 12-6',
  'UN',
  'P',
  32990,
  7800,
  6.80,
  25,
  10,
  'I',
  4,
  NULL
);

INSERT INTO producto VALUES (
  19,
  'ZAPATO MUJER MODELO BERLIN 4-56',
  'UN',
  'P',
  52000,
  1000,
  NULL,
  200,
  20,
  'N',
  1,
  NULL
);

INSERT INTO producto VALUES (
  20,
  'ZAPATO MUJER MODELO MADRID II',
  'UN',
  'P',
  42500,
  1200,
  NULL,
  90,
  9,
  'N',
  1,
  NULL
);

INSERT INTO producto VALUES (
  21,
  'ZAPATO MUJER MODELO PIAMONTE D-02',
  'UN',
  'P',
  34500,
  480,
  NULL,
  100,
  10,
  'N',
  1,
  NULL
);

INSERT INTO producto VALUES (
  22,
  'ZAPATO MUJER MODELO SERENA 1-019',
  'UN',
  'P',
  31900,
  NULL,
  NULL,
  NULL,
  NULL,
  'N',
  1,
  NULL
);

INSERT INTO producto VALUES (
  23,
  'ZAPATO MUJER MODELO TWISTER D-100',
  'UN',
  'P',
  35000,
  NULL,
  NULL,
  NULL,
  NULL,
  'N',
  1,
  NULL
);

INSERT INTO producto VALUES (
  24,
  'ZAPATO MUJER MODELO OSLO 308',
  'UN',
  'P',
  37000,
  NULL,
  NULL,
  NULL,
  NULL,
  'N',
  1,
  NULL
);

INSERT INTO producto VALUES (
  25,
  'ZAPATO MUJER MODELO CAIRO 0-11',
  'UN',
  'P',
  43990,
  NULL,
  NULL,
  NULL,
  NULL,
  'N',
  1,
  NULL
);

INSERT INTO producto VALUES (
  26,
  'ZAPATO MUJER MODELO SEVILLA 1-06',
  'UN',
  'P',
  59900,
  NULL,
  NULL,
  NULL,
  NULL,
  'N',
  1,
  NULL
);

INSERT INTO producto VALUES (
  27,
  'CREMA PROTECTORA INCOLORO',
  'UN',
  'A',
  4000,
  NULL,
  NULL,
  NULL,
  NULL,
  'N',
  1,
  NULL
);

INSERT INTO producto VALUES (
  28,
  'ZAPATO CASUAL HOMBRE BARI 0-10',
  'UN',
  'P',
  29000,
  NULL,
  NULL,
  NULL,
  NULL,
  'N',
  1,
  NULL
);

INSERT INTO producto VALUES (
  29,
  'ZAPATO CASUAL HOMBRE OPORTO 1-108',
  'UN',
  'P',
  28500,
  NULL,
  NULL,
  NULL,
  NULL,
  'N',
  1,
  NULL
);

INSERT INTO producto VALUES (
  30,
  'BOTIN MUJER PRIMAV 1-17',
  'UN',
  'P',
  25990,
  NULL,
  NULL,
  NULL,
  NULL,
  'N',
  1,
  NULL
);

INSERT INTO producto VALUES (
  31,
  'BOTIN MUJER SUMMER 1-17',
  'UN',
  'P',
  35000,
  NULL,
  NULL,
  NULL,
  NULL,
  'N',
  1,
  NULL
);

UPDATE producto
SET
  codproducto_rel = 11
WHERE
  codproducto <= 10;

UPDATE producto
SET
  codproducto_rel = 27
WHERE
  ( codproducto >= 12
    AND codproducto <= 26 );

COMMIT;

INSERT INTO factura VALUES (
  11520,
  '5446780-0',
  '12456778-1',
  TO_DATE('02/01/' || TO_CHAR(EXTRACT(YEAR FROM SYSDATE)-2)),
  TO_DATE('02/02/' || TO_CHAR(EXTRACT(YEAR FROM SYSDATE)-1)),
  100000,
  19000,
  119000,
  1,
  4,
  '178904',
  'EM'
);

INSERT INTO factura VALUES (
  11521,
  '7812354-2',
  '10712354-2',
  TO_DATE('02/01/' || TO_CHAR(EXTRACT(YEAR FROM SYSDATE)-2)),
  NULL,
  149000,
  28310,
  177310,
  NULL,
  1,
  NULL,
  'EM'
);

INSERT INTO factura VALUES (
  11522,
  '8125781-8',
  '12456778-1',
  TO_DATE('03/02/' || TO_CHAR(EXTRACT(YEAR FROM SYSDATE)-1)),
  NULL,
  209400,
  39786,
  249186,
  2,
  3,
  NULL,
  'PA'
);

INSERT INTO factura VALUES (
  11523,
  '5446780-0',
  '11124678-3',
  TO_DATE('04/02/' || TO_CHAR(EXTRACT(YEAR FROM SYSDATE)-1)),
  NULL,
  37500,
  7125,
  44625,
  NULL,
  1,
  NULL,
  'EM'
);

INSERT INTO factura VALUES (
  11524,
  '12444650-7',
  '11124678-3',
  TO_DATE('15/02/' || TO_CHAR(EXTRACT(YEAR FROM SYSDATE)-1)),
  NULL,
  58455,
  11606,
  69561,
  2,
  4,
  NULL,
  'EM'
);

INSERT INTO factura VALUES (
  11525,
  '8125781-8',
  '12456778-1',
  TO_DATE('16/02/' || TO_CHAR(EXTRACT(YEAR FROM SYSDATE)-1)),
  '16/03/2017',
  30000,
  5700,
  35700,
  2,
  4,
  '8904865',
  'EM'
);

INSERT INTO factura VALUES (
  11526,
  '13685017-1',
  '10456789-4',
  TO_DATE('17/02/' || TO_CHAR(EXTRACT(YEAR FROM SYSDATE)-1)),
  NULL,
  29700,
  5643,
  35343,
  2,
  3,
  NULL,
  'PA'
);

INSERT INTO factura VALUES (
  11527,
  '8125781-8',
  '10712354-2',
  TO_DATE('07/03/' || TO_CHAR(EXTRACT(YEAR FROM SYSDATE)-1)),
  NULL,
  29700,
  5643,
  35343,
  NULL,
  1,
  NULL,
  'EM'
);

INSERT INTO factura VALUES (
  11528,
  '5446780-0',
  '10712354-2',
  TO_DATE('07/03/' || TO_CHAR(EXTRACT(YEAR FROM SYSDATE)-1)),
  NULL,
  29700,
  5643,
  35343,
  2,
  4,
  'CF-123647',
  'EM'
);

INSERT INTO factura VALUES (
  11529,
  '8125781-8',
  '10456789-4',
  TO_DATE('08/03/' || TO_CHAR(EXTRACT(YEAR FROM SYSDATE)-1)),
  NULL,
  21900,
  4161,
  26061,
  NULL,
  1,
  NULL,
  'EM'
);

INSERT INTO factura VALUES (
  11530,
  '12444650-7',
  '10456789-4',
  TO_DATE('08/03/' || TO_CHAR(EXTRACT(YEAR FROM SYSDATE)-1)),
  NULL,
  27000,
  5130,
  32130,
  NULL,
  1,
  NULL,
  'EM'
);

INSERT INTO detalle_factura VALUES (
  11520,
  1,
  25000,
  NULL,
  NULL,
  0,
  4,
  100000
);

INSERT INTO detalle_factura VALUES (
  11521,
  15,
  12900,
  NULL,
  NULL,
  0,
  10,
  129000
);

INSERT INTO detalle_factura VALUES (
  11521,
  19,
  2000,
  NULL,
  NULL,
  0,
  10,
  20000
);

INSERT INTO detalle_factura VALUES (
  11522,
  15,
  12900,
  NULL,
  NULL,
  0,
  10,
  129000
);

INSERT INTO detalle_factura VALUES (
  11522,
  16,
  6990,
  NULL,
  NULL,
  0,
  10,
  69900
);

INSERT INTO detalle_factura VALUES (
  11522,
  21,
  700,
  NULL,
  NULL,
  0,
  15,
  10500
);

INSERT INTO detalle_factura VALUES (
  11523,
  2,
  12500,
  NULL,
  NULL,
  0,
  3,
  37500
);

INSERT INTO detalle_factura VALUES (
  11524,
  3,
  12990,
  NULL,
  NULL,
  50,
  6,
  58455
);

INSERT INTO detalle_factura VALUES (
  11525,
  15,
  10000,
  NULL,
  NULL,
  50,
  4,
  30000
);

INSERT INTO detalle_factura VALUES (
  11526,
  5,
  4950,
  NULL,
  NULL,
  0,
  6,
  29700
);

INSERT INTO detalle_factura VALUES (
  11527,
  5,
  4950,
  NULL,
  NULL,
  0,
  6,
  29700
);

INSERT INTO detalle_factura VALUES (
  11528,
  5,
  4950,
  NULL,
  NULL,
  0,
  6,
  29700
);

INSERT INTO detalle_factura VALUES (
  11529,
  22,
  21900,
  NULL,
  NULL,
  0,
  1,
  21900
);

INSERT INTO detalle_factura VALUES (
  11530,
  24,
  27000,
  NULL,
  NULL,
  0,
  1,
  27000
);

INSERT INTO boleta VALUES (
  120,
  '6245678-1',
  '12456778-1',
  TO_DATE('22/01/' || TO_CHAR(EXTRACT(YEAR FROM SYSDATE)-2)),
  119000,
  1,
  4,
  'DS4344',
  'EM'
);

INSERT INTO boleta VALUES (
  121,
  '9912478-3',
  '10712354-2',
  TO_DATE('22/01/' || TO_CHAR(EXTRACT(YEAR FROM SYSDATE)-2)),
  177310,
  NULL,
  1,
  NULL,
  'EM'
);

INSERT INTO boleta VALUES (
  122,
  '14456789-4',
  '12456778-1',
  TO_DATE('23/02/' || TO_CHAR(EXTRACT(YEAR FROM SYSDATE)-1)),
  249186,
  2,
  3,
  NULL,
  'PA'
);

INSERT INTO boleta VALUES (
  123,
  '11245678-5',
  '11124678-3',
  TO_DATE('24/02/' || TO_CHAR(EXTRACT(YEAR FROM SYSDATE)-1)),
  44625,
  NULL,
  1,
  NULL,
  'EM'
);

INSERT INTO boleta VALUES (
  124,
  '6467708-6',
  '11124678-3',
  TO_DATE('25/02/' || TO_CHAR(EXTRACT(YEAR FROM SYSDATE)-1)),
  69561,
  2,
  4,
  NULL,
  'EM'
);

INSERT INTO boleta VALUES (
  125,
  '10125945-7',
  '10456789-4',
  TO_DATE('26/02/' || TO_CHAR(EXTRACT(YEAR FROM SYSDATE)-1)),
  35700,
  2,
  4,
  '4865',
  'EM'
);

INSERT INTO boleta VALUES (
  126,
  '13746912-9',
  '12456778-1',
  TO_DATE('27/02/' || TO_CHAR(EXTRACT(YEAR FROM SYSDATE)-1)),
  35343,
  2,
  3,
  NULL,
  'PA'
);

INSERT INTO boleta VALUES (
  127,
  '10812874-0',
  '10712354-2',
  TO_DATE('17/03/' || TO_CHAR(EXTRACT(YEAR FROM SYSDATE)-1)),
  35343,
  NULL,
  1,
  NULL,
  'EM'
);

INSERT INTO boleta VALUES (
  128,
  '15123587-1',
  '10456789-4',
  TO_DATE('17/03/' || TO_CHAR(EXTRACT(YEAR FROM SYSDATE)-1)),
  35343,
  2,
  4,
  'S/N 36147',
  'EM'
);

INSERT INTO boleta VALUES (
  129,
  NULL,
  '12456778-1',
  TO_DATE('18/03/' || TO_CHAR(EXTRACT(YEAR FROM SYSDATE)-1)),
  26061,
  NULL,
  1,
  NULL,
  'EM'
);

INSERT INTO boleta VALUES (
  130,
  NULL,
  '10456789-4',
  TO_DATE('18/03/' || TO_CHAR(EXTRACT(YEAR FROM SYSDATE)-1)),
  32130,
  NULL,
  1,
  NULL,
  'EM'
);

INSERT INTO boleta VALUES (
  131,
  '6245678-1',
  '11124678-3',
  TO_DATE('19/03/' || TO_CHAR(EXTRACT(YEAR FROM SYSDATE)-1)),
  130900,
  1,
  4,
  'DS4344',
  'EM'
);

INSERT INTO detalle_boleta VALUES (
  120,
  1,
  25000,
  NULL,
  NULL,
  0,
  4,
  100000
);

INSERT INTO detalle_boleta VALUES (
  121,
  15,
  12900,
  NULL,
  NULL,
  0,
  10,
  129000
);

INSERT INTO detalle_boleta VALUES (
  121,
  19,
  2000,
  NULL,
  NULL,
  0,
  10,
  20000
);

INSERT INTO detalle_boleta VALUES (
  122,
  15,
  12900,
  NULL,
  NULL,
  0,
  10,
  129000
);

INSERT INTO detalle_boleta VALUES (
  122,
  16,
  6990,
  NULL,
  NULL,
  0,
  10,
  69900
);

INSERT INTO detalle_boleta VALUES (
  122,
  21,
  700,
  NULL,
  NULL,
  0,
  15,
  10500
);

INSERT INTO detalle_boleta VALUES (
  123,
  2,
  12500,
  NULL,
  NULL,
  0,
  3,
  37500
);

INSERT INTO detalle_boleta VALUES (
  124,
  3,
  12990,
  NULL,
  NULL,
  50,
  6,
  58455
);

INSERT INTO detalle_boleta VALUES (
  125,
  15,
  10000,
  NULL,
  NULL,
  50,
  4,
  30000
);

INSERT INTO detalle_boleta VALUES (
  126,
  5,
  4950,
  NULL,
  NULL,
  0,
  6,
  29700
);

INSERT INTO detalle_boleta VALUES (
  127,
  5,
  4950,
  NULL,
  NULL,
  0,
  6,
  29700
);

INSERT INTO detalle_boleta VALUES (
  128,
  5,
  4950,
  NULL,
  NULL,
  0,
  6,
  29700
);

INSERT INTO detalle_boleta VALUES (
  129,
  22,
  21900,
  NULL,
  NULL,
  0,
  1,
  21900
);

INSERT INTO detalle_boleta VALUES (
  130,
  24,
  27000,
  NULL,
  NULL,
  0,
  1,
  27000
);

INSERT INTO detalle_boleta VALUES (
  131,
  1,
  25000,
  NULL,
  NULL,
  0,
  4,
  100000
);

INSERT INTO detalle_boleta VALUES (
  131,
  27,
  10000,
  NULL,
  NULL,
  0,
  1,
  10000
);



--  CASO 1 -  Análisis de Facturas



-- Facturas del año anterior al de ejecución, con formatos y clasificaciones.
SELECT
  f.numfactura                          AS "N° Factura",
  TO_CHAR(f.fecha, 'DD "de" Month', 'NLS_DATE_LANGUAGE=SPANISH') AS "Fecha Emisión",
  EXTRACT(YEAR FROM f.fecha)            AS "Año",
  LPAD(f.rutcliente, 10, '0')           AS "RUT Cliente",
  '$' || TO_CHAR(f.neto,  'FM9G999G999G990', 'NLS_NUMERIC_CHARACTERS=,.')  AS "Monto Neto",
  '$' || TO_CHAR(f.iva,   'FM9G999G999G990', 'NLS_NUMERIC_CHARACTERS=,.')  AS "Monto Iva",
  '$' || TO_CHAR(f.total, 'FM9G999G999G990', 'NLS_NUMERIC_CHARACTERS=,.')  AS "Total Factura",
  CASE
    WHEN f.total BETWEEN 0 AND 50000         THEN 'Bajo'
    WHEN f.total BETWEEN 50001 AND 100000    THEN 'Medio'
    ELSE 'Alto'
  END                                   AS "Categoría Monto",
  CASE f.codpago
    WHEN 1 THEN 'EFECTIVO'
    WHEN 2 THEN 'TARJETA DEBITO'
    WHEN 3 THEN 'TARJETA CREDITO'
    ELSE 'CHEQUE'
  END                                   AS "Forma de pago"
FROM factura f
-- año anterior al actual (sin fechas fijas)
WHERE EXTRACT(YEAR FROM f.fecha) = EXTRACT(YEAR FROM SYSDATE) - 1
-- requisito: orden descendente por fecha y en igualdad por neto.
ORDER BY f.fecha DESC, f.neto DESC;




-- CASO 2 - Clasificación de Clientes



-- Clientes con estado A y crédito > 0, con enmascarados, dominios y categorías.
SELECT
  LPAD(c.rutcliente, 12, '*')                        AS "RUT",
  INITCAP(c.nombre)                                   AS "Cliente",
  NVL(TO_CHAR(c.telefono), 'Sin teléfono')           AS "TELEFONO",
  NVL(TO_CHAR(c.codcomuna), 'Sin comuna')            AS "COMUNA",
  c.estado                                           AS "ESTADO",
  CASE
    WHEN c.credito > 0 AND c.saldo/c.credito < 0.5 THEN
      'Bueno ( $'   || TO_CHAR(c.credito - c.saldo,
                       'FM9G999G999G990', 'NLS_NUMERIC_CHARACTERS=,.') || ')'
    WHEN c.credito > 0 AND c.saldo/c.credito <= 0.8 THEN
      'Regular ( $' || TO_CHAR(c.saldo,
                       'FM9G999G999G990', 'NLS_NUMERIC_CHARACTERS=,.') || ')'
    ELSE 'Critico'
  END                                               AS "Estado Crédito",
  CASE
    WHEN c.mail IS NULL OR INSTR(c.mail,'@') = 0 THEN 'Correo no registrado'
    ELSE UPPER(SUBSTR(c.mail, INSTR(c.mail,'@')+1))
  END                                               AS "Dominio Correo"
FROM cliente c
-- solo estado "A" y credito mayor a 0.
WHERE c.estado = 'A'
  AND NVL(c.credito,0) > 0
  -- orden ascendente por nombre.
ORDER BY INITCAP(c.nombre) ASC;



-- CASO 3 - Stock de productos.



-- Productos: sólo ZAPATO y procedencia 'I', con conversión USD a CLP, alertas y oferta 
SELECT
  p.codproducto                                                            AS "ID",
  INITCAP(p.descripcion)                                                   AS "Descripción de Producto",
  -- si no hay USD, mostrar 'sin registro'.
  NVL(TO_CHAR(p.valorcompradolar, 'FM9990D99', 'NLS_NUMERIC_CHARACTERS=,.') || ' USD',
      'Sin registro')                                                      AS "Compra en USD",
  -- conversion parametrica a CLP usando &TIPOCAMBIO_DOLAR.
  CASE
    WHEN p.valorcompradolar IS NOT NULL THEN
      '$' || TO_CHAR(ROUND(p.valorcompradolar * &TIPOCAMBIO_DOLAR),
                     'FM9G999G999G990', 'NLS_NUMERIC_CHARACTERS=,.') || ' PESOS'
    ELSE 'Sin registro'
  END                                                                      AS "USD convertido",
  p.totalstock                                                             AS "Stock",
  -- 4 niveles de alerta usando umbrales parametricos.
  CASE
    WHEN p.totalstock IS NULL THEN 'Sin registro'  -- o 'Sin datos' según consigna
    WHEN p.totalstock <  &UMBRAL_BAJO THEN '¡ALERTA stock muy bajo!'
    WHEN p.totalstock <= &UMBRAL_ALTO THEN '¡Reabastecer pronto!'
    ELSE 'OK'
  END                                                                      AS "Alerta Stock",
  -- descuento del 10% solo si stock > 80,si no N/A.  
  CASE
    WHEN p.totalstock > 80 THEN
      '$' || TO_CHAR(ROUND(p.vunitario * 0.90),
                     'FM9G999G999G990', 'NLS_NUMERIC_CHARACTERS=,.')
    ELSE 'N/A'
  END                                                                      AS "Precio Oferta"
FROM producto p
-- solo productos que contienen 'zapatos' y procedencia importado.
WHERE UPPER(p.descripcion) LIKE '%ZAPATO%'
  AND UPPER(p.procedencia) = 'I'
  -- orden descendente por ID.
ORDER BY p.codproducto DESC;


COMMIT;

