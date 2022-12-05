--Looking at the Data Bases

Select *
From PortfolioProject..CovidDeaths$
where continent!=Null OR continent!=''
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations$
--order by 3,4

-- Select data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths (%)
-- Shows the likelyhood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
Where location like '%argentina%'
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of the population got Covid

Select Location, date, total_cases, population, (total_cases/population)*100 as InfectionPercentage
From PortfolioProject..CovidDeaths$
Where location like '%argentina%'
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as InfectionPercentage
From PortfolioProject..CovidDeaths$
where continent is not null
Group by Location, population
order by InfectionPercentage desc

-- LET'S BREAK THINGS DOWN BY CONTINENT

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
Where continent!=null or continent!=''
Group by continent
order by TotalDeathCount desc

-- Showing the countries with the highest Deat Count per population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
Where continent!=null or continent!=''
Group by Location
order by TotalDeathCount desc


-- GLOBAL NUMBERS

Select date, SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Global_DeathPercentage
From PortfolioProject..CovidDeaths$
Where continent!=null or continent!=''
Group by date
order by 1,2

-- Looking at Total Population vs Vaccinations

With PopVsVac (continent, Location, Date, Population,new_vaccionations, vac_sum_per_country)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as vac_sum_per_country
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent!='' OR dea.continent!=NULL
--order by 1,2,3
)
Select *, (vac_sum_per_country/Population)*100 as VacPercentage
from PopVsVac


-- TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
vac_sum_per_country numeric,
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, cast(vac.new_vaccinations as float)
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as vac_sum_per_country
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac 
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent!='' OR dea.continent!=NULL
--order by 1,2,3

Select *, (vac_sum_per_country/Population)*100 as VacPercentage
from #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

drop view if exists PercentPopulationVaccinated

CREATE VIEW PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as vac_sum_per_country
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac 
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent!='' OR dea.continent!=NULL
--order by 1,2,3

SELECT *
FROM PercentPopulationVaccinated

