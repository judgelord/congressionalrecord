
# Load packages and functions
source("vignettes/setup.R")

# Load member data from voteview
library(legislators)

# years in data
years <- tibble(year = list.files(here('data', 'txt')) %>% as.numeric()) %>%
  mutate(congress = year_congress(year))

# join in member data for years
d <- years %<>% full_join(members %>% distinct(icpsr, congress, state_abbrev))

# count speeches per icpsr id
n_speeches <- function(year, i) {
  list.files(here('data', 'txt', year, i) ) %>%
    length()}

## Test
# map2_int(.x = d$year,
#          .y = d$icpsr,
#         .f = n_speeches)

d %<>% mutate(n_speeches = map2_int(year, icpsr, n_speeches))


# potential problems
d %>% filter(n_speeches == 0) %>%
  distinct(congress, bioname) %>%
  add_count(bioname, sort = T) %>%
  group_by(bioname) %>%
  mutate(congress = str_c(congress, sep = ", ", collapse = ", ")) %>%
  distinct(bioname, congress) %>%
  kablebox()

d_count <- d
save(d_count, file = here("data", "d_count.Rdata"))

dim(d)
d %<>% filter(n_speeches > 0)
dim(d)

# file names
file_names <- function(year, i) {
  list.files(here('data', 'txt', year, i) )
}

d %<>% mutate(file_name = map2(year, icpsr, file_names))

# unlist
d %<>% unnest(file_name)
head(d)

test_file <- here('data', 'txt', d$year[1], d$icpsr[1], d$file_name[1])
test_file
read_lines(test_file)

read_lines(test_file) %>%
  #str_c(sep = " ") %>%
  nchar()

# file size
d %<>% mutate(file_size = here('data', 'txt', year, icpsr, file_name) %>%
                file.size()
              )

head(d)

# filter out small files
#d %<>% filter(file_size > 1000)
#dim(d)

# nchar
d %<>%
  group_by(file_name) %>%
  mutate(nchar = here('data', 'txt', year, icpsr, file_name) %>%
                read_lines() %>%
                str_c(sep = " ") %>%
                nchar()
)%>%
  ungroup()

# variation
d$nchar %>% min()
d$nchar %>% max()

# save
d_files <- d
save(d_files, file = here("data", "d_files.Rdata"))
## RESTORE FROM SAVED
# load(here("data", "d_files.Rdata"))
d <- d_files

# Merge in metadata
load(here("data", "cr_metadata.Rdata"))
head(cr_metadata)

legislation_strings <- "ACT|BILL|RESOLUTION|AMENDMENT|EARMARK|APPROPRIATIONS|AUTHORIZATION|BUDGET|SPONSORS|WITHDRAWAL|PROVIDING FOR CONGRESSIONAL DISAPPROVAL OF A RULE SUBMITTED"

business_strings <- "PRAYER|PLEDGE OF ALLEGIANCE|MORNING BUSINESS|MESSAGE|PRIVILEGES OF THE|CONDEMING|APPOINTMENT|NOMINATION|CONFIRMATION|REPORT|PETITION|MEMORIAL|COMMUNICATION| MONTH|SCHEDULE|LEAVE OF ABSENCE|GENERAL LEAVE|ELECTING|RESIGNATION|MOMENT OF SILENCE"

process_strings <- "RECOGNIZED FOR [0-9] MINUTES|ANNOUNCEMENT|RESERVATION OF LEADER TIME|UNANIMOUS CONSENT|ADJOURNMENT|EXECUTIVE SESSION|PETITION| ORDER|^ORDER|MOTION|RECESS|CALENDAR|RECOGNITION|WELCOMING|OATH |SPEAKER PRO TEMPORE|MEASURES DISCHARGED|INTENT TO OBJECT"


# clean up headers into type and subtype
cr_metadata %<>%
  mutate(header = header %>% toupper(),
         legislation = str_extract(header, legislation_strings),
         business = str_extract(header, business_strings),
         process = str_extract(header, process_strings),
         subtype = coalesce(legislation, business, process, header) %>%
           str_remove(";.*") %>%
           str_remove_all(" BY .*| UNTIL.*| \\(EXECUTIVE.*"),
         type = ifelse(!is.na(process), "process", "other"),
         type = ifelse(!is.na(business), "business", type),
         type = ifelse(!is.na(legislation), "legislation", type)
  )

# inspect
cr_metadata$type %>% head()
cr_metadata$subtype %>% head()
count(cr_metadata, subtype, sort = T) %>% head(100) %>% kable(format = "pipe")
count(cr_metadata %>% filter(type == "other"), subtype, sort = T) %>% head(100) %>% kable(format = "pipe")


# Merge
cr_metadata %<>% rename(file_htm = file)

# from file name to cr htm file name
d %<>% mutate(file_htm = file_name %>%
  str_replace("-[0-9]+-[0-9]+.txt", ".htm") )

d %<>% left_join(cr_metadata) %>% mutate(type = replace_na(type, "other"))

d %>% count(type)

d %>% group_by(type) %>% summarise(average_nchar = mean(file_size)) %>% arrange(-average_nchar)

# save
d_meta <- d %>% select(year, congress, icpsr, state_abbrev, n_speeches, file_name, file_size, url, type, subtype)
save(d_meta, file = here("data", "d_meta.Rdata"))
