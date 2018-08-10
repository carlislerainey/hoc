
# load packages
library(tidyverse)
library(rstan)
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())
library(loo)  
library(bayesplot)

  # load simulated data
df <- read_rds("sim/gen/data.rds") %>%
  glimpse()

# format data for stan
f <- y ~ x1 + x2
mf <- model.frame(f, data = df)
mm <- model.matrix(f, mf)
stan_data_list <- list(y = mf$y, 
                       X = mm, 
                       N = nrow(mm), 
                       K = ncol(mm))

# fit stan model and write to both rds and csv (stan version) files
fit <- stan("stan/norm.stan", 
            data = stan_data_list, 
            iter = 1000,
            thin = 4,
            chains = 4,
            seed = 8792)
write_rds(fit, "sim/gen/stanfit-norm.rds")

# evalute stan model
log_lik0 <- extract_log_lik(fit) # see ?extract_log_lik
loo0 <- loo(log_lik0)
write_rds(loo0, path = "sim/gen/loo-norm.rds")

# plot y_rep
y <- df$y
y_rep <- extract(fit, "y_rep")$y_rep
ppc_dens_overlay(y, y_rep[1:20, ]) +
  labs(title = "Posterior Predictive Distribution (Simulated Data)",
       subtitle = "Normal Regression")
ggsave("sim/gen/ppd-norm.png", height = 3, width = 4, scale = 1.3)
