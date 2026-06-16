# Helper functions ------------------------------------------------------------
#
# Authors: Robert Esposito & Kendra Dickinson
# Description: This script contains helper functions used throughout the 
# project. See below for details on each one and sources.
#
# -----------------------------------------------------------------------------

# Round and format numbers to exactly N digits
# Author: Joseph Casillas
specify_decimal <- function(x, k) {
  out <- trimws(format(round(x, k), nsmall = k))
  return(out)
}