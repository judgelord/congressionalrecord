
# A script to parse congressional record text
# Data scraped using this script: https://judgelord.github.io/cr/scraper.html

library(tidyverse)
library(here)
library(readr)
library(magrittr)
library(tidytext)
library(crayon)
library(legislators)


### 1. Metadata from file names in htm folder (from scraper)
bulk_directory = here::here("data", "htm")

# load cr text file names
cr_file <- list.files(bulk_directory)

# in case we need to filter out small, corrupted files
# file.size(here::here("data", "htm", cr_file[1:10] ))
# cr %<>% filter(file.info)

# extract date from file name
cr <- tibble(file = cr_file,
             year = str_extract(cr_file, "[0-9]{4}") %>% as.numeric(),
             date = str_extract(cr_file, "[0-9]{4}-[0-9]{2}-[0-9]{2}") %>%
               as.Date() )

# order by date
cr %<>% arrange(date) %>% arrange(rev(date))


# get congress from year
cr %<>% mutate(congress = as.numeric(round((year - 2001.1)/2)) + 107) # the 107th congress began in 2001

# extract chamber from URL
cr %<>% mutate(chamber = str_extract(file, "Pg.") %>%
                 str_remove("Pg") %>%
                 str_replace("E", "Extensions of Remarks") %>%
                 str_replace("H", "House") %>%
                 str_replace("S", "Senate") )

# reconstruct URLs from file names
cr %<>% mutate(url_txt = str_c("https://www.congress.gov/", congress, "/crec/",
                               date %>% str_replace_all("-", "/"),
                               "/modified/",
                               file))





# FUNCTIONS

### 2. Functions to read in text

# a function to get the first bit of text
head_text <- function(file){

  text <- read_lines(str_c(bulk_directory, "/", file)) %>%
    str_c(collapse = " ") %>%
    str_squish() %>%
    str_remove(".*?www.gpo.gov</a>\\] ") %>%
    str_sub(0, 500) %>%
    str_c("...")

  return(text)
}

# a function to get all text
all_text <- function(file){

  text <- read_lines(str_c(bulk_directory, "/", file)) %>%
    str_c(collapse = " ") %>%
    str_squish() %>%
    str_remove(".*?www.gpo.gov</a>\\] ")

  return(text)
}



### 3. Extract speaker names from text

# a function to extract speaker names
extract_names <- function(file){

  speaker_names <- "(Mr.|Mrs.|Ms.|Miss|HON.) (([A-Z]|\\.| )* |-|)(Mc|Mac|Des|De|La|[A-Z])[A-Z][A-Z]+|The PRESIDING OFFICER|The SPEAKER pro tempore\\.|The SPEAKER pro tempore \\(.*?\\)|The SPEAKER\\.|The ACTING PRESIDENT|The VICE PRESIDENT"
  #FIXME the above is not getting hyphenated names, the below fix needs testing
  #  speaker_names <- "(Mr.|Mrs.|Ms.|Miss|HON.) ([A-Z]+(\\. | |-)|)(Mc|Mac|Des|De|La|[A-Z])[A-Z][A-Z]+|The PRESIDING OFFICER|The SPEAKER pro tempore\\.|The SPEAKER pro tempore \\(.*?\\)|The SPEAKER\\.|The ACTING PRESIDENT|The VICE PRESIDENT"

  # for testing
  #file <- d$file[41]

  text <- all_text(file)

     extracted_names <- text %>%
      str_extract_all(speaker_names) %>%
      unlist() %>%
      # drop first letter of first sentence
      str_remove("\\. [A-Z]$|\\.$") %>%
      str_squish() %>%
      str_c(collapse = ";")


  return(extracted_names)
}

## Test
# file <- d$file[1]
# extract_names(d$file[1])





### 4. Parse texts with multiple speakers

# a function to escape specials for regex search
escape_specials <- . %>%
  str_replace_all("\\)", "\\\\)") %>%
  str_replace_all("\\(", "\\\\(")


