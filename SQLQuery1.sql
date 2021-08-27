-- Recent summary of the infection data
With CTE As
(Select tbl1.location, cast(Max(tbl1.date) as date) as 'latest_date' From SQLPro1..covid_deaths as tbl1 Group by tbl1.location) --latest date for each country

Select tbl2.location,
Format(tbl2.total_cases,'#,0') as 'total_cases',
Format(tbl2.total_cases_per_million/1000000,'#,0.00%') as 'infection_rate',
Format(Cast(total_deaths as int),'#,0') as 'total_deaths',
Format(Cast(total_deaths_per_million as float)/1000000,'#,0.00%') as 'death_rate',
Format(population,'#,0') as 'population'
From SQLPro1..covid_deaths as tbl2
Where tbl2.continent IS NOT NULL
AND Exists(Select * From CTE Where location = tbl2.location AND latest_date = tbl2.date)
Order by tbl2.location


--Breakdown by continents
Drop Table If Exists Temp
Create Table #Temp
(location nvarchar(255),
latest_date date)
Insert into #Temp
Select location, Convert(date,Max(date)) From SQLPro1..covid_deaths Group by location

Select location,
Format(tbl2.total_cases,'#,0') as 'total_cases',
Format(Convert(int,total_deaths),'#,0') as 'total_deaths'
From SQLPro1..covid_deaths as tbl2
Where tbl2.continent IS NULL
AND Exists(Select * From #Temp Where location = tbl2.location AND latest_date = tbl2.date)
Order by tbl2.location


--Vaccination information by countries
Create View vax_data As
Select vax.location, Cast(vax.date as date) as 'date',
Format(Cast(vax.new_vaccinations as int),'#,0') as 'new_vaccination_number',
Format(Cast(vax.total_vaccinations as int),'#,0') as 'total_vaccination',
Format(Cast(vax.people_vaccinated_per_hundred as float)/100,'#,0.00%') as 'percentage_vaccination',
Format(Cast(vax.people_fully_vaccinated_per_hundred as float)/100,'#,0.00%') as 'percentage_fully_vaccinated',
Format(Cast(deaths.population as int),'#,0') as 'population'
From SQLPro1..covid_vax as vax
Inner Join SQLPro1..covid_deaths as deaths
On vax.location = deaths.location AND vax.date = deaths.date
Where vax.continent IS NOT NULL

Use SQLPro1

