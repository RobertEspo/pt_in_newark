# Tidy acoustic data -----------------------------------------------------------
#
# Authors: Robert Esposito & Kendra Dickinson
# Description: Loads in and tidies the acoustic data from
# the sentence completion task and the storytelling task.
#
# ------------------------------------------------------------------------------

# load libs
source(here::here("scripts","r","00_libs.R"))

# list all csv files with all acoustic data
csv_files <- list.files(
  here("data", "tidy", "acoustics"),
  pattern = "\\.csv$",
  full.names = TRUE
)

# load in all dfs
acoustics <- map_dfr(csv_files, read_csv) %>%
  separate(
    file_name,
    into = c("task", "participant_id", "item"),
    sep = "_",
    fill = "right"
  )
  
# clean up the environment
rm(csv_files)
gc()
