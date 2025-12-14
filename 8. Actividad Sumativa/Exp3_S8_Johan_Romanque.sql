/* =========================================================
   CASO 1 - ESTRATEGIA DE SEGURIDAD
   (ADMIN)
   =========================================================
   Objetivo:
   - Crear usuarios (USER1 owner / USER2 developer-consulta)
   - Crear roles y asignar privilegios mínimos
   - Asignar roles a cada usuario
   ========================================================= */

------------------------------------------------------------
-- 1) CREAR USUARIOS 
------------------------------------------------------------
CREATE USER PRY2205_USER1 
IDENTIFIED BY "User1_123#2025"
DEFAULT TABLESPACE USERS
TEMPORARY TABLESPACE TEMP
QUOTA UNLIMITED ON USERS;

CREATE USER PRY2205_USER2 
IDENTIFIED BY "User2_123#2025"
DEFAULT TABLESPACE USERS
TEMPORARY TABLESPACE TEMP
QUOTA UNLIMITED ON USERS;

------------------------------------------------------------
-- 2) CREAR ROLES (agrupan privilegios para asignación eficiente)
------------------------------------------------------------
CREATE ROLE PRY2205_ROL_D; -- rol del Dueño (owner)
CREATE ROLE PRY2205_ROL_P; -- rol del Perfil consulta / developer

------------------------------------------------------------
-- 3) PRIVILEGIOS MÍNIMOS PARA CONECTARSE
------------------------------------------------------------
GRANT CREATE SESSION TO PRY2205_USER1;
GRANT CREATE SESSION TO PRY2205_USER2;

------------------------------------------------------------
-- 4) PRIVILEGIOS POR ROL 
--    crear objetos en esquema.
------------------------------------------------------------
-- Dueño: puede crear tablas, vistas, sinónimos privados
GRANT CREATE TABLE, CREATE VIEW, CREATE SYNONYM TO PRY2205_ROL_D;

-- Developer: puede crear tabla/sequence/disparador para su informe
GRANT CREATE TABLE, CREATE SEQUENCE, CREATE TRIGGER TO PRY2205_ROL_P;

------------------------------------------------------------
-- 5) ASIGNAR ROLES A USUARIOS
------------------------------------------------------------
GRANT PRY2205_ROL_D TO PRY2205_USER1;
GRANT PRY2205_ROL_P TO PRY2205_USER2;

------------------------------------------------------------
-- 6) PRIVILEGIO ESPECIAL: crear sinónimos PUBLICOS
------------------------------------------------------------
GRANT CREATE PUBLIC SYNONYM TO PRY2205_USER1;

------------------------------------------------------------
-- 7) CONSULTAS DE VERIFICACIÓN DE PRIVILEGIOS
------------------------------------------------------------
-- Privilegios directos a usuario
SELECT * FROM dba_sys_privs 
WHERE grantee = 'PRY2205_USER1';

SELECT * FROM dba_sys_privs 
WHERE grantee = 'PRY2205_USER2';

-- Roles asignados a usuario
SELECT * FROM dba_role_privs 
WHERE grantee = 'PRY2205_USER1';

SELECT * FROM dba_role_privs 
WHERE grantee = 'PRY2205_USER2';

-- Privilegios dentro del rol
SELECT * FROM dba_sys_privs
WHERE grantee = 'PRY2205_ROL_D';

SELECT * FROM dba_sys_privs 
WHERE grantee = 'PRY2205_ROL_P';


-----------------------------------------------------------------
-- EN PRY2205_USER1 SE EJECUTA LA CREACION DEL ESQUEMA POBLADO (PRY2205_EXP3_S8)
-----------------------------------------------------------------

/* =========================================================
   CASO 1 - SINÓNIMOS PÚBLICOS + GRANTS DE LECTURA
   (EJECUTAR COMO PRY2205_USER1)
   =========================================================
   Objetivo:
   - Crear sinónimos PÚBLICOS para que USER2 no use nombres reales.
   - Otorgar SOLO SELECT a lo necesario (Caso 2).
   ========================================================= */

