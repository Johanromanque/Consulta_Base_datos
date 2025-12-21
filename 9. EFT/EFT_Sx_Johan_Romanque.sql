/*============================================================ 
  PRY2205 - EFT Semana 9 
  ============================================================ */
-- MOSTRAR USUARIO ADMIN:
SHOW USER;

-- LIMPIEZA DE DATOS
-- ROLES
DROP ROLE PRY2205_ROL_D;
DROP ROLE PRY2205_ROL_C; 
-- USUARIOS
DROP USER PRY2205_EFT;
DROP USER PRY2205_EFT_DES;
DROP USER PRY2205_EFT_CON;

/* ============================================================ 
   CASO 1 - ADMIN (Oracle Cloud): roles, usuarios, privilegios 
   ============================================================ */
   
-- USANDO USUARIO ADMIN 
-- CASO 1: ADMIN CREAR ROLES
CREATE ROLE PRY2205_ROL_D;
CREATE ROLE PRY2205_ROL_C;

-- CASO 1: ADMIN CREAR PRIVILEGIOS

-- DES: CONSTRUYE Y ALMACENA EL INFORME
GRANT CREATE SESSION, CREATE TABLE, CREATE VIEW, CREATE PROFILE, CREATE USER TO PRY2205_ROL_D;

-- CON: SOLO CONEXION (ACCESOR SERAN POR ROLES Y GRANTS)
GRANT CREATE SESSION TO PRY2205_ROL_C;


-- CASO 1: ADMIN CREAR USUARIOS OWNER/DES/CONSULTA
CREATE USER PRY2205_EFT
IDENTIFIED BY "Aa12BB34cc56"
DEFAULT TABLESPACE "DATA"
TEMPORARY TABLESPACE TEMP
QUOTA 10M ON "DATA";

CREATE USER PRY2205_EFT_DES
IDENTIFIED BY "Xy12ZZ34aa56"
DEFAULT TABLESPACE "DATA"
TEMPORARY TABLESPACE TEMP
QUOTA 10M ON "DATA";

CREATE USER PRY2205_EFT_CON
IDENTIFIED BY "Qw12TT34mm56"
DEFAULT TABLESPACE "DATA"
TEMPORARY TABLESPACE TEMP
QUOTA 10M ON "DATA";



-- Asignación de roles (concentramos SELECTs en roles)
GRANT PRY2205_ROL_D TO PRY2205_EFT_DES;
GRANT PRY2205_ROL_C TO PRY2205_EFT_CON;

-- OWNER CREAR OBJETOS Y SINONIMOS PUBLICOS
GRANT CREATE SESSION, CREATE TABLE, CREATE VIEW, CREATE SEQUENCE TO PRY2205_EFT;
GRANT CREATE SYNONYM, CREATE PUBLIC SYNONYM TO PRY2205_EFT;

-- PROBAR PRIVILEGIOS
SELECT * FROM dba_sys_privs WHERE grantee = 'PRY2205_EFT';
SELECT * FROM dba_sys_privs WHERE grantee = 'PRY2205_ROL_C';
SELECT * FROM dba_sys_privs WHERE grantee = 'PRY2205_ROL_D';

/* ============================================================
   CASO 1 - PRY2205_EFT: esquema/poblado + grants + sinónimos
   ============================================================ */

-- MUESTRA USUARIO PRY2205_EFT-
SHOW USER;

-- EJECUTAR ESQUEMA POBLADO 

-- LIMPIEZA DE DATOS
DROP PUBLIC SYNONYM SYN_PROFESIONAL;
DROP PUBLIC SYNONYM SYN_PROFESION;
DROP PUBLIC SYNONYM SYN_ISAPRE;
DROP PUBLIC SYNONYM SYN_RANGOS_SUELDOS;
DROP PUBLIC SYNONYM SYN_EMPRESA;
DROP PUBLIC SYNONYM SYN_ASESORIA;
DROP SYNONYM SYN_SECTOR_PRIV;
DROP VIEW VW_EMPRESAS_ASESORADAS
DROP INDEX IDX_ASESORIA_EMP_FIN;
DROP SEQUENCE SEQ_EFT_EVIDENCIA;

