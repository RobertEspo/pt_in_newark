# Load and score BLP ----------------------------------------------------------
#
# Authors: Robert Esposito & Kendra Dickinson
# Description: Loads and scores BLP data.
#
# -----------------------------------------------------------------------------

# load libs
source(here::here("scripts","r","00_libs.R"))

# load raw data
raw_blp <- read_csv(here("data","raw","blp_pt-en_raw.csv"))

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
      
      # language use is reported 0-100 but scored 0-10
      block == "language_use" ~
        participant_response / 10,
      
      # everything else is scored as entered
      TRUE ~ participant_response
    )
  )

# score adjustment for each block
adjustment <- tibble(
  block = c(
    "language_history",
    "language_use",
    "language_proficiency",
    "language_attitude"
  ),
  adjustment = c(0.454, 1.09, 2.27, 2.27)
)

# add up scores for each block in each language
# add weighted score based on adjustment
block_scores <- tidy_blp %>%
  group_by(participant_id, language, block) %>%
  summarise(
    block_score = sum(points),
    .groups = "drop"
  ) %>%
  left_join(adjustment, by = "block") %>%
  mutate(weighted_score = block_score * adjustment)

blp_scores_by_language <- block_scores %>%
  group_by(participant_id, language) %>%
  summarise(
    blp_score = sum(weighted_score),
    .groups = "drop"
  )

blp_scores <- blp_scores_by_language %>%
  select(participant_id, language, blp_score) %>%
  pivot_wider(
    names_from = language,
    values_from = blp_score
  ) %>%
  mutate(
    blp_score = portuguese - english
  ) %>%
  select(participant_id, blp_score)

# negative scores = English dominant

write_csv(blp_scores,
          here("data","tidy","blp_scores.csv"))
