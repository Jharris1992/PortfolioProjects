
SELECT *
FROM dbo.CovidDeaths$
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM DBO.CovidVaccinations$
--ORDER BY 3,4

-- Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM dbo.CovidDeaths$
ORDER BY 1,2

-- Looking at the Total Cases v Total Deaths
-- Shows the likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_Cases)*100 as DeathPercentage
FROM dbo.CovidDeaths$
where location like '%states%'
AND continent is not null
ORDER BY 1,2


-- Looking at the total cases v population
-- Shows what percentage of the population got covid
SELECT Location, date, total_cases, population, (total_cases/population)*100 as PopulationPercentageInfected
FROM dbo.CovidDeaths$
where location like '%states%'
ORDER BY 1,2

-- Looking at countries with the highest infection rate compared to population

SELECT Location, MAX(total_cases) as HighestInfectionCount, population, MAX((total_cases/population))*100 as PopulationPercentageInfected
FROM dbo.CovidDeaths$
--where location like '%states%'
GROUP BY Location, population
ORDER BY PopulationPercentageInfected desc

-- Showing the countries with the highest death count per population
SELECT Location,MAX(cast(total_deaths as int)) as TotalDeathCount
FROM dbo.CovidDeaths$
--where location like '%states%'
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount desc

-- LETS BREAK THINGS DOWN BY CONTINENT

SELECT continent,MAX(cast(total_deaths as int)) as TotalDeathCount
FROM dbo.CovidDeaths$
--where location like '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

-- Showing the continents with the highest death count

SELECT continent,MAX(cast(total_deaths as int)) as TotalDeathCount
FROM dbo.CovidDeaths$
--where location like '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

-- GLOBAL NUMBERS

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
FROM dbo.CovidDeaths$
--where location like '%states%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2


-- looking at total population v vaccinations

SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.date)  as RollingPeopleVaccinated
FROM dbo.CovidDeaths$ dea
JOIN dbo.CovidVaccinations$ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

-- USE CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.date)  as RollingPeopleVaccinated
FROM dbo.CovidDeaths$ dea
JOIN dbo.CovidVaccinations$ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
Select *,(RollingPeopleVaccinated/population)*100
FROM PopvsVac


--TEMP TABLE
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)


INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.date)  as RollingPeopleVaccinated
FROM dbo.CovidDeaths$ dea
JOIN dbo.CovidVaccinations$ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

Select *,(RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

--Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.date)  as RollingPeopleVaccinated
FROM dbo.CovidDeaths$ dea
JOIN dbo.CovidVaccinations$ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3