------------------------------------------------------------
-- 1) SINÓNIMOS PÚBLICOS PARA CASO 2 (CONTROL STOCK)
--    (USER2 consulta usando SYN_* y no el nombre real)
------------------------------------------------------------
CREATE OR REPLACE PUBLIC SYNONYM SYN_LIBRO    FOR PRY2205_USER1.LIBRO;
CREATE OR REPLACE PUBLIC SYNONYM SYN_EJEMPLAR FOR PRY2205_USER1.EJEMPLAR;
CREATE OR REPLACE PUBLIC SYNONYM SYN_PRESTAMO FOR PRY2205_USER1.PRESTAMO;
CREATE OR REPLACE PUBLIC SYNONYM SYN_EMPLEADO FOR PRY2205_USER1.EMPLEADO;

------------------------------------------------------------
-- 2) SINÓNIMOS PÚBLICOS PARA CASO 3 -MULTAS-
------------------------------------------------------------
CREATE OR REPLACE PUBLIC SYNONYM SYN_ALUMNO  FOR PRY2205_USER1.ALUMNO;
CREATE OR REPLACE PUBLIC SYNONYM SYN_CARRERA FOR PRY2205_USER1.CARRERA;
CREATE OR REPLACE PUBLIC SYNONYM SYN_REBAJA  FOR PRY2205_USER1.REBAJA_MULTA;

------------------------------------------------------------
-- 3) OTORGAR PERMISOS SOLO LECTURA PARA CASO 2

------------------------------------------------------------
GRANT SELECT ON PRY2205_USER1.LIBRO    TO PRY2205_ROL_P;
GRANT SELECT ON PRY2205_USER1.EJEMPLAR TO PRY2205_ROL_P;
GRANT SELECT ON PRY2205_USER1.PRESTAMO TO PRY2205_ROL_P;
GRANT SELECT ON PRY2205_USER1.EMPLEADO TO PRY2205_ROL_P;




/* =========================================================
   CASO 2 - CREACIÓN INFORME CONTROL_STOCK_LIBROS
   (EJECUTAR COMO PRY2205_USER2)
   =========================================================
   Reglas clave:
   - Periodo: mes actual - 24 meses (paramétrico, NO fecha fija)
   - Empleados: 190, 180, 150
   - usar secuencia SEQ_CONTROL_STOCK
   ========================================================= */

------------------------------------------------------------
-- 0) LIMPIEZA (opcional)
------------------------------------------------------------
DROP SEQUENCE SEQ_CONTROL_STOCK;

------------------------------------------------------------
-- 1) SECUENCIA 
------------------------------------------------------------
CREATE SEQUENCE SEQ_CONTROL_STOCK
  START WITH 1
  INCREMENT BY 1
  NOCACHE
  NOCYCLE;

------------------------------------------------------------
-- 2) CREAR TABLA (CTAS) CON LOS DATOS CALCULADOS
------------------------------------------------------------
CREATE TABLE CONTROL_STOCK_LIBROS AS
SELECT
    x.libro_id,
    x.nombre_libro,
    x.total_ejemplares,
    x.en_prestamo,
    (x.total_ejemplares - x.en_prestamo) AS disponibles,
    ROUND((x.en_prestamo / NULLIF(x.total_ejemplares,0)) * 100) AS porcentaje_prestamo,
    CASE
        WHEN (x.total_ejemplares - x.en_prestamo) > 2 THEN 'S'
        ELSE 'N'
    END AS stock_critico
FROM (
    SELECT
        l.libroid      AS libro_id,
        l.nombre_libro AS nombre_libro,

        -- Total de ejemplares existentes del libro
        COUNT(e.ejemplarid) AS total_ejemplares,

        -- Ejemplares en préstamo dentro del mes objetivo
        COUNT(DISTINCT p.ejemplarid) AS en_prestamo
    FROM SYN_LIBRO l
    JOIN SYN_EJEMPLAR e
      ON e.libroid = l.libroid

    LEFT JOIN SYN_PRESTAMO p
      ON p.libroid     = l.libroid
     AND p.ejemplarid  = e.ejemplarid
     AND p.empleadoid IN (150,180,190)

     -- Mes actual - 24 meses: rango [inicio_mes, inicio_mes+1)
     AND p.fecha_inicio >= ADD_MONTHS(TRUNC(SYSDATE,'MM'), -24)
     AND p.fecha_inicio <  ADD_MONTHS(TRUNC(SYSDATE,'MM'), -23)

    GROUP BY l.libroid, l.nombre_libro
) x
ORDER BY x.libro_id;

