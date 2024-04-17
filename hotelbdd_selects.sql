-- Quina és la mitjana de quantitat de reserves dels clients provinents d''HOLANDA' per anys?
SELECT t1.any, ROUND(AVG(t1.num_reserves),2) AS mitjana
FROM (SELECT YEAR(r.data_inici) AS any, c.client_id, COUNT(*) AS num_reserves
		FROM reserves r
		INNER JOIN clients c ON r.client_id = c.client_id
        INNER JOIN paisos p ON p.pais_id = c.pais_origen_id
		WHERE p.nom = "HOLANDA"
		GROUP BY YEAR(r.data_inici), c.client_id) AS t1
GROUP BY t1.any
ORDER BY t1.any ASC;

-- De l'Hotel 'Catalonia Ramblas' de Barcelona mostra la quantitat de nits disponibles (teòriques) que tindria l'hotel per cada mes de l'any 2016
SELECT MONTH(r1.data_inici) AS mes, COUNT(*) AS nits
	FROM habitacions h1
    INNER JOIN reserves r1 ON r1.hab_id = h1.hab_id
    INNER JOIN hotels ht1 ON ht1.hotel_id = h1.hotel_id
    WHERE ht1.nom = "Catalonia Ramblas" AND h1.hab_id NOT IN (SELECT r.hab_id
																FROM reserves r
																INNER JOIN habitacions h ON h.hab_id = r.hab_id
																INNER JOIN hotels ht ON ht.hotel_id = h.hotel_id
																WHERE ht.nom = "Catalonia Ramblas" AND EXTRACT(YEAR FROM r.data_inici) = 2016)
    GROUP BY mes
    ORDER BY mes;

