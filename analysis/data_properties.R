################################################################################
#
# Description: This script takes a dataset, summarises the variables using:
#              * skimr::skim(),
#              * class(),
#              * and ,
#              and saves the output to a .txt file
#
# The script should only be run via an action in the project.yaml only
# The script must be accompanied by two arguments
# The first is the dataset that is to be summarised
# The second in the directory where the txt output will be saved
#
# Input: /output/input_control.csv
#
# Output: /output/data_properties/input_control*.txt
#
# Author(s): W. Hulme (edited by M. Green)
# Date last updated: 04/07/2023
#
################################################################################


# Preliminaries ----

## Import libraries
library('tidyverse')
library('here')
library('lubridate')

## Custom functions
source(here("analysis", "lib", "custom_functions.R"))

## Import command-line arguments
args <- commandArgs(trailingOnly=TRUE)


# Data properties tables ----

if(length(args)==0){
  # use for interactive testing
  csv_files <- list("output/input_control.csv",
                    "output/input_treatment.csv")
  output_dir <- "output/data_properties"
} else {
  csv_files <- list(args[[1]], args[[2]])
  output_dir <- args[[3]]
}

for (i in 1:length(csv_files)){
  
  ## Specify data
  csv_file <- csv_files[[i]]
  
  stopifnot("must pass an .csv file" = fs::path_ext(csv_file)=="csv")
  
  filenamebase <- fs::path_ext_remove(fs::path_file(csv_file))
  
  ## Import data
  data <- readr::read_csv(here(csv_file))
  
  # Output summary .txt
  options(width=200) # set output width for capture.output
  
  dir.create(here(output_dir), showWarnings = FALSE, recursive=TRUE)
  
  
  ## High-level variable overview ----
  capture.output(
    skimr::skim_without_charts(data),
    file = here(output_dir, paste0(filenamebase, "_skim", ".txt")),
    split=FALSE
  )
  
  ## list of column types ----
  capture.output(
    lapply(data, class),
    file = here(output_dir, paste0(filenamebase, "_coltypes", ".txt"))
  )
  
  
  ## tabulated data ----
  
  # delete file if it exists
  if(file.exists(here(output_dir, paste0(filenamebase, "_tabulate", ".txt")))){
    file.remove(here(output_dir, paste0(filenamebase, "_tabulate", ".txt")))
  }
  
  
  ### categorical and logical ----
  sumtabs_cat <-
    data %>%
    select(-ends_with("_id")) %>%
    select(where(is.character), where(is.logical), where(is.factor)) %>%
    map(redacted_summary_cat) %>%
    enframe()
  
  capture.output(
    walk2(sumtabs_cat$value, sumtabs_cat$name, print_cat),
    file = here(output_dir, paste0(filenamebase, "_tabulate", ".txt")),
    append=FALSE
  )
  
  
  ### numeric ----
  sumtabs_num <-
    data %>%
    select(-ends_with("_id")) %>%
    select(where(~ {!is.logical(.x) & is.numeric(.x) & !is.Date(.x)})) %>%
    map(redacted_summary_num) %>%
    enframe()
  
  capture.output(
    walk2(sumtabs_num$value, sumtabs_num$name, print_num),
    file = here(output_dir, paste0(filenamebase, "_tabulate", ".txt")),
    append=TRUE
  )
  
  ### dates ----
  
  sumtabs_date <-
    data %>%
    select(-ends_with("_id")) %>%
    select(where(is.Date)) %>%
    map(redacted_summary_date) %>%
    enframe()
  
  capture.output(
    walk2(sumtabs_date$value, sumtabs_date$name, print_num),
    file = here(output_dir, paste0(filenamebase, "_tabulate", ".txt")),
    append=TRUE
  )
}
