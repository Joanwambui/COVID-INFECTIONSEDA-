SELECT *
FROM coviddeathscsv
ORDER BY 3,4

SELECT *
FROM sqldata..covv
ORDER BY 3,4

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM sqldata..coviddeathscsv
ORDER BY 1,2

--looking at total cases vs total deaths/likeliood of dying if you contract covid
SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS deathperctge
FROM sqldata..coviddeathscsv
ORDER BY 1,2

SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS deathperctge
FROM sqldata..coviddeathscsv
WHERE location LIKE '%states%'
ORDER BY 1,2

ALTER TABLE coviddeathscsv
ALTER COLUMN population float;

ALTER TABLE coviddeathscsv
ALTER COLUMN total_cases float;

--percetge of popltn that have covid
SELECT location,date,total_cases,population, (total_cases/population)*100 AS casesperctge
FROM sqldata..coviddeathscsv
WHERE location LIKE '%states%'
ORDER BY 1,2


SELECT location,population,MAX(total_cases) AS  highestinfectionrate,MAX((total_cases/population))*100 AS percetgepoptinfected
FROM sqldata..coviddeathscsv
GROUP BY location,population
ORDER BY percetgepoptinfected DESC

SELECT location,MAX(CAST(total_deaths as int)) as totaldeathcount
FROM sqldata..coviddeathscsv
WHERE continent is not null
GROUP BY location
ORDER BY totaldeathcount desc

--LETS BREAK THINGS DOWN BY CONTINENT
SELECT continent,MAX(CAST(total_deaths as int)) as totaldeathcount
FROM sqldata..coviddeathscsv
WHERE continent is not null
GROUP BY continent
ORDER BY totaldeathcount desc

SELECT location,MAX(CAST(total_deaths as int)) as totaldeathcount
FROM sqldata..coviddeathscsv
WHERE continent is null
GROUP BY location
ORDER BY totaldeathcount desc

--Global numbers
SELECT date,SUM(new_cases) as totalglocases
FROM sqldata..coviddeathscsv
WHERE continent is not null
GROUP BY date
ORDER BY 1 desc

SELECT date,SUM(new_cases) newcases,SUM(total_deaths) totaldeaths,SUM(new_cases)/SUM(total_deaths)*100 AS deathperc
FROM sqldata..coviddeathscsv
WHERE continent is not null
GROUP BY date
ORDER BY 1 desc

SELECT date,SUM(new_cases) newcases,SUM(total_deaths) totaldeaths,SUM(new_cases)/SUM(total_deaths)*100 AS deathperc
FROM sqldata..coviddeathscsv
WHERE continent is not null
GROUP BY date
ORDER BY 1 desc

SELECT SUM(new_cases) newcases,SUM(total_deaths) totaldeaths,SUM(new_cases)/SUM(total_deaths)*100 AS deathperc
FROM coviddeathscsv
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2 desc

SELECT SUM(new_cases) newcases,SUM(total_deaths) totaldeaths,SUM(new_cases)/SUM(total_deaths)*100 AS deathperc
FROM coviddeathscsv
WHERE continent is not null
--GROUP BY date
ORDER BY 1 desc

SELECT dea.continent,dea.location,dea.date,dea.population,vac.total_vaccinations
FROM sqldata..coviddeathscsv dea
JOIN sqldata..covv vac
    ON dea.location=vac.location
	AND dea.date=vac.date

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location,dea.date)
FROM sqldata..coviddeathscsv dea
JOIN sqldata..covv vac
    ON dea.location=vac.location
	AND dea.date=vac.date

---CTE
WITH Popsvac(continent,location,date,population,new_vaccinations,rollingpeoplevaccinated)
AS
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location,dea.date) AS rollingpeoplevaccinated
FROM sqldata..coviddeathscsv dea
JOIN sqldata..covv vac
    ON dea.location=vac.location
	AND dea.date=vac.date
WHERE dea.continent is null
)
SELECT*, (rollingpeoplevaccinated/population)*100
FROM Popsvac

--TEMP TABLE
DROP TABLE if exists #percentpopulationvaccinated
CREATE TABLE #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)

CREATE VIEW percentpopulationvaccinated AS
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location,dea.date) AS rollingpeoplevaccinated
FROM sqldata..coviddeathscsv dea
JOIN sqldata..covv vac
    ON dea.location=vac.location
	AND dea.date=vac.date
WHERE dea.continent is null

--SELECT*, (rollingpeoplevaccinated/population)*100
FROM Popsvac





