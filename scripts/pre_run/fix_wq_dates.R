# convert storm water quality data to tz Etc+6

wq <- read.csv('data_raw/ESW2 storm event data.csv', stringsAsFactors = F)

# set dates to time zone
.origin <- as.POSIXct(ifelse(Sys.info()[['sysname']] == "Windows", "1899-12-30", "1904-01-01"))
tz(.origin) <- site_tz

wq$sample_start <- as.POSIXct(wq$sample_start, origin = .origin, tz = site_tz, format = "%m/%d/%y %H:%M")
wq$sample_end <- as.POSIXct(wq$sample_start, origin = .origin, tz = site_tz, format = "%m/%d/%y %H:%M")
wq$storm_start <- as.POSIXct(wq$storm_start, origin = .origin, tz = site_tz, format = "%m/%d/%Y %H:%M")
wq$storm_end <- as.POSIXct(wq$storm_end, origin = .origin, tz = site_tz, format = "%m/%d/%Y %H:%M")

wq <- rename(wq, total_nitrogen_load_pounds = total_nitrogen_load_in_pounds)

write.csv(wq, 'data_raw/wq_dates_fixed.csv', row.names = FALSE)

