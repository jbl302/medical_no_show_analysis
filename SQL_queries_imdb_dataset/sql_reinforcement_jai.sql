-- 1. count the total number of records in each table of the database

use imdb;
show tables;


select count(*) as count_of_director_mapping from director_mapping ; -- count(*) counting the rows in result set
select count(*) as count_genre from genre ;
select count(*) as count_movie from movie;
select count(*) as count_names from names ;
select count(*) as count_ratings from ratings ;
select count(*) as count_role_mapping from role_mapping ;

-- 2 identify which columns in the movie table contain null values.
select * from movie;
SELECT DISTINCT column_name -- is null for checking null values and union for combining the result
FROM (
    SELECT 'id' AS column_name FROM movie WHERE id IS NULL
    UNION
    SELECT 'title' FROM movie WHERE title IS NULL
    UNION
    SELECT 'year' FROM movie WHERE year IS NULL
    UNION
    SELECT 'date_published' FROM movie WHERE date_published IS NULL
    UNION
    SELECT 'duration' FROM movie WHERE duration IS NULL
    UNION
    SELECT 'country' FROM movie WHERE country IS NULL
    UNION
    SELECT 'worlwide_gross_income' FROM movie WHERE worlwide_gross_income IS NULL
    UNION
    SELECT 'languages' FROM movie WHERE languages IS NULL
    UNION
    SELECT 'production_company' FROM movie WHERE production_company IS NULL
) AS null_columns; 
    
/* 3.Determine the total number of movies released each year, and analyze how the trend changes
month-wise. */
select distinct year as year ,count(*) as number_of_movie_released from movie
	group by year; -- group by year for year wise count
    
select year(date_published) as year_published,month(date_published) as month_published, count(*) as number_of_movie_released
	from movie
	group by year_published, month_published order by year_published; -- month wise count after grouping by year

-- 4. How many movies were produced in either the USA or India in the year 2019

select count(*) as count_of_movies from movie
	where country in ('USA','India') and year = 2019 ; -- using where and (and) for two conditions  

-- 5. List the unique genres in the dataset, and count how many movies belong exclusively to one genre.
select distinct genre from genre; -- distinct for getting unique genre
select count(*) as one_genre_count from (select movie_id, count(genre) from genre
	group by movie_id
    having count(genre) =1) as one_movie;
	
-- 6. Which genre has the highest total number of movies produced 
select genre,count(*) as count_genre from genre
	group by genre order by count_genre desc limit 1;
    
-- 7. Calculate the average movie duration for each genre.
 select g.genre,round(avg(m.duration),2) as average_duration from genre as g
 inner join movie as m on g.movie_id = m.id
 group by g.genre order by average_duration ;

/* 8. Identify actors or actresses who have appeared in more than three movies with an average
rating below 5 */

SELECT n.name,COUNT(rm.movie_id) AS movie_count, avg_rating
FROM names n
    INNER JOIN role_mapping rm ON n.id = rm.name_id -- joining role mapping and names
    INNER JOIN ratings r ON rm.movie_id = r.movie_id -- joining ratings and role mapping
GROUP BY 
    n.name,r.avg_rating -- grouping based on name and average rating
HAVING 
    COUNT(rm.movie_id) >=1 -- filtering
    AND r.avg_rating < 5
ORDER BY 
    avg_rating ASC;
    
/* 9. Find the minimum and maximum values for each column in the ratings table, excluding the
movie_id column*/
select * from ratings;
select max(avg_rating), min(avg_rating) ,max(total_votes), min(total_votes)
	,max(median_rating), min(median_rating) from ratings;

 -- 10. Which are the top 10 movies based on their average rating 
 select * from movie;
 select m.title,r.avg_rating from movie m 
	inner join ratings r on m.id = r.movie_id
    order by r.avg_rating desc  limit 10;

-- 11. Summarize the ratings table by grouping movies based on their median ratings.
select r.median_rating,max(r.avg_rating), max(r.total_votes)  from ratings as r
    group by r.median_rating;
select r.median_rating,min(r.avg_rating), min(r.total_votes)  from ratings as r
    group by r.median_rating;
    
/* 12. How many movies, released in March 2017 in the USA within a specific genre, had more
than 1,000 votes? */
select g.genre, count(*) as movie_count
from movie as m
    inner join genre g on m.id = g.movie_id -- joining genre to movie 
    inner join ratings r on r.movie_id = m.id -- rating to movie
where year(m.date_published) = 2017  -- filtering before grouping
    and month(m.date_published) = 3 
    and m.country = 'USA' 
    and r.total_votes > 1000
