
# load packages
library(tidyverse)
library(rstan)
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())
library(loo)  
library(bayesplot)

# load simulated data
rsw_df <- read_csv("rsw/budget.csv") %>%
  glimpse()

# format data for stan
f <- leg_total ~ gov_total
mf <- model.frame(f, data = rsw_df)
mm <- model.matrix(f, mf)
stan_data_list <- list(y = mf$leg_total, 
                       X = mm, 
                       N = nrow(mm), 
                       K = ncol(mm))

# simple linear model fit with least squares
fit_lm <- lm(f, data = rsw_df)
arm::display(fit_lm)
# fit stan model and write to file
fit <- stan("stan/norm.stan", 
            data = stan_data_list, 
            iter = 1000,
            thin = 1,
            chains = 4,
            seed = 8792)
print(fit, pars = c("beta", "sigma"))
write_rds(fit, "rsw/gen/stanfit-norm.rds")

# evalute stan model
log_lik0 <- extract_log_lik(fit) # see ?extract_log_lik
loo0 <- loo(log_lik0)
write_rds(loo0, path = "rsw/gen/loo-norm.rds")

# observed data
obs_df <- data.frame(state_abbr = rsw_df$state_abbr, 
                     year = rsw_df$year, 
                     x = rsw_df$gov_total,
                     y = rsw_df$leg_total) %>%
  mutate(state_abbr = reorder(state_abbr, y))

# simulated data from model
y_rep <- extract(fit, "y_rep")$y_rep
rep_df <- NULL
for (i in 1:10) {
  rep_df_i <- data.frame(state_abbr = rsw_df$state_abbr, 
                         year = rsw_df$year,
                         x = rsw_df$gov_total,
                         y_rep = y_rep[i, ], 
                         rep = i)
  rep_df <- bind_rows(rep_df, rep_df_i)
}
glimpse(rep_df)

# posterior predictive distribution by state
ggplot() + 
  geom_point(data = rep_df, aes(x = x, y = y_rep), color = "red", alpha = 0.3) + 
  geom_point(data = obs_df, aes(x = x, y = y)) + 
  #facet_wrap(~ year) +
  theme_bw()
