# Coronavirus Cases Modeling

**Coronavirus EDA and modeling for U.S. counties**

This project, written in R, explores the coronavirus spread rate in U.S. counties by way of exponential and power curve modeling.  The goal is to understand if the spread of the virus is increasing, leveling, or decreasing on a county by county basis, with the aim of identifying that happy time when coronavirus cases are on the decline.

## How To Run

This R code can be run in R, R Studio, R in Jupyter notebooks, or R in any incarnation.  It requires:

* data.table
* dplyr
* rvest

and features use of the nls function from the stats package for fitting non-linear models.

## Data

#### Source

The underlying data for this project comes the the NY Times repo with daily U.S. county reported data. The primary columns are:

* state
* city
* cases
* deaths

This data is culled from various state and county health departments and other online sources.  It is assumed that the data, to whatever degree it is accurate, is at least representative of the scope of the outbreak in individual counties.  Some county results were cross-referenced with Wiki pages and, while there were almost always some differences, the NY Times data was generally within +/-3% of what is expressed in Wiki tables.  Note that some counties, depending on government county agencies, do not report updated numbers on weekends.

#### Summary Counts

There are 1,797 U.S. counties in the data. Some of these are not actually counties, but rather cities or regions.  In the analysis below, a qualifying criteria is used so as to examine only the hardest hit counties.  For March 27, 2020 results, as shown, only counties with 50+ total reported cases are analyzed, resulting in 216 counties being included.

## Approach

The primary approach is as follows:

* define a rolling window duration (7 and 10 days were explored)
* determine a meaningful first date for each county, from which point to model the coronavirus outbreak for that county
  * method 1: build models over rolling time windows, look for the first model with a parameter which exceeds some threshold
  * method 2: examine variance of reported cases over rolling time windows, look for the first date at which variance exceeds some threshold
* with the reduced data per county, build various models to show the rate of outbreak in each county; the primary models explored are:
  * exponential
  * power curve
* define "days to double" as a key metric with which to express the severity of the outbreak in each county
* data mine for particular examples of counties that have high, low, or otherwise unusual virus growth patterns
* watch results for the happy time that there is evidence that the spread of coronavirus is on the decline across the country

Example)
About determining a meaningful first date for each county, use Los Angeles as an example. Each county began reporting data at various stages of the nationwide outbreak, even when case counts were very small in many cases.  Los Angeles began reporting coronavirus numbers on January 26, 2020, and there are 62 reported counts in the NY Times data set.  The case counts are:

```
1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 7 11 13 14 14 19 20 28 32 40 53 69 94 144 190 231 292 351 421 536 662 799 1216 1465
```

By using the variance method described above, the leading 1s are removed until there is sufficient evidence of counts variance.  The resulting set of count data for Los Angeles is thus:

```
1 1 1 1 1 1 7 11 13 14 14 19 20 28 32 40 53 69 94 144 190 231 292 351 421 536 662 799 1216 1465
```

## Results

These are the top 30 counties, sorted by number of reported cases, as of March 27, 2020.  The RMSE columns show the error rates when building the indicated model using the full data set available for the indicated county, from first date as described above to most recent data reported.  It appears that most harder hit counties are better handled by power curve models; but overall, about half of counties are best handled by exponential models, and in many cases, the power curve model is only marginally better/different from the exponential model for the county.

