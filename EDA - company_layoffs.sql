-- Exploratory Data Analysis on Layoffs

SELECT *
FROM layoffs;

SELECT *
FROM layoffs_staging2;


SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;


SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;


-- Companies with the highest amount of layoffs


SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

SELECT company, YEAR(`date`), SUM(total_laid_off) AS total_layoffs, SUM(percentage_laid_off) AS percentage_total_layoffs
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 2 DESC, 3 DESC;


SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;


-- Industry and  country with the highest amount of layoffs


SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;


SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;



-- Industry with the highest funding


SELECT industry, SUM(funds_raised_millions) total_funds_raised_millions
FROM layoffs_staging2
GROUP BY industry
ORDER BY total_funds_raised_millions DESC;


SELECT YEAR(`date`) AS years, ROUND(SUM(percentage_laid_off),0) AS total_percent_laid_off
FROM layoffs_staging2
WHERE YEAR(`date`) IS NOT NULL
GROUP BY years
ORDER BY years;



-- Layoffs by Year


SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;


SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;


-- Rolling total of layoffs by month and year 


SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
;


WITH Rolling_Total AS
(
SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
)
SELECT `MONTH`, total_off
,SUM(total_off) OVER(ORDER BY `MONTH`) AS rolling_total
FROM Rolling_Total;



-- Total layoffs per company per year


SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;


SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;


-- Rank of top layoffs by company


WITH Company_Year (company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
), 
Company_Year_Rank AS
(
SELECT *, 
DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
WHERE years IS NOT NULL
)
SELECT * 
FROM Company_Year_Rank 
WHERE Ranking <= 5
;


-- Rank of top layoffs by industry


WITH Industry_Layoffs (industry, years, total_laid_off) AS
(
SELECT industry, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry, YEAR(`date`)
), 
Industry_Layoffs_Rank AS
(
SELECT *, 
DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Industry_Layoffs
WHERE years IS NOT NULL
)
SELECT * 
FROM Industry_Layoffs_Rank 
WHERE Ranking <= 5
;


-- Rank of top layoffs by location


WITH Location_Layoffs (location, years, total_laid_off) AS
(
SELECT location, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY location, YEAR(`date`)
), 
Location_Layoffs_Rank AS
(
SELECT *, 
DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Location_Layoffs
WHERE years IS NOT NULL
)
SELECT * 
FROM Location_Layoffs_Rank 
WHERE Ranking <= 5
;


