Select *
From PortfolioProject.dbo.covid_deaths
order by 3,4

--Select *
--From PortfolioProject.dbo.covid_vaccinations$
--order by 3,4

-- Select data that we're going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject.dbo.covid_deaths
order by 1,2

-- Looking at Total cases vs Total Deaths

Select location, date, total_cases, total_deaths, CONVERT(float, total_deaths)/CONVERT(float, total_cases)*100 as mortality_percentage_rate
From PortfolioProject.dbo.covid_deaths
Where location like '%kingdom%'
order by 1,2

-- Looking at Total Cases vs Population

Select location, date, total_cases, population, CONVERT(float, total_cases)/CONVERT(float, population)*100 as percent_pop_infected
From PortfolioProject.dbo.covid_deaths
Where location like '%kingdom%'
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

Select location, population, MAX(CAST(total_cases as int)) as Total_Infection_Count, MAX(CONVERT(float, total_cases)/CONVERT(float, population))*100 as percent_pop_infected
From PortfolioProject.dbo.covid_deaths
Group by location, population
order by percent_pop_infected desc

--Showing Countries with Highest Death Count per Population

Select location, population, MAX(CAST(total_deaths as int)) as Total_Death_Count, MAX(CONVERT(float, total_deaths)/CONVERT(float, population))*100 as percent_mortality_rate
From PortfolioProject.dbo.covid_deaths
Group by location, population
order by percent_mortality_rate desc

-- Showing max deaths grouped by continent

Select continent, MAX(CAST(total_deaths as int)) as Total_Death_Count
From PortfolioProject.dbo.covid_deaths
Where continent is not null
Group by continent
order by Total_Death_Count  desc

-- GLOBAL NUMBERS

Select date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/NULLIF(SUM(new_cases),0)*100 as percent_mortality_rate
From PortfolioProject.dbo.covid_deaths
Where continent is not null
Group by date
Order by 1,2

-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(float, vac.new_vaccinations )) OVER (Partition by dea.location Order by dea.location, dea.date) as rolling_vaccinations
From PortfolioProject.dbo.covid_deaths dea
Join PortfolioProject.dbo.covid_vaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Working out percentage of people that are vaccinated, using CTE
-- Is showing that more than 100% of the population is vaccianted, but I don't think it accounts for multiple vaccaintions given to same person.

With PopvsVac (continent, location, date, population, new_vaccinations, rolling_vaccinations)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(float, vac.new_vaccinations )) OVER (Partition by dea.location Order by dea.location, dea.date) as rolling_vaccinations
From PortfolioProject.dbo.covid_deaths dea
Join PortfolioProject.dbo.covid_vaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *, (rolling_vaccinations/population)*100 as percentage_vaccinated_rolling
From PopvsVac
--Where location like '%kingdom%'

-- Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_vaccinations numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(float, vac.new_vaccinations )) OVER (Partition by dea.location Order by dea.location, dea.date) as rolling_vaccinations
From PortfolioProject.dbo.covid_deaths dea
Join PortfolioProject.dbo.covid_vaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *, (rolling_vaccinations/population)*100 as percentage_vaccinated_rolling
From #PercentPopulationVaccinated

--Creating View to store data for later visualisations

