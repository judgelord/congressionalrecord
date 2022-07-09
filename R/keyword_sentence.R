# a function to grab sentences with keywords
keyword_sentence <- function(file, word){
  text <- read_lines(here::here(file)) %>%
    str_c(collapse = " ") %>%
    str_squish()

  if( str_detect(text, regex(word, ignore_case = T) ) ){
    text %<>%
      enframe(name = NULL, value = "text") %>%
      unnest_tokens(sentence, text, token = "sentences") %>%
      filter(str_detect(sentence, word)) %>%
      .$sentence %>%
      str_c(collapse = "...")
  } else {
    text <- NA
  }

}
