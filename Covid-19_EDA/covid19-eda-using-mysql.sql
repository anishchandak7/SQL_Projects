-- 1. Create a database. 
CREATE DATABASE projectportfolio;

-- 2. Change the database. 
USE projectportfolio;

-- 3. Load the data in the database in the form of tables using python script first.
-- 4. Check the number of rows in tables. 
SELECT COUNT(*) FROM coviddeaths;
SELECT COUNT(*) FROM covidvaccinations;

-- Display first 20 rows from both tables.
SELECT * FROM coviddeaths LIMIT 20;
SELECT * FROM covidvaccinations LIMIT 20;

-- Display coviddeaths table columns
SHOW FIELDS FROM coviddeaths;

-- Fix the date column data-type.
-- 1. Add a new column
ALTER TABLE coviddeaths ADD formatted_date DATE;
-- 2. Disable the safe update mode to update the table.
SET SQL_SAFE_UPDATES=0;
-- 3. Update the table.
-- UPDATE coviddeaths SET formatted_date=str_to_date(date, '%d-%m-%Y');
-- 4. Reset the safe update mode.
SET SQL_SAFE_UPDATES=1;

-- Initial data analysis
SELECT location, formatted_date, total_cases, new_cases, total_deaths, population
FROM coviddeaths 
WHERE continent <> ""
ORDER BY location, formatted_date;

-- Total Deaths VS Total Cases 
-- calculate the percentage of total deaths happened since covid begin for each country.
SELECT location, formatted_date, total_cases, total_deaths, (CAST(total_deaths AS UNSIGNED)/CAST(total_cases AS UNSIGNED)) * 100 AS 'DeathPercentage'
FROM coviddeaths
WHERE continent <> ""
ORDER BY location, formatted_date;

-- Total cases VS Population
-- calculate what percentage of population are getting infected for all country.
SELECT location, formatted_date, total_cases, population, (CAST(total_cases AS UNSIGNED)/CAST(population AS UNSIGNED)) * 100 AS 'CasesPercentage'
FROM coviddeaths
WHERE continent <> ""
ORDER BY location, formatted_date;

-- Countries which are highly infected compared to population
SELECT location, population, MAX(CAST(total_cases AS UNSIGNED)) AS 'HighestCasesCount',MAX((CAST(total_cases AS UNSIGNED)/CAST(population AS UNSIGNED)) * 100) AS 'PercentagePopulationInfected'
FROM coviddeaths
WHERE continent <> ""
GROUP BY location
ORDER BY PercentagePopulationInfected DESC;

-- Countries with highest death count per population
SELECT location, MAX(CAST(total_deaths AS UNSIGNED)) AS 'HighestDeathsCount'
FROM coviddeaths
WHERE continent <> ""
GROUP BY location
ORDER BY HighestDeathsCount DESC;

-- CONTINENT WISE ANALYSIS
-- highest death count
SELECT continent, MAX(CAST(total_deaths AS UNSIGNED)) AS 'HighestDeathsCount'
FROM coviddeaths
WHERE continent <> ""
GROUP BY continent
ORDER BY HighestDeathsCount DESC;

-- GLOBAL LEVEL ANALYSIS
SELECT SUM(CAST(new_cases AS UNSIGNED)) 'total_cases', SUM(CAST(new_deaths AS UNSIGNED)) 'total_deaths', (SUM(CAST(new_deaths AS UNSIGNED))/SUM(CAST(new_cases AS UNSIGNED)))*100 'DeathPercentage'
FROM coviddeaths
WHERE continent <> "";
-- GROUP BY formatted_date
-- ORDER BY 1 ;


-- Display covidvaccinations data
SELECT * FROM covidvaccinations;

SHOW FIELDS FROM covidvaccinations;

-- Fix the date column data-type in covidvaccinations table.
-- 1. Add a new column
ALTER TABLE covidvaccinations ADD formatted_date DATE;
-- 2. Disable the safe update mode to update the table.
SET SQL_SAFE_UPDATES=0;
-- 3. Update the table.
UPDATE covidvaccinations SET formatted_date=str_to_date(date, '%d-%m-%Y');
-- 4. Reset the safe update mode.
SET SQL_SAFE_UPDATES=1;

SELECT cd.continent, cd.location, cd.formatted_date, cd.population, cv.new_vaccinations, SUM(CAST(cv.new_vaccinations AS UNSIGNED)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.formatted_date) 'total_vaccinations' 
FROM coviddeaths cd JOIN covidvaccinations cv
ON cd.location=cv.location AND cd.formatted_date=cv.formatted_date
WHERE cd.continent <> ""
ORDER BY 2,3;

WITH PopVSVac (continent, location, formatted_date, population, new_vaccinations, total_vaccinations)
AS (
SELECT cd.continent, cd.location, cd.formatted_date, cd.population, cv.new_vaccinations, SUM(CAST(cv.new_vaccinations AS UNSIGNED)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.formatted_date) 'total_vaccinations' 
FROM coviddeaths cd JOIN covidvaccinations cv
ON cd.location=cv.location AND cd.formatted_date=cv.formatted_date
WHERE cd.continent <> ""
ORDER BY 2,3
) SELECT *, (total_vaccinations/CAST(population AS UNSIGNED)) * 100
FROM PopVSVac;

CREATE VIEW PopulationVaccinated AS
SELECT cd.continent, cd.location, cd.formatted_date, cd.population, cv.new_vaccinations, SUM(CAST(cv.new_vaccinations AS UNSIGNED)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.formatted_date) 'total_vaccinations' 
FROM coviddeaths cd JOIN covidvaccinations cv
ON cd.location=cv.location AND cd.formatted_date=cv.formatted_date
WHERE cd.continent <> ""
ORDER BY 2,3;

SELECT * FROM PopulationVaccinated;