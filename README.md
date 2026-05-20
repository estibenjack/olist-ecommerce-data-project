# 🚀 Brazilian E-Commerce End-to-End Data Analytics Project

## 🎭 Business Scenario

It's late 2018, and I'm working as a Data Analyst for Olist, a Brazilian e-commerce marketplace. The executive leadership team has requested a clear picture of how the business has performed over the previous two years, with a particular focus on revenue growth, regional performance and customer satisfaction.

To support this, I needed to answer several key business questions.

**The main question:**
- How can Olist improve sustainable growth while maintaining customer satisfaction across regions and product categories?

**Supporting questions:**
- Is revenue growth being driven by increasing order volume or higher-value purchases?
- How does delivery performance impact customer satisfaction?
- Which regions experience the worst delivery performance, and how does it affect satisfaction?
- Which product categories create the greatest operational or customer satisfaction risks?

The challenge was that the data was fragmented across 9 CSV files and contained inconsistencies, missing values and Portuguese product category names.

My goal was to design and build an end-to-end analytics pipeline that transformed this raw operational data into a structured reporting layer capable of supporting executive decision-making.

---

## 📊 Dataset

This project uses the [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce), sourced from Kaggle.

The dataset contains 1.5 million rows across 9 tables covering real commercial transactions between 2016 and 2018, including orders, customers, products, sellers, payments, reviews and geolocation data.

---

## 🛠️ Tools Used

| Tool | Purpose |
|---|---|
| PostgreSQL | Data cleaning, transformation, modelling and analysis |
| SQL | Layered pipeline from raw ingestion through to business-ready analytical views |
| Power BI | Interactive dashboard development and business visualisation |
| GitHub | Project documentation and version control |

---

## 🏗️ Data Architecture

I structured this project using a layered analytics approach, moving from raw source data into cleaned staging models and finally into business-ready reporting tables.

The goal was to keep the raw data untouched, clean and standardise it in staging, and then build reliable analytical models for reporting in Power BI.

### Raw Layer (`raw/`)
The raw layer contains the original CSV data loaded directly into the database with no transformations applied.

I mainly used this layer for profiling and data quality checks before building any transformations. I wanted to understand how reliable the data was, spot inconsistencies early, and avoid issues later when calculating KPIs.

During a full exploratory data quality assessment, I checked for:
- Duplicate primary keys
- Missing values in important columns
- Invalid dates and delivery records
- Geography spelling inconsistencies
- Pricing and payment outliers
- One-to-many joins that could inflate metrics

Key profiling issues I found included:

- Over 1M geolocation rows with lots of duplicate ZIP mappings
- Seller city names entered in many different formats
- Coordinates outside Brazil that needed filtering
- Products missing category and metadata information
- Orders marked as delivered but missing delivery dates
- Orders using multiple payment records
- Around 8% of deliveries arriving late

These findings helped shape the cleaning logic I later built in the staging layer.

_**Example logic: Profiling checks**_
```sql
-- Validate customer_id uniqueness
SELECT
    customer_id,
    COUNT(*) AS frequency
FROM raw.customers
GROUP BY 1
HAVING COUNT(*) > 1;

-- Identify inconsistent seller city names
SELECT
    seller_city,
    COUNT(*) AS frequency
FROM raw.sellers
GROUP BY 1
ORDER BY 1 ASC;
```
---

### Cleaning Layer (`staging/`)
The staging layer contains cleaned and standardised views built to prepare the source data for reliable analysis.

This is where I handled most of the transformation work needed to make the data reliable for analysis.

Some of the cleaning and transformation steps included:
- Standardising city and state names
- Removing invalid geographic records
- Deduplicating geolocation data
- Translating Portuguese product categories
- Validating timestamps
- Filtering anomalous future dates
- Aggregating payment rows before joins
- Creating delivery performance flags

I also used this layer to fix structural issues I found during profiling, especially around geography inconsistencies and duplicated payment behaviour.

_**Example logic: Adding the `is_late_delivery` flag**_
```sql
SELECT 
    order_id,
    order_estimated_delivery_date,
    order_delivered_customer_date,
    CASE 
        WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1 
        ELSE 0 
    END AS is_late_delivery
FROM staging.stg_orders;
```

---

### Analytics Layer (`gold/`)
The analytics/marts layer contains the final business-ready models used for reporting and dashboarding.

Here, I consolidated transactional, customer, payment, delivery, and review data into denormalised analytical views that could support KPI tracking and business analysis in Power BI.

Main analytical models:
- `fact_sales`
- `monthly_revenue`
- `revenue_growth`
- `delivery_performance`
- `customer_segments`
- `region_segment_ltv`
- `category_risk`

These models support analysis across:
- Revenue trends
- Customer behaviour
- Delivery performance
- Seller activity
- Payment preferences
- Product category performance
- Customer review trends

_**Example logic: Building the customer segments**_
```sql
WITH customer_stats AS (
	SELECT
		customer_id,
		customer_city,
		customer_state,
		COUNT(DISTINCT order_id) AS total_orders,
		SUM(total_item_value) AS lifetime_value,
		MAX(order_purchase_timestamp) AS last_purchase_date
	FROM gold.fact_sales
	GROUP BY 1, 2, 3
)
SELECT
	*,
	CASE
		WHEN total_orders > 1 THEN 'Repeat Customer'
		WHEN total_orders = 1 AND lifetime_value > 200 THEN 'High-Value One-Timer'
		ELSE 'Standard Customer'
	END as segment_label
FROM customer_stats;
```

---

## 📈 Key KPIs Analysed

### Revenue & Growth
- Total Revenue
- Average Order Value (AOV)
- Monthly Revenue Growth

### Customer Experience
- Customer Review Score
- Average Delivery Time
- Late Delivery Rate
- Freight as % of Order Value

### Commercial Performance
- Regional Sales Performance
- Product Category Performance
- Customer Segmentation

---

## ⚙️ Current Project Progress

### ✅ Completed
- Data profiling and quality assessment
- Raw-to-staging cleaning pipeline
- Data standardisation and transformation
- Gold-layer analytical view creation
- KPI and business question definition

### 🚧 In Progress
- Power BI dashboard development
- Executive reporting and storytelling
- Final business insights and recommendations

--- 
