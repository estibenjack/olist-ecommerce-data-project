# 🚀 Brazilian E-Commerce End-to-End Data Analytics Project

## 🎭 Business Scenario

It is late 2018, and I am working as a Data Analyst for Olist, a Brazilian e-commerce marketplace. The executive leadership team has requested a clear picture of how the business has performed over the previous two years, with a particular focus on revenue growth, regional performance and customer satisfaction.

The executive team wanted answers to several key business questions:

**The main question:**
- How can Olist improve sustainable growth while maintaining customer satisfaction across regions and product categories?

**Supporting questions:**
- Is revenue growth driven by increasing order volume or higher-value purchases?
- How do delivery performance and regional operations impact customer satisfaction?
- Which customer segments and regions generate the highest long-term value?
- Which product categories and sellers create operational or customer satisfaction risks?

The challenge was that the data was fragmented across 9 separate CSV files, contained inconsistencies, missing values and Portuguese product category names.

My goal was to design and build an end-to-end analytics pipeline that transformed this raw operational data into a structured reporting layer capable of supporting executive decision-making.

---

## 📊 Dataset

This project uses the [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce), sourced from Kaggle.

The dataset contains:
- 100k+ orders
- customer information
- product and seller data
- payments
- customer reviews
- geolocation data
- logistics and delivery information

The data covers real commercial transactions between 2016–2018.

---

## 🛠️ Tools Used

| Tool | Purpose |
|---|---|
| PostgreSQL | Data cleaning, transformation, modelling and analysis |
| Power BI | Interactive dashboard development and business visualisation |
| GitHub | Project documentation and version control |

---

## 🏗️ Data Architecture

The project follows a layered analytics architecture informed by modern data warehousing practices.

### Raw Layer (`raw/`)
Contains unmodified source tables imported directly from the CSV files.

Tables:
- raw_customers
- raw_geolocation
- raw_order_items
- raw_order_payments
- raw_order_reviews
- raw_orders
- raw_products
- raw_sellers
- raw_product_category_translation

---

### Cleaning Layer (`staging/`)
Contains cleaned and transformed views used to standardise the source data.

Transformations included:
- handling missing values
- standardising text/city names
- translating Portuguese product categories
- validating timestamps
- calculating delivery durations
- removing duplicate or invalid records

---

### Analytics Layer (`gold/`)
Contains business-ready analytical models used for reporting and dashboarding.

Key analytical views:
- `fact_sales`
- `monthly_revenue`
- `delivery_performance`
- `customer_segments`

These analytical views aggregate transactional, customer, delivery and review data into business-ready models optimised for KPI reporting and Power BI visualisation.

---

## 📈 Key KPIs Analysed

### Revenue & Growth
- Total Revenue
- Average Order Value (AOV)
- Monthly Revenue Growth

### Customer Experience
- Customer Review Score
- Average Delivery Time

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
