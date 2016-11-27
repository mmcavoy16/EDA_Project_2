# SQL Database

From the command line run the following: 

`cat health.sql | sqlite3 health.db`

This will produce two files: 

- `health.db`: Database containing the medical data used for this analysis.

- `dataframe.csv`: csv file containing a joined version of the death and readmission table and the outpatient volumes.

# Data Source
Readmissions and Deaths: 30-Day Readmission and Death Measures

**Reporting Cycle**: 7/01/2012 \- 6/30/2015 AND 7/01/2014 \- 6/30/2015

## How? 
Data is collected from billing codes submitted to Medicare by healthcare providers.

## Who? 

- Patients +65 years old who were enrolled in __Original Medicare__ for 12 months prior to admission

### Excluded if:
- Transferred from separate acute treatment facility
- Enrolled in __Medicare Hospice__ program within 12 months prior to admission
- Discharged against the advice of the hospital 
- If the individuals stay was longer than 1 year
- Discharged alive on the same day or following day and didn't transfer to another acute care facility

## Why? 
Using claims data makes it possible to calculate death rate without having to review medical charts or requiring additional information from the hospital.

30-day time frame was selected because older adult patients are more vulnerable to adverse health outcomes during this time .  This is deemed a "clinically meaningful" period in which hospitals collaborate with the community in an effort to reduce mortality.

# Risk Standardized Mortality Rate
Death measures are adjusted fro patient characteristics(age, sex, past medical history, etc...) that would make death more likely. 
