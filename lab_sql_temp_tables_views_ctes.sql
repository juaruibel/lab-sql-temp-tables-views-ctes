-- ==========================================================
-- Lab · SQL · Temporary Tables, Views and CTEs (Sakila)
-- Objetivo: rellenar cada apartado con tu query (sin resolver aquí)
-- ==========================================================

USE sakila;

-- ==========================================================
-- CHALLENGE · Creating a Customer Summary Report
-- ==========================================================
-- Objetivo: crear un reporte que resuma información clave sobre
-- clientes: historial de alquileres y detalles de pago.
-- Herramientas: VIEW + TEMP TABLE + CTE
-- ==========================================================
    

-- ----------------------------------------------------------
-- STEP 1 · Crear una VIEW (rental summary)
-- ----------------------------------------------------------
-- La VIEW debe incluir:
--   - customer_id
--   - Nombre del cliente (first_name, last_name o concatenado)
--   - email
--   - rental_count (número total de alquileres)
--
-- Tablas a usar: customer, rental
-- Pista: JOIN + GROUP BY + COUNT
-- ----------------------------------------------------------

DROP VIEW IF EXISTS vw_rental_summary;

CREATE VIEW vw_rental_summary AS
SELECT
	c.customer_id,
	c.first_name,
    c.last_name,
    c.email,
    COUNT(r.rental_id) AS rental_count
FROM customer AS c
JOIN rental AS r
	ON c.customer_id = r.customer_id
GROUP BY 
	c.customer_id;
    
SELECT * FROM vw_rental_summary LIMIT 5;


-- ----------------------------------------------------------
-- STEP 2 · Crear una TEMPORARY TABLE (payment summary)
-- ----------------------------------------------------------
-- La TEMP TABLE debe:
--   - Usar la VIEW creada en Step 1
--   - Hacer JOIN con la tabla payment
--   - Calcular total_paid por cliente (SUM de amount)
--
-- Tablas a usar: la VIEW del Step 1 + payment
-- Pista: JOIN por customer_id + GROUP BY + SUM
-- ----------------------------------------------------------

DROP TEMPORARY TABLE IF EXISTS temp_total_paid_by_customer;

CREATE TEMPORARY TABLE temp_total_paid_by_customer AS
SELECT
	vwrs.customer_id,
    SUM(pay.amount) AS total_paid
FROM vw_rental_summary AS vwrs
JOIN payment AS pay
	ON vwrs.customer_id = pay.customer_id
GROUP BY
	vwrs.customer_id;
	
SELECT * FROM temp_total_paid_by_customer LIMIT 5;


-- ----------------------------------------------------------
-- STEP 3 · Crear una CTE y generar el Customer Summary Report
-- ----------------------------------------------------------
-- La CTE debe:
--   - Unir la VIEW (Step 1) con la TEMP TABLE (Step 2)
--   - Incluir: nombre, email, rental_count, total_paid
--
-- El SELECT final (después del CTE) debe mostrar:
--   - customer_name
--   - email
--   - rental_count
--   - total_paid
--   - average_payment_per_rental (columna derivada: total_paid / rental_count)
--
-- ----------------------------------------------------------

WITH customer_summary_report AS (
	SELECT
		CONCAT(vwrs.first_name, ' ', vwrs.last_name) AS full_name,
		vwrs.email,
		vwrs.rental_count,
		ttpbc.total_paid,
		(ttpbc.total_paid/vwrs.rental_count) AS average_payment_per_rental 
	FROM vw_rental_summary AS vwrs
	JOIN temp_total_paid_by_customer AS ttpbc
		ON vwrs.customer_id = ttpbc.customer_id
)

SELECT * FROM customer_summary_report;









