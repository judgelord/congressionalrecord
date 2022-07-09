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

