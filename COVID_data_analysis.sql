--SELECT *
--FROM ErikaSQLProject..CovidDeaths
--ORDER BY 3,4 --to order by country alphebatically but also by date from first date to last date

--SELECT *
--FROM ErikaSQLProject..CovidVaccinations
--ORDER BY 3,4

----------------- Select Data to use:
--SELECT Location, date, population, total_cases, new_cases, total_deaths
--FROM ErikaSQLProject..CovidDeaths
--ORDER BY 1,2 --to order by country and by date

-----------------Percentage of Total Deaths out of Total Cases ordered by Country
--SELECT Location, date, population, total_cases, total_deaths, FORMAT (total_deaths/total_cases, 'p') as "Death %" 
--FROM ErikaSQLProject..CovidDeaths
--WHERE Location like '%United States%'
--ORDER BY 1,2 --to order by country and by date

-----------------Percentage of Total Cases out of Population number ordered by Country
--SELECT Location, Date, Population, total_cases, FORMAT (total_cases/population, 'p') AS "Contracted %" 
--FROM ErikaSQLProject..CovidDeaths
--WHERE Location like '%United States%'
--ORDER BY 1,2 --to order by country and by date

-----------------Countries with highest infection rates compared to population, ordered from most to least
--SELECT Location, Date, Population, MAX(total_cases) AS "Highest Infection Count", MAX( FORMAT (total_cases/population, 'p')) as "Population Infected %" 
--FROM ErikaSQLProject..CovidDeaths
--GROUP BY Location,Date, Population
--ORDER BY Location, "Highest Infection Count", "Population Infected %" desc 

------------------Countries with highest death count per population
--SELECT Location, MAX(total_deaths) as TotalDeathCount
--FROM ErikaSQLProject..CovidDeaths
--GROUP BY Location
--ORDER BY TotalDeathCount

--SELECT 
--    d.Location,
--    d.Date,
--    d.Population,
--    d.total_cases AS [Highest Infection Count],
--    FORMAT(d.total_cases * 1.0 / d.Population, 'P') AS [Population Infected %]
--FROM ErikaSQLProject..CovidDeaths d
--JOIN (
--    SELECT Location, MAX(total_cases) AS MaxCases
--    FROM ErikaSQLProject..CovidDeaths
--    GROUP BY Location
--) maxes
--ON d.Location = maxes.Location AND d.total_cases = maxes.MaxCases
--ORDER BY Location, [Population Infected %] DESC;



---------------------Countries with highest deaths and date
--SELECT 
--d.Location,
--d.Date,
--d.total_deaths as "Total Death Count"
--FROM ErikaSQLProject..CovidDeaths d
--JOIN (
--      SELECT Location, MAX(total_deaths) as MAXDeaths
--      FROM ErikaSQLProject..CovidDeaths
--      WHERE Continent is not null --Some data has continents as countries and NULL in continent
--      GROUP BY Location) maxes
--ON d.Location = maxes.Location AND d.total_deaths = maxes.MAXDeaths
--ORDER BY "Total Death Count" desc



--------------------Countries with highest deaths NO dates: No join
--SELECT Location, MAX(total_deaths) as "Total Death Count"
--FROM ErikaSQLProject..CovidDeaths
--WHERE continent is not null
--GROUP BY Location
--Order by "Total Death Count" desc


------------------Continents with highest deaths
--SELECT Location as Continent, MAX(total_deaths) as "Total Deaths Count"
--FROM ErikaSQLProject..CovidDeaths
--WHERE continent is null --The data has continents under the location column to allocate their data, and so NULL for the column continent
--GROUP BY Location
--ORDER BY "Total Deaths Count" desc

--SELECT Continent, MAX(total_deaths) as "Total Deaths Count"
--FROM ErikaSQLProject..CovidDeaths
--WHERE continent is not null 
--GROUP BY continent
--ORDER BY "Total Deaths Count" desc


-------------------GLOBAL STUFF: all deaths and all acases in the world
--SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, FORMAT(SUM(new_deaths)/SUM(new_cases), 'P') AS "Death %"
--FROM ErikaSQLProject..CovidDeaths
--WHERE continent is not null
--ORDER BY 1,2


------------------Total Population vs Vaccination
--SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, 
--SUM(v.new_vaccinations) OVER (PARTITION BY d.Location ORDER BY d.Location, d.Date) AS "Rolling People Vaccinated"
--FROM ErikaSQLProject..CovidDeaths d
--JOIN ErikaSQLProject..CovidVaccinations v
--     ON d.location = v.location
--     AND d.date = v.date
--WHERE d.continent is not null
--ORDER BY 2,3



-------------------USE A CTE: In order to use the Rolling Poeple Vaccination Column-The CTE columns must match the SELECT columns
--WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, "Rolling People Vaccinated")
--AS
--(
--SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, 
--SUM(v.new_vaccinations) OVER (PARTITION BY d.Location ORDER BY d.Location, d.Date) AS "Rolling People Vaccinated"
--FROM ErikaSQLProject..CovidDeaths d
--JOIN ErikaSQLProject..CovidVaccinations v
--     ON d.location = v.location
--     AND d.date = v.date
--WHERE d.continent is not null
--)
--SELECT *, FORMAT("Rolling People Vaccinated"/Population, 'p') AS "Vaccination % Increase"
--FROM PopvsVac


------------------TEMP TABLE: Also tu use the column "Rolling People Vaccinated"
--DROP TABLE if exists #PercentPopulationVaccinated
--CREATE TABLE #PercentPopulationVaccinated
--(
--Continent nvarchar(255),
--Location nvarchar(255),
--Date datetime,
--Population float,
--New_vaccinations float,
--"Rolling People Vaccinated" float
--)

--INSERT INTO  #PercentPopulationVaccinated
--SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, 
--SUM(v.new_vaccinations) OVER (PARTITION BY d.Location ORDER BY d.Location, d.Date) AS "Rolling People Vaccinated"
--FROM ErikaSQLProject..CovidDeaths d
--JOIN ErikaSQLProject..CovidVaccinations v
--     ON d.location = v.location
--     AND d.date = v.date
----WHERE d.continent is not null

--SELECT *, FORMAT("Rolling People Vaccinated"/Population, 'p') AS "Vaccination % Increase"
--FROM #PercentPopulationVaccinated


-----------------------CREATING VIEW FOR VISUALIZATIONS LATER

CREATE VIEW PercentPopulationVaccinated AS
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, 
SUM(v.new_vaccinations) OVER (PARTITION BY d.Location ORDER BY d.Location, d.Date) AS "Rolling People Vaccinated"
FROM ErikaSQLProject..CovidDeaths d
JOIN ErikaSQLProject..CovidVaccinations v
     ON d.location = v.location
     AND d.date = v.date
WHERE d.continent is not null

