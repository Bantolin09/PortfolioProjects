select *
From PortfolioProj..CovidDeaths$
Where continent is not null
order by 3,4

--select *
--From PortfolioProj..CovidVaccinations$
--order by 3,4

-- Select the Data that we are going to be using.
select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProj..CovidDeaths$
Where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Likelihood of dying from Covid-19 in Canada.
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProj..CovidDeaths$
Where location like '%Canada%'
order by 1,2

-- Total cases vs Population
-- Percentage of population that has contracted Covid-19
select location, date, total_cases, population, (total_cases/population)*100 as InfectionPercentage
From PortfolioProj..CovidDeaths$
Where location like '%Canada%'
order by 1,2

-- Countries with the highest Infection Rate compared to Population
select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as InfectionPercentage
From PortfolioProj..CovidDeaths$
Where continent is not null
Group by location, population
order by InfectionPercentage desc

-- Showing countries with highest Death Count per population
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProj..CovidDeaths$
Where continent is not null
Group by location
order by TotalDeathCount desc

-- Death count for each continent
select continent, MAX(cast(total_deaths as bigint)) as TotalDeathCount
From PortfolioProj..CovidDeaths$
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- Global Numbers by date
select date, SUM(new_cases) as TotalCases , SUM(cast( new_deaths as bigint)) as TotalDeaths, SUM (cast(new_deaths as bigint))/SUM(new_cases) * 100 as DeathPercentage
From PortfolioProj..CovidDeaths$
Where continent is not null
Group By date
order by 1,2

-- Global numbers
select SUM(new_cases) as TotalCases , SUM(cast( new_deaths as bigint)) as TotalDeaths, SUM (cast(new_deaths as bigint))/SUM(new_cases) * 100 as DeathPercentage
From PortfolioProj..CovidDeaths$
Where continent is not null
order by 1,2

-- How many People have been vaccinated?
Select deaths.continent, deaths.location, deaths.date, deaths.population, vaccinations.new_vaccinations
, SUM(CONVERT(bigint, vaccinations.new_vaccinations)) OVER (Partition by deaths.location Order by deaths.location, deaths.Date) as RollingPeopleVaccinated --(RollingPeopleVaccinated/population) * 100
From PortfolioProj..CovidDeaths$ deaths
Join PortfolioProj..CovidVaccinations$ vaccinations
on deaths.location = vaccinations.location
and deaths.date = vaccinations.date
where deaths.continent is not null
order by 2, 3

--CTE Method
With PopVsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select deaths.continent, deaths.location, deaths.date, deaths.population, vaccinations.new_vaccinations
, SUM(CONVERT(bigint, vaccinations.new_vaccinations)) OVER (Partition by deaths.location Order by deaths.location, deaths.Date) as RollingPeopleVaccinated --(RollingPeopleVaccinated/population) * 100
From PortfolioProj..CovidDeaths$ deaths
Join PortfolioProj..CovidVaccinations$ vaccinations
on deaths.location = vaccinations.location
and deaths.date = vaccinations.date
where deaths.continent is not null
)
Select *, (RollingPeopleVaccinated/population)*100 as VaccinatedPopulationPercentage
From PopVsVac

--TEMP TABLE method
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar (255),
date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select deaths.continent, deaths.location, deaths.date, deaths.population, vaccinations.new_vaccinations
, SUM(CONVERT(bigint, vaccinations.new_vaccinations)) OVER (Partition by deaths.location Order by deaths.location, deaths.Date) as RollingPeopleVaccinated --(RollingPeopleVaccinated/population) * 100
From PortfolioProj..CovidDeaths$ deaths
Join PortfolioProj..CovidVaccinations$ vaccinations
on deaths.location = vaccinations.location
and deaths.date = vaccinations.date
where deaths.continent is not null

Select *, (RollingPeopleVaccinated/population)*100 as VaccinatedPopulationPercentage
From #PercentPopulationVAccinated

--View
Create View PercentPopulationVaccinated as 
Select deaths.continent, deaths.location, deaths.date, deaths.population, vaccinations.new_vaccinations
, SUM(CONVERT(bigint, vaccinations.new_vaccinations)) OVER (Partition by deaths.location Order by deaths.location, deaths.Date) as RollingPeopleVaccinated --(RollingPeopleVaccinated/population) * 100
From PortfolioProj..CovidDeaths$ deaths
Join PortfolioProj..CovidVaccinations$ vaccinations
on deaths.location = vaccinations.location
and deaths.date = vaccinations.date
where deaths.continent is not null