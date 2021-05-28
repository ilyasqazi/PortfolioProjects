-- Select data that we are going to be using
SELECT 
location, date, total_cases, new_cases, total_deaths, population
FROM dbo.CovidDeaths
order by 1,2

-- Looking at Total cases Vs Total deaths
SELECT location, date, total_cases, total_deaths, (total_deaths/ total_cases) * 100 as DeathPercentage
from dbo.CovidDeaths
where location = 'India'
and  continent is not null
order by 1,2

-- Looking at Total Cases Vs Population
-- Shows what percentage of population got covid
SELECT location, date, total_cases, population, (total_cases/ population) * 100 as CovidCasesPercentage
from dbo.CovidDeaths
where location = 'India'
and continent is not null
order by 1,2


-- Looking at Countries with highest infection rate compared to population
SELECT location, max(total_cases) HighestInfection, (max(total_cases)/ population) * 100 as HighestInfectionByCountry
from dbo.CovidDeaths
where continent is not null
group by location, population
order by 3 desc

-- Looking at Countries with highest death rate compared to population
SELECT location, max(cast(total_deaths as int)) HighestDeaths, (max(cast(total_deaths as int))/ population) * 100 as HighestDeathsByCountry
from dbo.CovidDeaths
where continent is not null
group by location, population
order by 3 desc

-- Let's break things down by continent
SELECT location, max(cast(total_deaths as int)) HighestDeaths
from dbo.CovidDeaths
where continent is null
group by location
order by 2 desc


-- Showing Continents with Highest Death per Population
SELECT continent, max(cast(total_deaths as int)) HighestDeaths
from dbo.CovidDeaths
where continent is not null
group by continent
order by 2 desc

-- Global Numbers
SELECT date, sum(new_cases) TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, 
(sum(cast(new_deaths as int)) / sum(new_cases)) * 100 as DeathPercentageWorldWide
from dbo.CovidDeaths
where continent is not null
group by date
order by 1 desc


SELECT  sum(new_cases) TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, 
(sum(cast(new_deaths as int)) / sum(new_cases)) * 100 as DeathPercentageWorld
from dbo.CovidDeaths
where continent is not null


-- Covid Vaccinations
select * from dbo.CovidVaccinations

-- Looking for Total Population Vs Vaccinations
SELECT dth.continent, dth.location, dth.date,  dth.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over(partition by dth.continent, dth.location order by dth.location, dth.date) as RunningTotalPeopleVaccinated
FROM dbo.CovidDeaths dth
inner join dbo.CovidVaccinations vac
on vac.location = dth.location
and vac.date = dth.date
where dth.continent is not null and new_vaccinations is not null
order by 2,3

-- With CTE
with CTE as 
(
SELECT dth.continent, dth.location, dth.date,  dth.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over(partition by dth.continent, dth.location order by dth.location, dth.date) as RunningTotalPeopleVaccinated
FROM dbo.CovidDeaths dth
inner join dbo.CovidVaccinations vac
on vac.location = dth.location
and vac.date = dth.date
where dth.continent is not null and new_vaccinations is not null
)
select continent, location, date, population, new_vaccinations,
(RunningTotalPeopleVaccinated / population) * 100
from CTE
order by 2,3

-- USING TEMP TABLE
drop table if exists  #PercentPopulationVaccincate
CREATE TABLE #PercentPopulationVaccincate
(
Continent varchar(255), Location varchar(255), date datetime, Populations int, New_Vaccinations int, RollingPeopleVaccinated int
)

insert into #PercentPopulationVaccincate
SELECT dth.continent, dth.location, dth.date,  dth.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over(partition by dth.continent, dth.location order by dth.location, dth.date) as RunningTotalPeopleVaccinated
FROM dbo.CovidDeaths dth
inner join dbo.CovidVaccinations vac
on vac.location = dth.location
and vac.date = dth.date
where dth.continent is not null and new_vaccinations is not null

select 
Continent, Location, date, Populations, RollingPeopleVaccinated, New_Vaccinations,
(RollingPeopleVaccinated / Populations) * 100
from #PercentPopulationVaccincate
order by 2,3


-- CREATE VIEW TO STORE DATA FOR LATER VISUALIZATION
	CREATE VIEW PercentPopulationVaccinated as
SELECT dth.continent, dth.location, dth.date,  dth.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over(partition by dth.continent, dth.location order by dth.location, dth.date) as RunningTotalPeopleVaccinated
FROM dbo.CovidDeaths dth
inner join dbo.CovidVaccinations vac
on vac.location = dth.location
and vac.date = dth.date
where dth.continent is not null and new_vaccinations is not null
 
SELECT * FROM PercentPopulationVaccinated

