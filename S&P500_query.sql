CREATE TABLE CompanyData (
    CompanyName VARCHAR(50) PRIMARY KEY,
    MarketCapitalization BIGINT NULL,
    Income BIGINT NULL,
    Revenue BIGINT NULL,
    BookValuePerShare DECIMAL(18,2) NULL,
    CashPerShare DECIMAL(18,2) NULL,
    Dividend DECIMAL(18,2) NULL,
    DividendYield DECIMAL(18,4) NULL,
    FullTimeEmployees INT NULL,
    OptionsTrading VARCHAR(10) NULL,
    ShortSelling VARCHAR(10) NULL,
    MeanRecommendation DECIMAL(18,1) NULL,
    PriceToBook DECIMAL(18,2) NULL,
    PriceToFreeCashFlow DECIMAL(18,2) NULL,
    CurrentRatio DECIMAL(18,1) NULL,
    TotalDebtToEquity DECIMAL(18,2) NULL,
    NextYearEPSEstimate DECIMAL(18,2) NULL,
    InsiderOwnership DECIMAL(18,4) NULL,
    InstitutionalOwnership DECIMAL(18,4) NULL,
    SharesOutstanding BIGINT NULL,
    SharesFloat BIGINT NULL,
    RelativeVolume DECIMAL(18,2) NULL,
    AverageVolume BIGINT NULL,
    Volume BIGINT NULL,
    AverageTrueRange DECIMAL(18,2) NULL,
    PreviousClose DECIMAL(18,2) NULL
);

SELECT * FROM CompanyData;

-- Market Cap Cutoffs
WITH ranked_companies AS (
  SELECT
    CompanyName,
    MarketCapitalization,
    ROW_NUMBER() OVER (ORDER BY MarketCapitalization) AS numb_row,
    COUNT(*) OVER () AS total_companies
  FROM
    CompanyData
), percentiles as(
SELECT
  CompanyName,
  MarketCapitalization,
  CASE
    WHEN numb_row <= total_companies * 0.33 THEN 'Small-cap'
    WHEN numb_row <= total_companies * 0.66 THEN 'Mid-cap'
    ELSE 'Large-cap'
  END AS market_cap_category
FROM
  ranked_companies) 
SELECT * FROM PERCENTILES WHERE CompanyName = 'AMZN' ;

-- Revenue and net income performance by market capitalization
SELECT 
    CompanyName, MarketCapitalization, Income, Revenue, 
    (Income / MarketCapitalization) * 100 AS IncomePercentage, 
    (Revenue / MarketCapitalization) * 100 AS RevenuePercentage
FROM 
    CompanyData
WHERE Income is not null and Revenue is not null
ORDER BY 
    MarketCapitalization desc
LIMIT 5;

-- Dividend and dividend yield performance by market capitalization 

SELECT CompanyName, MarketCapitalization, Dividend, DividendYield
FROM 
    CompanyData
WHERE 
    Dividend IS NOT NULL AND DividendYield IS NOT NULL
ORDER BY 
    MarketCapitalization DESC
LIMIT 5;

-- PricetoBook (mrq) and PricetoFreeCashFlow (ttm) Ratios
SELECT
    CompanyName,
    PriceToBook,
    PriceToFreeCashFlow
FROM
    CompanyData
WHERE
    PriceToBook IS NOT NULL AND
    PriceToFreeCashFlow IS NOT NULL;
    
WITH pb_pc_ratio AS (
  SELECT
    CompanyName,
    PriceToBook,
    PriceToFreeCashFlow
  FROM
    CompanyData
), labels as (
SELECT
  CompanyName,
  PriceToBook, 
  PriceToFreeCashFlow,
  CASE
    WHEN PriceToBook > PriceToFreeCashFlow THEN 'Higher P/B'
    WHEN PriceToBook < PriceToFreeCashFlow THEN 'Higher P/CF'
    WHEN PriceToBook is null or PriceToBook is null THEN 'Undetermined'
    ELSE 'Equal P/B and P/CF'
  END AS comparison_result
FROM
  pb_pc_ratio
) SELECT COMPARISON_RESULT, COUNT(*) FROM LABELS GROUP BY COMPARISON_RESULT;

-- Price to Book (mrq) vs Price to Free Cash Flow analysis based on the market cap
WITH pb_pc_ratio AS (
  SELECT
    CompanyName,
    PriceToBook,
    PriceToFreeCashFlow
  FROM
    CompanyData
),
labels AS (
  SELECT
    CompanyName,
    PriceToBook, 
    PriceToFreeCashFlow,
    CASE
      WHEN PriceToBook > PriceToFreeCashFlow THEN 'Higher P/B'
      WHEN PriceToBook < PriceToFreeCashFlow THEN 'Higher P/CF'
      WHEN PriceToBook is null or PriceToFreeCashFlow is null THEN 'Undetermined'
      ELSE 'Equal P/B and P/CF'
    END AS comparison_result
  FROM
    pb_pc_ratio
),
ranked_companies AS (
  SELECT
    CompanyName,
    MarketCapitalization,
    ROW_NUMBER() OVER (ORDER BY MarketCapitalization) AS numb_row,
    COUNT(*) OVER () AS total_companies
  FROM
    CompanyData
),
combined_data AS (
  SELECT
    rc.CompanyName,
    rc.MarketCapitalization,
    l.PriceToBook,
    l.PriceToFreeCashFlow,
    l.comparison_result,
    CASE
      WHEN rc.numb_row <= rc.total_companies * 0.33 THEN 'Small-cap'
      WHEN rc.numb_row <= rc.total_companies * 0.66 THEN 'Mid-cap'
      ELSE 'Large-cap'
    END AS market_cap_category
  FROM
    ranked_companies rc
  JOIN
    labels l ON rc.CompanyName = l.CompanyName
)
SELECT
  comparison_result,
  market_cap_category,
  COUNT(*) AS count
FROM
  combined_data
GROUP BY
  comparison_result,
  market_cap_category
ORDER BY
  count desc;

-- Debt-to-Equity Ratio vs Dividend Yield Performance
with cte as (
SELECT
  CompanyName,
  TotalDebtToEquity AS DebtToEquityRatio,
  DividendYield,
  CASE
    WHEN TotalDebtToEquity < 1 AND DividendYield >= (SELECT AVG(DividendYield) FROM CompanyData WHERE DividendYield IS NOT NULL) THEN 'Low Debt-to-Equity & High Dividend Yield'
    WHEN TotalDebtToEquity >= 1 AND DividendYield >= (SELECT AVG(DividendYield) FROM CompanyData WHERE DividendYield IS NOT NULL) THEN 'High Debt-to-Equity & High Dividend Yield'
    WHEN TotalDebtToEquity < 1 AND DividendYield < (SELECT AVG(DividendYield) FROM CompanyData WHERE DividendYield IS NOT NULL) THEN 'Low Debt-to-Equity & Low Dividend Yield'
    WHEN TotalDebtToEquity >= 1 AND DividendYield < (SELECT AVG(DividendYield) FROM CompanyData WHERE DividendYield IS NOT NULL) THEN 'High Debt-to-Equity & Low Dividend Yield'
    ELSE 'Unknown'
  END AS Scenario
FROM
  CompanyData) SELECT Scenario, COUNT(*) as count FROM CTE GROUP BY SCENARIO ORDER BY count desc;

-- Cash Per Share vs Book Per Share Value
SELECT
    CompanyName,
    CashPerShare,
    BookValuePerShare
FROM
    CompanyData
WHERE CashPerShare is not null and BookValuePerShare is not null
order by MarketCapitalization desc
limit 5;