# a function to parse files with more than one speaker
# for testing
# speaker_list <- d$speaker[22]
# file <- d$file[22]
parse <- function(speaker_list, file){

  speaker_list %<>% escape_specials()

  text <- all_text(file) # all text

  # in case the split pattern is first
  text <- str_c(":::", text)

  # speakers regex
  speaker_pattern <- speaker_list %>%  str_replace_all(";", "|")

  t <- text %>%  str_split(speaker_pattern) %>%
    unlist()

  ## if there are problems parsing, inspect the regex pattern that is failing
  # print(speaker_pattern)

  extracted <- text %>% str_extract_all(speaker_pattern) %>% unlist()

  s <- c("header", extracted) %>% str_c(" :::")


  speech <- map2(.x = s,
           .y = t,
           .f = paste)

  return( speech )
}

## test
# parse(d$speaker[1], d$file[1])

# A function applying the parse function to speakers and files in a dataframe, returing a longer dataframe that includes texts
parse_text <- function(d){

  d$text <- map2(.x = d$speaker,
               .y = d$file,
               .f = parse) # %>% flatten()

  d %<>% unnest(text)

  d %<>% distinct()

  d %<>% mutate(speakers = speaker,
              speaker = text %>% str_extract(".* :::") %>% str_remove(" :::"))

  d %<>% mutate(text_head = text %>%
                str_sub(0,500) %>%
                str_c("...") )

  return(d)
} #END parse





### 5. Match with voteview





### 6.Save text parsed by date & member name

# dates <- cr %>% pull(date)
# cr_date <- date[1]

# a function to make missing directories
make_dir <- function(x){
  if(!dir.exists(x)){dir.create(x)}
}

# A function that reads raw data and writes parsed data
write_cr <- function(cr_date){
  message(cr_date)

  d <- filter(cr, date == as.Date(cr_date) )
dim(d)

  # the first bit of text (faster because proceedural titles area at the beginning, no need to search full text)
  d$text_head <- d$file %>% map_chr(possibly(head_text, otherwise = ""))

  ## fill in proceedural roles
  # d %<>% mutate(process = str_extract(text_head, "^(ANNOUNCEMENT|RECESS|PRAYER|PLEDGE|MESSAGE|EXECUTIVE MESSAGE|EXECUTIVE COMMUNICATION|EXECUTIVE AND OTHER COMMUNICATION|MEASURE|ADJOURNMENT|DESIGNATION|THE JOURNAL|RESIGNATION|ELECTING|CONSTITUTIONAL|ADDITIONAL SPONSORS|SWEARING IN|MOMENT OF SILENCE|SENATE COMMITTEE MEETING|BUDGETARY|EFFECTS|REAPPOINTMENT|APPOINTMENT|RECALL|COMMUNICATION|REMOTE COMMITTEE PROCEEDINGS|REMOTE VOTING||ENROLLED BILL|ADDITIONAL COSPONSORS|DISCHARGED NOMINATION|CONFIRMATION|JOINT RESOLUTION|SENATE ENROLLED BILLS|PUBLICATION|EXPLANATORY STATEMENT|WITHDRAWAL)") )

  d %<>%
    mutate(speaker = file %>% map_chr(possibly(extract_names, otherwise = "404error"))) %>%
    mutate(speaker = ifelse(speaker == "", "404error", speaker))

  d %<>% parse_text()
dim(d)
  # get congress from year
  d %<>% mutate(congress = as.numeric(round((year - 2001.1)/2)) + 107) # the 107th congress began in 2001

  # clean up speaker names and add chamber titles for better matching
  d %<>% mutate(chamber = ifelse(
    chamber == "Extensions of Remarks" &
      str_detect(text_head, "(Mr|Mrs|Ms|Miss)\\. Speaker\\,|in the house of representatives"), "House", "Senate"),
    speaker = speaker %>%
      str_remove("(^|;)(Mr|Mrs|Ms|Miss|HON)(\\.| )") %>%
      str_squish() )

  d %<>% mutate(speaker =
                  ifelse(row_number() > 1 & str_detect(lag(speaker),
                                                       speaker),
                         lag(speaker),
                         speaker))

  d %<>% mutate(agency = "cr")


dim(d)
  d1 <- d %>% extractMemberName(col_name = "speaker", members = members)
dim(d1)
  # fill in empty
  d1 %<>%
    mutate(file = file %>% replace_na("CREC-missing"),
           icpsr = icpsr %>%
             as.character() %>%
             # Replace missing icpsr with speaker names
             coalesce(speaker) %>%
             replace_na("NA"))

  # FIXME next time I parse the whole thing, 2-diget ids by member+page may be better than by date
  # d1 %<>%
    # group_by(file, icpsr) %>%
    # mutate(ID = dplyr::row_number() %>% formatC(width=3, flag="0"))

  # FIXME path should be relative to bulk directory:
  # bulk_directory %>% str_replace(".htm", ".txt")
  # but here caused a problem maybe? I don't remember
  d1 %<>% mutate(path = str_c("data",
                              "txt",
                              year,
                              icpsr,
                              str_c(file %>% str_remove(".htm"),
                                    "-", match_id, "-", icpsr, ".txt"),
                              sep = "/"  ) )# %>% here::here())

 # make dir for text
  make_dir(here::here("data", "txt"))
  # make dir for years
  walk(str_remove(d1$path, "/[0-9A-Z]*/CREC.*"),
       .f = make_dir)

  # make dir for icpsr
  walk(str_remove(d1$path, "/CREC.*"),
       .f = make_dir)

  # dir.exists(head(d1$path))
  # dir.create(d1$path[1])
  ## May want to change directory
  # here(other_dir) %>% str_remove("project_root/")

  # test
  # write_lines(d1$text[1], d1$path[1])

  # save
  walk2(d1$text,
        d1$path,
        .f = write_lines)
} # /END SAVE TEXT FUNCTION

