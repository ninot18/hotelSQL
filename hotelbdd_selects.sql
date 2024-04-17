-- Cálculo de la media de reservas anuales hecha por clientes de nacionalidad holandesa.
SELECT t1.any, ROUND(AVG(t1.num_reserves),2) AS mitjana
FROM (SELECT YEAR(r.data_inici) AS any, c.client_id, COUNT(*) AS num_reserves
		FROM reserves r
		INNER JOIN clients c ON r.client_id = c.client_id
        INNER JOIN paisos p ON p.pais_id = c.pais_origen_id
		WHERE p.nom = "HOLANDA"
		GROUP BY YEAR(r.data_inici), c.client_id) AS t1
GROUP BY t1.any
ORDER BY t1.any ASC;

    