-- CASO 1: DAR PRIVILEGIOS GRANTS 
GRANT SELECT ON PROFESIONAL    TO PRY2205_EFT_DES;
GRANT SELECT ON PROFESION      TO PRY2205_EFT_DES;
GRANT SELECT ON ISAPRE         TO PRY2205_EFT_DES;
GRANT SELECT ON RANGOS_SUELDOS TO PRY2205_EFT_DES;


-- CREAR SINÓNIMOS PÚBLICOS 
CREATE PUBLIC SYNONYM SYN_PROFESIONAL    FOR PRY2205_EFT.PROFESIONAL;
CREATE PUBLIC SYNONYM SYN_PROFESION      FOR PRY2205_EFT.PROFESION;
CREATE PUBLIC SYNONYM SYN_ISAPRE         FOR PRY2205_EFT.ISAPRE;
CREATE PUBLIC SYNONYM SYN_RANGOS_SUELDOS FOR PRY2205_EFT.RANGOS_SUELDOS;
CREATE PUBLIC SYNONYM SYN_EMPRESA        FOR PRY2205_EFT.EMPRESA;
CREATE PUBLIC SYNONYM SYN_ASESORIA       FOR PRY2205_EFT.ASESORIA;

-- PRUEBA DE SINONIMO PRIVADO QUE SOLO ES VISIBLE POR EL USUARIO QUE LO CREA.
CREATE SYNONYM SYN_SECTOR_PRIV
FOR PRY2205_EFT.SECTOR;

SELECT * FROM SYN_SECTOR_PRIV;

-- SEQUENCE (EVIDENCIA)
CREATE SEQUENCE SEQ_EFT_EVIDENCIA 
START WITH 1 
INCREMENT BY 1
NOCACHE
NOCYCLE;


SELECT SEQ_EFT_EVIDENCIA.NEXTVAL FROM DUAL;


/* ============================================================
   CASO 3.1 - PRY2205_EFT: vista VW_EMPRESAS_ASESORADAS (año anterior)
   Objetivo:
   - Crear una vista con resumen de asesorías del último año calendario
   - Calcular métricas y clasificar tipo de cliente
   ============================================================ */


-- CASO 3.1: CREAR/REEMPLAZAR VISTA VW_EMPRESAS_ASESORADAS 
CREATE VIEW VW_EMPRESAS_ASESORADAS AS
SELECT
  TO_CHAR(e.rut_empresa, 'FM999G999G999') || '-' || e.dv_empresa AS RUT_EMPRESA,
  UPPER(e.nomempresa)                                           AS NOMBRE_EMPRESA,
  ROUND(e.iva_declarado)                                        AS IVA,
  TRUNC(MONTHS_BETWEEN(SYSDATE, e.fecha_iniciacion_actividades)/12) AS ANIOS_EXISTENCIA,
  ROUND(COUNT(*)/12)                                            AS TOTAL_ASESORIAS_ANUALES,
  ROUND( e.iva_declarado * (ROUND(COUNT(*)/12)) / 100 )          AS DEVOLUCION_IVA,
  CASE
    WHEN ROUND(COUNT(*)/12) > 5 THEN 'CLIENTE PREMIUM'
    WHEN ROUND(COUNT(*)/12) BETWEEN 3 AND 5 THEN 'CLIENTE'
    ELSE 'CLIENTE POCO CONCURRIDO'
  END                                                           AS TIPO_CLIENTE,
  CASE
    WHEN ROUND(COUNT(*)/12) > 5 THEN
      CASE WHEN COUNT(*) >= 7 THEN '1 ASESORIA GRATIS'
           ELSE '1 ASESORIA 40% DE DESCUENTO'
      END
    WHEN ROUND(COUNT(*)/12) BETWEEN 3 AND 5 THEN
      CASE WHEN COUNT(*) = 5 THEN '1 ASESORIA 30% DE DESCUENTO'
           ELSE '1 ASESORIA 20% DE DESCUENTO'
      END
    ELSE 'CAPTAR CLIENTE'
  END                                                           AS CORRESPONDE
