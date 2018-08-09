
# load packages
library(tidyverse)
library(loo)

# read loos
normal <- read_rds("loo/loo-normal-regression.rds")
hoc <- readRDS("loo/loo-hoc-regression.rds")

# compare loos
compare(normal, hoc)
