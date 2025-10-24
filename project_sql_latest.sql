
SELECT * FROM public.hr_data2

CREATE TABLE EducationLevel (
  Education_ID SERIAL PRIMARY KEY,
  Education_Name TEXT UNIQUE NOT NULL
);
CREATE TABLE Department (
  Department_ID SERIAL PRIMARY KEY,
  Department_Name TEXT UNIQUE NOT NULL
);

CREATE TABLE JobRole (
  JobRole_ID SERIAL PRIMARY KEY,
  JobRole_Name TEXT UNIQUE NOT NULL
);

CREATE TABLE Gender (
  Gender_ID SERIAL PRIMARY KEY,
  Gender_Name TEXT UNIQUE NOT NULL
);

CREATE TABLE MaritalStatus (
  MaritalStatus_ID SERIAL PRIMARY KEY,
  MaritalStatus_Name TEXT UNIQUE NOT NULL
);



INSERT INTO EducationLevel (Education_Name)
SELECT DISTINCT Education_Level FROM hr_data2 WHERE Education_Level IS NOT NULL;

INSERT INTO Department (Department_Name)
SELECT DISTINCT Department FROM hr_data2 WHERE Department IS NOT NULL;

INSERT INTO JobRole (JobRole_Name)
SELECT DISTINCT Job_Role FROM hr_data2 WHERE Job_Role IS NOT NULL;

INSERT INTO Gender (Gender_Name)
SELECT DISTINCT Gender FROM hr_data2 WHERE Gender IS NOT NULL;

INSERT INTO MaritalStatus (MaritalStatus_Name)
SELECT DISTINCT Marital_Status FROM hr_data2 WHERE Marital_Status IS NOT NULL;


CREATE TABLE FactHRData (
  Employee_ID INT PRIMARY KEY,
  Education_ID INT,
  Department_ID INT,
  JobRole_ID INT,
  Gender_ID INT,
  MaritalStatus_ID INT,
  Age INT,
  Monthly_Income INT,
  Years_At_Company INT,
  Years_In_Current_Role INT,
  Job_Satisfaction INT,
  Performance_Rating INT,
  Work_Life_Balance INT,
  Training_Hours_Last_Year INT,
  Last_Promotion_Years_Ago INT,
  Distance_From_Home INT,
  Overtime TEXT,
  Number_Of_Companies_Worked INT,
  FOREIGN KEY (Education_ID) REFERENCES EducationLevel(Education_ID),
  FOREIGN KEY (Department_ID) REFERENCES Department(Department_ID),
  FOREIGN KEY (JobRole_ID) REFERENCES JobRole(JobRole_ID),
  FOREIGN KEY (Gender_ID) REFERENCES Gender(Gender_ID),
  FOREIGN KEY (MaritalStatus_ID) REFERENCES MaritalStatus(MaritalStatus_ID)
);

INSERT INTO FactHRData (
  Employee_ID,
  Education_ID,
  Department_ID,
  JobRole_ID,
  Gender_ID,
  MaritalStatus_ID,
  Age,
  Monthly_Income,
  Years_At_Company,
  Years_In_Current_Role,
  Job_Satisfaction,
  Performance_Rating,
  Work_Life_Balance,
  Training_Hours_Last_Year,
  Last_Promotion_Years_Ago,
  Distance_From_Home,
  Overtime,
  Number_Of_Companies_Worked
)
SELECT DISTINCT ON (h.Employee_ID)
  h.Employee_ID,
  e.Education_ID,
  d.Department_ID,
  j.JobRole_ID,
  g.Gender_ID,
  m.MaritalStatus_ID,
  h.Age,
  h.Monthly_Income,
  h.Years_At_Company,
  h.Years_In_Current_Role,
  h.Job_Satisfaction,
  h.Performance_Rating,
  h.Work_Life_Balance,
  h.Training_Hours_Last_Year,
  h.Last_Promotion_Years_Ago,
  h.Distance_From_Home,
  h.Overtime,
  h.Number_Of_Companies_Worked
FROM hr_data2 h
LEFT JOIN EducationLevel e ON h.Education_Level = e.Education_Name
LEFT JOIN Department d ON h.Department = d.Department_Name
LEFT JOIN JobRole j ON h.Job_Role = j.JobRole_Name
LEFT JOIN Gender g ON h.Gender = g.Gender_Name
LEFT JOIN MaritalStatus m ON h.Marital_Status = m.MaritalStatus_Name
ORDER BY h.Employee_ID;

SELECT job_role,
ROUND(AVG(monthly_income),2)as average_salary
FROM hr_data2
GROUP BY job_role
ORDER BY average_salary DESC;

