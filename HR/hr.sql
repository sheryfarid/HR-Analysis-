create database project
use project
select *  from hr
-- we create new table for data cleaning if any issue in our table so we have our original data will be safe. 
create table hr2 like hr
insert  into hr2  select * from hr
select *  from hr2

-- change column name
ALTER TABLE hr2 change ï»¿id emp_id varchar(20)
-- change birthdate and hire_date format into--> '%m/%d/%Y'
UPDATE hr2
SET birthdate = CASE
    WHEN birthdate LIKE '%/%/%' THEN STR_TO_DATE(birthdate, '%m/%d/%Y')
    WHEN birthdate LIKE '%-%-%' THEN STR_TO_DATE(birthdate, '%m-%d-%y')
END;
-- CHANGE DATA TYPE OF BIRTHDATE  and hire_date
select * from hr2
ALTER TABLE hr2 modify birthdate DATE
describe hr2
SELECT* FROM hr2

-- update termdate ,we have data like this '%Y-%m-%d %H:%i:%s' and also null so we use substring_index to extract 
-- date and utc from term date and null cell fill with '0000-00-00' 
UPDATE hr2
SET termdate = CASE
    WHEN termdate IS NOT NULL AND termdate != '' THEN SUBSTRING_INDEX(termdate, ' ', 1)
    WHEN termdate IS NULL OR termdate = '' THEN '0000-00-00'
END;
--  MODIFY column data type
-- we use this to  modify the SQL mode to allow invalid dates like '0000-00-00'
SET sql_mode = '';
alter table hr2 modify column termdate date;
-- Error Code: 1292. Incorrect date value: '0000-00-00' for column 'termdate' at row 1	0.063 sec

-- ADD COLUMN
alter table hr2 add column age int;
update hr2
set  age = timestampdiff(year,birthdate , curdate() )

-- what is the gender breakdown of employees in company? 
select gender , count(*) as count from hr2 where age >= 18 and termdate = "0000-00-00" 
group by gender

select * from hr2
-- what is the race breakdown of employees in company? 
select  race , count(*)  as count from hr2  where age >= 18 and termdate = "0000-00-00" group by race order by 2 desc

-- what is the age distribution in company?
SELECT 
    CASE
        WHEN age >= 21 AND age <= 24 THEN '21-24'
        WHEN age >= 25 AND age <= 34 THEN '25-34'
        WHEN age >= 35 AND age <= 44 THEN '35-44'
        WHEN age >= 45 AND age <= 54 THEN '45-54'
        WHEN age >= 55 AND age <= 58 THEN '55-58'
    END AS age_group,gender,
    COUNT(*) AS num_employees
FROM hr2
WHERE age >= 21 AND termdate = '0000-00-00'
GROUP BY age_group ,gender
ORDER BY age_group,gender

-- 4. How many employees work at headquarters versus remote locations?
select location ,count(*) from hr2 where age>=21 and  termdate ='0000-00-00' group by location

-- 5. What is the average length of employment for employees who have been terminated?
SELECT 
    round(AVG(DATEDIFF(termdate, hire_date))/365,0) AS avg_length_of_employment_in_years
FROM hr2
WHERE termdate <= curdate() and termdate != '0000-00-00'  


-- 6. How does the gender distribution vary across departments ?
select department , gender,count(*) as count from hr2 
where age >=21 and termdate = "0000-00-00"
group by department ,  gender
 order by department 

-- 7. What is the distribution of job titles across the company?
select jobtitle ,count(*) as count from hr2 where termdate = "0000-00-00"
group by jobtitle 
order by jobtitle desc

-- 8. Which department has the highest turnover rate?
select department, total_count , terminated_count ,terminated_count/total_count as termination_rate 
from
(select department , count(*) as total_count  ,
sum(case when termdate <> '0000-00-00' and termdate <= curdate() then 1 else 0 end ) as terminated_count
from hr2 
where age >=21 
group by department) as subquery 
order by termination_rate desc

-- What is the distribution of employees across locations by  state?
SELECT location_state , COUNT(*) AS employee_count
FROM hr2
where age>=21 and termdate = '0000-00-00'
GROUP BY location_state
ORDER BY  2 desc;

-- 10. How has the company's employee count changed over time based on hire_date and termdates?
select year , hires , terminate , (hires - terminate) as net_change ,
ROUND(((hires - terminate) / hires) * 100, 2) AS turnover_percentage
from ( 															
select year(hire_date) as year, 
sum(case when termdate != '0000-00-00' and termdate <= curdate() then 1 else 0 end ) as terminate,
count(*) as hires from hr2
where age >=21 
group by year(hire_date) ) as yearly_stat
order by year asc;

-- 11. What is the tenure distribution for each department?
select department , round(AVG(DATEDIFF(termdate, hire_date))/365,0) as avg_tenure from hr2
where termdate <= curdate() and termdate <> '0000-00-00' and age >=21
group by department



