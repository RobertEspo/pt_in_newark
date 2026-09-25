#
# Enter the path to where the files are kept -------------------
#

dirFiles$ = "../../data/audio/sentence_completion_task/textgrid_drafts/"
newDir$ = "../../data/audio/sentence_completion_task/sentence_completion_corpus/"
number = 1

# --------------------------------------------------------------


#
# Prepare the loop ---------------------------------------------
#

# Find the .wav files
Create Strings as file list: "allFiles", dirFiles$ + "/*.wav"

# Select allFiles
select Strings allFiles

# Count number of stings
numberOfFiles = Get number of strings

# Clear info window just in case
clearinfo

# --------------------------------------------------------------


#
# Begin loop ---------------------------------------------------
#

for i from number to numberOfFiles
    select Strings allFiles
    fileName$ = Get string... i
    prefix$ = fileName$ - ".wav"
    
    # Read the WAV file
    Read from file... 'dirFiles$'/'fileName$'
    nameSound$ = selected$("Sound")
    
    # Open the corresponding TextGrid
    Read from file... 'dirFiles$'/'prefix$'.TextGrid
    nameTG$ = selected$("TextGrid")
    
    # Select both objects for editing/analysis
    select TextGrid 'nameTG$'
    select Sound 'nameSound$'
    plus TextGrid 'nameTG$'
    
    Edit
    pause Continue?
    
    # Save the corrected Sound and TextGrid to the new directory
    select Sound 'nameSound$'
    Write to WAV file... 'newDir$'/'nameSound$'.wav
    
    select TextGrid 'nameTG$'
    Write to binary file... 'newDir$'/'nameSound$'.TextGrid
    
    # Delete the old files
    wavFile$ = dirFiles$ + "/" + fileName$
    deleteFile: wavFile$

    tgFile$ = dirFiles$ + "/" + prefix$ + ".TextGrid"
    deleteFile: tgFile$

    
    # Clean up objects in Praat
    select all
    minus Strings allFiles
    Remove
    
    printline 'nameSound$' 'i'
endfor

# --------------------------------------------------------------