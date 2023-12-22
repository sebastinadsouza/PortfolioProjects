Select *
 from PortfolioProject..CovidDeaths
 where continent is not null
 order by 3,4

Select *
 from PortfolioProject..CovidVaccinations$
 order by 3,4 

 Select location,date, total_cases, new_cases, total_deaths, population
 from PortfolioProject..CovidDeaths
 order by 1, 2

Select Location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location = 'United States'
order by 1,2


Select Location, date, total_cases, population, (CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location = 'United States'
order by 1,2

Select Location, population, Max (total_cases) as HighestInfectionCount, Max(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--where location = 'United States'
group by location,population
order by PercentPopulationInfected desc


Select Location, Max (Cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location = 'United States'
where continent is not null
group by location
order by TotalDeathCount desc


Select continent, Max (Cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location = 'United States'
where continent is not null
group by continent
order by TotalDeathCount desc


Select date, SUM (new_cases) as total_cases, SUM (new_deaths) as total_deaths, SUM(new_deaths)/ nullif(SUM(new_cases),0)*100 as	DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
Group by date
order by 1, 2


Select SUM (new_cases) as total_cases, SUM (new_deaths) as total_deaths, SUM(new_deaths)/ nullif(SUM(new_cases),0)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
--Group by date
order by 1, 2


select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations,
SUM (convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2, 3

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations,
SUM (convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2, 3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac


Drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continet nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations,
SUM (convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date=vac.date
--where dea.continent is not null
--order by 2, 3
select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated
go

Create View PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations,
SUM (convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date=vac.date
where dea.continent is not null

select *
from PercentPopulationVaccinated