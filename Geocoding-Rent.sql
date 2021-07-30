--geocode address to get lon/lat, for analysis
-- need to download tiger data into DB, empty:(SELECT count(*) FROM tiger.addr;)
	-- https://docs.bitnami.com/google-templates/infrastructure/postgresql/administration/install-use-tiger/
	-- https://experimentalcraft.wordpress.com/2017/11/01/how-to-make-a-postgis-tiger-geocoder-in-less-than-5-days/
	-- cheated and used this: https://geocoding.geo.census.gov/geocoder/locations/onelineaddress?address=5336+Harvey+Way%2C+Long+Beach+CA+90808&benchmark=4
SET search_path=public,tiger;

SELECT g.rating, ST_X(g.geomout) As lon, ST_Y(g.geomout) As lat,
    (addy).address As stno, (addy).streetname As street,
    (addy).streettypeabbrev As styp, (addy).location As city, (addy).stateabbrev As st,(addy).zip
    FROM tiger.geocode('5336 Harvey Way, Long Beach CA 90808', 1) As g;
	
	
SELECT g.rating, ST_AsText(ST_SnapToGrid(g.geomout,0.00001)) As wktlonlat,
    (addy).address As stno, (addy).streetname As street,
    (addy).streettypeabbrev As styp, (addy).location As city, (addy).stateabbrev As st,(addy).zip
    FROM geocode('5336 Harvey Way, Long Beach CA 90808',1) As g;

/*Matched Address: 5336 E HARVEY WAY, LONG BEACH, CA, 90808
Coordinates:X: -118.12817 Y: 33.836094
-118.128180, 33.835850
Tiger Line Id: 141700584 Side: R
*/

/*ALTER TABLE public.census_map_layer
    ALTER COLUMN wkb_geometry TYPE geometry
CREATE INDEX census_map_layer_geom_gist ON census_map_layer USING gist(wkb_geometry);
*/	


--- next 

--sanity check
SELECT ST_GEOMFromWKB(ST_SETSRID(ST_MAKEPOINT(-118.1280, 33.8358), 4326));

--details on neighborhood, useful for LR trend analysis 
	-- perhaps join up with craig info
SELECT *
FROM census_map_layer
WHERE
	ST_CONTAINS(
		ST_GeomFromWKB(census_map_layer.wkb_geometry, 4326), 
		ST_GEOMFromWKB(ST_SETSRID(ST_MAKEPOINT(-118.1280, 33.8358), 4326))
	)
LIMIT 10;

--Nearest 100 points to lat/lon
	--https://postgis.net/workshops/postgis-intro/knn.html
WITH closest_candidates AS (
  SELECT
    craig.craigid,
    craig.price,
    craig.beds,
	craig.baths,
	craig.size,
	craig.geom
  FROM
    craig_dataset AS craig
  WHERE 
	1=1
	AND craig.beds != '19'
	AND craig.baths != '19'
	AND craig.size != '19'
	AND craig.price >1000 
  ORDER BY
    craig.geom <->
    'SRID=4326;POINT(-118.12817 33.836094)'::geometry
  LIMIT 100
)
SELECT closest_candidates.beds, AVG(closest_candidates.price)
FROM closest_candidates
GROUP BY closest_candidates.beds
/*ORDER BY
  ST_Distance(
    closest_candidates.geom,
    'SRID=4326;POINT(-118.12817 33.836094)'::geometry
    )
*/
LIMIT 100;

	

WITH census AS (

	SELECT 
		census_dataset.fips, census_dataset."NAME", census_tracts.wkb_geometry, census_dataset."Gross_rent_median_E"
		census_dataset."Commute_Mean_Travel_Time_E", census_dataset.rental_vacancy_rate
	FROM 
		census_dataset
	INNER JOIN 
		census_tracts
	ON 
		census_dataset.fips = census_tracts.geoid::bigint
	WHERE 
		1=1 
		AND census_dataset.state =06
		--AND census_dataset.county=37 
		AND census_dataset.rental_vacancy_rate != '19'
	-- LIMIT 100
),
craig AS (
	SELECT 
		craig.craigid, craig.price as price, craig.beds as beds, craig.baths as baths, craig.size as size, craig.contentlen, craig.numpic, craig.geom AS craig_geom
		--,la_county.geom AS la_county_geom, la_county.name AS neighborhood_name
	FROM 
		craig_dataset AS craig
	--INNER JOIN 
	--	la_county
	--ON 
	--	ST_CONTAINS(la_county.geom, craig.geom)
	WHERE 
		(beds = '0.0' OR beds = '1.0' OR beds = '2.0' OR beds ='3.0' OR beds = '4.0' OR beds ='5.0') 
		AND (price > '400' AND price < '20000') 
		AND (baths !='0.0' AND baths!='19.0') 
		AND (size != '0.0' AND size!= '19.0') 
)
	
	

	
	
--prior
SELECT gross_rent_median_e, year
FROM census_map_layer
WHERE 
	ST_WITHIN(
		census_map_layer.wkb_geometry,
		ST_MAKEPOINT(-118.12817, 33.836094)
	)
LIMIT 10;


SELECT 
		craig_dataset.price, la_county.name AS neighborhood_name
	FROM 
		craig_dataset
	INNER JOIN 
		la_county 
	ON 
		ST_CONTAINS((la_county.geom), ST_MAKEPOINT(-118.12817, 33.836094))
		


SELECT geom
FROM la_county
LIMIT 10;

SELECT ST_X (GeometryFromEWKB(wkb_geometry, 4326)) AS long
       --ST_Y (ST_Transform (geom, 4326)) AS lat
FROM census_tracts
LIMIT 10;

SELECT wkb_geometry
FROM census_map_layer
LIMIT 10;

SELECT ST_X (GeometryFromWKB(census_map_layer.wkb_geometry, 4326)) AS long
FROM census_map_layer
LIMIT 10;

SELECT
  ST_AsText(
	ST_GeomFromWKB(
	  ST_AsEWKB('POINT(2 5)'::geometry)
	)
  );