------------------------------------------------------------
-- 3) AGREGAR COLUMNA CORRELATIVO + CARGARLA CON SECUENCIA
------------------------------------------------------------
ALTER TABLE CONTROL_STOCK_LIBROS ADD (id_control NUMBER);

UPDATE CONTROL_STOCK_LIBROS
SET id_control = SEQ_CONTROL_STOCK.NEXTVAL;

COMMIT;

------------------------------------------------------------
-- 4) CONSULTA FINAL CON FORMATO
------------------------------------------------------------
SELECT
  id_control                                   AS "N°",
  libro_id                                     AS "ID LIBRO",
  nombre_libro                                 AS "NOMBRE LIBRO",
  total_ejemplares                             AS "TOTAL EJEMPLARES",
  en_prestamo                                  AS "EN PRESTAMO",
  disponibles                                  AS "DISPONIBLES",
  TO_CHAR(porcentaje_prestamo,'FM999G990') || '%' AS "% PRESTAMO",
  stock_critico                                AS "STOCK CRITICO"
FROM control_stock_libros
ORDER BY libro_id;



/* =========================================================
   CASO 3.1 - CREACIÓN VISTA VW_DETALLE_MULTAS
   (EJECUTAR COMO PRY2205_USER1)
   ========================================================= */

CREATE OR REPLACE VIEW VW_DETALLE_MULTAS AS
SELECT
    p.prestamoid                                                AS id_prestamo,
    INITCAP(a.nombre || ' ' || a.apaterno || ' ' || a.amaterno) AS nombre_alumno,
    c.descripcion                                               AS nombre_carrera,
    l.libroid                                                   AS id_libro,
    l.precio                                                    AS valor_libro,
    p.fecha_termino                                             AS fecha_termino,
    p.fecha_entrega                                             AS fecha_entrega,
    (p.fecha_entrega - p.fecha_termino)                         AS dias_atraso,

    -- Multa = 3% del precio por día de atraso
    ROUND(l.precio * 0.03 * (p.fecha_entrega - p.fecha_termino)) AS valor_multa,

    -- % rebaja (si existe convenio); si no existe, 0
    NVL(r.porc_rebaja_multa, 0)                                  AS porcentaje_rebaja_multa,

    -- Multa final con rebaja aplicada
    ROUND(
        (l.precio * 0.03 * (p.fecha_entrega - p.fecha_termino)) *
        (1 - NVL(r.porc_rebaja_multa,0)/100)
    ) AS valor_rebajado
FROM PRESTAMO p
JOIN ALUMNO a  
ON a.alumnoid  = p.alumnoid
JOIN CARRERA c 
ON c.carreraid = a.carreraid
JOIN LIBRO l   
ON l.libroid   = p.libroid
LEFT JOIN REBAJA_MULTA r 
ON r.carreraid = c.carreraid
WHERE p.fecha_entrega IS NOT NULL
  AND p.fecha_termino < p.fecha_entrega
  AND EXTRACT(YEAR FROM p.fecha_termino) = EXTRACT(YEAR FROM SYSDATE) - 2
ORDER BY p.fecha_entrega DESC;

-- Consulta de prueba con formato $
SELECT
  id_prestamo,
  nombre_alumno,
  nombre_carrera,
  id_libro,
  TO_CHAR(valor_libro,'FM$999G999G999')    AS valor_libro,
  fecha_termino,
  fecha_entrega,
  dias_atraso,
  TO_CHAR(valor_multa,'FM$999G999G999')    AS valor_multa,
  porcentaje_rebaja_multa,
  TO_CHAR(valor_rebajado,'FM$999G999G999') AS valor_rebajado
FROM VW_DETALLE_MULTAS;



/* =========================================================
   CASO 3.2 - ÍNDICES PARA OPTIMIZAR LA VISTA
   (EJECUTAR COMO PRY2205_USER1)
   ========================================================= */

-- Índice para el filtro de año y comparación fecha_termino < fecha_entrega
CREATE INDEX IDX_PRESTAMO_FTERM_FENT
ON PRESTAMO (FECHA_TERMINO, FECHA_ENTREGA);

-- Índices típicos para joins
CREATE INDEX IDX_PRESTAMO_ALUMNO 
ON PRESTAMO (ALUMNOID);
CREATE INDEX IDX_PRESTAMO_LIBRO  
ON PRESTAMO (LIBROID);
CREATE INDEX IDX_ALUMNO_CARRERA  
ON ALUMNO (CARRERAID);

