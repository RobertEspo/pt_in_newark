# Load data -------------------------------------------------------------------
#
# Authors: Robert Esposito & Kendra Dickinson
# Description: Loads Lextale, BLP, survey, and acoustic data into
# one DF.
#
# -----------------------------------------------------------------------------

# load libs
source(here::here("scripts","r","00_libs.R"))

# load all data
source(here("scripts","r","02_score_lextale.R"))
source(here("scripts","r","03_score_blp.R"))
source(here("scripts","r","04_tidy_survey.R"))
source(here("scripts","r","05_tidy_acoustic.R"))

# let's clean up the environment a bit
rm(list = setdiff(ls(), 
                  c("blp_scores", "lextpt_scores",
                    "survey_tidy","acoustics")))

gc()

# combine these into one df
master_df <- blp_scores %>% left_join(lextpt_scores, by = "participant_id") %>%
  left_join(acoustics, by = "participant_id")