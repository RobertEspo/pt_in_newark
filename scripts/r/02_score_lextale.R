# Load and score Lextale ------------------------------------------------------
#
# Authors: Robert Esposito & Kendra Dickinson
# Description: Loads Lextale data and scores it.
# Outputs csv files with all scored trials and
# a single csv file with just participant_id and score.
#
# -----------------------------------------------------------------------------

# load lextpt key
lextpt_key <- read_csv(here("stim","lextale","lextpt_key.csv"))

# load raw lextpt data from participants
raw_lextpt <- read_csv(here("data","raw","lextpt_raw.csv"))

# the first row contains the questions
lextpt_question_lookup <- raw_lextpt %>%
  slice(1) %>%
  select(Q1_1:Q1_90) %>%
  pivot_longer(
    everything(),
    names_to = "question_code",
    values_to = "question"
  )

# rows 3 and beyond contain participant responses
tidy_lextpt <- raw_lextpt %>%
  # remove first two rows
  slice(-(1:2)) %>%
  # give better names
  rename(
    duration = `Duration (in seconds)`,
    date = RecordedDate,
    participant_id = Participant_code
  ) %>%
  # pivot longer
  pivot_longer(
    cols = Q1_1:Q1_90,
    names_to = "question_code",
    values_to = "participant_response"
  ) %>%
  # get word associated with each question
  left_join(lextpt_question_lookup, by = "question_code") %>%
  # remove some cols and rename "question" to "pt_word"
  # so that it matches lextpt_key
  transmute(
    participant_id,
    date,
    duration,
    pt_word = word(question,-1),
    participant_response = word(participant_response,-1),
    participant_response = if_else(
      participant_response == "REAL",1,0)
  ) %>%
  # join answer key
  left_join(lextpt_key, by = "pt_word") %>%
  # score the trials
  # HIT = +1
  # FALSE ALARM = -2
  # other cases are not included in the score
  mutate(
    trial_score = case_when(
      real == 1 & participant_response == 1 ~ 1,
      real == 0 & participant_response == 1 ~ -2,
      TRUE ~ 0
    )
  )
  
# calculate lextale scores
lextpt_scores <- tidy_lextpt %>%
  group_by(participant_id) %>%
  summarise(
    lextpt_score = sum(trial_score),
    .groups = "drop"
  )

# write lextale scores
write_csv(lextpt_scores,
          here("data","tidy","lextpt_scores.csv"))