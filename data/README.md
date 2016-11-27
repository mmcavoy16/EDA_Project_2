# SQL Database

From the command line run the following: 

`cat health.sql | sqlite3 health.db`

This will produce two files: 

- `health.db`: Database containing the medical data used for this analysis.

- `dataframe.csv`: csv file containing a joined version of the death and readmission table and the outpatient volumes.
