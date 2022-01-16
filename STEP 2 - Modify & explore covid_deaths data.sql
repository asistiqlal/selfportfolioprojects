-- Modify the data
UPDATE covid_deaths SET continent = 'Africa' WHERE location = 'Africa'
UPDATE covid_deaths SET continent = 'Asia' WHERE location = 'Asia'
UPDATE covid_deaths SET continent = 'Europe' WHERE location = 'Europe'
UPDATE covid_deaths SET continent = 'Oceania' WHERE location = 'Oceania'
UPDATE covid_deaths SET continent = 'North America' WHERE location = 'North America'
UPDATE covid_deaths SET continent = 'South America' WHERE location = 'South America'
UPDATE covid_deaths SET continent = 'European Union' WHERE location = 'European Union'
DELETE FROM covid_deaths WHERE location = 'High income';
DELETE FROM covid_deaths WHERE location = 'International';
DELETE FROM covid_deaths WHERE location = 'Low income';
DELETE FROM covid_deaths WHERE location = 'Lower middle income';
DELETE FROM covid_deaths WHERE location = 'Upper middle income';
DELETE FROM covid_deaths WHERE location = 'World';

-- Quick overview
SELECT location, death_date, total_cases, new_cases, total_deaths, population
FROM covid_deaths
ORDER BY 1,2;

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT location, death_date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
FROM covid_deaths
WHERE location LIKE 'Indonesia'
ORDER BY 1,2;

-- Looking at Total Cases vs Populations
-- Shows what percentage that got Covid 
SELECT location, death_date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
FROM covid_deaths
WHERE location LIKE 'Indonesia'
ORDER BY 1,2;

-- Looking at countries with highest infection compared to population
SELECT location, population, MAX(total_cases) as HighestInfection, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY 1, 2
ORDER BY 4 DESC;

-- Showing continent with highest death count per population
SELECT continent, MAX(CAST(total_deaths as INT)) as TotalDeathCount
FROM covid_deaths
GROUP BY 1
ORDER BY 2 DESC;

-- GLOBAL NUMBERS
-- Showing total new deaths compared to total new deaths per date globally
SELECT death_date,
	SUM(new_cases) AS TotalCases,
	SUM(CAST(new_deaths as INT)) AS TotalDeaths,
	(SUM(CAST(new_deaths as INT))/SUM(new_cases))*100 AS DeathPercentage
FROM covid_deaths
GROUP BY 1
ORDER BY 1,2;