# Testing
# cr_date <- dates[3]
# cr_date <- "2020-09-23"
# cr_write(cr_date)

# save all
# walk(.x = unique(dates), .f = cr_write)

# a function to parse files from htm folder to txt folder
parse_cr <- function(bulk_directory = here::here("data", "htm"), # directory for bulk cr htm files
                     skip_parsed = T,
                     dates = "all"){

  ### 1. Metadata from file names
  # load cr text file names
  cr_file <- list.files(bulk_directory)

  # in case we need to filter out small, corrupted files
  # file.size(here::here("data", "htm", cr_file[1:10] ))
  # cr %<>% filter(file.info)

  # extract date from file name
  cr <- tibble(file = cr_file,
               year = str_extract(cr_file, "[0-9]{4}") %>% as.numeric(),
               date = str_extract(cr_file, "[0-9]{4}-[0-9]{2}-[0-9]{2}") %>%
                 as.Date() )

  # order by date
  cr %<>% arrange(date) %>% arrange(rev(date))


  # FIXME make dates a vector so that a vec of dates can be provided, not a df
  if(as.character(dates) == "all"){
    dates <- cr %>%
      filter(year <2021) %>% #FIXME when voteview members data are updated
      pull(date) %>% unique()
  }

  if(skip_parsed == T){
    cr_parsed <- list.files(bulk_directory %>% str_replace("/htm", "/txt"), recursive = T)
    length(cr_parsed)
    cr_parsed %<>% str_extract("[0-9]{4}-[0-9]{2}-[0-9]{2}") %<>% unique() %>% as.Date()
    length(cr_parsed)
    cr %<>% filter(!date %in% cr_parsed)
    dim(cr)
  }

  # get congress from year
  cr %<>% mutate(congress = as.numeric(round((year - 2001.1)/2)) + 107) # the 107th congress began in 2001

  # extract chamber from URL
  cr %<>% mutate(chamber = str_extract(file, "Pg.") %>%
                   str_remove("Pg") %>%
                   str_replace("E", "Extensions of Remarks") %>%
                   str_replace("H", "House") %>%
                   str_replace("S", "Senate") )

  # reconstruct URLs from file names
  cr %<>% mutate(url_txt = str_c("https://www.congress.gov/", congress, "/crec/",
                                 date %>% str_replace_all("-", "/"),
                                 "/modified/",
                                 file))

  # SAVE FILES
  walk(.x = unique(dates), .f = write_cr)
}

