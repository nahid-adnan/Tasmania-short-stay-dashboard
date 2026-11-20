<h1 align="center">🏝️ Tasmania Short-Stay Market Intelligence</h1>

<h3 align="center">An interactive Power BI dashboard on Tasmania's short-term rental market</h3>

<p align="center"><i>Where the supply sits, what it charges, and how much of its calendar is committed</i></p>

<p align="center">

![Power BI](https://img.shields.io/badge/Power%20BI-F2C811?style=for-the-badge&logo=powerbi&logoColor=black)
![DAX](https://img.shields.io/badge/DAX-01A88D?style=for-the-badge&logoColor=white)
![Data Modelling](https://img.shields.io/badge/Data%20Modelling-4B8BBE?style=for-the-badge&logo=databricks&logoColor=white)
![Pages](https://img.shields.io/badge/Report%20Pages-5-blue?style=for-the-badge)
![Listings](https://img.shields.io/badge/Listings-5%2C293-success?style=for-the-badge)

</p>

<p align="center">
  <img src="01-market-overview.png" width="900" alt="Market overview page" />
</p>

---

[Model diagram and relationships](model.md) · [80 DAX measures](measures.dax) · [Power Query transformations](power-query.pq) · [Calculated columns and tables](calculated-fields.md)

## 📊 Overview

This report examines Tasmania's short-term rental market from four angles: how the market is **structured**, how listings are **priced** and what they yield, **who runs the stock** and how guest experience varies, and how **individual listings** perform.

It pairs KPI cards with a geographic map, distribution and comparison charts, a drill-through register, and a hover tooltip — plus a **what-if repricing scenario** for revenue modelling.

> **What the calendar measures.** The report calculates unavailable nights as 365 minus available nights. The 44.6% headline averages that share across listings. Some nights may be blocked by owners. Multiplying unavailable nights by each listing’s advertised nightly price and summing gives the A$145.3 million annual revenue scenario. Actual bookings, discounts and paid rates are unknown. The repricing slider assumes a demand elasticity of −0.6. The original PBIX and screenshot use the words “upper bound”. Read that wording as a scenario assumption. An upper bound on actual revenue cannot be established from this snapshot.

---

## 🔢 Key Figures

| 🏠 Listings | 💵 Median Price | 📅 Unavailable nights | 💰 Annual revenue scenario | 📈 Scenario / listing |
|:---:|:---:|:---:|:---:|:---:|
| **5,293** | **$149** | **44.6%** | **$145.3M** | **$27,459** |

<sub><i>All of Tasmania · January 2020 snapshot</i></sub>

---

## 📄 The Five Pages

### 1️⃣ 🗺️ Market Overview — *where the supply sits*

![Market overview](01-market-overview.png)

Headline KPIs above a bubble map of estimated 12-month revenue by local government area. Regional rate rankings show **Bass Strait Islands ($200)** and the **East Coast ($190)** leading on price, while estimated occupancy peaks in the south (**Hobart & South, 51.6%**). A price-vs-rating scatter tests whether higher prices buy better reviews — they broadly don't.

**Filters:** tourism region · room type · property type · price band · host status

---

### 2️⃣ 💰 Pricing & Revenue — *rate architecture and a repricing what-if*

![Pricing and revenue](02-pricing-revenue.png)

Moves from the advertised rate to a modelled three-night stay including cleaning: the **3-night effective rate of $191** folds in a $41 cleaning fee, adding **6.0%** to the average nightly rate. A right-skewed price histogram shows half of all listings between **$100 and $200**, alongside median rate and stock composition by property class (houses & townhouses dominate at **2,442** listings).

A regional × price-band occupancy matrix shows budget listings out-occupying mid-market in five of six regions, and the **repricing slider** drives a baseline-vs-scenario revenue comparison.

---

### 3️⃣ ⭐ Hosts & Guest Experience — *who runs the stock*

![Hosts and guest experience](03-hosts-guest-experience.png)

**3,371 hosts** hold the 5,293 listings (1.57 each), with **49.1%** of listings run by superhosts and **20.9%** professionally managed. The counter-intuitive finding: **larger portfolios ask more but rate lower** — professional managers charge a median **$180** vs **$142** for individual hosts, yet occupancy and rating tiers both slip as portfolio size grows.

Sub-score analysis isolates **value for money (0.36 off a perfect 10)** as the weakest dimension market-wide. Host entry peaked in **2016**.

<sub><b>Superhost group differences:</b> +2.9 rating points · +2.5% est. occupancy · −6.9% on median rate</sub>

---

### 4️⃣ 🔎 Listing Explorer — *listing-level detail*

![Listing explorer](04-listing-explorer.png)

The **drill-through target** from any region on page 1. A funnel narrows 5,293 listings to the **4,775** that clear a user-set quality bar and the **3,824** reviewed recently. Yield by amenity count flattens quickly (RevPAN peaks around **$79**), while median rate climbs steeply with sleeping capacity — from **$115** for couples to **$240** for large groups.

The sortable listing register sits below, with a data-quality filter isolating **32 listings** whose bed or price values aren't credible.

---

### 5️⃣ 🧭 Area Snapshot — *tooltip page*

<p align="center">
  <img src="05-area-snapshot.png" width="480" alt="Area snapshot tooltip" />
</p>

A hover tooltip surfacing listings, median price, estimated occupancy, rating, and room-type mix for any area — context without leaving the page.

---

## 🖱️ Interactivity

| Element | Where it's used |
|:---|:---|
| 🎛️ **Slicers & filters** | Region, room type, property class, price band, host status, guest capacity, review recency, data quality |
| 🎚️ **What-if parameters** | Repricing scenario (revenue uplift) · quality-bar threshold |
| 🔀 **Drill-through** | Right-click a region on Market Overview → Listing Explorer |
| 🔎 **Drill-down** | Regional rate chart opens to area level |
| 💬 **Custom tooltip** | Area Snapshot page on hover |
| 🔖 **Bookmarks & buttons** | Page navigation |
| ↔️ **Cross-filtering** | Between visuals on every page |
| 📝 **Dynamic context text** | KPI subtitles and footer summaries respond to filters |

---

## 🧮 Key Measures

| Category | Measures |
|:---|:---|
| **Revenue & pricing** | Estimated Annual Revenue · Estimated Revenue per Listing · Avg Effective Nightly Rate · Median Nightly Price · Median Price per Guest · Avg RevPAN · Estimated Occupancy Rate · Availability Rate (30 Days) · Revenue Uplift ($ / %) · Scenario Annual Revenue |
| **Market & hosts** | Total Listings · Host Base · New Hosts · New Hosts YoY % · Cumulative Hosts · Superhost Share · Professionally Managed Share |
| **Guest experience** | Avg Guest Rating · Avg Sub-score · Sub-score Shortfall · Listings Above Rating Bar |

---

## 🗂️ Data Model

![Relationships in the published Tasmania model](model.png)

| Table | Role |
|:---|:---|
| **Listing** | Core listing records — the grain of the model |
| **Host** | Host attributes, tenure, and portfolio segments |
| **Geography** | Region / neighbourhood — drives the map and regional breakdowns |
| **Review Score** | Guest ratings and sub-scores |
| **Date** | Time context |
| ⚙️ **Price Scenario** | Disconnected helper table driving the repricing what-if |
| ⚙️ **Rating Threshold** | Helper table for the quality-bar filter |
| ⚙️ **Funnel Stage** | Helper table for the listing funnel |

---

## 🛠️ Tools & Techniques

- 🟡 **Power BI Desktop** — data modelling and report design
- 🧮 **DAX** — measures for pricing, revenue, occupancy, host, and rating metrics
- 🎚️ **What-if parameters** — repricing scenario with dynamic revenue uplift; adjustable quality threshold
- 🔀 **Drill-through & drill-down** — region → listing-level detail
- 🔖 **Bookmarks, buttons, and a custom tooltip page**
- 📝 **Dynamic titles and context text** driven by measures

---

## 📁 Data Source

Seven course-supplied Excel workbooks describe Tasmania Airbnb listings in January 2020. The files cover hosts, listings, availability, costs, features, location and reviews. The upstream publisher and collection method have not been verified. The snapshot supports historical comparisons.

---

## 🚀 How to Open

1. Download [TasmaniaShortStay.pbix](TasmaniaShortStay.pbix) and open it in Power BI Desktop. The saved data is available for exploration.
2. To refresh from source, set `SourceFolder` under **Home → Transform data → Edit parameters** to a local folder containing the seven original workbooks. Apply and choose **Refresh**. The public repository includes the query definitions and cached report. The original course workbooks are required for an independent source refresh.
3. See [Power Query](power-query.pq) for the exact filenames and sheet transformations.

---

<h3 align="center">👤 Author</h3>

<p align="center">

**B M Nahid Hasan Adnan**<br>
Master of Data Science student · James Cook University

<a href="https://github.com/nahid-adnan"><img src="https://img.shields.io/badge/GitHub-@nahid--adnan-181717?style=for-the-badge&logo=github&logoColor=white" alt="GitHub" /></a>

</p>
