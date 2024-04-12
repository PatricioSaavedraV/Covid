SELECT 
	*
FROM
	dbo.CovidDeaths as cd
WHERE
	cd.continent IS NOT NULL
ORDER BY
	3,4

SELECT 
	dea.location, 
	dea.date,
	dea.total_cases,
	dea.new_cases,
	dea.total_deaths,
	dea.population
FROM
	dbo.CovidDeaths as dea
WHERE
	dea.continent IS NOT NULL
ORDER BY
	1,2

-- Looking at total cases vs total deaths --
-- Shows likelihood of dying if you contract covid in your country -- 
SELECT 
	dea.location, 
	dea.date,
	dea.total_cases,
	dea.total_deaths,
	(dea.total_deaths/dea.total_cases)*100 as DeathPercentage
FROM
	dbo.CovidDeaths as dea
WHERE
	dea.location like '%Chile%'
	and	dea.continent IS NOT NULL
ORDER BY
	1,2

-- Looking at total cases vs population
-- Shows what percentage of population got Covid
SELECT 
	dea.location, 
	dea.date,
	dea.total_cases,
	dea.population,
	(dea.total_cases/dea.population)*100 as PopulationInfectedPercentage
FROM
	dbo.CovidDeaths as dea
WHERE
	dea.location like '%Chile%'
	and	dea.continent IS NOT NULL
ORDER BY
	1,2

-- Looking at countries with highest infection rate compared to population
SELECT 
	dea.location, 
	dea.population,
	MAX(dea.total_cases) as HighestInfectionCount,
	(MAX(dea.total_cases/dea.population))*100 as PopulationInfectedPercentage
FROM
	dbo.CovidDeaths as dea
WHERE
	dea.continent IS NOT NULL
GROUP BY
	dea.location,
	dea.population
ORDER BY
	PopulationInfectedPercentage DESC

-- Showing countries with highest death count per population
SELECT 
	dea.location, 
	MAX(CAST(dea.total_deaths as INT)) as TotalDeathCount
FROM
	dbo.CovidDeaths as dea
WHERE
	dea.continent IS NOT NULL
GROUP BY
	dea.location
ORDER BY
	TotalDeathCount DESC

-- Let's break things down by continent
-- Showing continents with the highest count per population --
SELECT 
	dea.continent, 
	MAX(CAST(dea.total_deaths as INT)) as TotalDeathCount
FROM
	dbo.CovidDeaths as dea
WHERE
	dea.continent IS NOT NULL
GROUP BY
	dea.continent
ORDER BY
	TotalDeathCount DESC

-- Global numbers
SELECT 
	SUM(dea.new_cases) as total_cases,
	SUM(dea.new_deaths) as total_death,
	SUM(CAST(dea.new_deaths as INT))/NULLIF(SUM(dea.new_cases),0)*100 as DeathPercentage
FROM
	dbo.CovidDeaths as dea
WHERE
	dea.continent IS NOT NULL
ORDER BY
	1,2


-- Looking at total population vs vaccinations -- 
SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CAST(new_vaccinations as FLOAT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated,
	(RollingPeopleVaccinated/dea.population)*100
FROM
	dbo.CovidDeaths as dea
JOIN
	dbo.CovidVaccinations vac 
		ON dea.location = vac.location
		and dea.date = vac.date
WHERE
	dea.continent IS NOT NULL
ORDER BY
	1,2,3


-- USE CTE --
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CAST(new_vaccinations as FLOAT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM
	dbo.CovidDeaths as dea
JOIN
	dbo.CovidVaccinations vac 
		ON dea.location = vac.location
		and dea.date = vac.date
WHERE
	dea.continent IS NOT NULL
)
SELECT 
	*,
	(RollingPeopleVaccinated/Population)*100
FROM
	PopvsVac


-- TEMP TABLE -- 
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location  nvarchar(255),
Date datetime,
Population numeric,
New_vaccionations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CAST(new_vaccinations as FLOAT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM
	dbo.CovidDeaths as dea
JOIN
	dbo.CovidVaccinations vac 
		ON dea.location = vac.location
		and dea.date = vac.date
WHERE
	dea.continent IS NOT NULL

SELECT
	*,
	(RollingPeopleVaccinated/Population)*100
FROM 
	#PercentPopulationVaccinated


-- Creating view to store data for later visualizations -- 

CREATE VIEW PercentPopulationVaccinated as
SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CAST(new_vaccinations as FLOAT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM
	dbo.CovidDeaths as dea
JOIN
	dbo.CovidVaccinations vac 
		ON dea.location = vac.location
		and dea.date = vac.date
WHERE
	dea.continent IS NOT NULL


SELECT 
	*
FROM
	PercentPopulationVaccinated