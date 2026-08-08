# 📊 E-Commerce Email & Account Performance Analytics

## 📌 Project Overview
This project focuses on analyzing user registration dynamics, email marketing activity (sends, opens, link clicks), and subscriber behavior using BigQuery SQL and Looker Studio. 

The goal is to evaluate key market trends, compare user engagement across top countries, and segment subscribers by verification status, send interval, and subscription status.

---

## 🛠️ Tech Stack & Methods
* **Database / Warehouse:** Google BigQuery (SQL)
* **SQL Techniques:** Common Table Expressions (CTEs), `UNION ALL`, Window Functions (`RANK() OVER`), Aggregations, Grouping.
* **Visualization:** Google Looker Studio
* **Core Domain:** E-Commerce, Email Marketing Analytics, User Segmentation.

---

## ❓ Key Objectives & Analytics Logic
1. **User Account Dynamics:** Track daily account creations (`account_cnt`) segmented by country, verification status (`is_verified`), send intervals, and unsubscription rates.
2. **Email Campaign Engagement:** Analyze email performance metrics including message volume (`sent_msg`), open rate indicators (`open_msg`), and click-through metrics (`visit_msg`).
3. **Country-Level Rankings:** Rank countries using Window Functions based on:
   * Total account volume (`rank_total_country_account_cnt`)
   * Total email volume (`rank_total_country_sent_cnt`)
4. **Data Aggregation via UNION:** Separate account-level and email-level granularity to preserve unique dimensions without duplicating records, combining them seamlessly via `UNION ALL`.
5. **Top 10 Market Filtering:** Filter out long-tail data to focus explicitly on the Top 10 performing markets by accounts or sent emails.

---

## 📐 Data Architecture & SQL Structure

The SQL query extracts data from the `account` and email tables using the following dimensional breakdown:
* `date` — Registration date or email send date
* `country` — Target country code
* `send_interval` — User-preferred sending interval
* `is_verified` — Account verification status (`TRUE`/`FALSE`)
* `is_unsubscribed` — Subscription status (`TRUE`/`FALSE`)

### Metrics Calculated:
* **Base Metrics:** `account_cnt`, `sent_msg`, `open_msg`, `visit_msg`
* **Country Aggregates:** `total_country_account_cnt`, `total_country_sent_cnt`
* **Window Rankings:** `rank_total_country_account_cnt`, `rank_total_country_sent_cnt`

---

## 📈 Dashboard & Visualizations (Looker Studio)

The finalized dataset was connected to **Looker Studio** to build an executive reporting view, featuring:
* **Top Country Scorecards & Tables:** Country-level breakdown of total accounts, email volumes, and national ranks.
* **Email Dynamics Over Time:** Line chart depicting daily trends in total messages sent (`sent_msg`).
* **Interactive Filters:** Dropdowns for quick breakdown by country, account verification, and subscriber status.

---

## 📁 Repository Structure
├── sql/
│   └── email_account_performance.sql   # Complete BigQuery SQL query with CTEs & Window Functions
├── dashboards/
│   └── looker_studio_dashboard.png     # Screenshot / PDF of the Looker Studio dashboard
└── README.md                           # Project documentation

--

## 🔗 Live Dashboard & Links
* 📊 **Looker Studio Interactive Dashboard:**  https://datastudio.google.com/s/vxMEq6YhZjw
