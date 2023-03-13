Select *
From Portfolio.dbo.[1CovidDeaths]
Where continent is not null
order by 3,4

--Select *
-- From Portfolio..covidvaccinations
-- order by 3,4

-- Select data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From Portfolio.dbo.[1CovidDeaths]
order by 1,2

 - - Looking at total cases vs total population per country

 Select Location, date, total_cases, new_cases, (total_cases/population)*100 as CasesPerPopulation
From Portfolio.dbo.[1CovidDeaths]
Where location like '%cote%'
order by 1,2

-- Looking a total cases vs population
-- shows what percentage of population gets covid
Select Location, date, total_cases, population, (total_cases/population)*100 as CovidtoPopulation
From Portfolio.dbo.[1CovidDeaths]
order by 1,2

-- Looking at countries with the highest infection rate compared to Population
Select Location, Population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From Portfolio.dbo.[1CovidDeaths]
Group by Location,Population
order by PercentPopulationInfected desc

-- Showing the countries with the highest case Count per Population
Select Location, MAX(cast(total_cases_per_million as int)) as TotalCaseCount
From Portfolio.dbo.[1CovidDeaths]
Where continent is not null
Group by Location
order by TotalCaseCount desc

-- LET"S BREAK THINGS DOWN BY CONTINENT
Select continent, max(cast(total_cases as int)) as totalcasecount
From Portfolio.dbo.[1CovidDeaths]
Where continent is not null
Group by continent
order by totalcasecount desc

--Then by location
Select location, max(cast(total_cases as int)) as totalcasecount
From Portfolio.dbo.[1CovidDeaths]
Where continent is null
Group by location
order by totalcasecount desc

--Global Numbers
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From Portfolio.dbo.[1CovidDeaths]
where continent is not null
Group by date
order by 1,2

Select *
FROM Portfolio..[1CovidDeaths]

--Join 2 tables together
Select *
From Portfolio..[1CovidDeaths] dea
Join Portfolio.dbo.[CovidVaccinations$] vac
	on dea.Location = vac.location
	and dea.date = vac.date

--Looking at the total population vs stringency index
Select dea.continent, dea.location, dea.date, dea.population, vac.stringency_index
From Portfolio..[1CovidDeaths] dea
Join Portfolio.dbo.[CovidVaccinations$] vac
	on dea.Location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	order by 2,3

--Look at doing a rolling count
Select dea.continent, dea.location, dea.date, dea.population, vac.stringency_index
, SUM(CONVERT(int,vac.stringency_index)) OVER (Partition by dea.location Order by
dea.date) as RollingstringencyIndex
, (RollingStringencyIndex/population)*100
From Portfolio..[1CovidDeaths] dea
Join Portfolio.dbo.[CovidVaccinations$] vac
	on dea.Location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	order by 2,3

--Use CTE
With PopvsStringency (Continent, location, date, population, stringency_index, RollingstringencyIndex)
	as
(
	Select dea.continent, dea.location, dea.date, dea.population, vac.stringency_index
, SUM(CONVERT(int,vac.stringency_index)) OVER (Partition by dea.location Order by
dea.date) as RollingstringencyIndex
--, (RollingStringencyIndex/population)*100
From Portfolio..[1CovidDeaths] dea
Join Portfolio.dbo.[CovidVaccinations$] vac
	on dea.Location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3
)
Select *, (RollingstringencyIndex/population)*100
From PopvsStringency

--TEMP TABLE (not working)

DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
Stringency_index numeric,
RollingstringencyIndex numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.stringency_index
, SUM(CONVERT(int,vac.stringency_index)) OVER (Partition by dea.location Order by
dea.date) as RollingstringencyIndex
--, (RollingStringencyIndex/population)*100
From Portfolio..[1CovidDeaths] dea
Join Portfolio.dbo.[CovidVaccinations$] vac
	on dea.Location = vac.location
	and dea.date = vac.date
	--where dea.continent is not null
	--order by 2,3

Select *, (Rollingstringencyindex/Population)*100
From #PercentPopulationVaccinated

--Create a view to store data for later visualizations (not working)
Create view #PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.stringency_index
, SUM(CONVERT(int,vac.stringency_index)) OVER (Partition by dea.location Order by
dea.date) as RollingstringencyIndex
--, (RollingStringencyIndex/population)*100
From Portfolio..[1CovidDeaths] dea
Join Portfolio.dbo.[CovidVaccinations$] vac
	on dea.Location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From #PercentPopulationVaccinated