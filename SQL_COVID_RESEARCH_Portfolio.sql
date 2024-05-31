select * from covid19_research..CovidVaccinations;

select * from covid19_research..covidDeaths;

--select location, date, total_cases, new_cases, total_deaths, population from covid19_research..CovidDeaths
--order by 1,2;

--looking at total cases vs total deaths
select * from covid19_research..covidDeaths;

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage from covid19_research.dbo.CovidDeaths
order by 1, 2;

select distinct location from covid19_research.dbo.coviddeaths order by location;

select location, date, population, total_cases, total_deaths, 
(total_deaths/total_cases)*100 as Death_Percentage from covid19_research.dbo.CovidDeaths
where location like '%states%' 
order by Death_Percentage desc;

select location, date, population, total_cases, (total_cases/population)*100 as Pop_Percent_infected, 
from covid19_research.dbo.CovidDeaths
where location like '%states%' 
order by Death_Percentage desc;

select location, date, population, total_cases, (total_cases/population)*100 as Pop_Percent_Infected
from covid19_research.dbo.CovidDeaths
--where location like '%states%' 
order by 1, 2 desc;

--percent of countries population infected
select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as Max_Pop_Percent_infected
from covid19_research.dbo.CovidDeaths
--where location like '%states%' 
group by location, population
order by Pop_Percent_infected desc;


select location, population, max(total_cases) as HightestInfectionCount, Max((total_cases/population))*100 as Pop_Percent_Infected
from covid19_research.dbo.CovidDeaths
--where location like '%states%'
--where date<'04/30/2021'
group by location, population
order by Pop_Percent_Infected desc;


select location, max(total_deaths) as total_death_count
from covid19_research.dbo.CovidDeaths
where 
--location like '%states%'
--date<'04/30/2021'
continent is not null
group by location
order by Total_death_count desc;

--break down by continent
select continent, max(total_deaths) as total_death_count
from covid19_research.dbo.CovidDeaths
where 
--location like '%states%'
--date<'04/30/2021'
continent is not null
group by continent
order by Total_death_count desc;


select continent, location, max(total_deaths) as total_death_count
from covid19_research.dbo.CovidDeaths
where 
--location like '%states%'
--date<'04/30/2021'
location is not null
group by continent, location
order by continent, Total_death_count desc;



select	sum(new_cases) as total_cases, 
		sum(new_deaths) as total_deaths,
		sum(new_deaths)/sum(new_cases)*100 as death_percentage
from covid19_research.dbo.CovidDeaths
--where location like '%state%'
where continent is not null
--group by date
order by 1,2;


--covid vaccinations
select * from covid19_research.dbo.CovidVaccinations;

--join the 2 tables:

select * from covid19_research.dbo.CovidDeaths dea
inner join
covid19_research.dbo.CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
	;

--look at total population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, 
		vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rolling_vaccinations
from covid19_research.dbo.CovidDeaths dea
inner join
covid19_research.dbo.CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
	and dea.continent is not null
	order by 2,3;


--use cte
with popvsvac (Continent, location, date, population, new_vaccinations, rolling_Vaccinations)
as (
select dea.continent, dea.location, dea.date, dea.population, 
		vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rolling_vaccinations
from covid19_research.dbo.CovidDeaths dea
inner join
covid19_research.dbo.CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
	and dea.continent is not null
--	order by 2,3;
)

select *, (rolling_vaccinations/population)*100 from popvsvac
;


--for ease of changes
drop table if exists #PopvsVacTemp
--temp table
create table #PopvsVacTemp
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric null,
rolling_vaccinations numeric null
)

insert into #PopvsVacTemp
select dea.continent, dea.location, dea.date, dea.population, 
		vac.new_vaccinations, 
		sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rolling_vaccinations
from covid19_research.dbo.CovidDeaths dea
inner join
covid19_research.dbo.CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
	and dea.continent is not null
--	order by 2,3;


select *, (rolling_vaccinations/population)*100 from #PopvsVacTemp;


--creating views for later visualizations
create view PopvsVac as 
select dea.continent, dea.location, dea.date, dea.population, 
		vac.new_vaccinations, 
		sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rolling_vaccinations
from covid19_research.dbo.CovidDeaths dea
inner join
covid19_research.dbo.CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
	and dea.continent is not null
;

select * from popvsvac;
