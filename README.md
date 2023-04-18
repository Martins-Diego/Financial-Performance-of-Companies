# Financial Performance of Companies from S&P500

## Business Problem

The S&P500 is an index of the 500 largest publicly traded companies in the United States and is considered a reliable barometer of the overall health of the US economy. For businesses in industries such as banking and consulting, understanding the financial performance of companies within it is crucial for making informed decisions about investments and partnerships. In this report, we have explored a dataset that contains financial performance information from the most recent year of the S&P500 index. Our goal was to extract relevant insights that can inform decision-making in the business world.

## Processed Data Overview

![S&P500_Dashboard_SS.png](Financial%20Performance%20of%20Companies%20from%20S&P500%20dd88e954c2064223845df261e89b3dec/SP500_Dashboard_SS.png)

## Data Collection

- [https://www.kaggle.com/datasets/ilyaryabov/financial-performance-of-companies-from-sp500](https://www.kaggle.com/datasets/ilyaryabov/financial-performance-of-companies-from-sp500)

## Data Pre-Processing

To prepare the Financial Performance of Companies from S&P500 dataset for analysis, we used VBA due to its compatibility with Excel and its ability to handle complex processing tasks.

1. **First of all, we found the columns with K (thousands) , M (millions) or B (billions) values**

```sql
Sub FindColumns()
Dim lastColumn As Long, lastRow As Long, i As Long, j As Long
Dim cellValue As String
Dim columnList As String

lastRow = Cells(Rows.Count, 1).End(xlUp).Row
lastColumn = Cells(1, Columns.Count).End(xlToLeft).Column

For i = 3 To lastColumn
    For j = 2 To lastRow
        cellValue = CStr(Cells(j, i).value)
        If InStr(cellValue, "K") > 0 Or InStr(cellValue, "M") > 0 Or InStr(cellValue, "B") > 0 Then
            columnList = columnList & Cells(1, i).Address(False, False) & ", "
            Exit For
        End If
    Next j
Next i

If columnList = "" Then
    Debug.Print "No columns with K, M, or B values found."
Else
    Debug.Print "Columns with K, M, or B values: " & Left(columnList, Len(columnList) - 2)
End If
End Sub
```

1. **After that, we found the columns with percentile values** 

```sql
Sub FindPercentileColumns()
Dim lastColumn As Long, lastRow As Long, i As Long, j As Long
Dim cellValue As String
Dim columnList As String

lastRow = Cells(Rows.Count, 1).End(xlUp).Row
lastColumn = Cells(1, Columns.Count).End(xlToLeft).Column

For i = 3 To lastColumn
    For j = 2 To lastRow
        If VarType(Cells(j, i).value) = vbDouble Then
            If Cells(j, i).NumberFormat = "0.00%" Or Cells(j, i).NumberFormat = "0.0%" Or Cells(j, i).NumberFormat = "0%" Then
                columnList = columnList & Cells(1, i).Address(False, False) & ", "
                Exit For
            End If
        Else
            cellValue = CStr(Cells(j, i).value)
            If InStr(cellValue, "%") > 0 Then
                columnList = columnList & Cells(1, i).Address(False, False) & ", "
                Exit For
            End If
        End If
    Next j
Next i

If columnList = "" Then
    Debug.Print "No columns with percentile values found."
Else
    Debug.Print "Columns with percentile values: " & Left(columnList, Len(columnList) - 2)
End If

End Sub
```

MySQL uses specific data types to store data, and percentages are not among them. Changing percentage values to the general format ensures that the data will be recognized by the database, allowing it to be properly stored and processed

3. **Then, we converted the K, M, and B column values into numeric types** 

```sql
Sub ConvertColumnsToNumeric()
    Dim lastRow As Long, i As Long
    Dim value As String
    lastRow = Cells(Rows.Count, "C").End(xlUp).Row
    
    For i = 2 To lastRow
        value = Cells(i, "C").value
        If Not IsEmpty(value) And value <> "null" Then
            value = Replace(value, "K", "*1000")
            value = Replace(value, "M", "*1000000")
            value = Replace(value, "B", "*1000000000")
            Cells(i, "C").value = Evaluate(value)
        End If
        
        value = Cells(i, "D").value
        If Not IsEmpty(value) And value <> "null" Then
            value = Replace(value, "K", "*1000")
            value = Replace(value, "M", "*1000000")
            value = Replace(value, "B", "*1000000000")
            Cells(i, "D").value = Evaluate(value)
        End If
        
        value = Cells(i, "E").value
        If Not IsEmpty(value) And value <> "null" Then
            value = Replace(value, "K", "*1000")
            value = Replace(value, "M", "*1000000")
            value = Replace(value, "B", "*1000000000")
            Cells(i, "E").value = Evaluate(value)
        End If
        
        value = Cells(i, "AX").value
        If Not IsEmpty(value) And value <> "null" Then
            value = Replace(value, "K", "*1000")
            value = Replace(value, "M", "*1000000")
            value = Replace(value, "B", "*1000000000")
            Cells(i, "AX").value = Evaluate(value)
        End If
        
        value = Cells(i, "AY").value
        If Not IsEmpty(value) And value <> "null" Then
            value = Replace(value, "K", "*1000")
            value = Replace(value, "M", "*1000000")
            value = Replace(value, "B", "*1000000000")
            Cells(i, "AY").value = Evaluate(value)
        End If
        
        value = Cells(i, "BH").value
        If Not IsEmpty(value) And value <> "null" Then
            value = Replace(value, "K", "*1000")
            value = Replace(value, "M", "*1000000")
            value = Replace(value, "B", "*1000000000")
            Cells(i, "BH").value = Evaluate(value)
        End If
        
    Next i
End Sub
```

When importing data into a database, it is essential that the data is formatted correctly and consistently to ensure proper indexing, searching, and querying. Additionally, the use of abbreviations such as K, M, or B to represent numeric values can lead to ambiguity and errors.

4. **Finally, we replaced all the empty fields within the dataset** 

```sql
Sub replaceEmpty()
    Dim lastColumn As Long, lastRow As Long, i As Long, j As Long
    Dim cellValue As String
    
    lastRow = Cells(Rows.Count, 1).End(xlUp).Row
    lastColumn = Cells(1, Columns.Count).End(xlToLeft).Column

    For i = 3 To lastColumn
        For j = 2 To lastRow
            cellValue = Trim(CStr(Cells(j, i).value))
            If cellValue = "-" Or cellValue = "" Then
                Cells(j, i).value = "/N"
            End If
        Next j
    Next i
End Sub
```

Empty fields can cause errors or inconsistencies when importing data into databases. By replacing them with a standardized placeholder like "/N", we ensure that the data will be interpreted correctly and consistently across different systems and applications.

## Data Modeling

We created our data table in MySQL and imported the dataset into it

```sql
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
```

## Exploratory Data Analysis (EDA)

To conduct the present exploratory data analysis, market capitalization was considered as the main variable for analyzing the other indicators. Market capitalization refers to the total value of a company's outstanding shares, which is calculated by multiplying the current market price of a single share by the total number of outstanding shares. In cases where a company did not provide information on a particular indicator, the subsequent ranking based on market capitalization was considered.

### Market Capitalization Cutoffs

In the context of the S&P 500, companies are generally considered large-cap stocks. However, within the index, you can still differentiate between large-cap, mid-cap, and small-cap based on the range of market capitalizations represented in the index. One common approach to determine the cutoffs for high, middle, and low market cap within the index is to use percentiles

```sql
WITH ranked_companies AS (
  SELECT
    CompanyName,
    MarketCapitalization,
    ROW_NUMBER() OVER (ORDER BY MarketCapitalization) AS numb_row,
    COUNT(*) OVER () AS total_companies
  FROM
    CompanyData
)SELECT
  CompanyName,
  MarketCapitalization,
  CASE
    WHEN numb_row <= total_companies * 0.33 THEN 'Small-cap'
    WHEN numb_row <= total_companies * 0.66 THEN 'Mid-cap'
    ELSE 'Large-cap'
  END AS market_cap_category
FROM
  ranked_companies;
```

### Revenue vs Net Income Performance

Comparing the performance of revenues and net income based on market capitalization can be a useful tool in identifying companies with strong revenues and earnings relative to their market value. With this in mind, a company with a high market capitalization but relatively low revenues and net income may indicate that it is overvalued or that its growth potential is limited. On the other hand, a company with lower market capitalization but strong revenues and net income may be undervalued and have greater growth potential

```sql
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
```

| Company Code | Company Name | Market Cap | Income | Revenue | Income Percentage | Revenue Percentage |
| --- | --- | --- | --- | --- | --- | --- |
| AAPL | APPLE | $2340000000000 | $95170000000 | $388000000000 | 4.0671% | 16.5812% |
| MSFT | MICROSOFT | $1860000000000 | $67450000000 | $204000000000 | 3.6263% | 10.9677% |
| GOOGL | GOOGLE | $1190000000000 | $59970000000 | $283000000000 | 5.0395% | 23.7815% |
| AMZN | AMAZON | $934000000000 | $-2722000000 | $514000000000 | -0.2914% | 55.0321% |
| NVDA | NVIDIA | $583000000000 | $4370000000 | $26970000000 | 0.7496% | 4.6261% |

- **Apple (AAPL)** has the highest market capitalization among these companies, standing at $2,340,000,000,000. It has a solid income percentage of 4.0671% and a revenue percentage of 16.5812%. This indicates that Apple is efficient at generating revenue and retaining profits relative to its market capitalization.
- **Microsoft (MSFT)** is the second-largest company in terms of market capitalization at $1,860,000,000,000. Its income percentage is 3.6263%, and its revenue percentage is 10.9677%. While Microsoft is generating good revenue and income, its percentages are slightly lower compared to Apple.
- **Google (GOOGL)** has a market capitalization of $1,190,000,000,000. It has a higher income percentage (5.0395%) than both Apple and Microsoft, showing strong profitability. Its revenue percentage is also relatively high at 23.7815%, indicating that Google is generating significant revenue compared to its market capitalization.
- **Amazon (AMZN)** has a market capitalization of $934,000,000,000. Interestingly, it has a negative income percentage (-0.2914%), which means the company is not retaining profits and has a net loss. However, Amazon has the highest revenue percentage (55.0321%) among these companies, suggesting that it is generating a large amount of revenue relative to its market capitalization. This could indicate that Amazon is heavily reinvesting its revenue into business operations or facing high costs, leading to a negative net income.
- **NVIDIA (NVDA)** has a market capitalization of $583,000,000,000. Its income percentage is the lowest among these companies at 0.7496%, but its revenue percentage is 4.6261%. This indicates that NVIDIA is generating revenue but has a relatively lower profit margin compared to the other companies in this list.

### Dividend vs Dividend Yield Performance

Analyzing the relationship between dividend and dividend yield in comparison to market capitalization can reveal how companies with different market sizes offer dividends to their shareholders. Its important to note that dividend is a portion of a company's earnings that is distributed to its shareholders, while dividend yield is a measure of the dividend payout as a percentage of the stock price (Dividends per share / Share price). 

![Higher Market CAP.png](Financial%20Performance%20of%20Companies%20from%20S&P500%20dd88e954c2064223845df261e89b3dec/Higher_Market_CAP.png)

Larger companies with high market capitalization may offer lower dividend yields but higher dividend payments due to their financial stability and long-term growth potential. Smaller companies with lower market capitalization may offer higher dividend yields to attract investors and maintain their competitive position in the market.

```sql
SELECT CompanyName, MarketCapitalization, Dividend, DividendYield
FROM 
    CompanyData
WHERE 
    Dividend IS NOT NULL AND DividendYield IS NOT NULL
ORDER BY 
    MarketCapitalization DESC
LIMIT 5;
```

| Company Code | Market Cap | Dividend | Dividend Yield |
| --- | --- | --- | --- |
| AAPL | $2340000000000 | $0.92 | 0.6% |
| MSFT | $1860000000000 | $2.72 | 1.07% |
| NVDA | $583000000000 | $0.16 | 0.07% |
| V | $448000000000 | $1.80 | 0.81% |
| XOM | $442000000000 | $3.64 | 3.31% |
- As stated in the previous prompt, both **AAPL** and **MSFT**, which have high market capitalization, offer relatively low dividend yields, but they still provide significant dividend payments. Furthermore, it is important to note that AAPL has consistently increased its dividend payout over the years which suggests that the company is committed to returning value to its shareholders in the long term, even if it may not be through high dividend yields.
- On the other hand, **NVDA** has an annual dividend of $0.16 per share and the lowest dividend yield of the sample (0.07%). This might imply that the company is focused on reinvesting its profits for growth and may not be as financially stable as AAPL or MSFT despite its considerable market cap.
- Companies like **XOM** present a particular behavior where both their annual dividend per share price and its dividend yield are considerably high, which may point that they are focused on paying out dividends to their shareholders and may not have as much growth potential as other companies that offer lower dividend yields.

### Price to Book (mrq) vs Price to Free Cash Flow (ttm)

Comparing the P/B and P/CF ratios can help investors evaluate a company's financial health and market valuation from different perspectives. While the P/B ratio focuses on the company's net asset value, the P/CF ratio emphasizes the company's ability to generate cash flow. By examining both ratios, investors can get a more comprehensive understanding of a company's overall financial position.

**Scenario 1 → Higher P/B than P/CF**

When a company has a higher P/B ratio compared to its P/CF ratio, it might indicate that the market is valuing the company's assets more than its cash flow generation. This could be the case for companies with significant tangible assets, such as real estate, manufacturing, or financial firms. However, a high P/B ratio could also signify an overvalued stock, particularly if the company's assets are not generating sufficient cash flows. In such cases, investors should be cautious and further analyze the company's financial performance and industry trends before making investment decisions.

**Scenario 2 → Higher P/CF than P/B**

When a company has a higher P/CF ratio compared to its P/B ratio, it might suggest that the market is valuing the company's cash flow generation more than its net assets. This is often the case for companies with strong cash flow generation but relatively fewer tangible assets, such as technology or service-based firms. A high P/CF ratio could indicate that the company is efficient in generating cash flows and has strong growth prospects. However, it might also signal an overvalued stock if the company's cash flows are not sustainable in the long term. Investors should further examine the company's cash flow sources and growth potential to make informed decisions.

```sql
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
```

| Scenario | Cutoff | Number of Companies |
| --- | --- | --- |
| Higher P/CF | Large-cap | 126 |
| Higher P/CF | Mid-cap | 120 |
| Higher P/CF | Small-cap | 115 |
| Undetermined | Small-cap | 44 |
| Undetermined | Mid-cap | 39 |
| Undetermined | Large-cap | 37 |
| Higher P/B | Large-cap | 6 |
| Higher P/B | Mid-cap | 5 |
| Higher P/B | Small-cap | 4 |

In the S&P 500 index, which primarily consists of large-cap companies, there is a predominance of firms with a higher Price to Free Cash Flow ratio compared to the Price to Book ratio. This observation suggests that these companies possess a substantial asset base along with a robust cash flow generation as indicated in the scenarios. The market's inclination towards valuing the cash flow generation capacity of these large-cap firms more than their tangible assets typically indicates their strong financial performance and stability. As a result, large-cap companies are known for their lower volatility and ability to provide investors with a more stable investment experience.

### Debt-to-Equity Ratio vs Dividend Yield Performance

A Debt-to-Equity Ratio vs. Dividend Yield Performance analysis is essential for investors to evaluate a company's financial health and assess its suitability as an investment. This analysis helps investors understand the company's capital structure, risk profile, and ability to return value to shareholders through dividend payments. 

1. **Risk Assessment:** The debt-to-equity ratio measures a company's financial leverage by comparing its total debt to its shareholders' equity. A high debt-to-equity ratio indicates that the company relies more on debt to finance its operations, which could lead to higher interest expenses and increased financial risk. In contrast, a low ratio implies that the company uses more equity financing and is less exposed to debt-related risks.
2. **Dividend Yield:** As explained in a previous analysis, dividend yield is a measure of the annual dividend payment as a percentage of the stock's price. A high dividend yield may suggest that the company is generating sufficient cash flows to distribute to shareholders, which could be attractive to income-seeking investors. However, a high dividend yield could also indicate that the stock price has dropped significantly, raising concerns about the company's financial health and future prospects.

**Scenario 1 → Low Debt-to-Equity Ratio and High Dividend Yield**

This scenario indicates a company with a lower financial risk due to its reliance on equity financing and its ability to return value to shareholders through dividend payments. Such companies might be attractive to income-seeking investors who prefer stable returns and lower risks.

**Scenario 2 → High Debt-to-Equity Ratio and High Dividend Yield**

In this scenario, a company has a high financial risk due to its dependence on debt financing but still manages to pay a high dividend yield. Investors should be cautious and analyze the sustainability of the company's dividend payments, as excessive debt could threaten the company's financial stability and future dividend payouts.

**Scenario 3 → Low Debt-to-Equity Ratio and Low Dividend Yield**

This scenario suggests a company with a lower financial risk but may not provide attractive returns to income-seeking investors due to its low dividend yield. These companies might be focusing on reinvesting their profits for future growth, making them more suitable for growth-oriented investors.

**Scenario 4 → High Debt-to-Equity Ratio and Low Dividend Yield**

A company with a high debt-to-equity ratio and low dividend yield represents a higher financial risk and limited returns to shareholders. Investors should carefully assess the company's ability to service its debt, growth prospects, and potential for future dividend payments before making investment decisions.

```sql
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
  CompanyData) SELECT Scenario, COUNT(*) FROM CTE GROUP BY SCENARIO
```

A high debt-to-equity ratio can vary depending on the industry and the individual company's financial situation. Generally, a debt-to-equity ratio greater than 1 or 100% is considered high, as it indicates that a company has more debt than equity to finance its assets

| Scenario | Number of Companies |
| --- | --- |
| Low Debt-to-Equity & Low Dividend Yield | 144 |
| Unknown | 127 |
| High Debt-to-Equity & High Dividend Yield | 86 |
| Low Debt-to-Equity & High Dividend Yield | 85 |
| High Debt-to-Equity & Low Dividend Yield | 54 |

The largest group of companies falls under the "Low Debt-to-Equity & Low Dividend Yield" category. These companies have lower financial leverage and pay smaller dividends to their shareholders. This could indicate that these companies are either reinvesting their earnings back into the business for growth or have lower profitability, which doesn't allow for higher dividend payments.

### Cash Per Share vs Book Per Share Value

Comparing CPS and BVPS allows investors to assess a company's overall financial health. A higher CPS relative to BVPS could indicate that the company has a strong cash position, which can help it navigate economic downturns, invest in growth opportunities, or weather unexpected financial challenges. Conversely, a lower CPS compared to BVPS may signify potential liquidity issues or a company's reliance on debt or other financing sources.

```sql
SELECT
    CompanyName,
    CashPerShare,
    BookValuePerShare
FROM
    CompanyData
WHERE CashPerShare is not null and BookValuePerShare is not null
order by MarketCapitalization desc
limit 5;
```

| Company Name | Cash Per Share | Book Value Per Share |
| --- | --- | --- |
| AAPL | 3.36 | 3.57 |
| MSFT | 13.59 | 24.58 |
| GOOGL | 9.03 | 19.86 |
| AMZN | 7.04 | 14.29 |
| NVDA | 5.52 | 8.97 |
- **Apple Inc. (AAPL)**: The CPS is relatively close to the BVPS, indicating that a significant portion of Apple's net asset value is held in cash or cash equivalents.
- **Microsoft Corp. (MSFT)**: Microsoft has a lower CPS compared to its BVPS, suggesting that the company holds a mix of cash and non-liquid assets. The company's cash position is still substantial, contributing to more than half of its net asset value.
- **Alphabet Inc. (GOOGL)**: Similar to Microsoft, Alphabet's CPS is less than its BVPS, indicating that the company has a mix of liquid and non-liquid assets. Cash represents a significant portion of Alphabet's net asset value.
- **Amazon.com Inc. (AMZN)**: Amazon's cash position contributes to nearly half of its net asset value. The company has a balance of cash and non-liquid assets in its asset base.
- **NVIDIA (NVDA)**: NVIDIA has a relatively high cash position compared to its BVPS, with cash representing more than half of its net asset value. This suggests a strong liquidity position for the company.

### Average True Range vs Relative Volume

ATR measures a stock's volatility by capturing the average range between its high and low prices over a specific period. High ATR values indicate that a stock is experiencing larger price swings, while low ATR values suggest lower volatility. By other hand, RV compares a stock's current trading volume to its average trading volume over a specified period. A high RV indicates that the stock is experiencing higher-than-average trading activity, while a low RV suggests lower trading activity. By comparing them cross companies in the S&P 500 dataset, investors can better understand the relationship between a stock's volatility and its trading activity. High volatility combined with high trading activity could indicate increased uncertainty or market reactions to specific events. Conversely, low volatility and low trading activity could suggest a stable market environment.

```sql
SELECT
    CompanyName,
    AverageTrueRange,
    RelativeVolume
FROM
    CompanyData
WHERE AverageTrueRange is not null and RelativeVolume is not null
order by MarketCapitalization desc
limit 5;
```

| Company Name | AverageTrueRange | RelativeVolume |
| --- | --- | --- |
| AAPL | 3.30 | 0.59 |
| MSFT | 5.80 | 0.70 |
| GOOG | 2.55 | 0.62 |
| GOOGL | 2.54 | 0.62 |
| AMZN | 2.96 | 0.73 |
- **Apple Inc. (AAPL)**: Apple's ATR indicates moderate price volatility, while its RV suggests that its trading activity is slightly below its average volume. This might imply that the market is experiencing a relatively stable period for Apple's stock.
- **Microsoft Corp. (MSFT)**: Microsoft's ATR is higher than Apple's, suggesting increased price volatility. The RV of 0.70 indicates that the trading activity is somewhat below its average volume. Investors might want to consider the higher volatility when assessing Microsoft's stock.
- **Alphabet Inc. Class C (GOOG)**:  Alphabet's Class C shares have a relatively low ATR, indicating lower price volatility. The RV of 0.62 suggests that trading activity is below its average volume, reflecting a potentially stable market environment for the stock.
- **Alphabet Inc. Class A (GOOGL**): Alphabet's Class A shares show similar characteristics to its Class C shares, with a low ATR and below-average trading activity. This suggests that both classes of Alphabet's shares are experiencing a relatively stable market environment.
- **Amazon.com Inc. (AMZN)**: Amazon's ATR indicates low-to-moderate price volatility. The RV of 0.73 reflects trading activity slightly below its average volume, suggesting a relatively stable market for Amazon's stock.
