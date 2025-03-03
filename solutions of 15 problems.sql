-- 1. Count the number of Movies vs TV Shows
SELECT type,count(*) as total_content FROM netflix1 
group by type


-- 2. Find the most common rating for movies and TV shows
with cte as(select type,rating,count(*) as total_count, 
rank() over (partition by type order by count(*) desc) as rnk 
from netflix1
group by type,rating
order by type,count(*) desc)
 select type,rating,total_count   from cte where rnk=1
 
 
 -- 3. List all movies released in a specific year (e.g., 2020)
 SELECT * 
FROM netflix1
WHERE release_year = 2020
and type='Movie'


-- 4. Find the top 5 countries with the most content on Netflix
SELECT * 
FROM (
    SELECT 
        country_list.country AS country,
        COUNT(*) AS total_content
    FROM netflix1,
        JSON_TABLE(
            CONCAT('["', REPLACE(country, ',', '","'), '"]'), 
            "$[*]" COLUMNS (country VARCHAR(255) PATH "$")
        ) AS country_list
    GROUP BY country_list.country
) AS country_counts  
WHERE country_counts.country IS NOT null
ORDER BY total_content DESC 
LIMIT 5;


-- 5. Identify the longest movie
SELECT *
FROM netflix1
WHERE type = 'Movie'
ORDER BY CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) DESC
limit 1


-- 6. Find content added in the last 5 years
select * ,STR_TO_DATE(date_added, '%M %d, %Y') from netflix1 
where STR_TO_DATE(date_added, '%M %d, %Y')>=date_sub(curdate(),interval 5 year)


-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
select * from netflix1 where director like'%Rajiv Chilaka%'



-- 8. List all TV shows with more than 5 seasons
select  * from netflix1 
where type='TV Show'
and CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED)>5


-- 9. Count the number of content items in each genre
SELECT * 
FROM (
    SELECT 
        listed.listed_in AS country,
        COUNT(*) AS total_content
    FROM netflix1,
        JSON_TABLE(
            CONCAT('["', REPLACE(listed_in, ',', '","'), '"]'), 
            "$[*]" COLUMNS (listed_in VARCHAR(255) PATH "$")
        ) AS listed
    GROUP BY listed.listed_in
) AS country_counts  



-- 10. Find each year and the average numbers of content release by India on netflix. 
-- return top 5 year with highest avg content release !
SELECT 
    YEAR(STR_TO_DATE(date_added, '%M %d, %Y')) as year_,
    COUNT(*),
   round( COUNT(*) / (SELECT 
            COUNT(*)
        FROM
            netflix1
        WHERE
            country = 'India')*100,2) as avg_
FROM
    netflix1
WHERE
    country = 'India'
GROUP BY YEAR(STR_TO_DATE(date_added, '%M %d, %Y'))


-- 11. List all movies that are documentaries
select count(*) from netflix1 
where type='Movie' and listed_in like'%Documentaries%'


-- 12. Find all content without a director
select * from netflix1 where director=''


-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
select count(*) from netflix1
where type='Movie' and casts like '%Salman Khan%'
and release_year>year(date_sub(curdate(),interval 10 year))



/*
Question 15:
Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.
*/
with cte as ( select *,case when lower(description) like "%kill%"
 or lower(description) like "%violence%" then 'bad content' else 'good content' end 
 as category 
 from netflix1)
 select category ,count(*) from cte group by category 