```            
            state        county ndays max_cases idx days_base days_sd rmse_power   rmse_exp
 1:      New York New York City    27     25399   1         1       1 4488.74421 6069.01071
 2:      New York   Westchester    24      7187   2         1       1  557.59128  824.30081
 3:      New York        Nassau    23      4657   3         1       1  839.81816 1158.80436
 4:      New York       Suffolk    20      3385   4         1       1  404.76930  636.88168
 5:      Illinois          Cook    64      2239   5        41      40  157.92633  264.17718
 6:    New Jersey       Unknown    16      1984   6         3       4  108.90663  215.55035
 7:    Washington          King    29      1830   7         1       1  171.25716  266.61628
 8:      Michigan         Wayne    18      1810   8         1       1  112.02517  237.22038
 9:    New Jersey        Bergen    24      1505   9         1       2  200.46574  192.76425
10:    California   Los Angeles    62      1465  10        33      33  184.14616  138.91076
11:      New York      Rockland    22      1457  11         1       1  245.22777  321.18188
12:     Louisiana       Orleans    18      1170  12         1       1   72.56199  135.79635
13:    Washington     Snohomish    67       913  13        36      38   99.83543  153.46067
14:      New York        Orange    16       910  14         1       1  103.71700  185.29205
15:       Florida    Miami-Dade    17       869  15         1       1   77.43848   41.34733
16:    New Jersey         Essex    16       826  16         1       1   95.66694   78.67178
17:      Michigan       Oakland    18       824  17         1       1   82.21224  135.15413
18:   Connecticut     Fairfield    20       752  18         1       1   75.50620  100.06107
19: Massachusetts     Middlesex    23       685  19         1       1  152.55617   98.61638
20:    New Jersey     Middlesex    17       640  20         1       1   68.05708   56.52417
21:    New Jersey      Monmouth    19       634  21         1       1   74.40094   81.57529
22:       Florida       Broward    22       631  22         1       1   38.08651   35.57731
23: Massachusetts       Suffolk    56       631  23        29      31   91.76033   65.18490
24:    New Jersey        Hudson    19       594  24         1       1   79.24370   61.63378
25:    California   Santa Clara    57       574  25        25      26   78.05028   61.25097
26:     Louisiana     Jefferson    19       548  26         1       1   34.86936   74.88977
27:  Pennsylvania  Philadelphia    18       530  27         1       1   37.59784   30.10441
28:    New Jersey         Union    19       519  28         1       2   62.44638   74.93800
29:       Indiana        Marion    22       484  29         3       5   47.30656   37.96042
30:    New Jersey         Ocean    15       484  30         1       1   58.88028   55.29969
```

#### Exponential vs. Power Curve Fits

This plot, for the top 9 highest case count U.S. counties, shows the exponential and power curve fits in red and blue, respectively.

