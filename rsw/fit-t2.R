
# load packages
library(tidyverse)
library(rstan)
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())
library(loo)  
library(bayesplot)

# load simulated data
rsw_df <- read_csv("rsw/budget.csv") %>%
  #filter(year == 2011) %>%
  mutate(leg_total_rs = arm::rescale(leg_total),
         gov_total_rs = arm::rescale(gov_total),
         population_rs = arm::rescale(population),
         estimated_imbalance_rs = arm::rescale(estimated_imbalance)) %>%
  glimpse()

# sum_df <- rsw_df %>%
#   mutate(sign_leg_total = sign(leg_total)) %>%
#   group_by(year) %>%
#   summarize(prop_neg = mean(sign_leg_total == -1),
#             prop_pos = mean(sign_leg_total == 1)) %>%
#   glimpse()


# format data for stan
f <- leg_total_rs ~ gov_total_rs
mf <- model.frame(f, data = rsw_df)
mm <- model.matrix(f, mf)
stan_data_list <- list(y = mf$leg_total_rs, 
                       X = mm, 
                       N = nrow(mm), 
                       K = ncol(mm))

# simple linear model fit with least squares
fit_lm <- lm(f, data = rsw_df)
arm::display(fit_lm)

# fit stan model and write to file
fit <- stan("stan/t2.stan", 
            data = stan_data_list, 
            iter = 1000,
            thin = 1,
            chains = 4,
            seed = 8792)
print(fit, pars = c("beta", "sigma"))
write_rds(fit, "rsw/gen/stanfit-t2.rds")

# evalute stan model
log_lik0 <- extract_log_lik(fit) # see ?extract_log_lik
loo0 <- loo(log_lik0)
write_rds(loo0, path = "rsw/gen/loo-t2.rds")