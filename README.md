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

The underlying data for this project comes the the NY Times repo with daily U.S. county reported data. The primary columns are:

* state
* city
* cases
* deaths

This data is culled from various state and county health departments and other online sources.  It is assumed that the data, to whatever degree it is accurate, is at least representative of the scope of the outbreak in individual counties.  Some county results were cross-referenced with Wiki pages and, while there were almost always some differences, the NY Times data was generally within +/-3% of what is expressed in Wiki tables.  Note that some counties, depending on government county agencies, do not report updated numbers on weekends.

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


## Contributing
Pull requests are welcome, as are suggestions on how to improve modeling or results presentation.

## License
License to explore and learn!
