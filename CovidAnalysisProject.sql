select *
from DataExp..CovidDeaths
where continent is not NULL

select location, date, population, total_cases, new_cases, total_deaths
from DataExp.dbo.CovidDeaths
where continent is not NULL


--Total Cases vs Total deaths

select location, date, population, total_cases, total_deaths, 
CONVERT(float,total_deaths)/NULLIF(CONVERT(float,total_cases),0)*100 as DeathPercentage
from DataExp.dbo.CovidDeaths
order by 1,2

--Total Cases vs Population

select location, date, population, total_cases, total_deaths, 
CONVERT(float,total_cases)/NULLIF(CONVERT(float,population),0)*100 as PercentPopulationInfected
from DataExp.dbo.CovidDeaths
order by 1,2

-- Countries with Highest Infection rate compared to population

select location, population, MAX(total_cases) as HighestInfectionCount,  
MAX(CONVERT(float,total_cases)/NULLIF(CONVERT(float,population),0))*100 as PercentPopulationInfected
from DataExp.dbo.CovidDeaths
group by location, population
order by 4 DESC


-- Countries with Highest Death count per population
select location, MAX(cast(total_deaths as int)) as TotalDeathCount  
from DataExp.dbo.CovidDeaths
where continent is not NULL
group by location
order by TotalDeathCount DESC


-- Continents with Highest Death count per population

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount  
from DataExp.dbo.CovidDeaths
where continent is not NULL
group by continent
order by TotalDeathCount DESC

-- Global Numbers

select date, sum(new_cases) as TotalCasesWW, sum(cast(new_deaths as int)) as TotalDeathsWW,
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from DataExp.dbo.CovidDeaths
where continent is not NULL
group by date
order by 1,2


-- Total Population vs Total Vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(INT,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
from DataExp..CovidDeaths dea
join DataExp..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not NULL
order by 2,3

-- CTE

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(INT,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
from DataExp..CovidDeaths dea
join DataExp..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not NULL
)

select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac


--creating view for later visualisation

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(INT,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
from DataExp..CovidDeaths dea
join DataExp..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not NULL
