# Load packages and functions
source("vignettes/setup.R")

# Load member data from voteview
library(legislators)

states <- members %>% distinct(state, state_abbrev)

# years in data
years <- tibble(year = list.files(here('data', 'txt')) %>% as.numeric()) %>%
  mutate(congress = year_congress(year))

# load metadata, including file names
load(here("data", "d_meta.Rdata"))
d <- d_meta

# filter out process speeches
d %<>% filter(!type %in% c('process', 'business'))

# filter out small speeches less than 1000 char
d %<>% filter(file_size > 1000)

keyword_detect <- function(d, word){
d %<>%
  group_by(file_name) %>%
  mutate(keyword = here('data', 'txt', year, icpsr, file_name) %>%
           read_lines(sep = " ") %>%
           str_c(sep = " ") %>%
           str_detect(regex(word, ignore_case = T))
  )%>%
  ungroup()
return(d)
}

d %<>% keyword_detect("district") %>% rename(mentions_district = keyword)


# save
d_district <- d %>% filter(mentions_district)
dim(d_district)
save(d_district, file = here("data", "d_district.Rdata"))

# average per member of the WI
d_district %>% group_by(congress, icpsr, state_abbrev) %>%
  count(name = "district_mentions") %>% filter(state_abbrev == "WI") %>%
  ungroup() %>%
  group_by(icpsr) %>%
  summarise(average_district_mentions = mean(district_mentions)) %>% left_join(members %>% distinct(bioname, icpsr))








# EXTRACT SENTENECES
keyword_sentence <- function(file, word){
  text <- read_lines(file) %>%
    str_c(collapse = " ") %>%
    str_squish()

  if( str_detect(text, regex(word, ignore_case = T) ) ){
    text %<>%
      enframe(name = NULL, value = "text") %>%
      unnest_tokens(sentence, text, token = "sentences") %>%
      filter(str_detect(sentence, regex(word, ignore_case = T) )) %>%
      pull(sentence) %>%
      str_c(collapse = "...") %>%
      str_squish() %>%
      str_to_sentence()
  } else {
    text <- "NA"
  }

  return(text)
}

# select sentences
d_district_sentences_wi <- d_district %>% filter(state_abbrev == "WI") %>%
  mutate(file = here("data", "txt", year, icpsr, file_name),
         district_sentences = map2_chr(.x = file, .y = "district", .f = keyword_sentence))

d_district_sentences_wi$district_sentences %>% head() %>% str_squish()

# save
save(d_district_sentences_wi, file = here("data", "d_district_sentences_wi.Rdata"))
