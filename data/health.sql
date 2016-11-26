/*
From command line: cat dump.sql | sqlite3 health.db 
*/


/* 

Create table for Timely and Effective Care.

 */

CREATE TABLE timelycare(
	provider_ID CHAR(8),
	hospital_name CHAR(52),
	address CHAR(46),
	city CHAR(22),
	state CHAR(4),
	zip CHAR(7),
	county CHAR(22),
	phone_number CHAR(12),
	condition CHAR(37),
	measure_id CHAR(24),
	measure_name CHAR(137),
	score CHAR(44),
	sample CHAR(15),
	footnote CHAR(181),
	measure_start_date CHAR(12),
	measure_end_date CHAR(12)
);

/*

Create table for Readmissions and Deaths

*/

CREATE TABLE readDeath(
	provider_ID CHAR(8),
	hospital_name CHAR(52),
	address CHAR(41),
	city CHAR(21),
	state CHAR(4),
	zip CHAR(7),
	county CHAR(22),
	phone_number CHAR(12),
	measure_name CHAR(79),
	measure_id CHAR(20),
	national_comp CHAR(37),
	denominator CHAR(15),
	score CHAR(15),
	lower_est CHAR(15),
	higher_est CHAR(15),
	footnote CHAR(147), 
	measure_start_date CHAR(12),
	measure_end_date CHAR(12)
);


/* 

Create table for outpaitent volume

*/

CREATE TABLE volume(
	provider_ID CHAR(8),
	hospital_name CHAR(67),
	measure_id CHAR(7),
	gastrointestinal CHAR(15),
	eye CHAR(15),
	nervous_system CHAR(15),
	musculoskeletal CHAR(15),
	skin CHAR(15),
	genitourinary CHAR(15),
	cardiovascular CHAR(15),
	respiratory CHAR(15),
	other CHAR(15),
	footnote CHAR(3),
	start_date CHAR(12),
	end_date CHAR(12)
);

/* 

Identify what separation our data is using and then import

*/

.separator ","
.import readDeath.csv readDeath
.import timely.csv timelycare
.import volume.csv volume

/*
Export a CSV containing the outpaitent volume for 2014
*/
.header on
.mode csv
.output dataframe.csv
SELECT * from readDeath JOIN volume USING (provider_ID);
.output stdout


