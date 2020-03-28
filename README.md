# Coronavirus Cases Modeling

Coronavirus EDA and modeling for U.S. counties

This project, written in R, explores the coronavirus spread rate in U.S. counties by way of exponential and power curve modeling.  The goal is to understand if the spread of the virus is increasing, leveling, or decreasing on a county by county basis, with the aim of identifying that happy time when coronavirus cases are on the decline.

## Installation

This R code can be run in R, R Studio, R in Jupyter notebooks, or R in any incarnation.  It requires:

* data.table
* dplyr
* rvest

and features use of the nls function from the stats package for fitting non-linear models.

## Results

These are the top 30 counties, sorted by number of reported cases, as of March 27, 2020.

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

![San Mateo County, CA](https://github.com/dalyea/coronavirus/blob/master/assets/san_mateo_20200327.png "San Mateo County, CA")


## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## License
License to explore and learn!
