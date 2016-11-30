# SQL Database

From the command line run the following: 

`cat health.sql | sqlite3 health.db`

This will produce two files: 

- `health.db`: Database containing the medical data used for this analysis.

- `dataframe.csv`: csv file containing a joined version of the death and readmission table and the outpatient volumes.


# Data
Condition-specific mortality measures/readmission measures used in Hospital Inpatient Quality Reporting prgram and publically reported on **Hospital Compare**. 

## How was it collected and by whom? 
Data was collected from Medicare billing codes provided by Healthcare providers.  The agency responsible for harvesting this data is the Centers of Medicare & Medicaid Services' (CMS's)-- a branch of the Department of Health and Human Services. 
Data between July 1, 2012 and June 30, 2015.

## Who is this intended for?
While the CMS's claims there reports are intended for a wide range of readers, there is a fair amount of Jargon.

# Quantifying "Worst"
## Risk Standardized Mortality Rate (henceforth known as Death Score)
The effort to maintain public records on a given hospitals Death Scores began in 2007-- CMS reported 30-day Death scores for AMI's and HF's for the nations non-federal short-term acute hospitals and critical access hospitals.  In an effort to improve these measures in response to stakeholder input/changes in science/changes in coding, measures are revaluated annually by Yale-New Haven Health Services.
In order to account for differences in patient mix among hospitals, the death score adjusts for variables that are clinically relevant to the mortality outcome.
Complications that arise after initial admission are not factored into this adjusted.
### Who is actually included? 
An **Index Admission** is the hospitiliztion to which the mortality outcome is attributed and includes patients that meet the following criteria: 

- Aged 65 or over
- Enrolled in Original Medicare for 12 months prior to admission
- Consistent or known vital status with clear demographic (age and gender data)
- **Not** discharged against medical advice
- **Not** transferred from another acute care facility
- **Not** enrolled in Medicare hospice program any time in the 12 months prior to admission
- **Many more special cases** ask us about it after...

### Why the 30-day timeframe? 
The measures assess mortality within a 30-day period from the date of the index admission.  This is so because, older adult patients are more vulnerable to adverse health outcomes during this timeframe. Thirty days is what has been defined as the clincally meaningful period for hospitals to colloborate with their communities in order to reduce mortality.  

### What is the Death Score? 
Their approach utilizes a hierachial logistic regression model in which patients are nested within  hospitals.  This nesting allows the statistician to simulataneously model data at the patient and hospital levels and account for variance in patient outcomes within and between hospitals. 

**Patient Level**
Models the log-odds of mortality within 30-days of index admission using age,sex, comorbities, and the hospital specific effect. 

**Hospital Level** 
Models the hospital specific effect, which represents the underlying risk of mortality at a given hospital, after accounting for patient risk. Hospital specific effects are given a distribution to account for the nesting of patients within hospitals... In other words we can't assume that the patients are independent. 

**Death Score**
Ratio of "Predicted"/"Expected" x National Mortality Rate

**Expected**
"Expected" mortality for each hospital is estimated for a given group of patients and using the average hospital-specific effect (average across all hospital specific effects in the sample).

**Predicted**
"Predicted" mortality for each hospital is estimated by taking the same group of patients and using that hospital-specific effect. 


# Data Source
Readmissions and Deaths: 30-Day Readmission and Death Measures

**Reporting Cycle**: 7/01/2012 \- 6/30/2015 AND 7/01/2014 \- 6/30/2015

## How? 
Data is collected from billing codes submitted to Medicare by healthcare providers .

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
eath measures are adjusted fro patient characteristics(age, sex, past medical history, etc...) that would make death more likely. 
