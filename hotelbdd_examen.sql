/* ----------------------------------------------------------------------------------- */

-- EXAMEN BASE DE DADES -- 

-- EXERCICI 1: 
/*El client Xiaoshan, Schaap (client_id = 16341) ens ha trucat dient que vol ampliar en 2 nits més totes les reserves que ha fet a  l'hotel BCNmontjuic (hotel_id=158)

El nostre cap ens diu que fem aquest canvi utilitzant una sola sentència DML
No cal comprovar si algunes de les reserves del senyor Xiaoshan, Schaap ampliades es sobreposen amb altres reserves.
Només hem d'ampliar les reserves posteriors a la data d'avui.*/

UPDATE reserves r
	INNER JOIN (
		SELECT r.reserva_id
				FROM clients c
				INNER JOIN reserves r ON r.client_id = c.client_id
				INNER JOIN habitacions h ON h.hab_id = r.hab_id
				INNER JOIN hotels ht ON ht.hotel_id = h.hotel_id
				WHERE c.client_id = 16341 AND ht.hotel_id = 158 AND r.data_inici > CURRENT_DATE()
                ) AS r1 ON r1.reserva_id = r.reserva_id
	SET data_fi = DATE_ADD(data_fi, INTERVAL 2 DAY);
    
-- EXERCICI 2:
/*Mostra quants carrers diferents tenim entrats a la BD.

Només contempla les adreces que tenen el caràcter ',' per separar el nom del carrer i el número.
No contemplis noms de carrers amb diferents idiomes. Si un carrer està en català i en castellà seran dos carrers diferents.
Ordena el resultat per adreça
+-----------+
| quantitat |
+-----------+*/

SELECT COUNT(DISTINCT TRIM(SUBSTRING_INDEX(adreca, ',', 1))) AS quantitat
	FROM hotels
    WHERE adreca RLIKE ('(.)*,');
    
-- EXERCICI 3:
/*Digues els noms dels hotels que els seus noms estan composats com a mínim per 2 paraules.

Es considera que un nom està composat per més d'una paraula quan aquest conté com a mínim dues paraules separades per un espai en blanc.
Ordena el resultat per nom de l'hotel de forma ascendent.
+------------+
| nom        |
+------------+*/

SELECT nom
	FROM hotels
    WHERE nom RLIKE ('. .')
    ORDER BY nom;
    
-- EXERCICI 4:
/*Mostra els clients que els hi coincideix el dia de naixement amb el mes.

Per exemple el client Pere Pi va nèixer el 01-01-1976 (el dia i el mes de naixment coincideixen 1 = 1)

Mostra el nom, el primer cognom i la data de naixement.
Ordena el resultat per client_id
+--------+---------+------------+
| nom    | cognom1 | data_naix  |
+--------+---------+------------+*/

SELECT nom, cognom1, data_naix
	FROM clients
    WHERE EXTRACT(DAY FROM data_naix) = EXTRACT(MONTH FROM data_naix)
    ORDER BY client_id;
    
-- EXERCICI 5: 
/*Obtenir el nom i i el primer cognom dels clients que van nèixer el mes d'abril i que el seu país d'origen sigui 'ALEMANIA' (pais_id=4)

Ordena el resultat per client_id
+----------+-----------+
| nom      | cognom1   |
+----------+-----------+*/

SELECT c.nom, c.cognom1
	FROM clients c
    WHERE EXTRACT(MONTH FROM c.data_naix) = 4 AND c.pais_origen_id = 4
    ORDER BY client_id;
    
-- EXERCICI 6:
/*Volem saber el número de clients per país.

Ordena el resultat de tal manera que els països amb més clients surtin en primera posició.
+---------+------+
| pais_id | num  |
+---------+------+*/

SELECT pais_origen_id AS pais_id, COUNT(*) AS num
	FROM clients
    GROUP BY pais_origen_id
    ORDER BY num DESC;
    
-- EXERCICI 7:
/*Quants hotels estan situats en el mateix carrer que l'hotel Eurostars Cristal Palace (hotel_id=52) de Barcelona si sabem que l'adreça d'aquest hotel és 'Diputació, 257'.

En el recompte exclou l'hotel Eurostars Cristal Palace.
+-----------+
| quantitat |
+-----------+*/

SELECT COUNT(*) AS quantitat
	FROM hotels
    WHERE adreca RLIKE ('(.)*Diputació(.)*') AND hotel_id != 52 AND poblacio_id = (
		SELECT poblacio_id
			FROM hotels
			WHERE hotel_id = 52);

-- EXERCICI 8: 
/*Volem obtenir la quanitat de reserves per pais_origen_id i número de nits. Però amb dues consideracions:

Només hem de contabilitzar aquelles reserves que tinguin una durada de 10,20,30,40,50,90 o 100 nits.
Només volem mostrar els registres resultants que la quantitat de reserves sigui superior a 100.
Ordena el resultat per quantitat de reserves de més gran a més petit.

+----------------+------+-------------------+
| pais_origen_id | nits | quantitat_reserves |
+----------------+------+-------------------+*/

SELECT c1.pais_origen_id, DATEDIFF(data_fi, data_inici) AS nits, COUNT(c1.pais_origen_id) AS quantitat_reserves
	FROM reserves r1
    INNER JOIN clients c1 ON c1.client_id = r1.client_id
    WHERE r1.reserva_id IN (SELECT reserva_id
								FROM reserves
								WHERE DATEDIFF(data_fi, data_inici) IN (10, 20, 30, 40, 50, 90, 100))
    GROUP BY c1.pais_origen_id, nits
    HAVING quantitat_reserves > 100
    ORDER BY quantitat_reserves DESC;

-- EXERCICI 9:
/*Especifica quins clients que van realitzar reserves el 2014  no en van realitzar cap el 2015.

Mostra l'dentificador del client, el nom i el primer cognom
Considera que una reserva pertany a un any si la seva data_inici hi pertany.
Ordena el resultat per client_id
+-----------+-------+---------+
| client_id |  nom  | cognom1 |
+-----------+-------+---------+*/

SELECT DISTINCT r14.client_id, c14.nom, c14.cognom1
	FROM reserves r14
    INNER JOIN clients c14 ON c14.client_id = r14.client_id
    WHERE YEAR(r14.data_inici) = 2014 AND r14.client_id NOT IN (
		SELECT r15.client_id
			FROM reserves r15
            WHERE YEAR(r15.data_inici) = 2015)
    ORDER BY r14.client_id;

