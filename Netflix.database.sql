# Create database for netflix
SELECT * FROM netflix.netflix;

# Segment 1: Database - Tables, Columns, Relationships
# Identify the tables in the dataset and their respective columns.
SELECT COUNT(*)
FROM netflix.netflix;

# Determine the number of rows in each table within the schema.
SELECT COUNT(*) AS row_count
FROM netflix.netflix;

# Identify and handle any missing values in the dataset.
SELECT 
    COALESCE(show_id, 'N/A') AS show_id,
    COALESCE(type, 'N/A') AS type,
    COALESCE(title, 'N/A') AS title,
    COALESCE(director, 'N/A') AS director,
    COALESCE(country, 'N/A') AS country,
    COALESCE(date_added, 'N/A') AS date_added,
    COALESCE(release_year, 'N/A') AS release_year,
    COALESCE(rating, 'N/A') AS rating,
    COALESCE(duration, 'N/A') AS duration,
    COALESCE(listed_in, 'N/A') AS listed_in
FROM netflix.netflix;

# Segment 2: Content Analysis
# Analyse the distribution of content types (movies vs. TV shows) in the dataset.
SELECT type, COUNT(*) AS COUNT
FROM netflix.netflix
GROUP BY TYPE;

# Determine the top 10 countries with the highest number of productions on Netflix
SELECT country, COUNT(show_id) AS num_productions
FROM netflix.netflix
GROUP BY country
ORDER BY num_productions DESC
LIMIT 10;

# -	Investigate the trend of content additions over the years.
SELECT YEAR(STR_TO_DATE(date_added, '%m/%d/%Y')) AS year,
COUNT(*) AS content_count
FROM netflix.netflix GROUP BY YEAR ORDER BY year;

# Analyse the relationship between content duration and release year.
select type,release_year,
       AVG(CASE WHEN type = 'Movie' THEN duration_minutes END) AS avg_movie_duration,
       AVG(CASE WHEN type = 'TV Show' THEN duration_seasons END) AS avg_tv_show_duration
FROM (
    SELECT *,
           CASE WHEN type = 'Movie' THEN CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) END AS duration_minutes,
           CASE WHEN type = 'TV Show' THEN CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) END AS duration_seasons
    FROM netflix.netflix
) AS data  
group by type , release_year;

# Identify the directors with the most content on Netflix.
SELECT director, COUNT(*) AS production_count
FROM netflix.netflix GROUP BY director
ORDER BY production_count DESC
LIMIT 10;

# Segment 3: Genre and Category Analysis
# Determine the unique genres and categories present in the dataset.
SELECT * FROM
(
SELECT distinct type as genre,listed_in as categories
from netflix.netflix
) t;

# Calculate the percentage of movies and TV shows in each genre.
SELECT TYPE as genre,
       COUNT(*) AS total_count,
       (COUNT(CASE WHEN type = 'Movie' THEN 1 END) * 100.0 / COUNT(*)) AS movie_percentage,
       (COUNT(CASE WHEN type = 'TV Show' THEN 1 END) * 100.0 / COUNT(*)) AS tv_show_percentage
FROM netflix.netflix
GROUP BY genre;

# Identify the most popular genres/categories based on the number of productions.
SELECT listed_in AS genre_category,
	COUNT(*) AS production_count
FROM netflix.netflix 
GROUP BY listed_in 
ORDER BY production_count DESC;

# Calculate the cumulative sum of content duration within each genre.

SELECT TYPE AS genre, SUM(duration) AS cumulative_duration
FROM netflix.netflix
GROUP BY genre;

# Segment 4: Release Date Analysis
# Determine the distribution of content releases by month and year. 
SELECT MONTH(STR_TO_DATE(date_added, '%m/%d/%Y')) AS month,YEAR(STR_TO_DATE(date_added, '%m/%d/%Y')) AS year,
COUNT(*) AS count
FROM Netflix.netflix
GROUP BY  month ,year;

# Analyse the seasonal patterns in content releases.
SELECT
    MONTH(STR_TO_DATE(date_added, '%m/%d/%Y')) AS month,
    YEAR(STR_TO_DATE(date_added, '%m/%d/%Y')) AS year,
    COUNT(*) AS count
FROM netflix.netflix
GROUP BY month, year
ORDER BY year, month;

# Identify the months and years with the highest number of releases.
SELECT
    MONTH(STR_TO_DATE(date_added, '%m/%d/%Y')) AS month,
    YEAR(STR_TO_DATE(date_added, '%m/%d/%Y')) AS year,
    COUNT(*) AS Highest_release
FROM netflix.netflix
GROUP BY month, year
ORDER BY Highest_release DESC;

# Segment 5: Rating Analysis
# Investigate the distribution of ratings across different genres.
SELECT listed_in,
       rating,
       COUNT(*) AS rating_count
FROM netflix.netflix
GROUP BY listed_in, rating
ORDER BY rating_count desc;

# Analyse the relationship between ratings and content duration.
SELECT duration, listed_in,
       rating,
       COUNT(*) AS rating_count
FROM netflix.netflix
GROUP BY listed_in ,duration, rating
ORDER BY listed_in , duration, rating;

# Segment 6: Co-occurrence Analysis
# Identify the most common pairs of genres/categories that occur together in content.
SELECT * FROM
(
SELECT distinct type,listed_in,duration,
count(*) over (partition by type,listed_in,duration) as co_occurence
FROM netflix.netflix
) t
where co_occurence>1
ORDER BY type,listed_in,duration;

# Analyse the relationship between genres/categories and content duration.
SELECT * FROM
(
SELECT Distinct type, listed_in,
count(*) OVER (PARTITION BY type, listed_in) AS co_occurence
FROM netflix.netflix
) t
WHERE co_occurence > 1
ORDER BY type, listed_in;

# Segment 7: International Expansion Analysis
# Identify the countries where Netflix has expanded its content offerings.
SELECT distinct country
FROM netflix.netflix
WHERE date_added IS NOT NULL;

# Analyse the distribution of content types in different countries.
SELECT country,type, COUNT(*) AS content_count
FROM netflix.netflix
GROUP BY country, type
ORDER BY country, content_count DESC;

# Investigate the relationship between content duration and country of production.
SELECT country,
       AVG(CASE WHEN type = 'Movie' THEN duration_minutes END) AS avg_movie_duration,
       AVG(CASE WHEN type = 'TV Show' THEN duration_seasons END) AS avg_tv_show_duration
FROM (
    SELECT *,
           CASE WHEN type = 'Movie' THEN CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) END AS duration_minutes,
           CASE WHEN type = 'TV Show' THEN CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) END AS duration_seasons
    FROM netflix.netflix
) AS data
GROUP BY country;

# Segment 8: Recommendations for Content Strategy

/Recommendations for Content Strategy Based on the analysis, provide recommendations for the types of content Netflix should focus on producing./
SELECT listed_in, COUNT(*) AS Content_count
FROM Netflix.netflix
GROUP BY listed_in
ORDER BY Content_count ;
 
  /Identify potential areas for expansion and growth based on the analysis of the dataset./
SELECT country, COUNT(*) AS count
FROM Netflix.netflix
WHERE country IS NOT NULL
GROUP BY country
ORDER BY count DESC
LIMIT 10;