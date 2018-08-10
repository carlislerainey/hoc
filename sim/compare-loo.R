
# load packages
library(tidyverse)
library(loo)

# read loos
norm <- read_rds("sim/gen/loo-norm.rds")
het_t <- read_rds("sim/gen/loo-het-t.rds")
hoc <- readRDS("sim/gen/loo-hoc.rds")

# compare loos
loo_df <- compare(norm, het_t, hoc) %>%
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
ggsave("sim/gen/looic.png", height = 3, width = 4, scale = 1.1)
