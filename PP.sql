SELECT *
FROM CovidDeaths

--SELECT *
--FROM CovidVaccinations

--select the data we are going to be using

SELECT location,date, total_cases,new_cases,total_deaths,population
FROM CovidDeaths
order by 1,2


--we are going to look at total cases vs total deaths
--shows the likelihood of dying if you contract covid in your country

SELECT location,date, total_cases,total_deaths,  (total_deaths/total_cases)*100 AS MortalityPercentage
FROM CovidDeaths
WHERE location like '%states%'
order by 1,2

--we are going to look at total cases vs total deaths
--Shows the percentage of the population that got covid to a specific location

SELECT location,date,population, total_cases, (total_cases/population)*100 AS InfectedPopulationPercentage
FROM CovidDeaths
WHERE location like '%states%'
order by 1,2

--looking at countries to countries with highest infection rate compared to population


SELECT location,population, MAX(total_cases) AS highestInfectionCount, MAX((total_cases/population))*100 AS InfectedPopulationPercentage
FROM CovidDeaths
--WHERE location like '%states%'
Group By location,population 
order by InfectedPopulationPercentage desc
 
 --countries with highest Death count per population

 SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent is not Null
Group By location,population 
order by TotalDeathCount desc

--Lets breakthings down by continent

 SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent is Null
Group By location 
order by TotalDeathCount desc

--continents with highest deathcount

 SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent is not Null
Group By location,population 
order by TotalDeathCount desc


--global numbers


SELECT date, SUM(new_cases) AS total_cases,SUM(CAST(new_deaths AS int)) AS total_deaths,  SUM(Cast(new_deaths AS int))/SUM(new_cases)*100 AS MortalityPercentage
FROM CovidDeaths
--WHERE location like '%states%'
Where continent is not null
Group by date
order by 1,2

--LOOKING AT TOTAL POPULATION VS VACCINATIONS

SELECT CD.continent,CD.location, CD.date, CD.population,VAC.new_vaccinations,
SUM(cast(VAC.new_vaccinations as bigint)) over (Partition BY CD.location order by CD.location, CD.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths CD
Join PortfolioProject..CovidVaccinations VAC
ON CD.location = VAC.location
AND CD.date = VAC.date 
where cd.continent is not null
Order By 2,3


--use cte
with popvsVac (continent, location,  date, population,new_vaccinations,RollingPeopleVaccinated)
as
(
SELECT CD.continent,CD.location, CD.date, CD.population,VAC.new_vaccinations,
SUM(cast(VAC.new_vaccinations as bigint)) over (Partition BY CD.location order by CD.location, CD.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths CD
Join PortfolioProject..CovidVaccinations VAC
ON CD.location = VAC.location
AND CD.date = VAC.date 
where cd.continent is not null
--Order By 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From popvsVac



--temptable

Create Table PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
NewVaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert Into PercentPopulationVaccinated
SELECT CD.continent,CD.location, CD.date, CD.population,VAC.new_vaccinations,
SUM(cast(VAC.new_vaccinations as bigint)) over (Partition BY CD.location order by CD.location, CD.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths CD
Join PortfolioProject..CovidVaccinations VAC
ON CD.location = VAC.location
AND CD.date = VAC.date 
where cd.continent is not null
--Order By 2,3

--Creating a view for visualization 

Create View PercentagePopulationVaccinated as
SELECT CD.continent,CD.location, CD.date, CD.population,VAC.new_vaccinations,
SUM(cast(VAC.new_vaccinations as bigint)) over (Partition BY CD.location order by CD.location, CD.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths CD
Join PortfolioProject..CovidVaccinations VAC
ON CD.location = VAC.location
AND CD.date = VAC.date 
where cd.continent is not null

Create View InfectionRate as 
SELECT location,population, MAX(total_cases) AS highestInfectionCount, MAX((total_cases/population))*100 AS InfectedPopulationPercentage
FROM CovidDeaths
--WHERE location like '%states%'
Group By location,population 
--order by InfectedPopulationPercentage desc

Create View MortalityRate as
SELECT location,date, total_cases,total_deaths,  (total_deaths/total_cases)*100 AS MortalityPercentage
FROM CovidDeaths
WHERE location like '%states%'
