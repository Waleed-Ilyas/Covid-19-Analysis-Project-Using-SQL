-- Table for Covid-19 Cases
CREATE TABLE covid_cases (
    Date DATE,
    Country VARCHAR(50),
    Cases INTEGER
);

-- Table for Covid-19 Deaths
CREATE TABLE covid_deaths (
    Date DATE,
    Country VARCHAR(50),
    Deaths INTEGER
);

-- Table for Covid-19 Vaccinations
CREATE TABLE covid_vaccinations (
    Date DATE,
    Country VARCHAR(50),
    Vaccinations INTEGER
);

-- Table for Covid-19 Testing
CREATE TABLE covid_testing (
    Date DATE,
    Country VARCHAR(50),
    Tests INTEGER
);

-- Table for Covid-19 Hospitalizations
CREATE TABLE covid_hospitalizations (
    Date DATE,
    Country VARCHAR(50),
    Hospitalizations INTEGER
);


---------------------------------- Easy Level Queries ---------------------------

-- 1. What is the total number of Covid-19 cases reported in 2020?

SELECT SUM(Cases) AS Total_Cases_2020
FROM covid_cases
WHERE Date BETWEEN '2020-01-01' AND '2020-12-31';


-- 2. Which country had the highest number of Covid-19 cases on a single day?

SELECT Country, Date, MAX(Cases) AS Max_Cases
FROM covid_cases
GROUP BY Country, Date
ORDER BY Max_Cases DESC
LIMIT 1;


	-- 3. What is the average number of deaths per day in the month of April 2021?

SELECT AVG(Deaths) AS Avg_Deaths_April_2021
FROM covid_deaths
WHERE Date BETWEEN '2021-04-01' AND '2021-04-30';


-- 4. How many countries reported more than 1,000,000 cases by December 2021?

SELECT COUNT(DISTINCT Country) AS Countries_With_1M_Cases
FROM (
    SELECT Country, SUM(Cases) AS Total_Cases
    FROM covid_cases
    WHERE Date <= '2021-12-31'
    GROUP BY Country
    HAVING SUM(Cases) > 1000000
) AS Subquery;


-- 5. Which country had the highest vaccination rate by the end of 2021?

SELECT Country, SUM(Vaccinations) AS Total_Vaccinations
FROM covid_vaccinations
WHERE Date <= '2021-12-31'
GROUP BY Country
ORDER BY Total_Vaccinations DESC
LIMIT 1;


-------------------------- Intermediate Level Queries ------------------------

-- 6. Calculate the average number of tests conducted per day across all countries in 2021.

SELECT AVG(Tests) AS Avg_Tests_Per_Day
FROM covid_testing
WHERE Date BETWEEN '2021-01-01' AND '2021-12-31';


-- 7. Identify the top 5 countries with the highest hospitalization rates in 2020.

SELECT Country, SUM(Hospitalizations) AS Total_Hospitalizations
FROM covid_hospitalizations
WHERE Date BETWEEN '2020-01-01' AND '2020-12-31'
GROUP BY Country
ORDER BY Total_Hospitalizations DESC
LIMIT 5;


-- 8. Find the country with the lowest death rate among those with more than 500,000 cases.

SELECT cc.Country, SUM(cd.Deaths) / SUM(cc.Cases) AS Death_Rate
FROM covid_cases cc
JOIN covid_deaths cd ON cc.Country = cd.Country AND cc.Date = cd.Date
GROUP BY cc.Country
HAVING SUM(cc.Cases) > 500000
ORDER BY Death_Rate ASC
LIMIT 1;



-------------------------------------- Advanced Level Queries ----------------------------

-- 9. Analyze the correlation between the number of tests conducted and the number of positive cases in 2021.

SELECT 
    CORR(Tests, Cases) AS Correlation
FROM 
    covid_testing ct
JOIN 
    covid_cases cc ON ct.Country = cc.Country AND ct.Date = cc.Date
WHERE 
    ct.Date BETWEEN '2021-01-01' AND '2021-12-31';


-- 10. Determine the month with the highest increase in vaccination rates compared to the previous month for each country.

SELECT Country, Month, MAX(Vaccination_Change) AS Max_Vaccination_Increase
FROM (
    SELECT 
        Country, 
        DATE_TRUNC('month', Date) AS Month, 
        SUM(Vaccinations) - LAG(SUM(Vaccinations)) 
		OVER (PARTITION BY Country ORDER BY DATE_TRUNC('month', Date))
		AS Vaccination_Change
    FROM 
        covid_vaccinations
    GROUP BY 
        Country, Month
) AS Subquery
GROUP BY Country, Month
ORDER BY Max_Vaccination_Increase DESC;


-- 11. Analyze the relationship between Covid-19 testing rates and case detection rates. Identify the top 5 countries with the highest ratio of detected cases to tests conducted, indicating possible underreporting or low testing efficiency.

WITH Case_Test_Ratio AS (
    SELECT 
ct.Country, SUM(ct.Cases) AS Total_Cases, SUM(tt.Tests) AS Total_Tests,
CASE WHEN SUM(tt.Tests) > 0 THEN SUM(ct.Cases) * 1.0 / SUM(tt.Tests)
ELSE 0 END AS Case_Test_Ratio
FROM covid_cases ct JOIN 
covid_testing tt ON ct.Country = tt.Country AND ct.Date = tt.Date
GROUP BY ct.Country)
SELECT 
    Country, Total_Cases, Total_Tests, Case_Test_Ratio
FROM Case_Test_Ratio
ORDER BY Case_Test_Ratio DESC
LIMIT 5;







 