FROM SYN_EMPRESA e
JOIN SYN_ASESORIA a
  ON a.idempresa = e.idempresa
WHERE a.fin >= TRUNC(ADD_MONTHS(SYSDATE,-12), 'YYYY')
  AND a.fin <  TRUNC(SYSDATE, 'YYYY')
GROUP BY
  e.rut_empresa, e.dv_empresa, e.nomempresa, e.iva_declarado, e.fecha_iniciacion_actividades;

-- CASO 3.1: GRANT A USUARIO PRY2205_EFT_CON SOBRE LA VISTA 
GRANT SELECT ON VW_EMPRESAS_ASESORADAS TO PRY2205_EFT_CON;

/* ============================================================
   CASO 3.2 - PRY2205_EFT: EXPLAIN PLAN antes/después + índice
   Objetivo:
   - Comparar el plan de ejecución antes y después de crear un índice
   - Mejorar acceso en JOIN (IDEMPRESA) y filtro por fecha (FIN)
   ============================================================ */

-- PLAN ANTES DEL ÍNDICE (no ejecuta la consulta, solo calcula el plan)
EXPLAIN PLAN FOR
SELECT * FROM VW_EMPRESAS_ASESORADAS;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- Índice compuesto para optimizar:
-- - JOIN por IDEMPRESA
-- - filtro por FIN (rango de fechas)
CREATE INDEX IDX_ASESORIA_EMP_FIN ON ASESORIA (IDEMPRESA, FIN);

-- CASO 3.2: PLAN DESPUÉS DEL ÍNDICE
EXPLAIN PLAN FOR
SELECT * FROM VW_EMPRESAS_ASESORADAS;

-- Muestra el plan y se evidencia el uso del índice
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

/* ============================================================
   CASO 2 - PRY2205_EFT_DES: CARTOLA_PROFESIONALES
   Objetivo:
   - Crear una tabla de informe (cartola) en el usuario DES
   - Poblarla con un INSERT...SELECT usando sinónimos públicos
   - Confirmar cambios (COMMIT)
   - Dar acceso de lectura al usuario CON
   ============================================================ */

-- CON USUARIO PRY2205_EFT_DES: 
SHOW USER;

-- LIMPIEZA DE DATOS
DROP TABLE CARTOLA_PROFESIONALES;

-- CASO 2: CREAR CARTOLA_PROFESIONALES
-- ------------------------------------------------------------
-- CREACIÓN DE TABLA DE INFORME (CARTOLA_PROFESIONALES)
-- Estructura: datos identificatorios + cálculos de pago
-- NOT NULL asegura que el informe se genere completo (sin nulos)
-- ------------------------------------------------------------
CREATE TABLE CARTOLA_PROFESIONALES (
  RUT_PROFESIONAL            VARCHAR2(10) NOT NULL,
  NOMBRE_PROFESIONAL         VARCHAR2(60) NOT NULL,
  PROFESION                  VARCHAR2(25) NOT NULL,
  ISAPRE                     VARCHAR2(20) NOT NULL,
  SUELDO_BASE                NUMBER(10)   NOT NULL,
  PORC_COMISION_PROFESIONAL  NUMBER(6,2)  NOT NULL,
  VALOR_TOTAL_COMISION       NUMBER(10)   NOT NULL,
  PORCENTATE_HONORARIO       NUMBER(10)   NOT NULL,
  BONO_MOVILIZACION          NUMBER(10)   NOT NULL,
  TOTAL_PAGAR                NUMBER(10)   NOT NULL
);

