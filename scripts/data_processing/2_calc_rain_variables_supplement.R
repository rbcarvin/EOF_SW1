
# read in WQ data to define storm start/end times
wq.dat <- read.csv(file.path('data_cached', paste0(site, '_prepped_WQbystorm.csv')), 
                   header = TRUE, stringsAsFactors = F, colClasses = c(storm_start = 'POSIXct', storm_end = 'POSIXct'))

############## Get rain data ###############
# get data from NWIS if file is not provided

    
  # read in precip file
  precip_raw <- read.csv('data_raw/sw1_cleaned_precip.csv', stringsAsFactors = FALSE, strip.white = TRUE)
  precip_raw$pdate <- as.POSIXct(precip_raw$pdate, tz = "Etc/GMT+6")
  precip_raw$pdate <- lubridate::with_tz(precip_raw$pdate, tz = 'America/Chicago')

  write.csv(x = precip_raw, 'data_raw/sw1_cleaned_precip_correctdates.csv', row.names = FALSE)

############## Process rain data ###########
# summarize precip data using Rainmaker
# run.rainmaker is a wrapper function for multiple
# Rainmaker steps/functions
precip.dat <- run.rainmaker(precip_raw = precip_raw, ieHr = 2, rainthresh = 0.008, wq.dat = wq.dat,
                            xmin = c(5,10,15,30,60), antecedentDays = c(1,2,7,14))

precip.dat <- rename(precip.dat, 'rain_startdate' = 'StartDate', 'rain_enddate' = 'EndDate')

write.csv(precip.dat, 'data_cached/SW1_rain_supplement.csv', row.names = FALSE)

# get daily rain data
# set readNWISuv parameters
parameterCd <- "00045"  # Precipitation
startDate <- as.Date(start_date) - 15 # put a week buffer on the study start date in case storm started prior to first sample date
endDate <- as.Date(end_date)

# get NWIS data

precip_daily <- readNWISdv(rain_site, parameterCd = "00045", statCd = '00006')

# now merge sw1, sw2, and daily values
sw2 <- read.csv('data_cached/SW2_rain_variables.csv', stringsAsFactors = F)
sw2$rain_startdate <- as.POSIXct(sw2$rain_startdate, tz = site_tz)
sw2$rain_enddate <- as.POSIXct(sw2$rain_enddate, tz = site_tz)

all_rain <- sw2 %>%
  mutate(date = lubridate::date(as.POSIXct(rain_startdate))) %>%
  left_join(select(precip_daily, date = Date, daily_rain = X_00045_00006, daily_rmk = X_00045_00006_cd)) %>%
  left_join(select(precip.dat, unique_storm_number, sw1_rain = rain)) %>%
  select(unique_storm_number, date, sw2_rain = rain, sw1_rain, daily_rain, daily_rmk) %>%
  left_join(select(wq.dat, unique_storm_number, storm_start, storm_end))

write.csv(all_rain, 'data_cached/sw1_sw2_daily_rain_comparison.csv', row.names = F)


# substitue sw1 when sw2 daily data are 0 and daily values have "estimated" designation
# pull row numbers where this is true
sw1_rows <- which(all_rain$sw2_rain == 0 & grepl('e', all_rain$daily_rmk))

sw2[sw1_rows, ] <- precip.dat[sw1_rows, ]

write.csv(sw2, 'data_cached/SW2_rain_variables_fixed.csv', row.names = TRUE)

head(sw2)