![Curve Fits](https://github.com/dalyea/coronavirus/blob/master/assets/images/exp-power-9.png "Curve Fits")


#### Individual County Results
These plots are produced from the R code.  Particular counties from around the U.S. are featured here.

![New York City, NY](https://github.com/dalyea/coronavirus/blob/master/assets/images/nyc_20200327.png "New York City, NY")
![San Francisco County, CA](https://github.com/dalyea/coronavirus/blob/master/assets/images/san_francisco_20200327.png "San Francisco County, CA")
![San Mateo County, CA](https://github.com/dalyea/coronavirus/blob/master/assets/images/san_mateo_20200327.png "San Mateo County, CA")
![Orleans, LA](https://github.com/dalyea/coronavirus/blob/master/assets/images/orleans_20200327.png "Orleans County, LA")
![Broward County, FL](https://github.com/dalyea/coronavirus/blob/master/assets/images/broward_20200327.png "Broward County, FL")

#### Smallest Days To Double

With the modeling complete, and all 216 counties with 50+ cases available for scanning, these are the U.S. counties with the fastest growth of coronavirus as of March 27, 2020.

```
                          key ndays max_cases idx days_base days_sd rmse_power   rmse_exp county_idx dpts   d2mean
1                 Lucas, Ohio    13        50 215         1       3   4.252220   4.112820        213    3 1.464179
2      Unknown, Massachusetts    12       304  48         1       1  47.193476  56.853009         48    3 1.519749
3    St. Louis city, Missouri    10        72 166         1       1  22.991099  24.412736        165    3 1.548381
4         Unknown, New Jersey    16      1984   6         3       4 108.906625 215.550346          6    3 1.585691
5      Hampden, Massachusetts    13        90 141         1       1   9.677155   8.181745        140    3 1.617174
6            Caddo, Louisiana    17       140  94         1       3  26.140261  28.416646         94    3 1.627916
7     Plymouth, Massachusetts    13       187  72         1       1  15.497281  18.509714         72    3 1.657390
8      Bristol, Massachusetts    14       129  99         1       1  16.514192  14.038557         98    3 1.700668
9    Worcester, Massachusetts    20       219  63         2       3  25.311933  25.312194         63    3 1.751038
10      Luzerne, Pennsylvania    13        55 203         1       2   5.114946   5.314142        201    3 1.753808
11       Ascension, Louisiana    12        91 136         1       1  20.672922  26.879528        135    3 1.784522
12          Genesee, Michigan     9        91 137         1       1   5.666465   9.036913        136    3 1.795944
13         Sussex, New Jersey     9        65 182         1       1   9.469912   6.848864        181    3 1.797791
14                 Ada, Idaho    15        76 160         3       3   8.655420   5.662683        159    3 1.812102
15     New Haven, Connecticut    14       222  59         1       1  31.283562  28.341056         59    3 1.829995
16       Essex, Massachusetts    18       350  41         1       1  22.159388  12.617680         41    3 1.871749
17           Unknown, Georgia     8       217  65         1       1  38.941596  53.552438         65    2 1.882061
18            Marion, Indiana    22       484  29         3       5  47.306560  37.960415         29    3 1.906910
19        St. Louis, Missouri    21       247  50         4       7  29.039943  27.217937         50    3 1.915348
20 Philadelphia, Pennsylvania    18       530  27         1       1  37.597845  30.104411         27    3 1.928690
21              Pima, Arizona    19       102 121         1       6  10.733604   7.449078        120    3 1.980861
22             Kane, Illinois    18        77 159         5       6  10.322602   6.448199        158    3 2.003884
23       Lehigh, Pennsylvania    13        93 131         1       1  13.829940  11.516726        130    3 2.015892
24 Charleston, South Carolina    22        92 133         6       9  11.608309  12.317169        132    3 2.032903
25             Will, Illinois    12       104 118         1       1  21.379591  14.685700        117    3 2.050222
```

This result set is sorted on the mean doubling days estimate of the final 3 model builds, using 7-day rolling periods, for each county, as defined as d2mean above.  Reference the max_cases column to hone in on particular counties with already high case counts.  Here are plots for Worcester, MA, the 9th fastest rate county as indicated above.

## UPDATE - April 6, 2020

This is the updated ranking of lowest "days to double" counties in the U.S.  The search criteria is all counties with at least 125 reported cases, and there are 239 such counties.  As heard on the news, Louisiana continues to have a troubling high rate growth of the virus, and these results using my rolling 7-day approach bear that out.

```
> counties %>% arrange(dd_mean) %>% filter(dd_days>1 & dd_mean>0) %>% head(25) %>% dplyr::select(-key, -diff, -county_idx, -exp_better)
          state               county ndays max_cases top_idx days_base days_sd  rmse_power    rmse_exp dd_days  dd_mean
1     Louisiana           Tangipahoa    17       171     213         2       4    33.17305    28.94355       3 1.789918
2     Louisiana          St. Charles    24       260     161         1       2    75.78980    81.63458       3 2.262140
3  Pennsylvania              Luzerne    22       741      64         1       1    56.71236    94.45929       3 2.507387
4     Louisiana St. John the Baptist    23       345     128         1       1   108.61882   117.84327       3 2.566686
5     Louisiana          St. Bernard    22       242     170         1       1    65.79414    68.94668       3 2.630186
6     Louisiana            Lafourche    23       228     182         1       1    48.82333    53.92159       3 2.742251
7          Utah                 Utah    22       216     189         1       1    33.00541    26.46079       3 2.813998
8  Pennsylvania               Lehigh    22       877      53         1       1    79.68897   117.41528       3 2.814531
9      Michigan              Unknown    11       333     131         1       1    71.15213    83.41826       3 2.889491
10     Virginia              Henrico    20       194     196         1       1    38.35392    27.20501       3 2.907859
11    Louisiana             Ouachita    16       182     203         1       1    32.63072    29.23523       3 2.934307
12 Pennsylvania            Lancaster    18       371     121         1       1    20.39336    42.36520       3 3.085354
13    Louisiana            Jefferson    28      3088      20         1       1   557.26820   601.96552       3 3.134633
14 Pennsylvania          Northampton    25       636      79         1       1    60.14093    96.34428       3 3.148129
15     Oklahoma                Tulsa    31       240     173         3       4    32.23377    35.60558       3 3.210234
16     Michigan              Genesee    18       504      98         1       1    73.61394   101.79699       3 3.222017
17    Louisiana     East Baton Rouge    20       656      76         1       1   154.73610   122.24292       3 3.270267
18      Georgia              Clayton    22       238     174         1       1    47.25252    52.42437       3 3.313920
19   California                 Kern    20       225     183         1       1    35.23624    49.46248       3 3.379523
20     New York        New York City    36     67552       1         1       1 12048.63958 20409.48064       3 3.404197
21    Louisiana          St. Tammany    24       560      87         1       1    80.99786    94.84992       3 3.404683
22     Virginia  Virginia Beach city    28       170     215         3       3   371.13423    22.96431       3 3.431367
23      Indiana            Hendricks    29       177     206         1       2   423.43352    25.40822       3 3.476189
24      Indiana                 Lake    20       335     130         1       1    33.12582    60.53714       3 3.517582
25         Ohio             Hamilton    18       319     134         1       1    51.37931    29.79729       3 3.533340
```

![Worcester County, MA](https://github.com/dalyea/coronavirus/blob/master/assets/images/worcester_20200327.png "Worcester County, MA")

## Contributing
Pull requests are welcome, as are suggestions on how to improve modeling or results presentation.

## License
License to explore and learn!
