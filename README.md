# ecommerce-sales-analysis-sql
End to end SQL analysis of e-commerce sales data (PostgreSQL) with findings and recommendations presented in PPT.
# Amazon India Sales & Customer Analytics (SQL)

A SQL-driven exploration of payments, products, customers, and seasonal trends across the Amazon marketplace — 19 queries across 3 analysis sections, translated into business recommendations for merchandising, payments, and retention strategy.

## 📁 Repository Structure

```
├── data/
│   └── raw_data.xlsx                  # Raw transactional dataset
├── sql/
│   └── queries.sql                   # All 19 analysis queries
├── presentation/
│   └── Amazon_India_Sales_Analysis.pptx   # Key findings & recommendations deck
└── README.md
```

 🔍 Project Overview

This project analyzes Amazon marketplace order, payment, and product data using SQL to uncover patterns in customer behavior, payment method performance, category pricing, and seasonal sales trends — with the goal of surfacing actionable recommendations for go-forward strategy.

The analysis is organized into three sections:

| Section | Focus | Queries |
|---|---|---|
| **I — Foundations** | Payment standardization, seasonal peaks, category price gaps, data quality | 7 |
| **II — Segmentation** | Order-value tiers, category pricing, repeat buyers, customer types, top revenue categories | 5 |
| **III — Trends & Cohorts** | Seasonal totals, monthly revenue, loyalty segments, top customers, product lifecycles, payment growth | 7 |

 📊 Key Findings

1. Credit card dominates** — 73.9% of all orders use credit card, averaging ₹163/transaction (~2.5× a voucher payment). This is the highest-leverage rail for EMI, rewards, and BNPL offers.
2. Mid-year is the peak season** — May, July, and August together generate 4.32M BRL in sales; Spring and Summer combined account for 64% of seasonal revenue.
3. Beleza_saude leads category revenue** — 1.26M BRL, with the top 5 categories combining for 5.39M BRL.
4. 95.5% of customers are one-and-done buyers** — only 2.1% qualify as "Loyal" (>4 orders), making the repeat-purchase funnel the single biggest growth lever.
5. 614 SKUs have missing or malformed categories** — actively hurting search, filtering, and ad targeting.
6. Wide price spreads exist within categories** (e.g., utilidades_domesticas spans a 6,732 BRL range) — signaling opportunity for tiered entry-level vs. premium storefronts.

 ✅ Recommendations

- Build credit-card-first payment incentives (EMI, rewards, BNPL) given its dominant share and consistent mid-range basket size.
- Pre-position inventory ahead of April to capture the May–August demand surge.
- Prioritize retention campaigns targeting the Returning → Loyal transition, since repeat buyers are a small but high-value segment.
- Send a category-enrichment ticket to merchandising to backfill the 614 SKUs with missing categories.
- Introduce tiered storefronts (entry-level vs. premium) within high price-spread categories to reduce shopper drop-off.
- Index marketing spend toward Spring/Summer and top-revenue categories (beleza_saude, relogios_presentes).

 🛠️ Tools Used

- SQL (PostgreSQL) — data querying and analysis
- PowerPoint — findings and recommendations presentation

 📎 Full Presentation

The complete deck with charts and detailed breakdowns is available in (https://github.com/vrajparekh09-hue/ecommerce-sales-analysis-sql/blob/main/Amazon_India_Sales_Analysis.pptx).