group by g.genre; -- grouping by genre



use imdb;
select * from movie;
select * from ratings;
select * from role_mapping;
select * from names;
show tables;
select * from genre;
select * from director_mapping; 


/* 13. Find movies from each genre that begin with the word “The” and have an average rating
greater than 8 */
select g.genre, m.title,r.avg_rating from movie m
	inner join genre g on g.movie_id = m.id
    inner join ratings r on g.movie_id = r.movie_id
	where m.title like 'the%' and r.avg_rating>8
    group by g.genre, m.title,r.avg_rating;

/* 14. Of the movies released between April 1, 2018, and April 1, 2019, how many received a
median rating of 8 */
select count(*)  as count_movies from movie m
	inner join ratings r on r.movie_id = m.id
    where m.date_published between '2018-04-1' and '2019-04-01'
    and r.median_rating>8;

/* 15. Do German movies receive more votes on average than Italian movies? */
select * from movie;
select case -- creating condtion 
	when (
		select m.languages,avg(r.avg_rating) from movie m  -- selecting language and avg rating
		inner join ratings r on r.movie_id = m.id -- joining movie and rating
		where m.languages = 'German')>(select m.languages,avg(r.avg_rating) from movie m 
		inner join ratings r on r.movie_id = m.id
		where m.languages = 'Italian') -- filtering the language
        then 'Yes german rating high' -- if true 
        else 'No german rating low' -- else this statement
        end as result;
        
-- 16. Identify the columns in the names table that contain null values
select * from names;

SELECT DISTINCT column_name
FROM (
    SELECT 'id' AS column_name FROM names WHERE id IS NULL
    UNION
    SELECT 'name' FROM names WHERE name IS NULL
    UNION
    SELECT 'height' FROM names WHERE height IS NULL
    UNION
    SELECT 'date_of_birth' FROM names WHERE date_of_birth IS NULL
    UNION
    SELECT 'known_for_movies' FROM names WHERE known_for_movies IS NULL
) AS null_columns;

/* 17. Who are the top two actors whose movies have a median rating of 8 or higher? */
select n.name ,r.median_rating from names as n
	inner join role_mapping rm on rm.name_id = n.id -- joins
    inner join ratings r on rm.movie_id = r.movie_id
    where r.median_rating>8 and rm.category = 'actor' -- filtering 
    order by r.median_rating limit 2; -- getting top 2

/* 18. Which are the top three production companies based on the total number of votes their
movies received? */
select m.production_company,sum(r.total_votes) as sum_total_votes from movie m 
	inner join ratings r on r.movie_id = m.id
    group by m.production_company
    order by  sum(r.total_votes)  desc limit 3; -- top 3 grouping based on total votes

-- 19. How many directors have worked on more than three movies?
select * from movie;
select * from director_mapping;
select * from role_mapping;
select count(*) as total_directors from (select d.name_id, count(*) as movie_director_count from director_mapping d
	inner join movie m on d.movie_id = m.id
     group by d.name_id
     having count(*)>3) as subquery;

-- 20. Calculate the average height of actors and actresses separately
select * from role_mapping;
select * from names;
select rm.category,round(avg(n.height),2) as average_height from names n
    join role_mapping rm on rm.name_id = n.id
    group by rm.category;

-- 21. List the 10 oldest movies in the dataset along with their title, country, and director. 
select * from movie;
select * from director_mapping;

select m.title,m.country,d.name_id,m.year from movie m
	inner join director_mapping d on d.movie_id = m.id
    order by m.year asc limit 10;

-- 22. List the top 5 movies with the highest total votes, along with their genres.
select genre from genre;
select g.genre, sum(r.total_votes) as sum_total_votes from genre g
	inner join ratings r on r.movie_id = g.movie_id
    group by g.genre
    order by sum(r.total_votes)  desc limit 10;

-- 23. Identify the movie with the longest duration, along with its genre and production company.
select m.duration, g.genre, m.production_company from movie m
	inner join genre g on m.id = g.movie_id
    order by m.duration desc limit 1;
    
-- 24. Determine the total number of votes for each movie released in 2018.
select m.title ,sum(r.total_votes)as sum_total_votes from movie m
	inner join ratings r on m.id = r.movie_id
    where m.year = 2018
    group by m.title
    order by sum(r.total_votes) desc;
-- 25. What is the most common language in which movies were produced?
select languages, count(*) as language_count from movie
	group by languages order by language_count desc limit 1;


 



