SELECT ST_X(craig_geom::geometry) AS longitude, ST_Y(craig_geom) AS latitude, ST_AsText(craig_geom), ST_AsGeoJSON(craig_geom), craig_geom, price, longitude, latitude
FROM website_craig_data
LIMIT 1000;
	
ALTER TABLE  website_craig_data ADD COLUMN latitude double precision;
UPDATE website_craig_data SET latitude=ST_Y(craig_geom);


WITH df AS (
SELECT TO_DATE(website_craig_data.date_scraped, 'MM/DD/YYYY') as ddate
FROM website_craig_data
LIMIT 10
	)
SELECT ddate
FROM df
WHERE ddate >='2020-06-14';
