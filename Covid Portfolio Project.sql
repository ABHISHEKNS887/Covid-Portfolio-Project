SELECT *
FROM PorfolioProject..CovidDeath
WHERE continent IS NOT NULL
ORDER BY 2

--SELECT *
--FROM PorfolioProject..CovidVaccination


SELECT location,date,total_cases,new_cases,total_deaths,population
FROM PorfolioProject..CovidDeath
ORDER BY 1,2

-- Total cases and Total deaths

SELECT location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PorfolioProject..CovidDeath
WHERE location Like '%Asia%'
ORDER BY 1,2

-- Total cases VS Population
-- Shows the percentage of population got covid

SELECT location,date,total_cases,population,(total_cases/population)*100 AS PercentPopulatioInfected
FROM PorfolioProject..CovidDeath
WHERE continent IS NOT NULL
--WHERE location LIKE '%Asia%'
ORDER BY 1,2


-- The countries with highest infection rate compare to the population

SELECT location,population,MAX(total_cases) AS HighestInfectioCount, MAX((total_cases/population))*100 AS PercentPopulatioInfected
FROM PorfolioProject..CovidDeath
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulatioInfected DESC 

-- The countries with highest death rate 

SELECT location,MAX(CAST(total_deaths AS int)) AS HighestDeathCount /** we use CAST to convert the data types**/
FROM PorfolioProject..CovidDeath
WHERE continent IS NOT NULL
Group BY location
ORDER BY HighestDeathCount DESC

-- Checking the Highest Death rate by continent

SELECT continent,MAX(CAST(total_deaths AS int)) AS HighestDeathCount
FROM PorfolioProject..CovidDeath
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY HighestDeathCount DESC

-- Globle Numbers

SELECT date, SUM(new_cases) as Total_cases, SUM(new_deaths) as Total_deaths, (SUM(new_deaths)/SUM(new_cases))*100 as DeathPercentage
FROM PorfolioProject..CovidDeath
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

SELECT SUM(new_cases) as Total_cases, SUM(new_deaths) as Total_deaths, (SUM(new_deaths)/SUM(new_cases))*100 as DeathPercentage
FROM PorfolioProject..CovidDeath
WHERE continent IS NOT NULL

-- Joining the CovidDeaths and CovidVaccination Tables

SELECT *
FROM PorfolioProject..CovidDeath Death
JOIN PorfolioProject..CovidVaccination Vaccin
 ON Death.location = Vaccin.location
 AND Death.date = Vaccin.date

 -- Looking at Total population VS Vaccination

SELECT Death.continent,Death.location, Death.date, Death.population, Vaccin.new_vaccinations,
SUM(Vaccin.new_vaccinations) OVER (PARTITION BY Death.location ORDER BY Death.location, Death.date) AS RollingPeopleVaccinated
FROM PorfolioProject..CovidDeath Death
JOIN PorfolioProject..CovidVaccination Vaccin
  ON Death.location = Vaccin.location
  AND Death.date = Vaccin.date
WHERE Death.continent IS NOT NULL
ORDER BY 1,2

-- Using CTE

WITH PopVSvaccin (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
SELECT Death.continent,Death.location, Death.date, Death.population, Vaccin.new_vaccinations,
SUM(Vaccin.new_vaccinations) OVER (PARTITION BY Death.location ORDER BY Death.location, Death.date) AS RollingPeopleVaccinated
FROM PorfolioProject..CovidDeath Death
JOIN PorfolioProject..CovidVaccination Vaccin
  ON Death.location = Vaccin.location
  AND Death.date = Vaccin.date
WHERE Death.continent IS NOT NULL
-- ORDER BY 1,2  ( We cant use Order BY Clause inside CTE)
)

SELECT *,(RollingPeopleVaccinated/population)*100
FROM PopVSvaccin


-- Creating a temp table

DROP TABLE IF EXISTS #PercentagePopulationVaccinated
CREATE TABLE #PercentagePopulationVaccinated
(
continent nvarchar(200),
location nvarchar(200),
date DateTime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentagePopulationVaccinated
SELECT Death.continent,Death.location, Death.date, Death.population, Vaccin.new_vaccinations,
SUM(Vaccin.new_vaccinations) OVER (PARTITION BY Death.location ORDER BY Death.location, Death.date) AS RollingPeopleVaccinated
FROM PorfolioProject..CovidDeath Death
JOIN PorfolioProject..CovidVaccination Vaccin
  ON Death.location = Vaccin.location
  AND Death.date = Vaccin.date
-- WHERE Death.continent IS NOT NULL
-- ORDER BY 1,2  ( We cant use Order BY Clause inside CTE)

SELECT *
FROM #PercentagePopulationVaccinated

-- Creating view to store data for later visualizarion

CREATE VIEW PercentagePopulationVaccinated AS
SELECT Death.continent,Death.location, Death.date, Death.population, Vaccin.new_vaccinations,
SUM(Vaccin.new_vaccinations) OVER (PARTITION BY Death.location ORDER BY Death.location, Death.date) AS RollingPeopleVaccinated
FROM PorfolioProject..CovidDeath Death
JOIN PorfolioProject..CovidVaccination Vaccin
  ON Death.location = Vaccin.location
  AND Death.date = Vaccin.date
WHERE Death.continent IS NOT NULL
-- ORDER BY 1,2  ( We cant use Order BY Vreate view)

SELECT *
FROM PercentagePopulationVaccinated