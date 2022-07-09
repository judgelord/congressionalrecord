# Scrape URLs for each subsection of the Congressional Record

# As we do so, we retain some helpful metadata
#
# - The record is divided by date
# - The record is divided into three sections: Senate, House, Extensions of Remarks (text submitted to the record later)
# - The page number ("S3253" is the 3,253rd page of the record, featuring remarks from the Senate)
#
# The Congressional Record has a page for each day: https://www.congress.gov/congressional-record/2017/6/6/senate-section
#
# On this page are URLs for each subsection. These URLs look like this:
#   https://www.congress.gov/congressional-record/2017/6/6/senate-section/article/S3253-6
#
# We can identify linked text (`html_nodes("a")`), and put the URLs (`html_attr("href")`) and their text (`html_text()`) for each date and each section of the record into a data frame.  With `map_dfr` from the `purrr` package, we can then apply this to a range of dates.

# a date range to scrape
dates <- seq(as.Date("2007/03/01"),
             as.Date("2007/03/01"),
             #as.Date("2021/04/01"),
             #Sys.Date(), # today
             by = "day")

# a function to make a data frame of of all cr text urls for a date
get_cr_df <- function(date, section){

  message(date)

  url <- str_c("https://www.congress.gov/congressional-record",
               date %>% str_replace_all("-", "/"),
               section, sep = "/")


  pages <- read_html(url) %>%
    html_nodes("a") # "a" nodes are linked text


  d <- tibble(header = html_text(pages), # the text of the linked text
              date = date,
              section = section,
              url = str_c("https://www.congress.gov",
                          html_attr(pages, "href") # urls are "href" attributes of linked text
              )
  ) %>%
    # trim down to html txt pages
    filter(url %>% str_detect("article"))

  return(d)
}

# an empty dataframe for failed calls
d_init <-  tibble(header = "",
                  date = as.Date(NA),
                  section = "",
                  url = "")

save(d_init, file = here::here("data", "d_init.rda"))

#FIXME EVERYTHING FROM HERE TO 150 SHOULD BE MOVED TO A VIGNETTE

## For testing
# section <- "senate-section"
# date <- "2020-09-15"
# get_cr_df(date, section)

# a dataframe of headers, dates, and url paths
senate <- map_dfr(dates, .f = possibly(get_cr_df, otherwise = d_init), section = "senate-section")
senate %<>% filter(header != "")
dim(senate)

house <- map_dfr(dates, .f = possibly(get_cr_df, otherwise = d_init), section = "house-section")
house %<>% filter(header != "")
dim(house)

ext <- map_dfr(dates, .f = possibly(get_cr_df, otherwise = d_init), section = "extensions-of-remarks-section")
ext %<>% filter(header != "")
dim(ext)

cr_metadata <- full_join(senate, house)

cr_metadata %<>%
  full_join(ext)

dim(cr_metadata)

head(cr_metadata)


# Make file var in metadata to merge in htm text
cr_metadata %<>%
  mutate(file = url %>%
           str_replace(".*record", "CREC") %>%
           str_replace("[a-z].*article/", "pt1-Pg") %>%
           str_replace_all("/", "-") %>%
           str_c(".htm") %>%
           str_replace("-1.htm", ".htm")
  )

# inspect
head(cr_metadata$url)
head(cr_metadata$file)


temp <- cr_metadata

# load previously saved data
# load(here::here("data", "cr_metadata.Rdata"))

# join with any new observations
cr_metadata %<>% full_join(temp)

# save new metadata
save(cr_metadata, file = here::here("data", "cr_metadata.Rdata"))

# Download the text of the congressional record

# The "View TXT in new window" URL takes us to a .htm file of just the congressional record text. Compared to the much larger .html of the main page, the (minimal) downside is that some of the header information is lost (nothing distinguishes main headers from subheaders).

# `html_session() %>% follow_link("View TXT in new window")` takes us to the raw TXT page. With `walk` from the `purrr` package, we can download each raw txt page to a file with the same name.

# TXT pages look like this: https://www.congress.gov/115/crec/2017/06/06/modified/CREC-2017-06-06-pt1-PgS3253-6.htm




# Identify files already downloaded
dir.create(here::here("data"))
dir.create(here::here("data", "htm"))
downloaded <- list.files(here::here("data", "htm"))
length(downloaded)
head(downloaded)

# id those that need to be downloaded
cr_metadata$downloaded <- cr_metadata$file %in% downloaded
head(cr_metadata$downloaded)

cr_to_get <- cr_metadata %>% filter(!downloaded)
dim(cr_to_get)

head(cr_to_get$file)
head(cr_to_get$url)

## test
# get_cr_htm(cr_metadata$url[1])

cr_metadata %<>% arrange(date) %>% arrange(rev(date))

# a function to download htm
get_cr_htm <- function(url){

  ## test
  # url <- "https://www.congress.gov/congressional-record/2020/03/02/senate-section/article/S1255-1"

  # follow the link to the txt htm
  url %<>%
    html_session() %>%
    follow_link("View TXT in new window")

  # name files the end of the url
  file <- str_remove(url$url, ".*modified/")

  # if the file has not already been downloaded
  if(!file %in% downloaded){
    read_html(url) %>%
      write_html(file = here::here("data","htm", file))
  }
}



# download file for each url
# COMMENTING THIS OUT FOR THE PACKAGE
# walk(cr_to_get$url, get_cr_htm)

