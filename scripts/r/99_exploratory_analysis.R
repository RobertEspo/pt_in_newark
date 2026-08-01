# Create plots -----------------------------------------------------------------
#
# Authors: Robert Esposito & Kendra Dickinson
# Description: This script is used for some exploratory analysis
# and trying out some plots.
#
# -----------------------------------------------------------------------------

# load libs & data
source(here::here("scripts","r","00_libs.R"))
source(here::here("scripts", "r", "06_load_data.R"))

# First we'll look at one variable at a time.

# BLP scores
# Note that negative scores = English-dominant
blp_scores %>%
  group_by(participant_id) %>%
  ggplot(aes(x = "", y = blp_score, color = blp_score)) +
  coord_cartesian(ylim = c(-218, 218)) +
  scale_y_continuous(breaks = seq(-218, 218, by = 20)) +
  geom_violin(fill = "black", alpha = 0.5) +
  geom_boxplot(width = 0.2, fill = "grey80", outlier.shape = NA) +
  geom_jitter(width = 0.08, size = 2, alpha = 0.9) +
  scale_color_gradient2(
    low = "#648FFF",
    mid = "#FFB000",
    high = "#DC267F",
    midpoint = 0,
    breaks = c(-218, 0, 218),
    limits = c(-218, 218),
    labels = c("English", "Balanced", "Portuguese")
  ) +
  labs(x = NULL, y = "Bilingual Language Profile score", color = "Bilingual Language \nProfile score") +
  ds4ling::ds4ling_bw_theme(base_size = 12)

# LextPT scores
lextpt_scores %>%
  group_by(participant_id) %>%
  ggplot(aes(x = "", y = lextpt_score)) +
  geom_violin(fill = "black", alpha = 0.5) +
  geom_boxplot(width = 0.2, fill = "grey80", outlier.shape = NA) +
  geom_jitter(width = 0.08, size = 2, alpha = 0.9) +
  labs(x = NULL, y = "LextPT score") +
  ds4ling::ds4ling_bw_theme(base_size = 12)

# distribution of age and age of arrival
# (doing these together just cuz...)
plot_age_aoa <- survey_tidy %>%
  filter(question_code %in% c("Age", "AoA")) %>%
  select(participant_id, question_code, participant_response) %>%
  pivot_wider(
    names_from = question_code,
    values_from = participant_response
  ) %>%
  mutate(
    Age = as.numeric(Age),
    AoA = as.numeric(AoA)
  ) %>% ggplot(aes(x = Age, y = AoA)) +
  geom_point() +
  labs(
    x = "Age",
    y = "Age of Arrival to USA (AoA)"
  ) +
  ds4ling::ds4ling_bw_theme(base_size = 12)

plot_density_age_aoa <- ggMarginal(
  plot_age_aoa,
  type = "density",
  margins = "both"
)

# Gender
plot_gender <- survey_tidy %>%
  filter(question_code == "Gender") %>%
  mutate(
    gender = case_when(
      str_detect(participant_response, regex("^m", ignore_case = TRUE)) ~ "male",
      str_detect(participant_response, regex("^f", ignore_case = TRUE)) ~ "female",
      TRUE ~ NA_character_
    )
  ) %>%
  select(participant_id, gender) %>%
  count(gender) %>%
  mutate(percent = n / sum(n) * 100) %>%
  ggplot(aes(x = gender, y = percent)) +
  geom_col() +
  labs(
    x = "Gender",
    y = "Percentage of participants"
  ) +
  ds4ling::ds4ling_bw_theme(base_size = 12)

# Where are our participants from?

survey_tidy %>%
  filter(question_code %in% c("Origin_pais", "Origin_city")) %>%
  select(participant_id, question_code, participant_response) %>%
  pivot_wider(
    names_from = question_code,
    values_from = participant_response
  ) %>%
  count(Origin_pais, Origin_city, sort = TRUE)

# Self-reported socioeconomic class in origin country and in USA

# Education level

# With which groups do the participants have contact?

################################################################################

# Now we'll look at combination of variables.

# BLP/LextPT

blp_lextpt <- blp_scores %>%
  select(participant_id, blp_score) %>%
  left_join(
    lextpt_scores %>% select(participant_id, lextpt_score),
    by = "participant_id"
  )

ggplot(blp_lextpt, aes(x = blp_score, y = lextpt_score)) +
  geom_point(size = 2, alpha = 0.8) +
  geom_smooth(method = "lm", se = TRUE) +
  labs(
    x = "Bilingual Language Profile score",
    y = "LextPT score"
  ) +
  ds4ling::ds4ling_bw_theme(base_size = 12)

# Gender/BLP

# Gender/LextPT

# Gender/Age/AoA

################################################################################
# %%% LexTALE analysis

# Signal Detection
# ########## |    Response "No"   | Response "Yes"
# Target     |        Miss        |    Hit
# Distractor |  Correct Rejection | False Alarm

tidy_lextpt %>%
  count(participant_id, signal_detection) %>%
  ggplot(aes(x = reorder(participant_id, n), y = n, fill = signal_detection)) +
  geom_col() +
  coord_flip() +
  labs(
    x = "Participant",
    y = "Trials",
    fill = "Response"
  )

tidy_lextpt %>%
  count(signal_detection) %>%
  mutate(prop = n / sum(n)) %>%
  ggplot(aes(x = signal_detection, y = prop, fill = signal_detection)) +
  geom_col(show.legend = FALSE) +
  scale_y_continuous(labels = scales::percent) +
  labs(
    x = NULL,
    y = "Percentage of trials"
  )

sdt_summary <- tidy_lextpt %>%
  filter(pt_word != "exhausto") %>%
  group_by(participant_id) %>%
  summarise(
    hit_rate = mean(signal_detection[real == 1] == "hit"),
    false_alarm_rate = mean(signal_detection[real == 0] == "false alarm")
  )
