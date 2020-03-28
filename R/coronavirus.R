# #############################################################################
# Coronavirus U.S. County EDA and Modeling
# #############################################################################
# Author: David Alyea
# Date: 3/27/2020
# Usage: This R script is meant to be run line by line, and the user is encouraged to tweak thresholds,
#        plots, columns, etc. while proceeding through the code.

# Libraries
require('data.table')
require('dplyr')
require('rvest')

# Set your working directory here
# setwd(...)

# U.S. County Data Source
url <- 'https://raw.githubusercontent.com/nytimes/covid-19-data/master/us-counties.csv'
webpage <- read_html(url)
txt <- html_text(webpage)
txt <- strsplit(txt, '\n')
txt <- unlist(txt)
txt <- data.frame(row=txt[2:length(txt)], stringsAsFactors=F)
ss <- apply(txt, 1, FUN=function(x) unlist(strsplit(x, ',')))
ss <- as.data.frame(t(ss))
colnames(ss) <- c('dt', 'county', 'state', 'fips', 'cases', 'deaths')
ss <- setDT(ss)
ss[,dt:=as.character(dt)]
max(ss$dt)

# Save and re-read
fwrite(ss, 'nytimes.csv', row.names=F)
ss <- fread('nytimes.csv', stringsAsFactors=F)

# Define deltas between days - use this to find anchor dates for each county
ss[,cases_lag:=shift(.SD, type='lag', n=1), .SDcols='cases', by=.(county, state)]
ss[is.na(cases_lag),cases_lag:=0]
ss[,new_cases:=cases-cases_lag]
ss[,cases_lag:=NULL]

# Take a look
s1 <- ss %>% sample_n(1)
ss[county==s1$county,]

# Define key to make things easier
ss[,key:=paste(county, state, sep=', ')]

# All counties with at least this many cases.
# Create indexing idx for late use.
min_cases <- 50
s2 <- ss %>% group_by(key, state, county) %>% summarise(ndays=n(), max_cases=max(cases)) %>% 
  filter(max_cases>=min_cases) %>% arrange(-max_cases)
s2 <- setDT(s2)
s2[,idx:=1:.N]
dim(s2)
# s2 <- ss[cases>=25,] %>% select(key, state, county) %>% unique()

# This will make it easier to look up data later
ss <- merge(ss, s2[,.(key, idx)], by='key', all.x=T)

# Look at exponential and/or power models for this length periods
per <- 7
# per <- 10

# Define counties with enough days
counties <- s2[ndays>=7,]
counties <- setDT(counties)
dim(counties)

# Example counties
counties[key=='Fort Bend, Texas',]
which(counties$key=='Fort Bend, Texas')

# Re-index, since some indexing may have been dropped
counties <- counties[order(idx),]
counties[order(idx),county_idx:=1:.N]
max(counties$idx)
max(counties$county_idx)

# Finding the first day at this exponentiation base
base_min <- 1.2

# Finding the first day at which variance on cases exceeds this number
sd_min <- 2.0

# Pause for viewing for each county
sleeping <- 0.0

# Tracking bases and sd first days per county
base_res <- c()
sd_res <- c()

# Save exponential model bases for plotting later
exp_list <- list()

