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
WITH RECURSIVE mesos AS (
	SELECT 1 AS mes
    UNION ALL 
    SELECT mes + 1 FROM mesos WHERE mes < 12
), habs2016 AS (
	SELECT ht.habitacions AS hab16
		FROM hotels ht
        INNER JOIN poblacions p ON p.poblacio_id = ht.poblacio_id
		WHERE ht.nom = 'Catalonia Ramblas' AND p.nom = 'Barcelona'
)
SELECT 	m.mes, 
		CASE 
			WHEN m.mes IN (1, 3, 5, 7, 8, 10, 12) THEN (30 * (SELECT hab16 FROM habs2016))
            WHEN m.mes IN (4, 6, 9, 11) THEN (29 * (SELECT hab16 FROM habs2016))
            ELSE (28 * (SELECT hab16 FROM habs2016))
		END AS nits
	FROM mesos m
    ORDER BY m.mes;
    
-- Digues quin o quins són els clients (Id del client, nom, primer cognom) juntament amb el número de reserves que han realitzat més reserves durant el mes d’agost de l’any 2016.
WITH bookings AS (
	SELECT r.client_id, COUNT(*) AS booking
		FROM reserves r
		WHERE YEAR(r.data_inici) = 2016 AND MONTH(r.data_inici) = 8
		GROUP BY r.client_id
)
SELECT r1.client_id, c.nom, c.cognom1, COUNT(*) AS num_reserves
	FROM reserves r1
    INNER JOIN clients c ON c.client_id = r1.client_id
    WHERE YEAR(r1.data_inici) = 2016 AND MONTH(r1.data_inici) = 8
    GROUP BY r1.client_id
    HAVING num_reserves >= (SELECT MAX(booking) FROM bookings)
    ORDER BY r1.client_id;

-- Digues quins clients (només mostra el seu id, el seu nom i els seu cognom 1) que han fet alguna reserva durant l'any 2015 i han repetit hotel respecte l'any 2014.
WITH clients2014 AS (
	SELECT r.client_id AS client2014, ht.hotel_id AS hotel2014
		FROM reserves r
		INNER JOIN habitacions h ON h.hab_id = r.hab_id
		INNER JOIN hotels ht ON ht.hotel_id = h.hotel_id
		WHERE YEAR(r.data_inici) = 2014
)
SELECT r.client_id, c.nom, c.cognom1
    FROM reserves r
    INNER JOIN clients c ON c.client_id = r.client_id
    INNER JOIN habitacions h ON h.hab_id = r.hab_id
    INNER JOIN hotels ht ON ht.hotel_id = h.hotel_id
    WHERE YEAR(r.data_inici) = 2015 AND EXISTS (SELECT 1 FROM clients2014 WHERE r.client_id = client2014 AND ht.hotel_id = hotel2014)
    GROUP BY r.client_id;

