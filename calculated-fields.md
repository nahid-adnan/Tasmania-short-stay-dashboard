# Calculated columns and tables

Definitions from the downloadable Power BI model. Each expression is shown in its own table context.

### Listing · Booked Nights

```dax
Booked Nights = 365 - 'Listing'[Available Nights 365]
```

### Listing · Occupancy Rate

```dax
Occupancy Rate = DIVIDE ( 365 - 'Listing'[Available Nights 365], 365 )
```

### Listing · Annual Revenue

```dax
Annual Revenue = 'Listing'[Nightly Price] * ( 365 - 'Listing'[Available Nights 365] )
```

### Listing · RevPAN

```dax
RevPAN = 'Listing'[Nightly Price] * DIVIDE ( 365 - 'Listing'[Available Nights 365], 365 )
```

### Listing · Price per Guest

```dax
Price per Guest = DIVIDE ( 'Listing'[Nightly Price], 'Listing'[Accommodates] )
```

### Listing · Effective Nightly Rate

```dax
Effective Nightly Rate = 'Listing'[Nightly Price] + DIVIDE ( COALESCE ( 'Listing'[Cleaning Fee], 0 ), 3 )
```

### Listing · Price Bin

```dax
Price Bin = MIN ( ROUNDDOWN ( 'Listing'[Nightly Price] / 25, 0 ) * 25, 500 )
```

### Listing · Price Bin Label

```dax
Price Bin Label = IF (
    'Listing'[Price Bin] >= 500,
    "$500+",
    "$" & FORMAT ( 'Listing'[Price Bin], "#,##0" )
)
```

### Listing · Price Band

```dax
Price Band = SWITCH (
    TRUE (),
    'Listing'[Nightly Price] < 100,  "Budget (under $100)",
    'Listing'[Nightly Price] < 175,  "Mid-market ($100-174)",
    'Listing'[Nightly Price] < 300,  "Premium ($175-299)",
    "Luxury ($300+)"
)
```

### Listing · Price Band Sort

```dax
Price Band Sort = SWITCH ( TRUE (), 'Listing'[Nightly Price] < 100, 1, 'Listing'[Nightly Price] < 175, 2, 'Listing'[Nightly Price] < 300, 3, 4 )
```

### Listing · Demand Tier

```dax
Demand Tier = SWITCH (
    TRUE (),
    'Listing'[Occupancy Rate] >= 0.75, "Very high (75%+)",
    'Listing'[Occupancy Rate] >= 0.50, "High (50-74%)",
    'Listing'[Occupancy Rate] >= 0.25, "Moderate (25-49%)",
    "Low (under 25%)"
)
```

### Listing · Demand Tier Sort

```dax
Demand Tier Sort = SWITCH ( TRUE (), 'Listing'[Occupancy Rate] >= 0.75, 1, 'Listing'[Occupancy Rate] >= 0.5, 2, 'Listing'[Occupancy Rate] >= 0.25, 3, 4 )
```

### Listing · Capacity Band

```dax
Capacity Band = SWITCH (
    TRUE (),
    'Listing'[Accommodates] <= 2, "Couple (1-2)",
    'Listing'[Accommodates] <= 4, "Small group (3-4)",
    'Listing'[Accommodates] <= 8, "Family (5-8)",
    "Large group (9+)"
)
```

### Listing · Capacity Band Sort

```dax
Capacity Band Sort = SWITCH ( TRUE (), 'Listing'[Accommodates] <= 2, 1, 'Listing'[Accommodates] <= 4, 2, 'Listing'[Accommodates] <= 8, 3, 4 )
```

### Listing · Rating Tier

```dax
Rating Tier = SWITCH (
    TRUE (),
    ISBLANK ( 'Listing'[Guest Rating] ), "Not yet rated",
    'Listing'[Guest Rating] >= 98, "Exceptional (98-100)",
    'Listing'[Guest Rating] >= 95, "Excellent (95-97)",
    'Listing'[Guest Rating] >= 90, "Good (90-94)",
    "Below par (under 90)"
)
```

### Listing · Rating Tier Sort

```dax
Rating Tier Sort = SWITCH (
    TRUE (),
    'Listing'[Guest Rating] >= 98, 1,
    'Listing'[Guest Rating] >= 95, 2,
    'Listing'[Guest Rating] >= 90, 3,
    NOT ISBLANK ( 'Listing'[Guest Rating] ), 4,
    5
)
```

### Listing · Amenity Band

```dax
Amenity Band = SWITCH (
    TRUE (),
    'Listing'[Amenity Count] >= 40, "Very well equipped (40+)",
    'Listing'[Amenity Count] >= 30, "Well equipped (30-39)",
    'Listing'[Amenity Count] >= 20, "Standard (20-29)",
    "Basic (under 20)"
)
```

### Listing · Amenity Band Sort

```dax
Amenity Band Sort = SWITCH ( TRUE (), 'Listing'[Amenity Count] >= 40, 1, 'Listing'[Amenity Count] >= 30, 2, 'Listing'[Amenity Count] >= 20, 3, 4 )
```