# Loop through counties
for (keyidx in 1:nrow(counties)) {
  # for (keyidx in 1:20) {
  loc <- counties[keyidx,]
  data <- ss[key==loc$key,]
  cat(keyidx, loc$idx, loc$key, loc$max_cases, '\n')
  
  powers <- c()
  sds <- c()
  # for (sidx in 1:1) {
  for (sidx in 1:(nrow(data)-per+1)) {
    # sidx <- 19
    # print(sidx)
    sdata <- data[sidx:(sidx+per-1),]
    sdata$x <- 1:per
    sds <- c(sds, sd(sdata$cases))
    c_a <- 0
    c_b <- 0
    if (sd(sdata$cases)>0) {
      is_fit <- FALSE
      tryCatch({
        # Power model
        # expr={ sfit <- nls(cases ~ a*x^b, data=sdata, start=list(a=1.1, b=1.0)) }
        # Exponential model - this requires some hand tuning
        # expr={ sfit <- nls(cases ~ a*b^x, data=sdata, start=list(a=1.1, b=1.8)) }
        expr={ sfit <- nls(cases ~ a*b^x, data=sdata, start=list(a=1.1, b=1.3), control=list(maxiter=500)) }
        is_fit <- TRUE
      },
      error = function(e) {
        cat('Did not fit 1.0', sidx, '\n')
        tryCatch({
          # Powr model
          # sfit <- nls(cases ~ a*x^b, data=sdata, start=list(a=1.1, b=2.0))
          # Exponential model
          # sfit <- nls(cases ~ a*b^x, data=sdata, start=list(a=1.1, b=2.0))
          sfit <- nls(cases ~ a*b^x, data=sdata, start=list(a=1.1, b=2.0), control=list(maxiter=500))
          is_fit <- TRUE
        },
        error = function(e) {
          cat('Did not fit 2.0', sidx, '\n')
          c_b <- 0
        })
      })
      if (is_fit==TRUE) {
        par(mar=c(4,3,3,3))
        par(mfrow=c(2,2))
        plot(sdata$x, sdata$cases, type='b', ylim=c(0,1.2*max(sdata$cases)), xlab='', xaxt='n', main=max(sdata$dt))
        axis(1, at=1:nrow(sdata), labels=sdata$sdt, las=2, cex.axis=0.9)
        c_a <- coefficients(sfit)[1]
        c_b <- coefficients(sfit)[2]
        # lines(1:per, c_a*(1:per)^c_b, col='red')
        lines(predict(sfit))
        text(1, 1.1*max(sdata$cases), adj=c(0,0), round(c_a, 3), cex=1.2)
        text(1, 1.0*max(sdata$cases), adj=c(0,0), round(c_b, 3), cex=1.2)
      } else {
        c_b <- 0
      }
    }
    powers <- c(powers, c_b)
  }
  plot(data$cases, type='b', lwd=3)
  plot(sds, lwd=2, col='blue', type='b')
  # plot(powers, type='b', main=loc$key)
  plot(c(rep(0, per), powers), type='b', main=loc$key)
  p1 <- min(which(powers>base_min))
  cat('first_day power', p1, loc$key, '\n')
  base_res <- c(base_res, p1)
  sd1 <- min(which(sds>sd_min))
  cat('first_day SD', sd1, loc$key, '\n')
  sd_res <- c(sd_res, sd1)
  
  # Save for future exploration
  exp_list[[1+length(exp_list)]] <- powers
  
  # Debugging
  # print(data.frame(power=powers))
}

# Keep track of start days per county, using either first acceptable base in exponential modeling
# or variance on case counts
starts <- data.frame(base=base_res, sd=sd_res)
starts

# Index for later
starts$start_idx <- 1:nrow(starts)

# Compare base vs. cases methods for determining start days
par(mfrow=c(1,2))
boxplot(starts$base, ylim=c(0,50))
boxplot(starts$sd, ylim=c(0,50))
summary(starts$base)
summary(starts$sd)

# Look for cases where the case variance suggestion is less than the base suggestion
# for first day to use
which(starts$sd<starts$base)
counties[194,]
ss[key==counties[194,]$key,]

# Add starts data to counties object.  This assumes the counties data is in order,
# but just to be sure, re-sort.
counties <- counties[order(idx),]
counties[,days_base:=starts$base]
counties[,days_sd:=starts$sd]

# Reduce to just days needed for modeling
# Using variance on cases first days
# Define county index by date
ss[order(key, dt),key_idx:=1:.N, by=.(key)]
# ss[,county_idx:=NULL]
# ss[,days_base:=NULL]
# ss[,days_sd:=NULL]
ss <- merge(ss, unique(counties[,.(key, county_idx, days_base, days_sd)]), by='key', all.x=T)
head(ss)
ss <- setDT(ss)
# Re-order after merge
ss <- ss[order(county_idx, dt),]

# Optional:
# For any county, first day at 5 cases will qualify as a start day
# ss[,is_limit:=ifelse(cases>=5, 1, 0)]
# use <- ss[key_idx>=days_sd | is_limit==1,]
# use <- use[!is.na(days_7),]

# Define data table for use below for modeling
use <- ss[key_idx>=days_sd,]
dim(use)
length(unique(use$key))

# Should be empty
table(is.na(use$days_sd))

# Look for missing counties, if interested
unique(use$idx) %>% sort
unique(use$county_idx) %>% sort

# Look at samples of counties, looking to see early days left out.
# If it appears there are some counties which should be pruned more heavily
# for early low count days, adjust the sd_min setting above and re-run the
# for loop to re-find first day suggestions.
s1 <- use %>% sample_n(1)
ss[key==s1$key,] %>% head(10)
use[key==s1$key,] %>% head(10)

