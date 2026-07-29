# Rename audio files for sentence completion task -----------------------------
# Authors: Robert Esposito & Kendra Dickinson
#
# Description:
# This script is used to rename the audio files for the sentence completion
# task. Originally, the audio files are named after the trial number.
# This script renames the audio files to be named after the sentence code.
# -----------------------------------------------------------------------------

# load libs
source(here::here("scripts","r","00_libs.R"))

# Load following function & then run the function below

rename_wavs <- function(participant_code) {
  
  # Read trial mapping
  stim <- read_csv(here(
    "data", "audio",
    "sentence_completion_task", "trials",
    paste0(participant_code, ".csv")
  ))
  
  # Audio directory
  audio_dir <- here(
    "data", "audio",
    "sentence_completion_task",
    participant_code
  )
  
  # Rename files
  walk2(
    stim$trial,
    stim$sentence_code,
    ~{
      from <- file.path(
        audio_dir,
        sprintf("%s-%02d.wav", participant_code, .x)
      )
      
      to <- file.path(
        audio_dir,
        paste0(participant_code, "_", .y, ".wav")
      )
      
      if (file.exists(from)) {
        file.rename(from, to)
      } else {
        warning("Missing file: ", from)
      }
    }
  )
}

# Run function here with participant's code
# e.g., rename_wavs(001) or rename_wavs(020)

rename_wavs()

