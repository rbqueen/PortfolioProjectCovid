select distinct continent, location 
from PortfolioProject..CovidDeaths$
where continent is not null
order by location

--create view
create view TotalDeathsByContinent as
select continent, max(cast(total_deaths as bigint)) 
	as TotalDeathCount
from PortfolioProject..CovidDeaths$
where continent is not null 
group by continent

-- from PortfolioProject..CovidVaccinations
--Select data going to be using

select location, date, total_cases,new_cases,total_deaths,
		population
from PortfolioProject..CovidDeaths$
order by 3,4

-- looking at total cases vs total deaths
-- shows likelihood of dying if contracted covid

select location, date, total_cases,total_deaths,
	 (total_deaths/total_cases) *100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where continent is not null
order by 1,2

-- looking at total cases vs population
-- shows what percentage of population had covid

select location, date, total_cases,population,
	  (total_cases/population) *100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths$
where continent is not null 
-- and location like '%states'
order by 1,2

-- Looking at countries with highest infection rate
-- compared to population

select location, max(total_cases) as HighestInfectionCount,
		population,max((total_cases/population)) *100 
			as PercentPopulationInfected
from PortfolioProject..CovidDeaths$
where continent is not null
group by  location,population
order by PercentPopulationInfected desc

-- showing highest death count per population

select location, max(cast(total_deaths as bigint)) 
	as TotalDeathCount
from PortfolioProject..CovidDeaths$
where continent is not null 
group by  location
order by TotalDeathCount desc

-- broken down by continent
-- created a new view called TotalDeathsByContinent2
-- removed the order by clause
select location, max(cast(total_deaths as bigint)) 
	as TotalDeathCount
from PortfolioProject..CovidDeaths$
where continent is null and 
location <> 'upper middle income'and location
<>'high income' and location <> 'lower middle income'
and  location <> 'low income'
group by location
order by TotalDeathCount desc

--showing contintents with highest death counts

select continent, max(cast(total_deaths as bigint)) 
	as TotalDeathCount
from PortfolioProject..CovidDeaths$
where continent is not null-- and 
--location <> 'upper middle income'and location
--<>'high income' and location <> 'lower middle income'
--and  location <> 'low income'
group by continent
order by TotalDeathCount desc

-- breaking down global numbers

select sum(new_cases) total_cases, 
	   sum(cast(new_deaths as int)) Total_Deaths,
	   sum(cast(new_deaths as int))/sum(new_cases) *100
	   as Death_Percentage
from PortfolioProject..CovidDeaths$
where continent is not null
--group by date
order by 1,2

--Total Population vs Vaccinations

--select top 800000 
	--dea.continent, dea.location, dea.date,dea.population,
	--vac.new_vaccinations
--from PortfolioProject..CovidDeaths$  dea
--join PortfolioProject..CovidVaccinations$  vac
	--on dea.location = vac.location and
	--dea.date = vac.date
	--where dea.continent is not null 
	--order by 2,3
	


	--CTE
	--rolling count
--insert into percentPopulationVaccinated

with PopVsVac (continent,location,date,population,
	RollingPeopleVaccinated,new_vaccinations) as
	(
	select top 800000 
	dea.continent, dea.location, dea.date,dea.population,
	vac.new_vaccinations, sum(convert(bigint, vac.new_vaccinations))
over(partition by dea.location order by dea.population desc,
	 dea.date)
	as RollingPeopleVaccinated 
from PortfolioProject..CovidDeaths$  dea
join PortfolioProject..CovidVaccinations$  vac
	on dea.location = vac.location and
	dea.date = vac.date
	where dea.continent is not null 
	--order by 2,3
	)
	select *, (RollingPeopleVaccinated/population) *100 percent_vacs
from popvsvac
--where new_vaccinations is not null

--Temp Table
	drop table if exists PercentPopulationVaccinated
	create table PercentPopulationVaccinated
		(continent nvarchar (255), location nvarchar (255),
		 date datetime, population numeric,
		 new_vaccinations numeric, 
		 RollingPeopleVaccinated numeric)
insert into PercentPopulationVaccinated
	select top 800000 
	dea.continent, dea.location, dea.date,dea.population,
	vac.new_vaccinations, sum(convert(bigint, vac.new_vaccinations))
over(partition by dea.location order by dea.population desc,
	 dea.date) as RollingPeopleVaccinated 
from PortfolioProject..CovidDeaths$  dea
join PortfolioProject..CovidVaccinations$  vac
	on dea.location = vac.location and dea.date = vac.date
--where dea.continent is not null
select *, (RollingPeopleVaccinated/population) *100 percent_vacs
from PercentPopulationVaccinated

--create view to store date for later vis
create view PercentVaccinated as
select top 800000 
	dea.continent, dea.location, dea.date,dea.population,
	vac.new_vaccinations, sum(convert(bigint, vac.new_vaccinations))
over(partition by dea.location order by dea.population desc,
	 dea.date) as RollingPeopleVaccinated 
from PortfolioProject..CovidDeaths$  dea
join PortfolioProject..CovidVaccinations$  vac
	 on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
select * from PercentVaccinated