
# load packages
library(tidyverse)
library(loo)

# read loos
normal <- read_rds("loo/loo-normal-regression.rds")
het <- read_rds("loo/loo-het-students-t-regression.rds")
hoc <- readRDS("loo/loo-hoc-regression.rds")

# compare loos
loo_df <- compare(normal, het, hoc) %>%
  as.data.frame() %>%
  rownames_to_column(var = "model") %>%
  mutate(model = fct_reorder(as_factor(model), looic)) %>%
  mutate(lwr = looic + se_looic,
         upr = looic - se_looic) %>%
  glimpse()

# plot looics
ggplot(loo_df, aes(x = model, y = looic, ymin = lwr, ymax = upr)) + 
  geom_point() + 
  geom_linerange() + 
  coord_flip()
ggsave("loo/looic.png", height = 3, width = 4, scale = 1.1)
