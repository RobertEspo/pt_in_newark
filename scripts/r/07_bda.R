# Bayesian data analysis ------------------------------------------------------
# Authors: Robert Esposito & Kendra Dickinson
#
# Description: This script includes all Bayesian models used for analysis.
# 
# -----------------------------------------------------------------------------

# Source libraries, helpers, load data 

source(here::here("scripts", "r", "02_load_data.R"))

# if you added new data, make sure to open 06_load_data.R and switch
# loop to TRUE so that the data is updated.
source(here::here("scripts", "r", "06_load_data.R"))

# ------------------------------------------------------------------------------

# Set weakly informative priors
priors <- c(
  prior(normal(x,y), class = "Intercept"),
  prior(normal(x,y), class = b),
  prior(cauchy(x,y), class = sd)
)


# ------------------------------------------------------------------------------

m_rq1 <- brm(
  formula = VARIABLE1 + VARIABLE2 + ... +
    (1 | participant_id) + 
    (1 | item), 
  data = master_df,
  prior = priors, 
  warmup = 2000, iter = 4000, chains = 4, 
  family = "", 
  cores = 4, 
  control = list(adapt_delta = 0.99, max_treedepth = 20),
  file = here("models", "m_rq1")
)
