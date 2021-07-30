# SQL-Portoflio-Examples

Included are 3 examples of SQL queries used in a project that predicted rent using data collected from Craigslist, Apartments.com, the census, and other sources.

LA-Census=Pull.sql is a simple pull that joins census data to the tracts so that it was viewable upon a map. It pulls data for LA's census tract on county / fips.

Craigslist-Geometries-Updating converts the geometries used in postgres into lat/lon, and alters the table to include those columns for future exploration in other forms ( a geoserver using CQL, as well as analysis in python.)

Geocoding-Rent.sql uses tiger to geocode an address and collects points nearby. This was an attempt to predict rent only by using nearby properties with similar characteristics. It was then joined to nearby census data to provide context for the property in question.
