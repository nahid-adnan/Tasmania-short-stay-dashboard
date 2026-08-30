# Tasmania Short-Stay Dashboard

Interactive **Power BI** dashboard analysing Tasmania's short-stay (short-term rental) market — market overview, pricing & revenue, host and guest experience, and a listing-level explorer.

<!-- Crop your screenshot to just the report canvas, name it dashboard-preview.png, and upload it -->
![Dashboard preview](dashboard-preview.png)
<img width="1882" height="1170" alt="dashboard-preview png" src="https://github.com/user-attachments/assets/bedbbc0f-2965-45cd-a265-d8df70c6cf13" />


## Overview

This report explores the Tasmanian short-term rental market from four angles: how the market is structured, how listings are priced and how much revenue they generate, how hosts and guest ratings compare, and how individual listings perform. It combines KPI cards, charts, a geographic map, slicers, and bookmark-driven navigation, plus a what-if price scenario for revenue modelling.

## Key figures (January 2020 snapshot, all of Tasmania)

- **5,293** listings
- **$149** median nightly price
- **44.6%** estimated occupancy
- **$145.3M** estimated annual revenue
- **$27,459** estimated revenue per listing

## Report pages

1. **Market overview** — headline KPIs (listings, median nightly price, estimated occupancy, estimated revenue) with filters for tourism region, room type, property type, price band, and host status; a map of estimated 12-month revenue by local government area; average nightly rate and estimated occupancy vs 30-day availability by region; and a price-vs-rating scatter (bubble size = listing count).
2. **Pricing & revenue** — average effective nightly rate, median nightly price, median price per guest, estimated revenue per listing, RevPAN, occupancy and 30-day availability, broken down by price band. Includes a **price scenario** control that models revenue uplift ($ and %) and scenario annual revenue.
3. **Hosts & guest experience** — average guest rating, superhost status and share, host experience and segments, review sub-scores and shortfalls, and rating-tier thresholds (e.g. listings above a chosen rating bar).
4. **Listing explorer** — a filterable, listing-level table with room type, property category, capacity, amenity band, occupancy, revenue, and performance/status flags for drilling into individual properties.
5. **Area snapshot** — a tooltip page giving a quick regional summary on hover.

## Key measures

Revenue & pricing: Estimated Annual Revenue · Estimated Revenue per Listing · Avg Effective Nightly Rate · Median Nightly Price · Median Price per Guest · Avg RevPAN · Estimated Occupancy Rate · Availability Rate (30 Days) · Revenue Uplift ($ / %) · Scenario Annual Revenue

Market & hosts: Total Listings · Host Base · New Hosts · New Hosts YoY % · Cumulative Hosts · Superhost Share · Professionally Managed Share

Guest experience: Avg Guest Rating · Avg Sub-score · Sub-score Shortfall · Listings Above Rating Bar

## Data model

Tables: **Listing**, **Host**, **Geography** (Region / Neighbourhood), **Review Score**, **Date**, plus helper tables for **Price Scenario**, **Rating Threshold**, and **Funnel Stage** that drive the what-if and threshold controls.

## Tools & techniques

- **Power BI Desktop** — data modelling and report design
- **DAX** — measures for pricing, revenue, occupancy, and host metrics
- **What-if parameter** — price scenario modelling with dynamic revenue uplift
- Bookmarks and buttons for page navigation, a custom tooltip page, a map visual, and dynamic KPI context text

## Data source

Historical snapshot of Tasmanian short-term rental listings, **January 2020**. Occupancy and revenue are estimated from listing calendar availability.

_(Add the dataset name and link here if you can share it.)_

## How to open

1. Download `TasmaniaShortStay.pbix`.
2. Open it in **Power BI Desktop** (free from Microsoft).

## Author

**B M Nahid Hasan Adnan** — Master of Data Science student, James Cook University
GitHub: [@nahid-adnan](https://github.com/nahid-adnan)
