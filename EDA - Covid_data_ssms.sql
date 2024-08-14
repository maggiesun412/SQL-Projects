/*

-- Exploratory Data Analysis on Covid data

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

SELECT *
FROM CovidData..CovidDeaths
WHERE continent is not null
ORDER BY 3, 4

UPDATE CovidDeaths
SET continent = NULL
WHERE continent = '';

--SELECT *
--FROM CovidData..CovidVaccinations
--ORDER BY 3, 4

-- SELECT Data that to be used

SELECT location, date, total_cases, new_cases, population
FROM CovidData..CovidDeaths
ORDER BY 1, 2



-- Comparing Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country


SELECT 
    location, date, total_cases, total_deaths, 
    CASE 
        WHEN total_cases = 0 THEN 0 
        ELSE CAST(total_deaths AS FLOAT) / total_cases * 100
    END AS DeathPercentage
FROM 
    CovidData..CovidDeaths
WHERE location like '%states%'
ORDER BY location, date;



-- Comparing Total Cases vs Population
-- Shows what percentage of population got Covid


SELECT 
    location, date, total_cases, population,
    CASE 
        WHEN total_cases = 0 THEN 0 
        ELSE CAST(total_cases AS FLOAT) / population * 100
    END AS PercentPopulationInfected
FROM 
    CovidData..CovidDeaths
ORDER BY location, date;


-- Comparing Countries with highest infection rate vs Population


SELECT 
    location, population, MAX(total_cases) AS HighestInfectionCount,
	MAX(
		CASE 
        WHEN total_cases = 0 THEN 0
        ELSE CAST(total_cases AS FLOAT) / population * 100
    END) AS PercentPopulationInfected
FROM 
    CovidData..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC



SELECT 
    location, population, date, MAX(total_cases) AS HighestInfectionCount,
	MAX(
		CASE 
        WHEN total_cases = 0 THEN 0
        ELSE CAST(total_cases AS FLOAT) / population * 100
    END) AS PercentPopulationInfected
FROM 
    CovidData..CovidDeaths
GROUP BY location, population, date
ORDER BY PercentPopulationInfected DESC



-- Showing Countries with highest death count per Population


SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM CovidData..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC



-- Showing the Continent with the highest death count


SELECT continent, SUM(CAST(total_deaths as bigint)) AS TotalDeathCount
FROM CovidData..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC



-- Global numbers


SELECT SUM(CAST(new_cases AS bigint)) AS TotalNewCases, SUM(CAST(new_deaths AS bigint)) AS TotalNewDeaths,
     CASE 
        WHEN SUM(CAST(new_cases AS BIGINT)) = 0 THEN 0 
        ELSE (SUM(CAST(new_deaths AS BIGINT)) * 1.0 / SUM(CAST(new_cases AS BIGINT))) * 100 
    END AS DeathPercentage
FROM CovidData..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;


-- Global numbers by continent


SELECT location, SUM(CAST(new_deaths as bigint)) AS TotalDeathCount
FROM CovidData..CovidDeaths
WHERE continent is null
AND location not in ('World', 'European Union', 'International', 'High income', 'Upper middle income', 'Lower middle income', 'Low income')
GROUP BY location
ORDER BY TotalDeathCount DESC


-- Comparing Total Population vs Vaccinations


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, 
	dea.date) AS RollingPeopleVaccinated
FROM CovidData..CovidDeaths dea
JOIN CovidData..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


-- Looking at Rolling total of people vaccinated

WITH PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, 
	dea.date) AS RollingPeopleVaccinated
FROM CovidData..CovidDeaths dea
JOIN CovidData..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *,
CASE 
        WHEN RollingPeopleVaccinated = 0 THEN 0 
        ELSE (RollingPeopleVaccinated * 1.0 / population) * 100 
		END AS RollingPeopleVaccinatedPercentage
FROM PopVsVac



-- Temp Table for Percent of Population vaccinated
 

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, 
	dea.date) AS RollingPeopleVaccinated
FROM CovidData..CovidDeaths dea
JOIN CovidData..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null

SELECT *, 
CASE 
        WHEN RollingPeopleVaccinated = 0 THEN 0 
        ELSE (RollingPeopleVaccinated * 1.0 / population) * 100 
		END
FROM #PercentPopulationVaccinated



-- View of percent vaccinated to store data  visualizations


Create View PercentVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, 
	dea.date) AS RollingPeopleVaccinated
FROM CovidData..CovidDeaths dea
JOIN CovidData..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null

SELECT *
FROM PercentVaccinated
