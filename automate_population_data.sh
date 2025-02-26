#!/bin/bash

# Define variables
DATA_URL="https://www2.census.gov/programs-surveys/popest/datasets/2023/population.csv"
HDFS_PATH="/user/hive/warehouse/population_data"
LOCAL_FILE="population.csv"

# Download the file
wget -O $LOCAL_FILE $DATA_URL

# Move to HDFS
hadoop fs -rm -r $HDFS_PATH
hadoop fs -mkdir -p $HDFS_PATH
hadoop fs -put $LOCAL_FILE $HDFS_PATH/

# Load data into Hive
hive -e "LOAD DATA INPATH '$HDFS_PATH/$LOCAL_FILE' INTO TABLE census_db.population_table;"

# Validate data
hive -e "SELECT * FROM census_db.population_table LIMIT 10;"