### Listing · Days Since Last Review

```dax
Days Since Last Review = IF ( ISBLANK ( 'Listing'[Last Review] ), BLANK (), DATEDIFF ( 'Listing'[Last Review], DATE(2020, 1, 5), DAY ) )
```

### Listing · Listing Status

```dax
Listing Status = SWITCH (
    TRUE (),
    ISBLANK ( 'Listing'[Last Review] ),        "Never reviewed",
    'Listing'[Days Since Last Review] <= 60,   "Reviewed within 60 days",
    'Listing'[Days Since Last Review] <= 180,  "Reviewed 61-180 days ago",
    "No review for 180+ days"
)
```

### Listing · Listing Status Sort

```dax
Listing Status Sort = SWITCH (
    TRUE (),
    ISBLANK ( 'Listing'[Last Review] ),        4,
    'Listing'[Days Since Last Review] <= 60,   1,
    'Listing'[Days Since Last Review] <= 180,  2,
    3
)
```

### Listing · Property Category

```dax
Property Category = SWITCH (
    TRUE (),
    'Listing'[Property Type] IN { "House", "Townhouse", "Villa", "Bungalow" },
        "House & townhouse",
    'Listing'[Property Type] IN { "Apartment", "Condominium", "Serviced apartment", "Loft", "Aparthotel" },
        "Apartment & unit",
    'Listing'[Property Type] IN { "Cottage", "Cabin", "Chalet", "Tiny house", "Hut", "Barn", "Earth house", "Dome house" },
        "Cottage & cabin",
    'Listing'[Property Type] IN { "Bed and breakfast", "Guest suite", "Guesthouse", "Hostel" },
        "B&B & guesthouse",
    'Listing'[Property Type] IN { "Boutique hotel", "Hotel", "Resort" },
        "Hotel & resort",
    "Farm, rural & unique"
)
```

### Listing · Months Listed

```dax
Months Listed = IF ( ISBLANK ( 'Listing'[First Review] ), BLANK (), DATEDIFF ( 'Listing'[First Review], DATE(2020, 1, 5), MONTH ) )
```

### Host · Host Join Year

```dax
Host Join Year = YEAR ( 'Host'[Host Since] )
```

### Host · Host Tenure (Years)

```dax
Host Tenure (Years) = IF ( ISBLANK ( 'Host'[Host Since] ), BLANK (), DATEDIFF ( 'Host'[Host Since], DATE(2020, 1, 5), YEAR ) )
```

### Host · Host Experience

```dax
Host Experience = SWITCH (
    TRUE (),
    ISBLANK ( 'Host'[Host Tenure (Years)] ), "Unknown",
    'Host'[Host Tenure (Years)] >= 6, "Veteran (6+ years)",
    'Host'[Host Tenure (Years)] >= 3, "Established (3-5 years)",
    'Host'[Host Tenure (Years)] >= 1, "Growing (1-2 years)",
    "New (under 1 year)"
)
```

### Host · Host Experience Sort

```dax
Host Experience Sort = SWITCH (
    TRUE (),
    'Host'[Host Tenure (Years)] >= 6, 1,
    'Host'[Host Tenure (Years)] >= 3, 2,
    'Host'[Host Tenure (Years)] >= 1, 3,
    NOT ISBLANK ( 'Host'[Host Tenure (Years)] ), 4,
    5
)
```

### Date (calculated table)

```dax
Date = ADDCOLUMNS (
    CALENDAR ( DATE ( 2009, 1, 1 ), DATE ( 2020, 12, 31 ) ),
    "Year", YEAR ( [Date] ),
    "Quarter", "Q" & QUARTER ( [Date] ),
    "Year Quarter", YEAR ( [Date] ) & " Q" & QUARTER ( [Date] ),
    "Month Name", FORMAT ( [Date], "mmm" ),
    "Month Number", MONTH ( [Date] ),
    "Year Month", FORMAT ( [Date], "yyyy-mm" )
)
```

### Price Scenario (calculated table)

```dax
Price Scenario = SELECTCOLUMNS ( GENERATESERIES ( -0.3, 0.3, 0.05 ), "Price Change %", [Value] )
```

### Rating Threshold (calculated table)

```dax
Rating Threshold = SELECTCOLUMNS ( GENERATESERIES ( 80, 100, 1 ), "Minimum Guest Rating", [Value] )
```

### Funnel Stage (calculated table)

```dax
Funnel Stage = DATATABLE (
    "Stage", STRING,
    "Stage Order", INTEGER,
    "What this stage counts", STRING,
    {
        { "All listings", 1,
          "Every listing in the current filter selection." },
        { "Has guest reviews", 2,
          "Of those, the ones carrying at least one guest review, so a rating exists." },
        { "Clears the quality bar", 3,
          "Of those, the ones whose rating meets the quality bar set on the slider." },
        { "Reviewed within 60 days", 4,
          "Of those, the ones last reviewed within 60 days of the 4 Jan 2020 snapshot." }
    }
)
```