-- CASO 2: INSERT (SELECT) USANDO SINÓNIMOS
-- ------------------------------------------------------------
-- INSERCIÓN MASIVA: INSERT INTO ... SELECT
-- Inserta en la cartola el resultado de un SELECT con joins y cálculos
-- Usa SINÓNIMOS para no depender del esquema real de las tablas
-- ------------------------------------------------------------
INSERT INTO CARTOLA_PROFESIONALES
(
  RUT_PROFESIONAL, NOMBRE_PROFESIONAL, PROFESION, ISAPRE,
  SUELDO_BASE, PORC_COMISION_PROFESIONAL, VALOR_TOTAL_COMISION,
  PORCENTATE_HONORARIO, BONO_MOVILIZACION, TOTAL_PAGAR
)
SELECT
  p.rutprof AS RUT_PROFESIONAL,
  INITCAP(p.nompro || ' ' || p.apppro || ' ' || p.apmpro) AS NOMBRE_PROFESIONAL,
  pr.nomprofesion AS PROFESION,
  i.nomisapre AS ISAPRE,
  ROUND(p.sueldo) AS SUELDO_BASE,
  
  NVL(p.comision, 0) AS PORC_COMISION_PROFESIONAL,
  ROUND(p.sueldo * NVL(p.comision,0)) AS VALOR_TOTAL_COMISION,
  ROUND(p.sueldo * (rs.honor_pct/100)) AS PORCENTATE_HONORARIO,

  CASE
    WHEN p.idtcontrato = 1 THEN 150000
    WHEN p.idtcontrato = 2 THEN 120000
    WHEN p.idtcontrato = 3 THEN  60000
    WHEN p.idtcontrato = 4 THEN  50000
    ELSE 0
  END AS BONO_MOVILIZACION,

  ROUND(
      p.sueldo
    + (p.sueldo * NVL(p.comision,0))
    + (p.sueldo * (rs.honor_pct/100))
    + CASE
        WHEN p.idtcontrato = 1 THEN 150000
        WHEN p.idtcontrato = 2 THEN 120000
        WHEN p.idtcontrato = 3 THEN  60000
        WHEN p.idtcontrato = 4 THEN  50000
        ELSE 0
      END
  ) AS TOTAL_PAGAR

FROM SYN_PROFESIONAL p
JOIN SYN_PROFESION pr
  ON pr.idprofesion = p.idprofesion
JOIN SYN_ISAPRE i
  ON i.idisapre = p.idisapre
JOIN SYN_RANGOS_SUELDOS rs
  ON p.sueldo BETWEEN rs.s_min AND rs.s_max

ORDER BY
  pr.nomprofesion ASC,
  p.sueldo DESC,
  NVL(p.comision,0) ASC,
  p.rutprof ASC;

COMMIT;

-- CASO 2: DAR PRIVILEGIO SELECT DE CARTOLA_PROFESIONALES A PRY2205_EFT_CON
GRANT SELECT ON CARTOLA_PROFESIONALES TO PRY2205_EFT_CON;

/* ============================================================
   CASO 2 - PRY2205_EFT_CON: consultar cartola
   ============================================================ */

-- MUESTRA USUARIO PRY2205_EFT_CON:
SHOW USER;

-- CASO 2: CONSULTA CARTOLA.
SELECT
  rut_profesional, nombre_profesional, profesion, isapre,
  sueldo_base, porc_comision_profesional, valor_total_comision,
  porcentate_honorario, bono_movilizacion, total_pagar
FROM PRY2205_EFT_DES.CARTOLA_PROFESIONALES
ORDER BY profesion, sueldo_base DESC, porc_comision_profesional, rut_profesional;

/* ============================================================
   CASO 3 - PRY2205_EFT_CON: ejecutar vista
   ============================================================ */

-- CASO 3: CONSULTA VISTA (ORDEN POR NOMBRE EMPRESA)
SELECT
  rut_empresa, nombre_empresa, iva, anios_existencia,
  total_asesorias_anuales, devolucion_iva, tipo_cliente, corresponde
FROM PRY2205_EFT.VW_EMPRESAS_ASESORADAS
ORDER BY nombre_empresa ASC;

