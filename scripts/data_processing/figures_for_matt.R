# file for matt

mod_dat <- mod_env$dat.mod

library(ggplot2)

mod_dat_nonfrozen <- filter(mod_dat, frozen == FALSE)
mod_dat_frozen <- filter(mod_dat, frozen == TRUE)

p <- ggplot(mod_dat, aes(x = days_since_fertilizer, y = total_nitrogen_load_pounds)) +
  geom_point(aes(color = frozen)) +
  geom_smooth(aes(group = frozen, color = frozen), method = 'lm') +
  labs(x = 'Days since manure or fertilizer application', y  = 'log10 Total N load (pounds)') +
  theme_bw()

ggsave('figures/totaln_load_fert.png', p, height = 4, width = 5)

test <- lm(mod_dat_frozen$orthophosphate_load_pounds ~ mod_dat_frozen$days_since_fertilizer)
summary(test)
