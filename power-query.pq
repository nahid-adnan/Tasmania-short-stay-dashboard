// Model queries and named expressions. Set the folder parameter to the input workbook directory.
section Dashboard;

shared #"SourceFolder" = "C:\Data" meta [IsParameterQuery=true, Type="Text", IsParameterQueryRequired=true];

shared #"Listing" = let
    // ---------------------------------------------------------------
    // Resolve the source folder (parameter driven so the model can be
    // re-pointed at a new data drop without editing any query step).
    // ---------------------------------------------------------------
    Root = if Text.EndsWith(SourceFolder, "\") then SourceFolder else SourceFolder & "\",
    GetSheet = (fileName as text, sheetName as text) as table =>
        Table.PromoteHeaders(
            Excel.Workbook(File.Contents(Root & fileName), null, true){[Item = sheetName, Kind = "Sheet"]}[Data],
            [PromoteAllScalars = true]),

    // 1. Load the six listing-grain source files --------------------
    Base     = GetSheet("AirBNB_Listings.xlsx", "Listings"),
    Costs    = GetSheet("AirBNB_Listings_Costs.xlsx", "Costs"),
    Features = GetSheet("AirBNB_Listings_Features.xlsx", "Features"),
    Avail    = GetSheet("AirBNB_Listings_Availability.xlsx", "Availability"),
    Reviews  = GetSheet("AirBNB_Listings_Review.xlsx", "Review"),
    Place    = GetSheet("AirBNB_Listings_Location.xlsx", "Location"),

    // 2. Flatten the six files onto the listing grain ---------------
    #"Join Costs" = Table.ExpandTableColumn(
        Table.NestedJoin(Base, {"listing_id"}, Costs, {"listing_id"}, "Costs", JoinKind.LeftOuter), "Costs",
        {"price","security_deposit","cleaning_fee","guests_included","extra_people","minimum_nights","maximum_nights"}),
    #"Join Features" = Table.ExpandTableColumn(
        Table.NestedJoin(#"Join Costs", {"listing_id"}, Features, {"listing_id"}, "Features", JoinKind.LeftOuter), "Features",
        {"property_type","room_type","accommodates","bathrooms","bedrooms","beds","bed_type","amenities","cancellation_policy"}),
    #"Join Availability" = Table.ExpandTableColumn(
        Table.NestedJoin(#"Join Features", {"listing_id"}, Avail, {"listing_id"}, "Avail", JoinKind.LeftOuter), "Avail",
        {"availability_30","availability_60","availability_90","availability_365"}),
    #"Join Reviews" = Table.ExpandTableColumn(
        Table.NestedJoin(#"Join Availability", {"listing_id"}, Reviews, {"listing_id"}, "Reviews", JoinKind.LeftOuter), "Reviews",
        {"number_of_reviews","number_of_reviews_last_month","first_review","last_review","review_scores_rating",
         "review_scores_accuracy","review_scores_cleanliness","review_scores_checkin","review_scores_communication",
         "review_scores_location","review_scores_value","reviews_per_month"}),
    #"Join Location" = Table.ExpandTableColumn(
        Table.NestedJoin(#"Join Reviews", {"listing_id"}, Place, {"listing_id"}, "Place", JoinKind.LeftOuter), "Place",
        {"neighbourhood","city","zipcode","latitude","longitude","is_location_exact"}),

    // 3. Derive amenity intelligence from the packed amenities string
    //    Split on commas, but not on commas inside a quoted amenity name.
     //    A plain Text.Split overcounts 195 listings by one - names like
     //    "Ethernet connection, wired" carry an internal comma - and that moves
     //    seven listings into the wrong amenity band. Splitting on the quote-aware
     //    boundary first, then on bare commas, gets the true count.
    SplitAmenities = (raw as text) as list =>
        let Inner  = Text.Trim(raw, {"{","}"," "}),
            Chunks = Text.Split(Inner, """"),
            Parts  = List.Transform(
                List.Select(List.Positions(Chunks), each Number.Mod(_, 2) = 0),
                each Text.Split(Chunks{_}, ",")),
            Quoted = List.Transform(
                List.Select(List.Positions(Chunks), each Number.Mod(_, 2) = 1),
                each {Chunks{_}}),
            All    = List.Combine(Parts) & List.Combine(Quoted),
            Clean  = List.Select(List.Transform(All, Text.Trim), each _ <> "")
        in  Clean,
    #"Amenity Count" = Table.AddColumn(#"Join Location", "Amenity Count", each
        let Raw = if [amenities] = null then "" else Text.From([amenities])
        in  List.Count(SplitAmenities(Raw)), Int64.Type),
    HasAny = (t as nullable text, needles as list) as text =>
        if t = null then "No"
        else if List.AnyTrue(List.Transform(needles, (n) => Text.Contains(t, n))) then "Yes" else "No",
    #"Flag Wifi"      = Table.AddColumn(#"Amenity Count", "Has Wifi", each HasAny([amenities], {"Wifi","Internet"}), type text),
    #"Flag Aircon"    = Table.AddColumn(#"Flag Wifi", "Has Air Conditioning", each HasAny([amenities], {"Air conditioning"}), type text),
    #"Flag Parking"   = Table.AddColumn(#"Flag Aircon", "Has Free Parking", each HasAny([amenities], {"Free parking on premises","Free street parking"}), type text),
    #"Flag Luxury"    = Table.AddColumn(#"Flag Parking", "Has Pool or Hot Tub", each HasAny([amenities], {"Pool","Hot tub"}), type text),
    #"Flag Pets"      = Table.AddColumn(#"Flag Luxury", "Pet Friendly", each HasAny([amenities], {"Pets allowed"}), type text),
    #"Flag SelfCheck" = Table.AddColumn(#"Flag Pets", "Self Check-in", each HasAny([amenities], {"Self check-in"}), type text),
    #"Flag Family"    = Table.AddColumn(#"Flag SelfCheck", "Family Friendly", each HasAny([amenities], {"Family/kid friendly"}), type text),

    // 4. Standardise coded text so it is presentation ready ---------
    #"Tidy Cancellation" = Table.AddColumn(#"Flag Family", "Cancellation Policy", each
        Record.FieldOrDefault(
            [flexible = "Flexible", moderate = "Moderate",
             strict_14_with_grace_period = "Strict (14-day grace)",
             super_strict_30 = "Super strict (30-day)",
             super_strict_60 = "Super strict (60-day)"],
            if [cancellation_policy] = null then "" else Text.From([cancellation_policy]), "Other"), type text),
    #"Tidy Locality" = Table.AddColumn(#"Tidy Cancellation", "Locality", each
        if [city] = null or Text.Trim(Text.From([city])) = "" then "Unknown"
        else Text.Proper(Text.Trim(Text.From([city]))), type text),
    #"Tidy Postcode" = Table.AddColumn(#"Tidy Locality", "Postcode", each
        if [zipcode] = null then "Unknown" else Text.Trim(Text.From([zipcode])), type text),
    #"Tidy Precision" = Table.AddColumn(#"Tidy Postcode", "Location Precision", each
        if [is_location_exact] = "t" then "Exact" else "Approximate", type text),

    // 5. Drop the raw/coded columns now that they are derived -------
    #"Removed Raw" = Table.RemoveColumns(#"Tidy Precision",
        {"amenities","cancellation_policy","city","zipcode","is_location_exact"}),
    #"Renamed" = Table.RenameColumns(#"Removed Raw", {
        {"listing_id","Listing ID"},{"listing_name","Listing Name"},{"host_id","Host ID"},
        {"price","Nightly Price"},{"security_deposit","Security Deposit"},{"cleaning_fee","Cleaning Fee"},
        {"guests_included","Guests Included"},{"extra_people","Extra Person Fee"},
        {"minimum_nights","Minimum Nights"},{"maximum_nights","Maximum Nights"},
        {"property_type","Property Type"},{"room_type","Room Type"},{"accommodates","Accommodates"},
        {"bathrooms","Bathrooms"},{"bedrooms","Bedrooms"},{"beds","Beds"},{"bed_type","Bed Type"},
        {"availability_30","Available Nights 30"},{"availability_60","Available Nights 60"},
        {"availability_90","Available Nights 90"},{"availability_365","Available Nights 365"},
        {"number_of_reviews","Number of Reviews"},{"number_of_reviews_last_month","Reviews Last Month"},
        {"first_review","First Review"},{"last_review","Last Review"},
        {"review_scores_rating","Guest Rating"},{"review_scores_accuracy","Score Accuracy"},
        {"review_scores_cleanliness","Score Cleanliness"},{"review_scores_checkin","Score Check-in"},
        {"review_scores_communication","Score Communication"},{"review_scores_location","Score Location"},
        {"review_scores_value","Score Value"},{"reviews_per_month","Reviews per Month"},
        {"neighbourhood","Neighbourhood"},{"latitude","Latitude"},{"longitude","Longitude"}}),
    #"Typed" = Table.TransformColumnTypes(#"Renamed", {
        {"Listing ID", Int64.Type},{"Listing Name", type text},{"Host ID", Int64.Type},
        {"Nightly Price", Int64.Type},{"Security Deposit", type number},{"Cleaning Fee", type number},
        {"Guests Included", Int64.Type},{"Extra Person Fee", Int64.Type},
        {"Minimum Nights", Int64.Type},{"Maximum Nights", Int64.Type},
        {"Property Type", type text},{"Room Type", type text},{"Accommodates", Int64.Type},
        {"Bathrooms", type number},{"Bedrooms", type number},{"Beds", type number},{"Bed Type", type text},
        {"Available Nights 30", Int64.Type},{"Available Nights 60", Int64.Type},
        {"Available Nights 90", Int64.Type},{"Available Nights 365", Int64.Type},
        {"Number of Reviews", Int64.Type},{"Reviews Last Month", Int64.Type},
        {"First Review", type date},{"Last Review", type date},
        {"Guest Rating", type number},{"Score Accuracy", type number},{"Score Cleanliness", type number},
        {"Score Check-in", type number},{"Score Communication", type number},{"Score Location", type number},
        {"Score Value", type number},{"Reviews per Month", type number},
        {"Neighbourhood", type text},{"Latitude", type number},{"Longitude", type number}}),

    // 6a. Maximum Nights carries an Airbnb sentinel rather than a real
     //    booking rule: 3,111 listings say 1125, 3,174 say 1000 or more,
     //    and the top value is 9,999. Anything at or beyond a full year
     //    is not a stay limit anyone could book, so it is nulled out and
     //    a speaking label is derived from what is left.
    #"Max Nights Sentinel" = Table.TransformColumns(#"Typed", {
        {"Maximum Nights", each if _ = null or _ >= 365 then null else _, Int64.Type}}),
    #"Maximum Stay" = Table.AddColumn(#"Max Nights Sentinel", "Maximum Stay",
        each if [Maximum Nights] = null then "No maximum set"
             else if [Maximum Nights] <= 7 then "A week or less"
             else if [Maximum Nights] <= 30 then "Up to a month"
             else "One to twelve months", type text),

    // 6b. A few listings carry capacities that cannot be taken at face
     //    value - up to 25 bedrooms and 25 beds. They are kept, because
     //    dropping them would quietly change the counts, but they are
     //    flagged so any per-room analysis can exclude them in one click.
    //    The tests run price-first on purpose. A listing can trip more than one
     //    rule, and the column can only hold one label, so the order decides what
     //    the counts mean: price first makes "Extreme nightly rate" equal to the
     //    21 listings actually priced $1,000 or more, which is the number a reader
     //    gets by filtering the price column themselves.
    #"Quality Flag" = Table.AddColumn(#"Maximum Stay", "Data Quality Flag", each
        if [Nightly Price] <> null and [Nightly Price] >= 1000 then "Extreme nightly rate"
        else if [Bedrooms] <> null and [Bedrooms] >= 10 then "Extreme bedroom count"
        else if [Beds] <> null and [Beds] >= 16 then "Extreme bed count"
        else if [Bedrooms] = null or [Beds] = null then "Capacity not stated"
        else "Passes all checks", type text),

    // 6c. Two listings carry impossible nightly rates (up to $14,375).
     //    Capping the analytic frame at $2,000 keeps the mean, the
     //    histogram and the revenue model interpretable. 5,293 of
     //    5,295 listings are retained.
    #"Removed Price Outliers" = Table.SelectRows(#"Quality Flag",
        each [Nightly Price] <> null and [Nightly Price] > 0 and [Nightly Price] <= 2000)
in
    #"Removed Price Outliers";

shared #"Host" = let
    // ---------------------------------------------------------------
    // Resolve the source folder (parameter driven so the model can be
    // re-pointed at a new data drop without editing any query step).
    // ---------------------------------------------------------------
    Root = if Text.EndsWith(SourceFolder, "\") then SourceFolder else SourceFolder & "\",
    GetSheet = (fileName as text, sheetName as text) as table =>
        Table.PromoteHeaders(
            Excel.Workbook(File.Contents(Root & fileName), null, true){[Item = sheetName, Kind = "Sheet"]}[Data],
            [PromoteAllScalars = true]),

    Source = GetSheet("AirBNB_Host_information.xlsx", "Sheet1"),

    // Decode the t/f flags into speaking labels ---------------------
    #"Superhost Status" = Table.AddColumn(Source, "Superhost Status",
        each if [host_is_superhost] = "t" then "Superhost" else "Standard host", type text),
    #"Identity" = Table.AddColumn(#"Superhost Status", "Identity Verified",
        each if [host_identity_verified] = "t" then "Verified" else "Not verified", type text),

    // Portfolio segmentation: the commercialisation lens ------------
    #"Host Segment" = Table.AddColumn(#"Identity", "Host Segment", each
        let n = if [host_listings_count] = null then 1 else Number.From([host_listings_count])
        in  if n <= 1 then "Individual host (1)"
            else if n <= 4 then "Small operator (2-4)"
            else "Professional manager (5+)", type text),
    #"Host Segment Sort" = Table.AddColumn(#"Host Segment", "Host Segment Sort", each
        let n = if [host_listings_count] = null then 1 else Number.From([host_listings_count])
        in  if n <= 1 then 1 else if n <= 4 then 2 else 3, Int64.Type),

    // Where the operator actually lives (absentee-owner lens) -------
    #"Host Base" = Table.AddColumn(#"Host Segment Sort", "Host Base", each
        let t = if [host_location] = null then "" else Text.From([host_location])
        in  if t = "" then "Unknown"
            else if Text.Contains(t, "Tasmania") or Text.Contains(t, "TAS") then "Tasmania-based"
            else if Text.Contains(t, "Australia") then "Interstate (Australia)"
            else "Overseas", type text),

    #"Removed Raw" = Table.RemoveColumns(#"Host Base", {"host_is_superhost","host_identity_verified"}),
    #"Renamed" = Table.RenameColumns(#"Removed Raw", {
        {"host_id","Host ID"},{"host_name","Host Name"},{"host_since","Host Since"},
        {"host_location","Host Location"},{"host_listings_count","Listings Count"},
        {"host_total_listings_count","Total Listings Count"}}),
    #"Typed" = Table.TransformColumnTypes(#"Renamed", {
        {"Host ID", Int64.Type},{"Host Name", type text},{"Host Since", type date},
        {"Host Location", type text},{"Listings Count", Int64.Type},{"Total Listings Count", Int64.Type}})
in
    #"Typed";

shared #"Geography" = let
    // Conformed geography dimension. The 29 supplied local government
    // areas are rolled up to the six Tourism Tasmania marketing regions
    // so every chart can drill Region -> Local Government Area.
    Source = #table(
        type table [Neighbourhood = text, Region = text, #"Region Sort" = Int64.Type],
        {
            {"Hobart", "Hobart & South", 1},
            {"Glenorchy", "Hobart & South", 1},
            {"Clarence", "Hobart & South", 1},
            {"Kingborough", "Hobart & South", 1},
            {"Brighton", "Hobart & South", 1},
            {"Derwent Valley", "Hobart & South", 1},
            {"Huon Valley", "Hobart & South", 1},
            {"Central Highlands", "Hobart & South", 1},
            {"Southern Midlands", "Hobart & South", 1},
            {"Sorell", "Hobart & South", 1},
            {"Tasman", "Hobart & South", 1},
            {"Glamorgan/Spring Bay", "East Coast", 2},
            {"Break O'Day", "East Coast", 2},
            {"Launceston", "Launceston & North", 3},
            {"West Tamar", "Launceston & North", 3},
            {"George Town", "Launceston & North", 3},
            {"Northern Midlands", "Launceston & North", 3},
            {"Meander Valley", "Launceston & North", 3},
            {"Dorset", "Launceston & North", 3},
            {"Devonport", "North West", 4},
            {"Burnie", "North West", 4},
            {"Central Coast", "North West", 4},
            {"Kentish", "North West", 4},
            {"Latrobe", "North West", 4},
            {"Waratah/Wynyard", "North West", 4},
            {"Circular Head", "North West", 4},
            {"West Coast", "West Coast", 5},
            {"Flinders", "Bass Strait Islands", 6},
            {"King Island", "Bass Strait Islands", 6}
        })
in
    Source;

shared #"Review Score" = let
    // ---------------------------------------------------------------
    // Resolve the source folder (parameter driven so the model can be
    // re-pointed at a new data drop without editing any query step).
    // ---------------------------------------------------------------
    Root = if Text.EndsWith(SourceFolder, "\") then SourceFolder else SourceFolder & "\",
    GetSheet = (fileName as text, sheetName as text) as table =>
        Table.PromoteHeaders(
            Excel.Workbook(File.Contents(Root & fileName), null, true){[Item = sheetName, Kind = "Sheet"]}[Data],
            [PromoteAllScalars = true]),

    Source = GetSheet("AirBNB_Listings_Review.xlsx", "Review"),

    // Unpivot the six review sub-scores onto a score grain so a single
    // bar chart can compare them on one categorical axis, instead of
    // six separate measures competing for one legend.
    #"Kept Sub-scores" = Table.SelectColumns(Source, {
        "listing_id", "review_scores_accuracy", "review_scores_cleanliness",
        "review_scores_checkin", "review_scores_communication",
        "review_scores_location", "review_scores_value"}),
    #"Unpivoted" = Table.UnpivotOtherColumns(#"Kept Sub-scores", {"listing_id"}, "Score Type", "Score"),
    #"Named Scores" = Table.TransformColumns(#"Unpivoted", {{"Score Type", each
        Record.FieldOrDefault(
            [review_scores_accuracy      = "Accuracy",
             review_scores_cleanliness   = "Cleanliness",
             review_scores_checkin       = "Check-in",
             review_scores_communication = "Communication",
             review_scores_location      = "Location",
             review_scores_value         = "Value for money"], _, _), type text}}),
    #"Score Order" = Table.AddColumn(#"Named Scores", "Score Type Sort", each
        Record.FieldOrDefault(
            [Communication = 1, #"Check-in" = 2, Location = 3,
             Accuracy = 4, Cleanliness = 5, #"Value for money" = 6],
            [Score Type], 9), Int64.Type),
    #"Renamed" = Table.RenameColumns(#"Score Order", {{"listing_id", "Listing ID"}}),
    #"Typed" = Table.TransformColumnTypes(#"Renamed", {{"Listing ID", Int64.Type}, {"Score", type number}}),
    #"Removed Blanks" = Table.SelectRows(#"Typed", each [Score] <> null)
in
    #"Removed Blanks";
