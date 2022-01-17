-- Modify the data
UPDATE covid_vaccinations SET continent = 'Africa' WHERE location = 'Africa';
UPDATE covid_vaccinations SET continent = 'Asia' WHERE location = 'Asia';
UPDATE covid_vaccinations SET continent = 'Europe' WHERE location = 'Europe';
UPDATE covid_vaccinations SET continent = 'Oceania' WHERE location = 'Oceania';
UPDATE covid_vaccinations SET continent = 'North America' WHERE location = 'North America';
UPDATE covid_vaccinations SET continent = 'South America' WHERE location = 'South America';
UPDATE covid_vaccinations SET continent = 'European Union' WHERE location = 'European Union';
DELETE FROM covid_vaccinations WHERE location = 'High income';
DELETE FROM covid_vaccinations WHERE location = 'International';
DELETE FROM covid_vaccinations WHERE location = 'Low income';
DELETE FROM covid_vaccinations WHERE location = 'Lower middle income';
DELETE FROM covid_vaccinations WHERE location = 'Upper middle income';
DELETE FROM covid_vaccinations WHERE location = 'World';

-- Quick overview
SELECT *
FROM covid_vaccinations;

-- Join covid_deaths & covid_vaccinations tables
SELECT *
FROM covid_deaths dea
JOIN covid_vaccinations vac
	ON dea.location = vac.location AND dea.death_date = vac.vac_date;

-- CREATING A CTE
WITH PopvsVac (Continent, Location, GeneralDate, Population, NewVac, TotalVacUpdate)
AS 
	(
	SELECT dea.continent, dea.location, dea.death_date,  dea.population, vac.new_vaccinations,
		SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.death_date) as TotalVacUpdate
	FROM covid_deaths dea
	JOIN covid_vaccinations vac
		ON dea.location = vac.location AND dea.death_date = vac.vac_date
	ORDER BY 2, 3
	)
SELECT *, (TotalVacUpdate/population)*100 AS VacUpdatePercentage
FROM PopvsVac;

-- CREATING TEMP TABLE
DROP TABLE IF EXISTS PercentPopulationVaccinated;
CREATE TABLE  PercentPopulationVaccinated
	(
	Continent TEXT,
	Location TEXT,
	GeneralDate TEXT,
	Population INT,
	NewVaccinations INT,
	TotalVacUpdate INT
	);

INSERT INTO PercentPopulationVaccinated (Continent, Location, GeneralDate, Population, NewVaccinations, TotalVacUpdate)
SELECT dea.continent, dea.location, dea.death_date,  dea.population, vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.death_date) as TotalVacUpdate
FROM covid_deaths dea
JOIN covid_vaccinations vac
	ON dea.location = vac.location AND dea.death_date = vac.vac_date
ORDER BY 2, 3;

SELECT *, (TotalVacUpdate/population)*100 AS VacUpdatePercentage
FROM PercentPopulationVaccinated
