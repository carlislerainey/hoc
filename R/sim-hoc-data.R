
# load packages
library(tidyverse)

# create variables 
n <- 500
x1 <- rnorm(n)
x2 <- rbinom(n, 1, 0.25)
df <- tibble(x1, x2)
X <- cbind(1, df$x1, df$x2)  # for convenient computation below

# create hoc direction probs
beta_pos <- c(0, 1, 0)
beta_neg <- c(0, 0, 1)
df <- df %>%
  mutate(pr_neg = exp(X%*%beta_neg)/(1 + exp(X%*%beta_neg) + exp(X%*%beta_pos)),
         pr_zero = 1/(1 + exp(X%*%beta_neg) + exp(X%*%beta_pos)),
         pr_pos = exp(X%*%beta_pos)/(1 + exp(X%*%beta_neg) + exp(X%*%beta_pos))) %>%
  glimpse()

# create hoc directions
dirs <- matrix(NA, ncol = 3, nrow = n)
for (i in 1:n) {
  dirs[i, ] <- rmultinom(1, 1, prob = c(df$pr_neg[i], df$pr_zero[i], df$pr_pos[i]))
}
df <- df %>%
  mutate(neg = dirs[, 1],
         zero = dirs[, 2],
         pos = dirs[, 3],
         dir = ifelse(neg == 1, -1, 
                      ifelse(zero == 1, 0, 1))) %>%
  glimpse()

# create magntiudes
beta_pos_mag <- c(0, 1, 0)
beta_neg_mag <- c(0, 0, 1)
df <- df %>%
  mutate(neg_mag = -rweibull(n, shape = 3, scale = exp(X%*%beta_neg_mag)),
         pos_mag = rweibull(n, shape = 3, scale = exp(X%*%beta_pos_mag)))

# create observed y
df <- df %>%
  mutate(y = neg_mag*neg + pos_mag*pos) %>%
  glimpse()

# write to file
df %>%
  write_csv("data/sim-hoc-data.csv") %>%
  write_rds("data/sim-hoc-data.rds")


