USE App_Store;

-- Data Cleaning
SELECT *
FROM AppleStore

-- Check null values
SELECT *
FROM AppleStore
WHERE ID IS NULL
OR track_name IS NULL
OR size_bytes IS NULL
OR price IS NULL
OR rating_count_tot IS NULL
OR user_rating IS NULL
OR ver IS NULL
OR prime_genre IS NULL
OR 'lang.num' IS NULL

-- Check duplicates
SELECT id
FROM AppleStore
GROUP BY id
HAVING COUNT(*) > 1

-- Change the unit of size_bytes into Megabytes for convenience
ALTER TABLE AppleStore
CHANGE COLUMN size_bytes size_in_mb DECIMAL(20,2)

UPDATE AppleStore
SET size_in_mb = ROUND( size_in_mb / (1024 * 1024), 2)


-- Questions
-- number of free and paid apps
SELECT 
	track_name AS app_name,
	prime_genre AS genre,
    CASE 
		WHEN price > 0 THEN 'paid'
		WHEN price = 0 THEN 'free'
	END AS category,
    price
FROM AppleStore

-- Which genres have the highest average user ratings for all versions of apps, and which have the lowest?
WITH genre_avg_ratings AS (
    SELECT
        prime_genre AS genre,
        AVG(user_rating) AS avg_user_rating
    FROM
        AppleStore
    GROUP BY
        prime_genre
)

SELECT
    genre,
    avg_user_rating
FROM (
    SELECT
        genre,
        avg_user_rating,
        ROW_NUMBER() OVER (ORDER BY avg_user_rating DESC) AS highest_rn,
        ROW_NUMBER() OVER (ORDER BY avg_user_rating ASC) AS lowest_rn
    FROM
        genre_avg_ratings
) AS ranked
WHERE
    highest_rn = 1
    OR lowest_rn = 1

-- How many apps in the dataset support more than five languages?
SELECT 
    (SELECT COUNT(*) FROM AppleStore WHERE `lang.num` > 5)  AS five_languages_above,
    COUNT(*) AS total_apps,
    CONCAT(
        ROUND((SELECT COUNT(*) FROM AppleStore WHERE `lang.num` > 5) / COUNT(*) * 100, 2),
        '%'
    ) AS percentage
FROM AppleStore

-- What is the price distribution for each primary genre?
SELECT
	track_name AS app_name,
    prime_genre AS genre,
    price,
    user_rating
FROM AppleStore

-- price distribution excluding outliner
SELECT
	track_name AS app_name,
    prime_genre AS genre,
    price
FROM AppleStore
WHERE price < 50

-- Which genres have the highest total number of user ratings across all versions of apps, and which have the lowest?
WITH count_user_rating AS (
	SELECT 
		prime_genre AS genre,
		SUM(rating_count_tot) AS total_rating
	FROM AppleStore
    GROUP BY prime_genre
)

SELECT 
	c.genre,
    c.total_rating 
FROM count_user_rating C
WHERE c.total_rating = (SELECT MAX(total_rating) FROM count_user_rating)
OR  c.total_rating = (SELECT MIN(total_rating) FROM count_user_rating)

-- What is the distribution of app sizes (in Megabytes) for a specific genre, and are there any outliers?
SELECT
    track_name AS app_name,
    prime_genre AS genre,
    size_in_mb AS app_size
FROM
    AppleStore

-- As the size of the app increases do they get pricier?
SELECT 
	track_name,
    prime_genre AS genre,
	size_in_mb,
    CASE 
		WHEN price > 0 THEN 'paid'
		WHEN price = 0 THEN 'free'
	END AS category
FROM AppleStore
ORDER BY size_in_mb DESC
    
-- Which genres have the highest and lowest numbers of apps in the dataset?
WITH genre_counts AS (
    SELECT
        prime_genre AS genre,
        COUNT(*) AS numbers_of_apps
    FROM AppleStore
    GROUP BY prime_genre
)

SELECT 
    gc.genre,
    gc.numbers_of_apps
FROM genre_counts gc
WHERE gc.numbers_of_apps = (SELECT MAX(numbers_of_apps) FROM genre_counts)
   OR gc.numbers_of_apps = (SELECT MIN(numbers_of_apps) FROM genre_counts)

-- How many apps have received more than 10,000 user ratings for all versions?
SELECT
	(SELECT COUNT(*) FROM AppleStore WHERE rating_count_tot > 10000) AS more_than_10k,
	COUNT(*) AS total_apps,
    CONCAT(
		ROUND((SELECT COUNT(*) FROM AppleStore WHERE rating_count_tot > 10000) / COUNT(*) * 100, 2),
        '%'
	) AS percentage
FROM AppleStore
