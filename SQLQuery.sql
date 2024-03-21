/*

Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

Select *
From CovidDeaths
Where continent is not null 
order by 3,4

Select *
From CovidDeaths
Where continent is null

Select *
From CovidDeaths
Where continent is not null 



-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
Where continent is not null 
order by 1,2

-- Shows likelihood of dying if you contract covid in Morocco

Select Location, date, total_cases,total_deaths, CAST((total_deaths/total_cases)*100 as decimal(10,2) ) as DeathPercentage
From CovidDeaths
Where location like '%Morocco%'
and continent is not null 
and total_deaths is not null
order by 2

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases,  CAST((total_cases/population)*100 as DECIMAL(10,6)) as PercentPopulationInfected
From CovidDeaths
Where location like '%Morocco%'
and continent is not null 
and total_cases is not null
order by 1,2

-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths
--Where location like '%states%'
where continent is not null 
Group by Location,Population
order by PercentPopulationInfected desc 

--Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as HighestDeathsCount
From CovidDeaths
--Where location like '%states%'
where continent is not null 
Group by Location
order by HighestDeathsCount desc 

-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeaths
--Where location like '%states%'
where continent is not null
Group by Location
order by TotalDeathCount desc

-- BREAKING THINGS DOWN BY CONTINENT
--Showing contintents with the highest death count per population

SELECT continent, Max(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeaths
where continent is not null
GROUP BY continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths
--Where location like '%states%'
where continent is not null 

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order By dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
	and vac.new_vaccinations is not null
)
select *, Cast((RollingPeopleVaccinated/population)*100 as Decimal(10, 4)) as PercentagePeopleVaccinated
from PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
	and vac.new_vaccinations is not null 
--order by 2,3
Select *, Cast((RollingPeopleVaccinated/population)*100 as Decimal(10, 4)) as PercentagePeopleVaccinated
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
	and vac.new_vaccinations is not null 

SELECT * From PercentPopulationVaccinated













