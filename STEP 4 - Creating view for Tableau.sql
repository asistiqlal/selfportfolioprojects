-- Creating view to store data for later visualization
CREATE VIEW [VaccinatedPopulation] AS
SELECT dea.continent, dea.location, dea.death_date,  dea.population, vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.death_date) as TotalVacUpdate
FROM covid_deaths dea
JOIN covid_vaccinations vac
	ON dea.location = vac.location AND dea.death_date = vac.vac_date
ORDER BY 2, 3;