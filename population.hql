CREATE DATABASE IF NOT EXISTS census_db;
USE census_db;

DROP TABLE IF EXISTS population_table;

CREATE EXTERNAL TABLE population_table (
    state STRING,
    county STRING,
    population INT,
    year INT
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/user/hive/warehouse/population_data/';
#new to git