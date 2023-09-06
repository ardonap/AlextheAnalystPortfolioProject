-- Here's a Data Exploration on Covid Dataset following Alex the Analyst's instructions in https://www.youtube.com/watch?v=qfyynHBFOsM&t=2882s. 
-- Visualization was done via Tableau - https://public.tableau.com/app/profile/fred.a7345/viz/CovidDACaseStudy/Dashboard1#2

-- Check data
SELECT * 
FROM `covid-da-case-study.covid_data.covid_deaths` 
WHERE continent IS NOT NULL
ORDER BY 3,4;

-- Select data needed
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM `covid-da-case-study.covid_data.covid_deaths`
WHERE continent IS NOT NULL
ORDER BY 1,2;

-- Total Cases vs Total Deaths
-- Death Percentage
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM `covid-da-case-study.covid_data.covid_deaths`
WHERE location LIKE '%philippines%' 
  AND continent IS NOT NULL
ORDER BY 1,2;

-- Population vs Total Cases
-- Infection Rate
SELECT location, date, population, total_cases, (total_cases/population)*100 AS InfectionRate
FROM `covid-da-case-study.covid_data.covid_deaths`
WHERE continent IS NOT NULL
ORDER BY 1,2;

-- Countries with Highest Infection Rate compared to population
SELECT location, population, date, MAX(total_cases) AS HighiestInfectionCount, MAX((total_cases/population)*100) AS PercentPopulationInfected
FROM `covid-da-case-study.covid_data.covid_deaths`
WHERE continent IS NOT NULL
GROUP BY location, population, date
ORDER BY PercentPopulationInfected DESC;

-- Countries with Highest Death Count per Population
SELECT location, SUM(new_deaths) as TotalDeathCount
FROM `covid-da-case-study.covid_data.covid_deaths`
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- Continents with Highest Death Count per Population
SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM `covid-da-case-study.covid_data.covid_deaths`
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- Global Numbers
SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, (SUM(new_deaths)/SUM(new_cases))*100 AS DeathPercentage
FROM `covid-da-case-study.covid_data.covid_deaths`
WHERE continent IS NOT NULL
ORDER BY 1,2;

-- SELECT SUM(total_cases) AS TotalCases, SUM(total_deaths) AS TotalDeaths, (SUM(total_deaths)/SUM(total_cases))*100 AS DeathPercentage
-- FROM `covid-da-case-study.covid_data.covid_deaths`
-- WHERE continent IS NOT NULL
-- ORDER BY 1,2;

-- Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
  SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM `covid-da-case-study.covid_data.covid_deaths` AS dea
JOIN `covid-da-case-study.covid_data.covid_vaccinations` AS vac
  ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

-- Using CTE to perform calculation on Partition By in previous query
WITH PopVsVac AS
(
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
  SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM `covid-da-case-study.covid_data.covid_deaths` AS dea
JOIN `covid-da-case-study.covid_data.covid_vaccinations` AS vac
  ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/Population)*100 AS VaccinationRate
FROM PopVsVac
ORDER BY 2,3;


-- Not Allowed for BigQuerySandbox (INSERT INTO)
-- DECLARE continent string;
-- DECLARE location string;
-- DECLARE date date;
-- DECLARE population numeric;
-- DECLARE new_vaccinations numeric;
-- DECLARE RollingPeopleVaccinated numeric;

-- DROP TABLE IF EXISTS `covid-da-case-study.covid_data.PercentPopulationVaccinated`;

-- CREATE TABLE `covid-da-case-study.covid_data.PercentPopulationVaccinated` AS
--   SELECT continent, location, date, population, new_vaccinations, RollingPeopleVaccinated;

-- INSERT INTO `covid-da-case-study..PercentPopulationVaccinated`
-- SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
--   SUM(new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
-- --, (RollingPeopleVaccinated/population)*100
-- From `covid-da-case-study.covid_data.covid_deaths` dea
-- Join `covid-da-case-study.covid_data.covid_vaccinations` vac
-- 	On dea.location = vac.location
-- 	and dea.date = vac.date;
-- --where dea.continent is not null 
-- --order by 2,3

-- Select *, (RollingPeopleVaccinated/Population)*100
-- From `covid-da-case-study.covid_data.PercentPopulationVaccinated`;


CREATE OR REPLACE VIEW `covid-da-case-study.covid_data.PopulationVaccinated` AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM `covid-da-case-study.covid_data.covid_deaths` AS dea
JOIN `covid-da-case-study.covid_data.covid_vaccinations` AS vac
  ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;


