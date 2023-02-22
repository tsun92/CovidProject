use [Portfolio Project]
SELECT *
FROM [Portfolio Project]..CovidDeaths
ORDER BY 3,4

--SELECT *
--FROM [Portfolio Project]..CovidVaccinations
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project]..CovidDeaths
ORDER BY 1,2

--Looking at total cases vs total deaths
--Likelihood of death if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM [Portfolio Project]..CovidDeaths
WHERE location like '%states%'
and continent is not null
ORDER BY 1,2

-- total cases vs population
--shows what percentage of population got covid
SELECT location, date, total_cases, population, (total_cases/population)*100 as PercentageCovid
FROM [Portfolio Project]..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

--countries with highest infection rate compared to population
SELECT location, MAX(total_cases)as HighestInfectionCount, population, MAX((total_cases/population))*100 as PercentagePopulationInfected
FROM [Portfolio Project]..CovidDeaths
--WHERE location like '%states%'
GROUP BY population, location
ORDER BY PercentagePopulationInfected DESC

--Showing Countries with Highest Death Count per Population
SELECT location, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM [Portfolio Project]..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Lets break things down by continent
SELECT location, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM [Portfolio Project]..CovidDeaths
--WHERE location like '%states%'
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount DESC


-- Global numbers
SELECT date, SUM(new_cases), SUM(cast(new_deaths as int)), SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM [Portfolio Project]..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2



-- Looking at total population vs vaccinations

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations,  RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)

Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--USE CTE

-- TEMP Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--Order by 2,3

Select*, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

--Creating View to store data for later visualization

Drop View if exists PercentPopulationVaccinated
CREATE View PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3


Select *
From PercentPopulationVaccinated


