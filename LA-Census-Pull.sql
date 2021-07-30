-- pull all census variables for LA county 2806 rows

SELECT 
	census_dataset.fips, census_dataset."NAME", census_tracts.wkb_geometry, 
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
	AND census_dataset.county=37 
	AND census_dataset.rental_vacancy_rate != '19'
LIMIT 
	100;


SELECT fips, county
FROM census_dataset
WHERE county=37
LIMIT 10;

SELECT geoid::bigint 
FROM census_tracts
LIMIT 10;
