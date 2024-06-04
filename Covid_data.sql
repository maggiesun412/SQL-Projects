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

-- SELECT Data that we are going to be using

SELECT location, date, total_cases, new_cases, population
FROM CovidData..CovidDeaths
ORDER BY 1, 2


ALTER TABLE CovidDeaths ALTER COLUMN total_deaths int
ALTER TABLE CovidDeaths ALTER COLUMN total_cases int
ALTER TABLE CovidDeaths ALTER COLUMN population bigint
ALTER TABLE CovidDeaths ALTER COLUMN new_cases int
ALTER TABLE CovidDeaths ALTER COLUMN new_cases_smoothed float
ALTER TABLE CovidDeaths ALTER COLUMN new_deaths bigint
ALTER TABLE CovidDeaths ALTER COLUMN new_deaths_smoothed float
ALTER TABLE CovidDeaths ALTER COLUMN total_cases_per_million float
ALTER TABLE CovidDeaths ALTER COLUMN new_cases_per_million float
ALTER TABLE CovidDeaths ALTER COLUMN new_cases_smoothed_per_million float
ALTER TABLE CovidDeaths ALTER COLUMN total_deaths_per_million float
ALTER TABLE CovidDeaths ALTER COLUMN new_deaths_per_million float
ALTER TABLE CovidDeaths ALTER COLUMN new_deaths_smoothed_per_million float
ALTER TABLE CovidDeaths ALTER COLUMN reproduction_rate float
ALTER TABLE CovidDeaths ALTER COLUMN icu_patients int
ALTER TABLE CovidDeaths ALTER COLUMN icu_patients_per_million float
ALTER TABLE CovidDeaths ALTER COLUMN hosp_patients int
ALTER TABLE CovidDeaths ALTER COLUMN hosp_patients_per_million float
ALTER TABLE CovidDeaths ALTER COLUMN weekly_icu_admissions int
ALTER TABLE CovidDeaths ALTER COLUMN weekly_icu_admissions_per_million float
ALTER TABLE CovidDeaths ALTER COLUMN weekly_hosp_admissions int
ALTER TABLE CovidDeaths ALTER COLUMN weekly_hosp_admissions_per_million float
ALTER TABLE CovidDeaths ALTER COLUMN total_tests bigint

ALTER TABLE CovidVaccinations ALTER COLUMN new_tests int
ALTER TABLE CovidVaccinations ALTER COLUMN total_tests_per_thousand float
ALTER TABLE CovidVaccinations ALTER COLUMN new_tests_per_thousand float
ALTER TABLE CovidVaccinations ALTER COLUMN new_tests_smoothed int
ALTER TABLE CovidVaccinations ALTER COLUMN new_tests_smoothed_per_thousand float
ALTER TABLE CovidVaccinations ALTER COLUMN positive_rate float
ALTER TABLE CovidVaccinations ALTER COLUMN tests_per_case float
ALTER TABLE CovidVaccinations ALTER COLUMN total_vaccinations bigint
ALTER TABLE CovidVaccinations ALTER COLUMN people_vaccinated bigint
ALTER TABLE CovidVaccinations ALTER COLUMN people_fully_vaccinated bigint
ALTER TABLE CovidVaccinations ALTER COLUMN total_boosters bigint
ALTER TABLE CovidVaccinations ALTER COLUMN new_vaccinations int
ALTER TABLE CovidVaccinations ALTER COLUMN new_vaccinations_smoothed int
ALTER TABLE CovidVaccinations ALTER COLUMN total_vaccinations_per_hundred float
ALTER TABLE CovidVaccinations ALTER COLUMN people_vaccinated_per_hundred float
ALTER TABLE CovidVaccinations ALTER COLUMN people_fully_vaccinated_per_hundred float
ALTER TABLE CovidVaccinations ALTER COLUMN total_boosters_per_hundred float
ALTER TABLE CovidVaccinations ALTER COLUMN new_vaccinations_smoothed_per_million int
ALTER TABLE CovidVaccinations ALTER COLUMN new_people_vaccinated_smoothed int
ALTER TABLE CovidVaccinations ALTER COLUMN new_people_vaccinated_smoothed_per_hundred float
ALTER TABLE CovidVaccinations ALTER COLUMN stringency_index float
ALTER TABLE CovidVaccinations ALTER COLUMN population_density float
ALTER TABLE CovidVaccinations ALTER COLUMN median_age float
ALTER TABLE CovidVaccinations ALTER COLUMN aged_65_older float
ALTER TABLE CovidVaccinations ALTER COLUMN aged_70_older float
ALTER TABLE CovidVaccinations ALTER COLUMN gdp_per_capita float
ALTER TABLE CovidVaccinations ALTER COLUMN extreme_poverty float
ALTER TABLE CovidVaccinations ALTER COLUMN cardiovasc_death_rate float
ALTER TABLE CovidVaccinations ALTER COLUMN diabetes_prevalence float
ALTER TABLE CovidVaccinations ALTER COLUMN female_smokers float
ALTER TABLE CovidVaccinations ALTER COLUMN male_smokers float
ALTER TABLE CovidVaccinations ALTER COLUMN handwashing_facilities float
ALTER TABLE CovidVaccinations ALTER COLUMN hospital_beds_per_thousand float
ALTER TABLE CovidVaccinations ALTER COLUMN life_expectancy float
ALTER TABLE CovidVaccinations ALTER COLUMN human_development_index float
ALTER TABLE CovidVaccinations ALTER COLUMN excess_mortality_cumulative_absolute float
ALTER TABLE CovidVaccinations ALTER COLUMN excess_mortality_cumulative float
ALTER TABLE CovidVaccinations ALTER COLUMN excess_mortality float
ALTER TABLE CovidVaccinations ALTER COLUMN excess_mortality_cumulative_per_million float

ALTER TABLE CovidDeaths
ALTER COLUMN date DATETIME

ALTER TABLE CovidVaccinations
ALTER COLUMN date DATETIME


-- Looking at total cases vs total deaths
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



-- Looking at total cases vs population
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


-- Looking at countries with highest infection rate compared to population


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



-- Showing countries with highest death count per population


SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM CovidData..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC


-- Let's break things down by continent




-- Showing the continent with the highest death count


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


-- Looking at total population vs vaccinations


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, 
	dea.date) AS RollingPeopleVaccinated
FROM CovidData..CovidDeaths dea
JOIN CovidData..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


-- Use CTE

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
		END
FROM PopVsVac



-- Temp Table
 

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



-- Creating view to store data for later visualizations


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
