# Fetching Census Data, Storing in HDFS, and Creating a Hive Table

## Overview
This project automates the process of fetching population dataset files from the U.S. Census Bureau, storing them in HDFS, and creating a Hive table for querying and analysis.

## Prerequisites
Before proceeding, ensure you have the following installed:

- **Hadoop** (HDFS setup)
- **Hive** (Configured and running)
- **wget** or **curl** (For downloading files)
- **Bash** (For automation scripting)

## Steps to Execute

### 1. Verify Accessibility and Download Capability
Check whether the dataset URL is accessible:
```bash
curl -I https://www2.census.gov/programs-surveys/popest/datasets/
```
If the response is `200 OK`, proceed with downloading the required file.

### 2. Identify Data Format and Schema
Run the following command to list available files:
```bash
wget --spider -r -l1 -nd -A "*.csv" https://www2.census.gov/programs-surveys/popest/datasets/
```
This will return available CSV files. Analyze the structure of the dataset.

### 3. Download the Data File
Use `wget` to download a specific dataset (e.g., `population.csv`):
```bash
wget https://www2.census.gov/programs-surveys/popest/datasets/2023/population.csv -O population.csv
```

### 4. Store the File into HDFS
Move the downloaded file into HDFS for further processing:
```bash
hadoop fs -mkdir -p /user/hive/warehouse/population_data
hadoop fs -put population.csv /user/hive/warehouse/population_data/
```

### 5. Create a Hive Table
Define the schema and create a Hive table.

#### HiveQL Script (`population.hql`):
```sql
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
```
#### Execute the Hive Script:
```bash
hive -f population.hql
```

### 6. Load Data into Hive Table
Use the `LOAD DATA INPATH` command to insert data from HDFS into Hive:
```sql
LOAD DATA INPATH '/user/hive/warehouse/population_data/population.csv' INTO TABLE population_table;
```
#### Run in Hive CLI:
```bash
hive -e "LOAD DATA INPATH '/user/hive/warehouse/population_data/population.csv' INTO TABLE population_table;"
```

### 7. Verify Data Integrity
To ensure the data is correctly loaded, run a simple query:
```sql
SELECT * FROM population_table LIMIT 10;
```
#### Execute in Hive CLI:
```bash
hive -e "SELECT * FROM population_table LIMIT 10;"
```

### 8. Automate the Process
To automate data fetching, storage, and loading, create a bash script `automate_population_data.sh`.

#### Bash Automation Script:
```bash
#!/bin/bash

# Define Variables
data_url="https://www2.census.gov/programs-surveys/popest/datasets/2023/population.csv"
hdfs_path="/user/hive/warehouse/population_data"
local_file="population.csv"

# Download the file
wget -O $local_file $data_url

# Move file to HDFS
hadoop fs -rm -r $hdfs_path
hadoop fs -mkdir -p $hdfs_path
hadoop fs -put $local_file $hdfs_path/

# Load data into Hive
hive -e "LOAD DATA INPATH '$hdfs_path/$local_file' INTO TABLE census_db.population_table;"

# Verify data
hive -e "SELECT * FROM census_db.population_table LIMIT 10;"
```

#### Make the Script Executable and Run:
```bash
chmod +x automate_population_data.sh
./automate_population_data.sh
```

## Expected Output
- The dataset is successfully retrieved and stored in HDFS.
- The Hive table is created and populated with the dataset.
- A simple query confirms the data integrity.
- The automation script ensures periodic data refreshes.

## Future Enhancements
- Implement incremental data loads instead of full refresh.
- Convert CSV to ORC or Parquet for optimized performance.
- Schedule the script using `crontab` for periodic execution.

## Troubleshooting
- If `wget` fails, ensure the URL is accessible.
- If HDFS commands fail, check if Hadoop services are running.
- If Hive commands fail, verify Hive metastore and database permissions.

---
This setup ensures efficient data ingestion and processing using Hadoop and Hive. 🚀

