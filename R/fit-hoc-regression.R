
# load packages
library(tidyverse)
library(rstan)
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())
library(loo)  
library(bayesplot)

# load simulated data
df <- read_rds("data/sim-hoc-data.rds") %>%
  glimpse()

# format data for stan
## basics
f <- y ~ x1 + x2
mf <- model.frame(f, data = df)
mm <- model.matrix(f, mf)
## details
y <- mf$y
y_dir <- ifelse(sign(y) == 0, 1, 
                ifelse(sign(y) == -1, 2, 3))
X <- mm
K <- ncol(X)
N <- nrow(X)
y_pos_indicies <- which(y > 0)
y_neg_indicies <- which(y < 0)
N_pos <- length(y_pos_indicies)
N_neg <- length(y_neg_indicies)
## final data list
stan_data_list <- list(N, K, y, y_dir, X, 
                       y_pos_indicies, N_pos,
                       y_neg_indicies, N_neg)

# fit stan model and write to both rds and csv (stan version) files
fit <- stan("stan/hoc-regression.stan", 
            iter = 1000,
            thin = 4,
            chains = 4, 
            seed = 8792)
write_rds(fit, "stanfit/stanfit-hoc-regression.rds")


# check estimates (compare to true values)
summary(fit, pars = "beta_pos")
summary(fit, pars = "beta_neg")
summary(fit, pars = "beta_pos_mag")
summary(fit, pars = "beta_neg_mag")
summary(fit, pars = "alpha_pos_mag")
summary(fit, pars = "alpha_neg_mag")

# evalute stan model
log_lik0 <- extract_log_lik(fit) # see ?extract_log_lik
loo0 <- loo(log_lik0)
write_rds(loo0, path = "loo/loo-hoc-regression.rds")

# plot y_rep
y <- df$y
y_rep <- extract(fit, "y_rep")$y_rep
ppc_dens_overlay(y, y_rep[1:20, ]) +
  labs(title = "Posterior Predictive Distribution (Simulated Data)",
       subtitle = "HOC Regression")
ggsave("ppd/ppd-hoc-regression.png", height = 3, width = 4, scale = 1.3)
