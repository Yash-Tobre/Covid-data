-- Data Selection

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- Looking at Total cases vs Total Deaths with death percentage: India
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Fatality_Rate
FROM PortfolioProject..CovidDeaths
where location like '%india%'
ORDER BY 1

-- Looking at Total cases vs Total Deaths with death percentage: States
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Fatality_Rate
FROM PortfolioProject..CovidDeaths
where location like '%states%'
ORDER BY 1

-- Looking at Total cases vs Total population with death percentage: States.
-- Showing what percentage of population has gotten covid
SELECT Location, date, total_cases, population, (total_cases/population)*100 as InfectionRate
FROM PortfolioProject..CovidDeaths
where location like '%states%'
ORDER BY 1,2

-- Looking at Total cases vs Total population with death percentage: India.
-- Showing what percentage of population has gotten covid
SELECT Location, date, total_cases, population, (total_cases/population)*100 as InfectionRate
FROM PortfolioProject..CovidDeaths
where location like '%india%'
ORDER BY 1,2


-- Finding out the countries with highest infection rate
SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population)*100) as HighestInfectionRate
FROM PortfolioProject..CovidDeaths
group by Location, Population
order by HighestInfectionRate desc
--Curiousity: Which one is the highest in count and which one is highest in infection rate

-- Showing the countries with the highest death count per population
SELECT Location, MAX(CAST(Total_deaths AS INT)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
where continent is not null --imp
group by Location
order by TotalDeathCount desc
--In the result there are wrong locations like Asia, World, High_income, we want to remove that since it happened because there were NULL values in continent.


-- Let us break things by Continent

-- Showing the continents with the highest death count
SELECT continent, MAX(CAST(Total_deaths AS INT)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
where continent is not null --imp
group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS


SELECT 
    date, 
    SUM(new_cases) as TotalNewCases, 
    SUM(new_deaths) as TotalNewDeaths, 
    CASE 
        WHEN SUM(new_cases) = 0 THEN 0  -- Handling division by zero
        ELSE (SUM(new_deaths) / SUM(new_cases)) * 100 
    END as DeathPercentage
FROM 
    PortfolioProject..CovidDeaths
WHERE 
    continent IS NOT NULL

GROUP BY 
    date
ORDER BY 
    1,2;


--joining tables, looking at total population vs total vaccinations
Select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
SUM(CAST(v.new_vaccinations AS DECIMAL(18,2))) OVER (Partition by d.location order by d.location, d.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths d 
Join PortfolioProject..CovidVaccinations v
ON
    d.location = v.location 
and d.date = v.date
where d.continent is not null
order by 2,3


--Use CTE
With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
--joining tables, looking at total population vs total vaccinations
Select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
SUM(CAST(v.new_vaccinations AS DECIMAL(18,2))) OVER (Partition by d.location order by d.location, d.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths d 
Join PortfolioProject..CovidVaccinations v
ON
    d.location = v.location 
and d.date = v.date
where d.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- TEMP TABLE
DROP Table if exists #VaccinePercentage
Create TABLE #VaccinePercentage
(
Continent NVARCHAR(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated NUMERIC
)

Insert into #VaccinePercentage
Select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
SUM(CAST(v.new_vaccinations AS DECIMAL(18,2))) OVER (Partition by d.location order by d.location, d.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths d 
Join PortfolioProject..CovidVaccinations v
ON
    d.location = v.location 
and d.date = v.date
where d.continent is not null
order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #VaccinePercentage



--creating view to store data for later visualizations
USE PortfolioProject;
GO -- This ensures the CREATE VIEW statement is the first in the batch

CREATE OR ALTER VIEW PercentPopulationVaccinated AS 
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, 
       SUM(CAST(v.new_vaccinations AS DECIMAL(18,2))) OVER (PARTITION BY d.location ORDER BY d.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths d 
JOIN PortfolioProject..CovidVaccinations v ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL;