# Create both power and exponential models for each county, using the new
# data table 'use' restricted to chosen first days.  This is not on rolling 7 days,
# rather, it's on the full data set for each county, in order to evaluate the use
# of power vs. exponential modeling.
counties$rmse_power <- 0.0
counties$rmse_exp <- 0.0

for (sidx in 1:nrow(counties)) {
  # for (sidx in 3:3) {
  # sidx <- 81
  # data <- ss[idx==sidx,]
  # starts[sidx,]
  # data
  # data <- data[starts[sidx,]$sd:nrow(data),]
  # data$x <- 1:nrow(data)
  # data
  
  data <- use[county_idx==sidx,]
  data$x <- 1:nrow(data)
  data
  
  tryCatch({
    expr = { sfit <- nls(cases ~ a*x^b, data=data, start=list(a=1.1, b=1.8), control=list(maxiter=500)) }},
    error = function(e) { error <- TRUE }
  )
  tryCatch({
    expr = { bfit <- nls(cases ~ a*b^x, data=data, start=list(a=1.1, b=1.5), control=list(maxiter=500)) }},
    error = function(e) { error <- TRUE }
  )
  par(mfrow=c(1,1))
  plot(data$cases, main=unique(data$key))
  lines(predict(sfit), col='blue')
  lines(predict(bfit), col='red')
  # c_a <- coefficients(sfit)[1]
  # c_b <- coefficients(sfit)[2]
  # lines(1:nrow(data), c_a*(1:nrow(data))^c_b, col='red')
  data$spred <- predict(sfit)
  data$bpred <- predict(bfit)
  rmse_s <- sqrt(sum((data$cases-data$spred)^2))
  rmse_b <- sqrt(sum((data$cases-data$bpred)^2))
  cat(unique(data$key), rmse_s, rmse_b, '\n')
  counties[sidx,]$rmse_power <- rmse_s
  counties[sidx,]$rmse_exp <- rmse_b
}

summary(starts$rmse_exp)
summary(starts$rmse_power)
which(starts$rmse_power<starts$rmse_exp)

# Which model does best? 50/50
table(starts$rmse_exp>starts$rmse_power)
starts[1:20,]

# Look for big differences
starts <- setDT(starts)
starts$diff <- abs(starts$rmse_exp-starts$rmse_power)
starts[,exp_better:=ifelse(rmse_exp<rmse_power, '*', '')]
starts %>% arrange(-diff) %>% head(25)

# Proceed with exponential
# Make plots for specific counties
counties[1:25,]
sidx <- 25
data <- ss[idx==sidx,]
starts[sidx,]
data
data <- data[starts[sidx,]$sd:nrow(data),]
data$x <- 1:nrow(data)
bases <- 100*(exp_list[[sidx]]-1)
length(bases)
bases <- bases[starts[sidx,]$sd:length(bases)]
bases[bases>100] <- 100
# Days to double
d2 <- log(2)/log((bases/100)+1)
length(bases)

cexm <- 1.5
par(mfrow=c(3,1))
par(mar=c(2,4.4,4,3))
plot(data$cases, type='b', main=paste0(unique(data$key), '\nReported Cases'), xlab='', ylab='Cases', lwd=2, cex.main=cexm)
par(mar=c(2,4.4,3,3))
plot(1:(nrow(data)-6), bases, type='b', main='Exponentiation Model - Daily Growth', col='red', 
     xlim=c(1, nrow(data)), xlab='', ylab='% Daily Increase', lwd=2, cex.main=cexm)
text(nrow(data)-3, 0.925*max(bases), adj=c(0,0), 'Rolling 7 Days')
par(mar=c(6,4.4,3,3))
plot(1:(nrow(data)-6), d2, type='b', main='Days To Double Cases', col='green', 
     xlim=c(1, nrow(data)), xlab='', ylab='Days', lwd=2, xaxt='n', cex.main=cexm)
axis(1, at=1:nrow(data), labels=data$dt, las=2, cex.axis=0.95)

# Double-check from plots if desired
sdata <- data[1:7,]
sdata$x <- 1:nrow(sdata)
bfit <- nls(cases ~ a*b^x, data=sdata, start=list(a=1.1, b=1.5), control=list(maxiter=500))
plot(sdata$cases, type='b')
lines(predict(bfit), col='red')
coefficients(bfit)

# For displaying summary results
counties[1:30,] %>% select(-key, -county_idx)
