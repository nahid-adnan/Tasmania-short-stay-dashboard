<div align="center">

# 🏝️ Tasmania Short-Stay Dashboard

### Interactive **Power BI** analysis of Tasmania's short-term rental market

![Power BI](https://img.shields.io/badge/Power%20BI-F2C811?style=for-the-badge&logo=powerbi&logoColor=black)
![DAX](https://img.shields.io/badge/DAX-01A88D?style=for-the-badge&logoColor=white)
![Data Visualisation](https://img.shields.io/badge/Data%20Visualisation-4B8BBE?style=for-the-badge&logo=chartdotjs&logoColor=white)
![Status](https://img.shields.io/badge/Project-Portfolio-success?style=for-the-badge)

</div>

<div align="center">

<!-- Crop your screenshot to just the report canvas, name it dashboard-preview.png, and upload it -->
![Dashboard preview](dashboard-preview.png)

<sub><i>Market overview page — Tasmania short-stay market, January 2020</i></sub>

</div>

---

## 📊 Overview

This report explores the Tasmanian short-term rental market from four angles: how the market is **structured**, how listings are **priced** and how much **revenue** they generate, how **hosts and guest ratings** compare, and how **individual listings** perform.

It combines KPI cards, charts, a geographic map, slicers, and bookmark-driven navigation, plus a **what-if price scenario** for revenue modelling.

---

## 🔢 Key Figures

<div align="center">

| 🏠 Listings | 💵 Median Price | 📅 Est. Occupancy | 💰 Est. Revenue | 📈 Revenue / Listing |
|:---:|:---:|:---:|:---:|:---:|
| **5,293** | **$149** | **44.6%** | **$145.3M** | **$27,459** |

<sub><i>All of Tasmania · January 2020 snapshot</i></sub>

</div>

---

## 📄 Report Pages

| # | Page | What it shows |
|:---:|:---|:---|
| 1 | 🗺️ **Market overview** | Headline KPIs, a map of estimated 12-month revenue by local government area, average nightly rate & occupancy vs 30-day availability by region, and a price-vs-rating scatter |
| 2 | 💰 **Pricing & revenue** | Effective nightly rate, RevPAN, occupancy, and revenue per listing by price band — with a **price-scenario control** modelling revenue uplift |
| 3 | ⭐ **Hosts & guest experience** | Guest ratings, superhost status & share, review sub-scores and shortfalls, and rating-tier thresholds |
| 4 | 🔎 **Listing explorer** | A filterable, listing-level table with room type, capacity, occupancy, revenue, and performance flags |
| 5 | 🧭 **Area snapshot** | A tooltip page giving a quick regional summary on hover |

<!-- Optional: add more screenshots as you capture them
<div align="center">
  <img src="pricing-revenue.png"   width="80%" />
  <img src="hosts-experience.png"  width="80%" />
  <img src="listing-explorer.png"  width="80%" />
</div>
-->

---

## 🧮 Key Measures

| Category | Measures |
|:---|:---|
| **Revenue & pricing** | Estimated Annual Revenue · Estimated Revenue per Listing · Avg Effective Nightly Rate · Median Nightly Price · Median Price per Guest · Avg RevPAN · Estimated Occupancy Rate · Availability Rate (30 Days) · Revenue Uplift ($ / %) · Scenario Annual Revenue |
| **Market & hosts** | Total Listings · Host Base · New Hosts · New Hosts YoY % · Cumulative Hosts · Superhost Share · Professionally Managed Share |
| **Guest experience** | Avg Guest Rating · Avg Sub-score · Sub-score Shortfall · Listings Above Rating Bar |

---

## 🗂️ Data Model

| Table | Role |
|:---|:---|
| **Listing** | Core listing records — the grain of the model |
| **Host** | Host attributes and segments |
| **Geography** | Region / neighbourhood, used for the map and regional breakdowns |
| **Review Score** | Guest ratings and sub-scores |
| **Date** | Time context |
| **Price Scenario** ⚙️ | Helper table driving the what-if price control |
| **Rating Threshold** ⚙️ | Helper table for the rating-bar filter |
| **Funnel Stage** ⚙️ | Helper table for stage-based views |

---

## 🛠️ Tools & Techniques

- 🟡 **Power BI Desktop** — data modelling and report design
- 🧮 **DAX** — measures for pricing, revenue, occupancy, and host metrics
- 🎚️ **What-if parameter** — price-scenario modelling with dynamic revenue uplift
- 🔖 **Bookmarks & buttons** — page navigation, a custom tooltip page, a map visual, and dynamic KPI context text

---

## 📁 Data Source

Airbnb short-term rental data for **Tasmania** — a **January 2020** snapshot supplied as a structured, multi-table dataset. Seven linked tables cover listings, hosts, availability, costs, features, location, and reviews. Occupancy and revenue are **estimated from listing calendar availability**. Built as a postgraduate data-visualisation project.

---

## 🚀 How to Open

```text
1. Download  TasmaniaShortStay.pbix
2. Open it in Power BI Desktop (free from Microsoft)
```

---

<div align="center">

### 👤 Author

**B M Nahid Hasan Adnan**
Master of Data Science student · James Cook University

[![GitHub](https://img.shields.io/badge/GitHub-@nahid--adnan-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/nahid-adnan)

</div>
