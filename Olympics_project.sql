

SELECT name, gender, country_code, country, birth_date
FROM Projects..athletes

-- Checking if duplicate number of athletes in data

SELECT name, gender, country_code, country, birth_date, COUNT(name) as Number_of_athletes
FROM Projects..athletes
GROUP BY name, gender, country_code, country, birth_date

WITH duplicate_cte AS
(
SELECT name, gender, country_code, country, birth_date, COUNT(name) as Number_of_athletes
FROM Projects..athletes
GROUP BY name, gender, country_code, country, birth_date
)
SELECT *
FROM duplicate_cte
WHERE Number_of_athletes > 1

-- Checking names of athletes and deleting anomolies

SELECT name
FROM Projects..athletes
ORDER BY name

DELETE
FROM Projects..athletes
WHERE name = '671'

--Join tables together

SELECT *
FROM Projects..athletes ATH
JOIN Projects..medals MED
	ON ATH.code = MED.code

-- look at number of medals per country

SELECT ATH.country, MED.medal_type, COUNT(MEDAL_TYPE) AS number_of_medals
FROM Projects..athletes ATH
JOIN Projects..medals MED
	ON ATH.code = MED.code
GROUP BY ATH.country, MED.medal_type
ORDER BY number_of_medals desc

-- number of medals per country by gender

SELECT ATH.country, MED.medal_type, ATH.gender, COUNT(MEDAL_TYPE) AS number_of_medals
FROM Projects..athletes ATH
JOIN Projects..medals MED
	ON ATH.code = MED.code
GROUP BY ATH.country, MED.medal_type, ATH.gender
ORDER BY number_of_medals desc

-- number of medals per country by event discipline

SELECT ATH.country, MED.medal_type, MED.discipline, COUNT(MEDAL_TYPE) AS number_of_medals
FROM Projects..athletes ATH
JOIN Projects..medals MED
	ON ATH.code = MED.code
GROUP BY ATH.country, MED.medal_type, MED.discipline
ORDER BY number_of_medals desc

-- Create views to store data for PowerBI

Create View All Athletes as
SELECT name, gender, country_code, country, birth_date
FROM Projects..athletes

Create View Medallists as
SELECT ATH.name, ATH.gender, ATH.birth_date, ATH.country, MED.medal_type, MED.discipline, MED.event
FROM Projects..athletes ATH
JOIN Projects..medals MED
	ON ATH.code = MED.code
