# Load and score BLP ----------------------------------------------------------
#
# Authors: Robert Esposito & Kendra Dickinson
# Description: Loads and scores BLP data.
#
# -----------------------------------------------------------------------------

raw_blp <- read_csv(here("data","pilot_raw","blp_pt-en_raw.csv"))

# create lookup for questions
blp_question_lookup <- raw_blp %>%
  # first row has questions
  slice(1) %>%
  select(`start_learning_1`:`native_other_2`) %>%
  pivot_longer(
    everything(),
    names_to = "question_code",
    values_to = "question"
  ) %>%
  mutate(
    # assign block names for scoring
    block = case_when(
      row_number() <= 12 ~ "language_history",
      row_number() <= 27 ~ "language_use",
      row_number() <= 35 ~ "language_proficiency",
      TRUE ~ "language_attitude"
    ),
    # add language col
    language = case_when(
      str_detect(question, regex("português", ignore_case = TRUE)) ~ "portuguese",
      str_detect(question, regex("inglês", ignore_case = TRUE)) ~ "english",
      TRUE ~ "other"
    )
  )

# rows 3 and beyond contain participant responses
tidy_blp <- raw_blp %>%
  # remove first two rows
  slice(-(1:2)) %>%
  # give better names
  rename(
    duration = `Duration (in seconds)`,
    date = RecordedDate,
    participant_id = participant_code
  ) %>%
  # pivot longer
  pivot_longer(
    cols = `start_learning_1`:`native_other_2`,
    names_to = "question_code",
    values_to = "participant_response"
  ) %>%
  # if participant_response == NA, we make it 0
  mutate(
    participant_response = if_else(is.na(participant_response), 
                                   as.numeric(0), 
                                   as.numeric(participant_response))
  ) %>%
  # add questions
  left_join(blp_question_lookup, by = "question_code") %>%
  # select only relevant cols
  select(
    participant_id,
    duration,
    date,
    question_code:language
  ) %>%
  # score trials
  mutate(
    points = case_when(
      # first two history questions are reverse scored
      block == "language_history" &
        question_code %in% c("start_learning_1", "start_learning_2") ~
        20 - participant_response,
      
      # everything else is scored as entered
      TRUE ~ participant_response
    )
  )

write_csv(tidy_blp,
          here("data","pilot_tidy","tidy_blp.csv"))

block_scores <- tidy_blp %>%
  group_by(participant_id, language, block) %>%
  summarise(
    block_score = sum(points),
    .groups = "drop"
  )
