select * from CovidDeaths
where continent is not null
order by 3,4

/*Select Data that we are going to using*/
select location, date, total_cases, new_cases, total_deaths, population 
from CovidDeaths
where continent is not null
order by 3 DESC

/* looking at the total cases vs total deaths */
--Shows likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where location = 'India' and date = '2021-04-30' 
and continent is not null
order by 1,2

--OR
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where Location like '%India%'
and continent is not null
order by 1,2


/* looking at the total cases vs population */
--shows what persentage of population got covid
select location, date, total_cases, population ,(total_cases/population)*100 as PercentPopulationInfected
from CovidDeaths
--where location = 'India' 
where continent is not null
order by PercentPopulationInfected desc

/*Looking at countries with hightest Infection rate compared to population*/
select location, population, MAX(total_cases) AS HighetInfectionCount ,MAX(total_cases/population)*100 as PercentPopulationInfected
from CovidDeaths
--where location = 'India'
where continent is not null
Group by Location, Population
order by PercentPopulationInfected DESC



/*Showing Countries with Highest Death Count per Population */ 
select location, MAX(CAST(Total_deaths AS int)) as TotalDeathCount, population
from CovidDeaths
where continent is not null
Group by Location, population
order by TotalDeathCount DESC



/*Showing contintents with the highest death count per population */
select continent, MAX(CAST(Total_deaths AS int)) as TotalDeathCount
from CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount DESC



/*Global Number */
select date,SUM(NEW_CASES) as total_Cases, SUM(CAST(new_deaths AS int))as Total_Deaths ,SUM(CAST(new_deaths AS int))/SUM(NEW_CASES)*100 as  DeathPercentage
from CovidDeaths
where continent is not null
GROUP BY DATE
order by 1,2


-- CovidVaccinations
select * from CovidDeaths d
Join CovidVaccinations v
ON d.location = v.location
and d.date = v.date


/*Total Population vs Vaccinations*/
select  d.continent, d.location, d.date, d.population, v.new_vaccinations
,sum(convert(int, v.new_vaccinations)) over (partition by d.location order by d.location, d.date) as RollingPeopleVaccinated
from CovidDeaths d
Join CovidVaccinations v
ON d.location = v.location
and d.date = v.date
where d.continent is not null
order by 2, 3


/* USE CTE */
With PopvsVac(continent, location,date, population,new_vaccinations, RollingPeopleVaccinated)
as
(select  d.continent, d.location, d.date, d.population, v.new_vaccinations,
 sum(convert(int, v.new_vaccinations)) over (partition by d.location order by d.location, d.date) as RollingPeopleVaccinated
from CovidDeaths d
Join CovidVaccinations v
ON d.location = v.location
and d.date = v.date
where d.continent is not null
--order by 2, 3
)
select *,(RollingPeopleVaccinated/population)*100 
from PopvsVac


/*Temp Table */
DROP TABLE IF EXISTS #percentagePopulationVaccinate

Create Table #percentagePopulationVaccinate
(
Continent nvarchar(255),
Location nvarchar(255),
Date Datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #percentagePopulationVaccinate
select  d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(convert(int, v.new_vaccinations)) over (partition by d.location order by d.location, d.date) as RollingPeopleVaccinated
from CovidDeaths d
Join CovidVaccinations v
ON d.location = v.location
and d.date = v.date
--where d.continent is not null
--order by 2, 3

select * ,(RollingPeopleVaccinated/population)*100
from #percentagePopulationVaccinate



/*Creating view to store data for later*/
Create view percentagePopulationVaccinate as
select  d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(convert(int, v.new_vaccinations)) over (partition by d.location order by d.location, d.date) as RollingPeopleVaccinated
from CovidDeaths d
Join CovidVaccinations v
ON d.location = v.location
and d.date = v.date
where d.continent is not null
--order by 2, 3

select *
from percentagePopulationVaccinate
