# Tidy sociodialect survey -----------------------------------------------------
#
# Authors: Robert Esposito & Kendra Dickinson
# Description: Tidies the sociodialect survey.
#
# -----------------------------------------------------------------------------

# load libs
source(here::here("scripts","r","00_libs.R"))

# load raw data
survey_raw <- read_csv(here("data","raw","sociodialect_survey_raw.csv"))

# create question look up
survey_question_lookup <- survey_raw %>%
  # first row has questions
  slice(1) %>%
  select(`Age`:last_col()) %>%
  pivot_longer(
    everything(),
    names_to = "question_code",
    values_to = "question"
  )

survey_tidy <- survey_raw %>%
  # remove first two rows
  slice(-(1:2)) %>%
  # give better names
  select(
    duration = `Duration (in seconds)`,
    date = RecordedDate,
    participant_id = Participant_code,
    `Age`:last_col()
  ) %>%
  # pivot longer
  pivot_longer(
    cols = `Age`:last_col(),
    names_to = "question_code",
    values_to = "participant_response"
  )

# write csv
write_csv(survey_tidy,
          here("data","tidy","survey_tidy.csv"))