select * from FactHRData

WITH avg_salary AS (
    SELECT AVG(monthly_income) AS overall_avg_salary
    FROM hr_data2
)
SELECT 
    employee_id,
    job_role,
    department,
    performance_rating,
    monthly_income
FROM hr_data2, avg_salary
WHERE performance_rating >= 3
  AND monthly_income < overall_avg_salary
ORDER BY performance_rating DESC, monthly_income ASC;

SELECT 
    d.department_name AS Department,
    ROUND(AVG(f.monthly_income), 2) AS Avg_Salary,
    ROUND(AVG(f.job_satisfaction), 2) AS Avg_Job_Satisfaction,
    ROUND(AVG(f.years_at_company), 2) AS Avg_Tenure,
    COUNT(f.employee_id) AS Total_Employees
FROM FactHRData f
JOIN Department d ON f.department_id = d.department_id
GROUP BY d.department_name
ORDER BY Avg_Salary DESC;

SELECT
employee_id,years_at_company,performance_rating
from FactHRData
where years_at_company >5 AND performance_rating <4 ;

SELECT 
    d.department_name AS Department,
    j.jobrole_name AS Job_Role,
    f.performance_rating AS Performance_Rating,
    ROUND(AVG(f.monthly_income), 2) AS Avg_Salary,
    COUNT(f.employee_id) AS Employee_Count
FROM FactHRData f
JOIN Department d ON f.department_id = d.department_id
JOIN JobRole j ON f.jobrole_id = j.jobrole_id
GROUP BY d.department_name, j.jobrole_name, f.performance_rating
ORDER BY f.performance_rating DESC, Avg_Salary ASC;

CREATE VIEW view_attrition_1 AS
SELECT employee_id,
attrition,
job_satisfaction
FROM hr_data2
WHERE attrition='Yes';
 select * from view_attrition_1;

 SELECT
 employee_id,
 performance_rating,
 years_at_company,
 last_promotion_years_ago
 from hr_data2
 where  last_promotion_years_ago>=1
 order by last_promotion_years_ago desc;
 
 SELECT 
  employee_id,
  job_satisfaction,
  overtime
  FROM hr_data2
  WHERE job_satisfaction < 2 AND overtime ='Yes'

  SELECT 
    Employee_ID,
     job_role,
    Years_At_Company,
    Last_Promotion_Years_Ago,
    Job_Satisfaction,
    Performance_Rating
FROM hr_data2
WHERE Last_Promotion_Years_Ago <= 1
ORDER BY Job_Satisfaction DESC, Performance_Rating DESC;

SELECT 
    el.Education_ID,
    el.Education_Name AS Education_Level,
    ROUND(AVG(f.Performance_Rating), 2) AS Avg_Performance,
    ROUND(AVG(f.Years_At_Company), 2) AS Avg_Years_At_Company,
    ROUND(AVG(f.Monthly_Income), 2) AS Avg_Income,
    ROUND(AVG(f.Last_Promotion_Years_Ago), 2) AS Avg_Years_Since_Promotion
FROM FactHRData f
JOIN educationLevel el ON f.Education_ID = el.Education_ID
GROUP BY el.Education_ID,el.Education_Name
ORDER BY Avg_Performance DESC;

SELECT 
    m.MaritalStatus_Name AS Marital_Status,
    ROUND(AVG(f.Work_Life_Balance), 2) AS Avg_Work_Life_Balance,
    ROUND(AVG(f.Job_Satisfaction), 2) AS Avg_Job_Satisfaction,
    COUNT(f.Employee_ID) AS Employee_Count
FROM FactHRData f
JOIN MaritalStatus m ON f.MaritalStatus_ID = m.MaritalStatus_ID
GROUP BY m.MaritalStatus_Name
ORDER BY Avg_Work_Life_Balance DESC;
SELECT 
    CASE 
        WHEN Training_Hours_Last_Year < 10 THEN 'Low (0-9 hrs)'
        WHEN Training_Hours_Last_Year BETWEEN 10 AND 30 THEN 'Moderate (10-30 hrs)'
        WHEN Training_Hours_Last_Year BETWEEN 31 AND 50 THEN 'High (31-50 hrs)'
        ELSE 'Very High (50+ hrs)'
    END AS Training_Level,
    ROUND(AVG(Job_Satisfaction), 2) AS Avg_Satisfaction,
    ROUND(AVG(Performance_Rating), 2) AS Avg_Performance,
    COUNT(Employee_ID) AS Employee_Count
FROM FactHRData
GROUP BY Training_Level
ORDER BY Avg_Performance DESC;


  


  
 


